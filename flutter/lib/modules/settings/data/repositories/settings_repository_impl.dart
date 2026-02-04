import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/settings/domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  @override
  Future<TenantEntity?> getTenantById(String tenantId) {
    return _db.tenantsHomesDao.getTenantById(tenantId);
  }

  @override
  Future<HomeEntity?> getHomeByTechnicalId(int tenantId, String homeId) {
    return _db.tenantsHomesDao.getHomeByTechnicalId(tenantId, homeId);
  }

  @override
  Future<UserPreferenceEntity?> getPreferences() {
    return _db.userPreferencesDao.getPreferences();
  }

  @override
  Future<void> setSelectedTenant(String? tenantId) {
    return _db.userPreferencesDao.setSelectedTenant(tenantId);
  }

  @override
  Future<void> setSelectedHome(String? homeId) {
    return _db.userPreferencesDao.setSelectedHome(homeId);
  }
}
