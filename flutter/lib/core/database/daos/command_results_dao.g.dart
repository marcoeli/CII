// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_results_dao.dart';

// ignore_for_file: type=lint
mixin _$CommandResultsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  $DevicesV24Table get devicesV24 => attachedDatabase.devicesV24;
  $ResourcesV24Table get resourcesV24 => attachedDatabase.resourcesV24;
  $CommandResultsTable get commandResults => attachedDatabase.commandResults;
  CommandResultsDaoManager get managers => CommandResultsDaoManager(this);
}

class CommandResultsDaoManager {
  final _$CommandResultsDaoMixin _db;
  CommandResultsDaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db.attachedDatabase, _db.homes);
  $$DevicesV24TableTableManager get devicesV24 =>
      $$DevicesV24TableTableManager(_db.attachedDatabase, _db.devicesV24);
  $$ResourcesV24TableTableManager get resourcesV24 =>
      $$ResourcesV24TableTableManager(_db.attachedDatabase, _db.resourcesV24);
  $$CommandResultsTableTableManager get commandResults =>
      $$CommandResultsTableTableManager(
        _db.attachedDatabase,
        _db.commandResults,
      );
}
