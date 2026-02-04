import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'command_results_dao.g.dart';

@DriftAccessor(tables: [CommandResults])
class CommandResultsDao extends DatabaseAccessor<AppDatabase>
    with _$CommandResultsDaoMixin {
  CommandResultsDao(super.db);

  Future<int> insertResult(CommandResultsCompanion result) =>
      into(commandResults).insert(result);

  Future<void> updateStatus(int id, String status, String? resultJson) {
    return (update(commandResults)..where((t) => t.id.equals(id))).write(
      CommandResultsCompanion(
        status: Value(status),
        resultJson: Value(resultJson),
      ),
    );
  }

  Stream<List<CommandResultEntity>> watchRecentResults(
    int resourceId, {
    int limit = 5,
  }) {
    return (select(commandResults)
          ..where((t) => t.resourceId.equals(resourceId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<CommandResultEntity?> watchLastCommandByResource(int resourceId) {
    return (select(commandResults)
          ..where((t) => t.resourceId.equals(resourceId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .watchSingleOrNull();
  }
}
