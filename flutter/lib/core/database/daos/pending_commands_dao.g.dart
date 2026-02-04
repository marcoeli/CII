// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_commands_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingCommandsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingCommandsTable get pendingCommands => attachedDatabase.pendingCommands;
  PendingCommandsDaoManager get managers => PendingCommandsDaoManager(this);
}

class PendingCommandsDaoManager {
  final _$PendingCommandsDaoMixin _db;
  PendingCommandsDaoManager(this._db);
  $$PendingCommandsTableTableManager get pendingCommands =>
      $$PendingCommandsTableTableManager(
        _db.attachedDatabase,
        _db.pendingCommands,
      );
}
