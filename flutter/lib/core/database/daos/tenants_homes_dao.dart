import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'tenants_homes_dao.g.dart';

@DriftAccessor(tables: [Tenants, Homes])
class TenantsHomesDao extends DatabaseAccessor<AppDatabase>
    with _$TenantsHomesDaoMixin {
  TenantsHomesDao(super.db);

  // --- Tenants ---
  Future<int> upsertTenant(TenantsCompanion tenant) {
    return into(tenants).insert(
      tenant,
      onConflict: DoUpdate((old) => tenant, target: [tenants.tenantId]),
    );
  }

  Stream<List<TenantEntity>> watchAllTenants() => select(tenants).watch();

  Future<TenantEntity?> getTenantById(String tenantId) {
    return (select(
      tenants,
    )..where((t) => t.tenantId.equals(tenantId))).getSingleOrNull();
  }

  // --- Homes ---
  Future<int> upsertHome(HomesCompanion home) {
    return into(homes).insert(
      home,
      onConflict: DoUpdate(
        (old) => home,
        target: [homes.tenantId, homes.homeId],
      ),
    );
  }

  Stream<List<HomeEntity>> watchHomesByTenant(int tenantInternalId) {
    return (select(
      homes,
    )..where((h) => h.tenantId.equals(tenantInternalId))).watch();
  }

  Future<HomeEntity?> getHomeByTechnicalId(int tenantId, String homeId) {
    return (select(homes)
          ..where((h) => h.tenantId.equals(tenantId) & h.homeId.equals(homeId)))
        .getSingleOrNull();
  }

  /// Resolve Home by string identifiers (from MQTT topics)
  Future<HomeEntity?> getHomeByTenantAndHomeId(
    String tenantUid,
    String homeUid,
  ) async {
    final tenant = await getTenantById(tenantUid);
    if (tenant == null) return null;
    return getHomeByTechnicalId(tenant.id, homeUid);
  }

  Future<void> deleteHome(int id) =>
      (delete(homes)..where((h) => h.id.equals(id))).go();
}
