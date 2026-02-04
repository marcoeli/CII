// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_v24_dao.dart';

// ignore_for_file: type=lint
mixin _$EventsV24DaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  $DevicesV24Table get devicesV24 => attachedDatabase.devicesV24;
  $ResourcesV24Table get resourcesV24 => attachedDatabase.resourcesV24;
  $EventsV24Table get eventsV24 => attachedDatabase.eventsV24;
  EventsV24DaoManager get managers => EventsV24DaoManager(this);
}

class EventsV24DaoManager {
  final _$EventsV24DaoMixin _db;
  EventsV24DaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db.attachedDatabase, _db.homes);
  $$DevicesV24TableTableManager get devicesV24 =>
      $$DevicesV24TableTableManager(_db.attachedDatabase, _db.devicesV24);
  $$ResourcesV24TableTableManager get resourcesV24 =>
      $$ResourcesV24TableTableManager(_db.attachedDatabase, _db.resourcesV24);
  $$EventsV24TableTableManager get eventsV24 =>
      $$EventsV24TableTableManager(_db.attachedDatabase, _db.eventsV24);
}
