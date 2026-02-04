// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_dao.dart';

// ignore_for_file: type=lint
mixin _$DevicesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  $DevicesV24Table get devicesV24 => attachedDatabase.devicesV24;
  DevicesDaoManager get managers => DevicesDaoManager(this);
}

class DevicesDaoManager {
  final _$DevicesDaoMixin _db;
  DevicesDaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db.attachedDatabase, _db.homes);
  $$DevicesV24TableTableManager get devicesV24 =>
      $$DevicesV24TableTableManager(_db.attachedDatabase, _db.devicesV24);
}
