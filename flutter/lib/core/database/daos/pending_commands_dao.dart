import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'pending_commands_dao.g.dart';

@DriftAccessor(tables: [PendingCommands])
class PendingCommandsDao extends DatabaseAccessor<AppDatabase>
    with _$PendingCommandsDaoMixin {
  PendingCommandsDao(super.db);

  Future<void> insertCommand(PendingCommandEntity command) {
    return into(
      pendingCommands,
    ).insert(command, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateStatus(
    String correlationId,
    String status, {
    DateTime? completedAt,
  }) {
    return (update(
      pendingCommands,
    )..where((t) => t.correlationId.equals(correlationId))).write(
      PendingCommandsCompanion(
        status: Value(status),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<PendingCommandEntity?> getCommand(String correlationId) {
    return (select(
      pendingCommands,
    )..where((t) => t.correlationId.equals(correlationId))).getSingleOrNull();
  }

  Future<List<PendingCommandEntity>> getPendingCommands() {
    return (select(pendingCommands)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Stream<PendingCommandEntity?> watchCommand(String correlationId) {
    return (select(
      pendingCommands,
    )..where((t) => t.correlationId.equals(correlationId))).watchSingleOrNull();
  }
}
