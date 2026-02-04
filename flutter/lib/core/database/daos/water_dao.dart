import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';
import '../../../modules/water/data/models/water_aggregates.dart';

part 'water_dao.g.dart';

@DriftAccessor(
  tables: [
    ResourcesV24,
    ResourceStates,
    ResourceData,
    ResourceBindings,
    WaterLevelHistory, // ✅ Added for Trends
  ],
)
class WaterDao extends DatabaseAccessor<AppDatabase> with _$WaterDaoMixin {
  WaterDao(super.db);

  /// Monitorar todos os sensores de água (level, flow) de uma residência
  Stream<List<WaterSensorAggregate>> watchWaterSensors(int homeId) {
    final query =
        select(resourcesV24).join([
          leftOuterJoin(
            resourceData,
            resourceData.resourceId.equalsExp(resourcesV24.id),
          ),
        ])..where(
          resourcesV24.homeId.equals(homeId) &
              resourcesV24.domain.equals('water') &
              resourcesV24.kind.isIn(['level', 'flow']),
        );

    return query.watch().map((rows) {
      return rows.map((row) {
        return WaterSensorAggregate(
          resource: row.readTable(resourcesV24),
          data: row.readTableOrNull(resourceData),
        );
      }).toList();
    });
  }

  /// Monitorar atuadores de água (pump, valve) com seus estados e bindings
  Stream<List<WaterActuatorAggregate>> watchWaterActuators(int homeId) {
    final resourcesQuery =
        select(resourcesV24).join([
          leftOuterJoin(
            resourceStates,
            resourceStates.resourceId.equalsExp(resourcesV24.id),
          ),
        ])..where(
          resourcesV24.homeId.equals(homeId) &
              resourcesV24.domain.equals('water') &
              resourcesV24.kind.isIn(['pump', 'valve']),
        );

    return resourcesQuery.watch().asyncMap((rows) async {
      final list = <WaterActuatorAggregate>[];
      for (final row in rows) {
        final resource = row.readTable(resourcesV24);
        final state = row.readTableOrNull(resourceStates);

        // Buscar bindings para este atuador
        final bindingsList = await (select(
          resourceBindings,
        )..where((b) => b.resourceId.equals(resource.id))).get();

        list.add(
          WaterActuatorAggregate(
            resource: resource,
            state: state,
            bindings: bindingsList,
          ),
        );
      }
      return list;
    });
  }

  /// Monitorar o último nível de água de uma residência (para dashboard)
  Stream<ResourceDataEntity?> watchLatestWaterLevel(int homeId) {
    final query =
        select(resourcesV24).join([
            innerJoin(
              resourceData,
              resourceData.resourceId.equalsExp(resourcesV24.id),
            ),
          ])
          ..where(
            resourcesV24.homeId.equals(homeId) &
                resourcesV24.domain.equals('water') &
                resourcesV24.kind.equals('level'),
          )
          ..limit(1);

    return query.watchSingleOrNull().map((row) => row?.readTable(resourceData));
  }

  /// Histórico de nível de água (últimas N amostras)
  /// - limit: padrao 20 pontos para sparkline
  Stream<List<WaterLevelHistoryEntity>> watchWaterLevelHistory(
    String semanticResourceId, {
    int limit = 20,
  }) {
    // JOIN necessário pois WaterLevelHistory usa INT FK, mas a UI passa STRING ResourceId
    final query =
        select(waterLevelHistory).join([
            innerJoin(
              resourcesV24,
              resourcesV24.id.equalsExp(waterLevelHistory.resourceId),
            ),
          ])
          ..where(resourcesV24.resourceId.equals(semanticResourceId))
          ..orderBy([
            OrderingTerm(
              expression: waterLevelHistory.timestamp,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(waterLevelHistory)).toList();
    });
  }
}
