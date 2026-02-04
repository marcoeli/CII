// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resources_dao.dart';

// ignore_for_file: type=lint
mixin _$ResourcesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  $DevicesV24Table get devicesV24 => attachedDatabase.devicesV24;
  $ResourcesV24Table get resourcesV24 => attachedDatabase.resourcesV24;
  $ResourceStatesTable get resourceStates => attachedDatabase.resourceStates;
  $ResourceDataTable get resourceData => attachedDatabase.resourceData;
  $ResourceConfigsTable get resourceConfigs => attachedDatabase.resourceConfigs;
  $ResourceBindingsTable get resourceBindings =>
      attachedDatabase.resourceBindings;
  ResourcesDaoManager get managers => ResourcesDaoManager(this);
}

class ResourcesDaoManager {
  final _$ResourcesDaoMixin _db;
  ResourcesDaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db.attachedDatabase, _db.homes);
  $$DevicesV24TableTableManager get devicesV24 =>
      $$DevicesV24TableTableManager(_db.attachedDatabase, _db.devicesV24);
  $$ResourcesV24TableTableManager get resourcesV24 =>
      $$ResourcesV24TableTableManager(_db.attachedDatabase, _db.resourcesV24);
  $$ResourceStatesTableTableManager get resourceStates =>
      $$ResourceStatesTableTableManager(
        _db.attachedDatabase,
        _db.resourceStates,
      );
  $$ResourceDataTableTableManager get resourceData =>
      $$ResourceDataTableTableManager(_db.attachedDatabase, _db.resourceData);
  $$ResourceConfigsTableTableManager get resourceConfigs =>
      $$ResourceConfigsTableTableManager(
        _db.attachedDatabase,
        _db.resourceConfigs,
      );
  $$ResourceBindingsTableTableManager get resourceBindings =>
      $$ResourceBindingsTableTableManager(
        _db.attachedDatabase,
        _db.resourceBindings,
      );
}
