import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/settings/domain/repositories/i_settings_repository.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/modules/settings/presentation/providers/settings_providers.dart';
import 'package:cii/core/providers/global_providers.dart';

class ContextState {
  final TenantEntity? tenant;
  final HomeEntity? home;
  final bool isLoading;

  const ContextState({this.tenant, this.home, this.isLoading = false});

  bool get hasContext => tenant != null && home != null;

  ContextState copyWith({
    TenantEntity? tenant,
    HomeEntity? home,
    bool? isLoading,
  }) {
    return ContextState(
      tenant: tenant ?? this.tenant,
      home: home ?? this.home,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContextViewModel extends Notifier<ContextState> {
  late final ISettingsRepository _repository;
  late final MqttRepository _mqttRepository;

  @override
  ContextState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _mqttRepository = ref.watch(mqttRepositoryProvider);

    // Iniciar carregamento de forma segura
    Future.microtask(() => _loadSavedContext());

    return const ContextState();
  }

  Future<void> _loadSavedContext() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await _repository.getPreferences();
      if (prefs?.selectedTenantId != null) {
        final tenant = await _repository.getTenantById(
          prefs!.selectedTenantId!,
        );

        if (tenant != null && prefs.selectedHomeId != null) {
          final home = await _repository.getHomeByTechnicalId(
            tenant.id,
            prefs.selectedHomeId!,
          );
          if (home != null) {
            state = state.copyWith(tenant: tenant, home: home);
            await _mqttRepository.refreshDevices(tenant: tenant, home: home);
          } else {
            // Parcial context (tenant only)
            state = state.copyWith(tenant: tenant);
          }
        } else if (tenant != null) {
          state = state.copyWith(tenant: tenant);
        }
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setContext({TenantEntity? tenant, HomeEntity? home}) async {
    state = state.copyWith(isLoading: true);
    try {
      state = state.copyWith(tenant: tenant, home: home);

      await _repository.setSelectedTenant(tenant?.tenantId);
      await _repository.setSelectedHome(home?.homeId);

      if (tenant != null && home != null) {
        await _mqttRepository.refreshDevices(tenant: tenant, home: home);
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearContext() async {
    await setContext(tenant: null, home: null);
  }
}
