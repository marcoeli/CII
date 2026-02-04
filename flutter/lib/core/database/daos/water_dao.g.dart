// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_dao.dart';

// ignore_for_file: type=lint
mixin _$WaterDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  $DevicesV24Table get devicesV24 => attachedDatabase.devicesV24;
  $ResourcesV24Table get resourcesV24 => attachedDatabase.resourcesV24;
  $ResourceStatesTable get resourceStates => attachedDatabase.resourceStates;
  $ResourceDataTable get resourceData => attachedDatabase.resourceData;
  $ResourceBindingsTable get resourceBindings =>
      attachedDatabase.resourceBindings;
  $WaterLevelHistoryTable get waterLevelHistory =>
      attachedDatabase.waterLevelHistory;
  WaterDaoManager get managers => WaterDaoManager(this);
}

class WaterDaoManager {
  final _$WaterDaoMixin _db;
  WaterDaoManager(this._db);
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
  $$ResourceBindingsTableTableManager get resourceBindings =>
      $$ResourceBindingsTableTableManager(
        _db.attachedDatabase,
        _db.resourceBindings,
      );
  $$WaterLevelHistoryTableTableManager get waterLevelHistory =>
      $$WaterLevelHistoryTableTableManager(
        _db.attachedDatabase,
        _db.waterLevelHistory,
      );
}
