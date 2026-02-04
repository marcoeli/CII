// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenants_homes_dao.dart';

// ignore_for_file: type=lint
mixin _$TenantsHomesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TenantsTable get tenants => attachedDatabase.tenants;
  $HomesTable get homes => attachedDatabase.homes;
  TenantsHomesDaoManager get managers => TenantsHomesDaoManager(this);
}

class TenantsHomesDaoManager {
  final _$TenantsHomesDaoMixin _db;
  TenantsHomesDaoManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db.attachedDatabase, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db.attachedDatabase, _db.homes);
}
