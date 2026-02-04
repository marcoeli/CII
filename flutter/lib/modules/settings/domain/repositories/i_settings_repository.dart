import 'package:cii/core/database/app_database.dart';

abstract class ISettingsRepository {
  /// Obtém tenant por ID
  Future<TenantEntity?> getTenantById(String tenantId);

  /// Obtém home por ID técnico (tenantId + homeId)
  Future<HomeEntity?> getHomeByTechnicalId(int tenantId, String homeId);

  /// Obtém preferências salvas
  Future<UserPreferenceEntity?> getPreferences();

  /// Salva ID do Tenant selecionado
  Future<void> setSelectedTenant(String? tenantId);

  /// Salva ID da Home selecionada
  Future<void> setSelectedHome(String? homeId);
}
