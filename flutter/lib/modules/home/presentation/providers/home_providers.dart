import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'dart:convert';
// --- REFACTORED SYSTEM STATUS ---

// 1. Total Devices Stream
final totalDevicesCountProvider = StreamProvider.autoDispose<int>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);
  return db.devicesDao.watchDevicesByHome(home.id).map((list) => list.length);
});

// 2. System Status State Definition (Moved here to avoid import)
class SystemStatusState {
  final int devicesOnline;
  final int devicesTotal;
  final int criticalAlerts;
  final int warningAlerts;
  final DateTime? lastUpdate;
  final bool isLoading;

  const SystemStatusState({
    this.devicesOnline = 0,
    this.devicesTotal = 0,
    this.criticalAlerts = 0,
    this.warningAlerts = 0,
    this.lastUpdate,
    this.isLoading = true,
  });

  SystemStatusState copyWith({
    int? devicesOnline,
    int? devicesTotal,
    int? criticalAlerts,
    int? warningAlerts,
    DateTime? lastUpdate,
    bool? isLoading,
  }) {
    return SystemStatusState(
      devicesOnline: devicesOnline ?? this.devicesOnline,
      devicesTotal: devicesTotal ?? this.devicesTotal,
      criticalAlerts: criticalAlerts ?? this.criticalAlerts,
      warningAlerts: warningAlerts ?? this.warningAlerts,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get devicesOffline => devicesTotal - devicesOnline;
  bool get hasAlerts => (criticalAlerts + warningAlerts) > 0;
  bool get allDevicesOnline =>
      devicesTotal > 0 && devicesOnline == devicesTotal;
}

// 3. Functional Provider (Composed)
final systemStatusNotifierProvider = Provider.autoDispose<SystemStatusState>((
  ref,
) {
  final healthAsync = ref.watch(homeHealthProvider);
  final totalAsync = ref.watch(totalDevicesCountProvider);

  if (healthAsync.isLoading || totalAsync.isLoading) {
    return const SystemStatusState(isLoading: true);
  }

  final total = totalAsync.asData?.value ?? 0;
  final health = healthAsync.asData?.value;

  final offline = health?.offlineDevices ?? 0;
  final critical = health?.criticalEvents ?? 0;
  final warning = health?.warningEvents ?? 0;

  // Calculate online (ensure non-negative)
  final online = (total - offline).clamp(0, total);

  return SystemStatusState(
    devicesTotal: total,
    devicesOnline: online,
    criticalAlerts: critical,
    warningAlerts: warning,
    lastUpdate: DateTime.now(),
    isLoading: false,
  );
});

// SharedPreferences Provider (Singleton)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in the entry point');
});

// View mode for the Home dashboard
enum HomeViewMode { category, device, physical }

class HomeViewModeNotifier extends Notifier<HomeViewMode> {
  static const _key = 'home_view_mode';

  @override
  HomeViewMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedValue = prefs.getString(_key);
    if (savedValue == HomeViewMode.device.name) return HomeViewMode.device;
    if (savedValue == HomeViewMode.physical.name) return HomeViewMode.physical;
    return HomeViewMode.category;
  }

  void setMode(HomeViewMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final homeViewModeProvider =
    NotifierProvider<HomeViewModeNotifier, HomeViewMode>(
      HomeViewModeNotifier.new,
    );

/// Status de Saúde da Residência V2.4
class HomeHealthStatus {
  final int offlineDevices;
  final int criticalEvents;
  final int warningEvents;

  HomeHealthStatus({
    required this.offlineDevices,
    required this.criticalEvents,
    required this.warningEvents,
  });
}

// Stream of offline devices count
final offlineCountProvider = StreamProvider.autoDispose<int>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);
  return db.devicesDao
      .watchDevicesByHome(home.id)
      .map((list) => list.where((d) => d.status != 'ONLINE').length);
});

// Stream of critical events count
// Stream of critical events count (ACTIVE ALERTS using Resource State)
final criticalEventsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);

  return db.resourcesDao.watchResourcesWithData(home.id).map((rows) {
    int count = 0;
    for (final row in rows) {
      final dataEntity = row.readTableOrNull(db.resourceData);
      if (dataEntity != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(dataEntity.dataJson);
          final rawAlert = map['alert']?.toString().toUpperCase();
          if (rawAlert == 'CRITICAL') {
            count++;
          }
        } catch (_) {}
      }
    }
    return count;
  });
});

final warningEventsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(0);
  final db = ref.watch(databaseProvider);

  return db.resourcesDao.watchResourcesWithData(home.id).map((rows) {
    int count = 0;
    for (final row in rows) {
      final dataEntity = row.readTableOrNull(db.resourceData);
      if (dataEntity != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(dataEntity.dataJson);
          final rawAlert = map['alert']?.toString().toUpperCase();
          if (rawAlert == 'WARN' || rawAlert == 'WARNING') {
            count++;
          }
        } catch (_) {}
      }
    }
    return count;
  });
});

// Combined Health Status Provider
final homeHealthProvider = Provider.autoDispose<AsyncValue<HomeHealthStatus>>((
  ref,
) {
  final offlineAsync = ref.watch(offlineCountProvider);
  final criticalAsync = ref.watch(criticalEventsCountProvider);
  final warningAsync = ref.watch(warningEventsCountProvider);

  if (offlineAsync.isLoading ||
      criticalAsync.isLoading ||
      warningAsync.isLoading) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    HomeHealthStatus(
      offlineDevices: offlineAsync.value ?? 0,
      criticalEvents: criticalAsync.value ?? 0,
      warningEvents: warningAsync.value ?? 0,
    ),
  );
});

// 4. Active Alerting Resources Provider (V2.4 UI Fix)
// Returns list of resources that currently have an active alert state.
final activeAlertingResourcesProvider =
    StreamProvider.autoDispose<List<TypedResult>>((ref) {
      final home = ref.watch(selectedHomeProvider);
      if (home == null) return Stream.value([]);
      final db = ref.watch(databaseProvider);

      return db.resourcesDao.watchResourcesWithData(home.id).map((rows) {
        final filtered = <TypedResult>[];
        for (final row in rows) {
          final dataEntity = row.readTableOrNull(db.resourceData);
          if (dataEntity != null) {
            try {
              final dataStr = dataEntity.dataJson;
              if (dataStr.contains('"alert"')) {
                final Map<String, dynamic> map = jsonDecode(dataStr);
                final rawAlert = map['alert']?.toString().toUpperCase();
                if (rawAlert == 'WARN' ||
                    rawAlert == 'CRITICAL' ||
                    rawAlert == 'WARNING') {
                  filtered.add(row);
                }
              }
            } catch (_) {}
          }
        }
        return filtered;
      });
    });
