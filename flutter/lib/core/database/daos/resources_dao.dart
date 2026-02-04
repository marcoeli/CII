import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';
import '../../utils/resource_id_parser.dart';

part 'resources_dao.g.dart';

@DriftAccessor(
  tables: [
    ResourcesV24,
    ResourceStates,
    ResourceData,
    ResourceConfigs,
    ResourceBindings,
  ],
)
class ResourcesDao extends DatabaseAccessor<AppDatabase>
    with _$ResourcesDaoMixin {
  ResourcesDao(super.db);

  // --- Meta Sync ---
  // --- Meta Sync ---

  /// Usado pelo _handleResourceMeta (Topic meta/resource/...)
  /// Força a atualização de label/room pois é uma ação explícita de configuração
  Future<int> upsertResourceMeta(
    int homeId,
    int deviceId,
    String resourceId,
    String label,
    String capability,
    String? metadataJson,
  ) async {
    final info = ResourceIdParser.parse(resourceId);

    final companion = ResourcesV24Companion(
      homeId: Value(homeId),
      deviceId: Value(deviceId),
      resourceId: Value(resourceId),
      domain: Value(info.domain),
      kind: Value(info.kind),
      name: Value(info.name),
      label: Value(label),
      capabilityType: Value(capability),
      metadataJson: Value(metadataJson),
      updatedAt: Value(DateTime.now()),
    );

    return into(resourcesV24).insert(
      companion,
      onConflict: DoUpdate(
        (old) => companion,
        target: [resourcesV24.homeId, resourcesV24.resourceId],
      ),
    );
  }

  /// Usado pelo _handleDeviceStatus (Heartbeat/Topology)
  /// PRESERVA label e room se já existirem no banco (User Edits > Firmware Defaults)
  Future<int> upsertResourceTopology(
    int homeId,
    int deviceId,
    String resourceId,
    String defaultLabel,
    String capability,
    String? metadataJson,
  ) async {
    final info = ResourceIdParser.parse(resourceId);

    // Default companion (usado para insert novo)
    final companion = ResourcesV24Companion(
      homeId: Value(homeId),
      deviceId: Value(deviceId),
      resourceId: Value(resourceId),
      domain: Value(info.domain),
      kind: Value(info.kind),
      name: Value(info.name),
      label: Value(defaultLabel),
      capabilityType: Value(capability),
      metadataJson: Value(metadataJson),
      updatedAt: Value(DateTime.now()),
    );

    return into(resourcesV24).insert(
      companion,
      onConflict: DoUpdate(
        (old) => companion.copyWith(
          // PRESERVE user edits: Use absent to NOT update these columns
          label: const Value.absent(),
          room: const Value.absent(),
        ),
        target: [resourcesV24.homeId, resourcesV24.resourceId],
      ),
    );
  }

  // --- Local Meta Update (App Only) ---
  Future<int> updateResourceMeta(
    String resourceId, {
    String? label,
    String? room,
  }) {
    return (update(
      resourcesV24,
    )..where((r) => r.resourceId.equals(resourceId))).write(
      ResourcesV24Companion(
        label: label != null ? Value(label) : const Value.absent(),
        room: room != null ? Value(room) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --- State/Data/Config Sync ---
  Future<int> upsertState(int resourceInternalId, String stateJson) {
    return into(resourceStates).insert(
      ResourceStatesCompanion(
        resourceId: Value(resourceInternalId),
        stateJson: Value(stateJson),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> upsertData(int resourceInternalId, String dataJson) {
    return into(resourceData).insert(
      ResourceDataCompanion(
        resourceId: Value(resourceInternalId),
        dataJson: Value(dataJson),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<int> upsertConfig(int resourceInternalId, String configJson) {
    return into(resourceConfigs).insert(
      ResourceConfigsCompanion(
        resourceId: Value(resourceInternalId),
        configJson: Value(configJson),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Stream<ResourceStateEntity?> watchState(int resourceInternalId) {
    return (select(resourceStates)
          ..where((s) => s.resourceId.equals(resourceInternalId)))
        .watchSingleOrNull();
  }

  Stream<ResourceDataEntity?> watchData(int resourceInternalId) {
    return (select(resourceData)
          ..where((d) => d.resourceId.equals(resourceInternalId)))
        .watchSingleOrNull();
  }

  Stream<ResourceDataEntity?> watchDataByTechnicalId(
    int homeId,
    String resourceId,
  ) {
    final query = select(resourceData).join([
      innerJoin(
        resourcesV24,
        resourcesV24.id.equalsExp(resourceData.resourceId),
      ),
    ]);
    query.where(
      resourcesV24.homeId.equals(homeId) &
          resourcesV24.resourceId.equals(resourceId),
    );
    return query.map((row) => row.readTable(resourceData)).watchSingleOrNull();
  }

  Stream<ResourceStateEntity?> watchStateByTechnicalId(
    int homeId,
    String resourceId,
  ) {
    final query = select(resourceStates).join([
      innerJoin(
        resourcesV24,
        resourcesV24.id.equalsExp(resourceStates.resourceId),
      ),
    ]);
    query.where(
      resourcesV24.homeId.equals(homeId) &
          resourcesV24.resourceId.equals(resourceId),
    );
    return query
        .map((row) => row.readTable(resourceStates))
        .watchSingleOrNull();
  }

  Future<ResourceDataEntity?> getData(int resourceInternalId) {
    return (select(
      resourceData,
    )..where((d) => d.resourceId.equals(resourceInternalId))).getSingleOrNull();
  }

  Future<ResourceDataEntity?> getDataByTechnicalId(
    int homeId,
    String resourceId,
  ) {
    final query = select(resourceData).join([
      innerJoin(
        resourcesV24,
        resourcesV24.id.equalsExp(resourceData.resourceId),
      ),
    ]);
    query.where(
      resourcesV24.homeId.equals(homeId) &
          resourcesV24.resourceId.equals(resourceId),
    );
    return query.map((row) => row.readTable(resourceData)).getSingleOrNull();
  }

  // --- Helpers ---
  Future<ResourceEntity?> getResourceByTechnicalId(
    int homeId,
    String resourceId,
  ) {
    return (select(resourcesV24)..where(
          (r) => r.homeId.equals(homeId) & r.resourceId.equals(resourceId),
        ))
        .getSingleOrNull();
  }

  Stream<List<ResourceEntity>> watchResourcesByHome(int homeId) {
    return (select(
      resourcesV24,
    )..where((r) => r.homeId.equals(homeId))).watch();
  }

  Stream<List<ResourceEntity>> watchResourcesByHomeAndDomain(
    int homeId,
    String domain,
  ) {
    return (select(
      resourcesV24,
    )..where((r) => r.homeId.equals(homeId) & r.domain.equals(domain))).watch();
  }

  /// Método para providers listarem recursos por domínio (Filtrado por Home)
  Stream<List<ResourceEntity>> watchResourcesByDomain(
    int homeId,
    String domain,
  ) {
    return (select(
      resourcesV24,
    )..where((r) => r.homeId.equals(homeId) & r.domain.equals(domain))).watch();
  }

  Stream<List<ResourceEntity>> watchResourcesByMultipleDomains(
    int homeId,
    List<String> domains,
  ) {
    return (select(
      resourcesV24,
    )..where((r) => r.homeId.equals(homeId) & r.domain.isIn(domains))).watch();
  }

  Stream<List<ResourceEntity>> watchResourcesByMultipleKinds(
    int homeId,
    List<String> kinds,
  ) {
    return (select(
      resourcesV24,
    )..where((r) => r.homeId.equals(homeId) & r.kind.isIn(kinds))).watch();
  }

  /// RCO-2401: Método para ViewModels observarem recursos completos
  Stream<ResourceEntity?> watchResourceByTechnicalId(
    String resourceId, {
    int? homeId,
  }) {
    final query = select(resourcesV24);
    if (homeId != null) {
      query.where(
        (r) => r.homeId.equals(homeId) & r.resourceId.equals(resourceId),
      );
    } else {
      query.where((r) => r.resourceId.equals(resourceId));
    }
    return query.watchSingleOrNull();
  }

  /// Returns list of resources joined with their latest data
  /// Used for System Status (checking active alerts in dataJson)
  Stream<List<TypedResult>> watchResourcesWithData(int homeId) {
    final query = select(resourcesV24).join([
      leftOuterJoin(
        resourceData,
        resourceData.resourceId.equalsExp(resourcesV24.id),
      ),
    ]);
    query.where(resourcesV24.homeId.equals(homeId));
    return query.watch();
  }
}
