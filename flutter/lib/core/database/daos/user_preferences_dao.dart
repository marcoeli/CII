import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'user_preferences_dao.g.dart';

@DriftAccessor(tables: [UserPreferences])
class UserPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$UserPreferencesDaoMixin {
  UserPreferencesDao(super.db);

  Future<UserPreferenceEntity?> getPreferences() {
    return (select(userPreferences)..limit(1)).getSingleOrNull();
  }

  Future<void> setSelectedTenant(String? tenantId) async {
    final current = await getPreferences();
    if (current == null) {
      await into(userPreferences).insert(
        UserPreferencesCompanion.insert(
          selectedTenantId: Value(tenantId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await (update(
        userPreferences,
      )..where((tbl) => tbl.id.equals(current.id))).write(
        UserPreferencesCompanion(
          selectedTenantId: Value(tenantId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> setSelectedHome(String? homeId) async {
    final current = await getPreferences();
    if (current == null) {
      await into(userPreferences).insert(
        UserPreferencesCompanion.insert(
          selectedHomeId: Value(homeId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await (update(
        userPreferences,
      )..where((tbl) => tbl.id.equals(current.id))).write(
        UserPreferencesCompanion(
          selectedHomeId: Value(homeId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}
