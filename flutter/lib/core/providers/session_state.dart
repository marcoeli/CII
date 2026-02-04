import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:cii/core/database/app_database.dart';

import 'package:cii/core/database/daos/user_preferences_dao.dart';
import 'package:cii/core/database/daos/tenants_homes_dao.dart';
import 'package:cii/core/providers/global_providers.dart';

// --- STATE ---
class SessionState {
  final TenantEntity? tenant;
  final HomeEntity? home;
  final bool isLoading;

  const SessionState({this.tenant, this.home, this.isLoading = false});

  bool get hasContext => tenant != null && home != null;

  SessionState copyWith({
    TenantEntity? Function()? tenant, // Use thunk for nullable update
    HomeEntity? Function()? home,
    bool? isLoading,
  }) {
    return SessionState(
      tenant: tenant != null ? tenant() : this.tenant,
      home: home != null ? home() : this.home,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- VIEW MODEL ---
class SessionViewModel extends Notifier<SessionState> {
  late final UserPreferencesDao _prefsDao;
  late final TenantsHomesDao _tenantsHomesDao;

  // Guard against double init (hot reload / rebuild)
  bool _didInit = false;

  // Operation ID for concurrency control (stale writes)
  int _opId = 0;

  final _log = Logger('SessionViewModel');

  @override
  SessionState build() {
    final db = ref.watch(databaseProvider);
    _prefsDao = ref.watch(userPreferencesDaoProvider);
    _tenantsHomesDao = db.tenantsHomesDao;

    Logger('SessionViewModel').info('Build with DB HashCode: ${db.hashCode}');

    if (!_didInit) {
      _didInit = true;
      Future.microtask(() => _loadSavedContext());
    }

    return const SessionState();
  }

  Future<void> _loadSavedContext() async {
    final currentOp = ++_opId;
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await _prefsDao.getPreferences();
      if (currentOp != _opId) return; // Stale operation check

      _log.info(
        'Loading Context... Prefs: Tenant=${prefs?.selectedTenantId}, Home=${prefs?.selectedHomeId}',
      );

      if (prefs?.selectedTenantId == null) {
        _log.warning('No tenant selected in preferences');
        return;
      }

      final tenant = await _tenantsHomesDao.getTenantById(
        prefs!.selectedTenantId!,
      );
      if (currentOp != _opId) return; // Stale operation check

      if (tenant != null) {
        HomeEntity? home;
        if (prefs.selectedHomeId != null) {
          // User pointed out "getTenantById" (if taking String) fetches by Technical ID.
          // We assume selectedTenantId is Technical ID string.
          home = await _tenantsHomesDao.getHomeByTechnicalId(
            tenant.id, // Internal PK
            prefs.selectedHomeId!, // Technical ID
          );
        }
        if (currentOp != _opId) return; // Stale operation check

        _log.info(
          'Loaded Entities: Tenant=${tenant.id}/${tenant.tenantId}, Home=${home?.id}/${home?.homeId}',
        );

        // Use thunks to update state
        state = state.copyWith(tenant: () => tenant, home: () => home);

        // Sync Management
        if (home != null) {
          _refreshMqtt(tenant, home);
        }

        // Force initial refresh of devices if we have a home
        if (home != null) {
          ref
              .read(mqttRepositoryProvider)
              .refreshDevices(tenant: tenant, home: home);
        }
      } else {
        _log.warning(
          'Tenant entity not found for ID: ${prefs.selectedTenantId}',
        );
      }
    } finally {
      if (currentOp == _opId) {
        // Only set isLoading to false if this is the latest operation
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> setContext({TenantEntity? tenant, HomeEntity? home}) async {
    final currentOp = ++_opId;
    state = state.copyWith(isLoading: true);

    try {
      // IF tenant passed -> Use it (switch tenant). ELSE -> Keep current.
      final nextTenant = tenant ?? state.tenant;

      // IF home passed -> Use it. IF null -> Clear home.
      // (This implies setContext always defines the target Home, resetting if omitted)
      final nextHome = home;

      state = state.copyWith(tenant: () => nextTenant, home: () => nextHome);

      // Persist
      await _prefsDao.setSelectedTenant(nextTenant?.tenantId);
      await _prefsDao.setSelectedHome(nextHome?.homeId);

      if (currentOp != _opId) return;

      // Refresh MQTT
      // We perform refresh if we have a valid tenant (and potentially home)
      if (nextTenant != null) {
        // Even if home is null, we might want to ensure connection or partial subs?
        // Existing logic wrapped in (home != null). I will keep that safety for now.
        if (nextHome != null) {
          _refreshMqtt(nextTenant, nextHome);
        }
      }
      // If partial context or clearing, should we stop sync?
      // Usually handled by clearContext, but safety check:
      // If we just switch Tenant (home null), we should probably stop sync.
      // But logic below calls refreshMqtt only if both present.
    } finally {
      if (currentOp == _opId) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> clearContext() async {
    // 1. Stop components
    try {
      ref.read(mqttSyncServiceProvider).stopSync();
      ref.read(mqttRepositoryProvider).clearSubscriptions();
    } catch (_) {}

    // 2. Clear state
    state = state.copyWith(tenant: () => null, home: () => null);

    // 3. Clear Persistence
    await _prefsDao.setSelectedTenant(null);
    await _prefsDao.setSelectedHome(null);

    // No need to set isLoading=true for this synchronous-feel action,
    // but better for consistency if async write happens.
  }

  void _refreshMqtt(TenantEntity tenant, HomeEntity home) {
    // 1. Start Sync Service (Persistence & Listeners) FIRST
    // Prevents missing "retained" messages that arrive immediately after subscribe
    ref
        .read(mqttSyncServiceProvider)
        .startSync(home.id, tenant.tenantId, home.homeId);

    // 2. Refresh Subscriptions (Repository) SECOND
    ref.read(mqttRepositoryProvider).refreshDevices(tenant: tenant, home: home);
  }
}

// --- PROVIDERS ---

// 1. Session Provider (The Notifier)
final sessionProvider = NotifierProvider<SessionViewModel, SessionState>(
  SessionViewModel.new,
);

// 2. Helper Provider: Selected Tenant
final selectedTenantProvider = Provider<TenantEntity?>((ref) {
  return ref.watch(sessionProvider).tenant;
});

// 3. Helper Provider: Selected Home
final selectedHomeProvider = Provider<HomeEntity?>((ref) {
  return ref.watch(sessionProvider).home;
});
