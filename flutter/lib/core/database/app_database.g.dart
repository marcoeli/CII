// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TenantsTable extends Tenants
    with TableInfo<$TenantsTable, TenantEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tenantId, name, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenants';
  @override
  VerificationContext validateIntegrity(
    Insertable<TenantEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TenantEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TenantEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TenantsTable createAlias(String alias) {
    return $TenantsTable(attachedDatabase, alias);
  }
}

class TenantEntity extends DataClass implements Insertable<TenantEntity> {
  final int id;
  final String tenantId;
  final String name;
  final String? email;
  final DateTime createdAt;
  const TenantEntity({
    required this.id,
    required this.tenantId,
    required this.name,
    this.email,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TenantsCompanion toCompanion(bool nullToAbsent) {
    return TenantsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory TenantEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TenantEntity(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TenantEntity copyWith({
    int? id,
    String? tenantId,
    String? name,
    Value<String?> email = const Value.absent(),
    DateTime? createdAt,
  }) => TenantEntity(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    createdAt: createdAt ?? this.createdAt,
  );
  TenantEntity copyWithCompanion(TenantsCompanion data) {
    return TenantEntity(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TenantEntity(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, name, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TenantEntity &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.name == this.name &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class TenantsCompanion extends UpdateCompanion<TenantEntity> {
  final Value<int> id;
  final Value<String> tenantId;
  final Value<String> name;
  final Value<String?> email;
  final Value<DateTime> createdAt;
  const TenantsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TenantsCompanion.insert({
    this.id = const Value.absent(),
    required String tenantId,
    required String name,
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : tenantId = Value(tenantId),
       name = Value(name);
  static Insertable<TenantEntity> custom({
    Expression<int>? id,
    Expression<String>? tenantId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TenantsCompanion copyWith({
    Value<int>? id,
    Value<String>? tenantId,
    Value<String>? name,
    Value<String?>? email,
    Value<DateTime>? createdAt,
  }) {
    return TenantsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HomesTable extends Homes with TableInfo<$HomesTable, HomeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<int> tenantId = GeneratedColumn<int>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tenants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<String> homeId = GeneratedColumn<String>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    homeId,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tenantId, homeId},
  ];
  @override
  HomeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenant_id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HomesTable createAlias(String alias) {
    return $HomesTable(attachedDatabase, alias);
  }
}

class HomeEntity extends DataClass implements Insertable<HomeEntity> {
  final int id;
  final int tenantId;
  final String homeId;
  final String label;
  final DateTime createdAt;
  const HomeEntity({
    required this.id,
    required this.tenantId,
    required this.homeId,
    required this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tenant_id'] = Variable<int>(tenantId);
    map['home_id'] = Variable<String>(homeId);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HomesCompanion toCompanion(bool nullToAbsent) {
    return HomesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      homeId: Value(homeId),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory HomeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeEntity(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<int>(json['tenantId']),
      homeId: serializer.fromJson<String>(json['homeId']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<int>(tenantId),
      'homeId': serializer.toJson<String>(homeId),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HomeEntity copyWith({
    int? id,
    int? tenantId,
    String? homeId,
    String? label,
    DateTime? createdAt,
  }) => HomeEntity(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    homeId: homeId ?? this.homeId,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  HomeEntity copyWithCompanion(HomesCompanion data) {
    return HomeEntity(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeEntity(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('homeId: $homeId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tenantId, homeId, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeEntity &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.homeId == this.homeId &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class HomesCompanion extends UpdateCompanion<HomeEntity> {
  final Value<int> id;
  final Value<int> tenantId;
  final Value<String> homeId;
  final Value<String> label;
  final Value<DateTime> createdAt;
  const HomesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.homeId = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HomesCompanion.insert({
    this.id = const Value.absent(),
    required int tenantId,
    required String homeId,
    required String label,
    this.createdAt = const Value.absent(),
  }) : tenantId = Value(tenantId),
       homeId = Value(homeId),
       label = Value(label);
  static Insertable<HomeEntity> custom({
    Expression<int>? id,
    Expression<int>? tenantId,
    Expression<String>? homeId,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (homeId != null) 'home_id': homeId,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HomesCompanion copyWith({
    Value<int>? id,
    Value<int>? tenantId,
    Value<String>? homeId,
    Value<String>? label,
    Value<DateTime>? createdAt,
  }) {
    return HomesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      homeId: homeId ?? this.homeId,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<int>(tenantId.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<String>(homeId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('homeId: $homeId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DevicesV24Table extends DevicesV24
    with TableInfo<$DevicesV24Table, DeviceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesV24Table(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<int> homeId = GeneratedColumn<int>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES homes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNKNOWN'),
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contractVersionMeta = const VerificationMeta(
    'contractVersion',
  );
  @override
  late final GeneratedColumn<String> contractVersion = GeneratedColumn<String>(
    'contract_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uptimeMeta = const VerificationMeta('uptime');
  @override
  late final GeneratedColumn<int> uptime = GeneratedColumn<int>(
    'uptime',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hardwareRevisionMeta = const VerificationMeta(
    'hardwareRevision',
  );
  @override
  late final GeneratedColumn<String> hardwareRevision = GeneratedColumn<String>(
    'hardware_revision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vendorMeta = const VerificationMeta('vendor');
  @override
  late final GeneratedColumn<String> vendor = GeneratedColumn<String>(
    'vendor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _macMeta = const VerificationMeta('mac');
  @override
  late final GeneratedColumn<String> mac = GeneratedColumn<String>(
    'mac',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rssiMeta = const VerificationMeta('rssi');
  @override
  late final GeneratedColumn<int> rssi = GeneratedColumn<int>(
    'rssi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    homeId,
    deviceId,
    role,
    status,
    lastSeen,
    firmwareVersion,
    contractVersion,
    uptime,
    hardwareRevision,
    ipAddress,
    vendor,
    model,
    mac,
    serial,
    rssi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices_v24';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    }
    if (data.containsKey('contract_version')) {
      context.handle(
        _contractVersionMeta,
        contractVersion.isAcceptableOrUnknown(
          data['contract_version']!,
          _contractVersionMeta,
        ),
      );
    }
    if (data.containsKey('uptime')) {
      context.handle(
        _uptimeMeta,
        uptime.isAcceptableOrUnknown(data['uptime']!, _uptimeMeta),
      );
    }
    if (data.containsKey('hardware_revision')) {
      context.handle(
        _hardwareRevisionMeta,
        hardwareRevision.isAcceptableOrUnknown(
          data['hardware_revision']!,
          _hardwareRevisionMeta,
        ),
      );
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    }
    if (data.containsKey('vendor')) {
      context.handle(
        _vendorMeta,
        vendor.isAcceptableOrUnknown(data['vendor']!, _vendorMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('mac')) {
      context.handle(
        _macMeta,
        mac.isAcceptableOrUnknown(data['mac']!, _macMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    if (data.containsKey('rssi')) {
      context.handle(
        _rssiMeta,
        rssi.isAcceptableOrUnknown(data['rssi']!, _rssiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      ),
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      ),
      contractVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_version'],
      ),
      uptime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uptime'],
      ),
      hardwareRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hardware_revision'],
      ),
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      ),
      vendor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      mac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac'],
      ),
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial'],
      ),
      rssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rssi'],
      ),
    );
  }

  @override
  $DevicesV24Table createAlias(String alias) {
    return $DevicesV24Table(attachedDatabase, alias);
  }
}

class DeviceEntity extends DataClass implements Insertable<DeviceEntity> {
  final int id;
  final int homeId;
  final String deviceId;
  final String role;
  final String status;
  final DateTime? lastSeen;
  final String? firmwareVersion;
  final String? contractVersion;
  final int? uptime;
  final String? hardwareRevision;
  final String? ipAddress;
  final String? vendor;
  final String? model;
  final String? mac;
  final String? serial;
  final int? rssi;
  const DeviceEntity({
    required this.id,
    required this.homeId,
    required this.deviceId,
    required this.role,
    required this.status,
    this.lastSeen,
    this.firmwareVersion,
    this.contractVersion,
    this.uptime,
    this.hardwareRevision,
    this.ipAddress,
    this.vendor,
    this.model,
    this.mac,
    this.serial,
    this.rssi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['home_id'] = Variable<int>(homeId);
    map['device_id'] = Variable<String>(deviceId);
    map['role'] = Variable<String>(role);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    if (!nullToAbsent || contractVersion != null) {
      map['contract_version'] = Variable<String>(contractVersion);
    }
    if (!nullToAbsent || uptime != null) {
      map['uptime'] = Variable<int>(uptime);
    }
    if (!nullToAbsent || hardwareRevision != null) {
      map['hardware_revision'] = Variable<String>(hardwareRevision);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    if (!nullToAbsent || vendor != null) {
      map['vendor'] = Variable<String>(vendor);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || mac != null) {
      map['mac'] = Variable<String>(mac);
    }
    if (!nullToAbsent || serial != null) {
      map['serial'] = Variable<String>(serial);
    }
    if (!nullToAbsent || rssi != null) {
      map['rssi'] = Variable<int>(rssi);
    }
    return map;
  }

  DevicesV24Companion toCompanion(bool nullToAbsent) {
    return DevicesV24Companion(
      id: Value(id),
      homeId: Value(homeId),
      deviceId: Value(deviceId),
      role: Value(role),
      status: Value(status),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
      contractVersion: contractVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(contractVersion),
      uptime: uptime == null && nullToAbsent
          ? const Value.absent()
          : Value(uptime),
      hardwareRevision: hardwareRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(hardwareRevision),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      vendor: vendor == null && nullToAbsent
          ? const Value.absent()
          : Value(vendor),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      mac: mac == null && nullToAbsent ? const Value.absent() : Value(mac),
      serial: serial == null && nullToAbsent
          ? const Value.absent()
          : Value(serial),
      rssi: rssi == null && nullToAbsent ? const Value.absent() : Value(rssi),
    );
  }

  factory DeviceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceEntity(
      id: serializer.fromJson<int>(json['id']),
      homeId: serializer.fromJson<int>(json['homeId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      role: serializer.fromJson<String>(json['role']),
      status: serializer.fromJson<String>(json['status']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
      contractVersion: serializer.fromJson<String?>(json['contractVersion']),
      uptime: serializer.fromJson<int?>(json['uptime']),
      hardwareRevision: serializer.fromJson<String?>(json['hardwareRevision']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      vendor: serializer.fromJson<String?>(json['vendor']),
      model: serializer.fromJson<String?>(json['model']),
      mac: serializer.fromJson<String?>(json['mac']),
      serial: serializer.fromJson<String?>(json['serial']),
      rssi: serializer.fromJson<int?>(json['rssi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'homeId': serializer.toJson<int>(homeId),
      'deviceId': serializer.toJson<String>(deviceId),
      'role': serializer.toJson<String>(role),
      'status': serializer.toJson<String>(status),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
      'contractVersion': serializer.toJson<String?>(contractVersion),
      'uptime': serializer.toJson<int?>(uptime),
      'hardwareRevision': serializer.toJson<String?>(hardwareRevision),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'vendor': serializer.toJson<String?>(vendor),
      'model': serializer.toJson<String?>(model),
      'mac': serializer.toJson<String?>(mac),
      'serial': serializer.toJson<String?>(serial),
      'rssi': serializer.toJson<int?>(rssi),
    };
  }

  DeviceEntity copyWith({
    int? id,
    int? homeId,
    String? deviceId,
    String? role,
    String? status,
    Value<DateTime?> lastSeen = const Value.absent(),
    Value<String?> firmwareVersion = const Value.absent(),
    Value<String?> contractVersion = const Value.absent(),
    Value<int?> uptime = const Value.absent(),
    Value<String?> hardwareRevision = const Value.absent(),
    Value<String?> ipAddress = const Value.absent(),
    Value<String?> vendor = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> mac = const Value.absent(),
    Value<String?> serial = const Value.absent(),
    Value<int?> rssi = const Value.absent(),
  }) => DeviceEntity(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deviceId: deviceId ?? this.deviceId,
    role: role ?? this.role,
    status: status ?? this.status,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    firmwareVersion: firmwareVersion.present
        ? firmwareVersion.value
        : this.firmwareVersion,
    contractVersion: contractVersion.present
        ? contractVersion.value
        : this.contractVersion,
    uptime: uptime.present ? uptime.value : this.uptime,
    hardwareRevision: hardwareRevision.present
        ? hardwareRevision.value
        : this.hardwareRevision,
    ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
    vendor: vendor.present ? vendor.value : this.vendor,
    model: model.present ? model.value : this.model,
    mac: mac.present ? mac.value : this.mac,
    serial: serial.present ? serial.value : this.serial,
    rssi: rssi.present ? rssi.value : this.rssi,
  );
  DeviceEntity copyWithCompanion(DevicesV24Companion data) {
    return DeviceEntity(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      contractVersion: data.contractVersion.present
          ? data.contractVersion.value
          : this.contractVersion,
      uptime: data.uptime.present ? data.uptime.value : this.uptime,
      hardwareRevision: data.hardwareRevision.present
          ? data.hardwareRevision.value
          : this.hardwareRevision,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      vendor: data.vendor.present ? data.vendor.value : this.vendor,
      model: data.model.present ? data.model.value : this.model,
      mac: data.mac.present ? data.mac.value : this.mac,
      serial: data.serial.present ? data.serial.value : this.serial,
      rssi: data.rssi.present ? data.rssi.value : this.rssi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceEntity(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('uptime: $uptime, ')
          ..write('hardwareRevision: $hardwareRevision, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('vendor: $vendor, ')
          ..write('model: $model, ')
          ..write('mac: $mac, ')
          ..write('serial: $serial, ')
          ..write('rssi: $rssi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    homeId,
    deviceId,
    role,
    status,
    lastSeen,
    firmwareVersion,
    contractVersion,
    uptime,
    hardwareRevision,
    ipAddress,
    vendor,
    model,
    mac,
    serial,
    rssi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceEntity &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deviceId == this.deviceId &&
          other.role == this.role &&
          other.status == this.status &&
          other.lastSeen == this.lastSeen &&
          other.firmwareVersion == this.firmwareVersion &&
          other.contractVersion == this.contractVersion &&
          other.uptime == this.uptime &&
          other.hardwareRevision == this.hardwareRevision &&
          other.ipAddress == this.ipAddress &&
          other.vendor == this.vendor &&
          other.model == this.model &&
          other.mac == this.mac &&
          other.serial == this.serial &&
          other.rssi == this.rssi);
}

class DevicesV24Companion extends UpdateCompanion<DeviceEntity> {
  final Value<int> id;
  final Value<int> homeId;
  final Value<String> deviceId;
  final Value<String> role;
  final Value<String> status;
  final Value<DateTime?> lastSeen;
  final Value<String?> firmwareVersion;
  final Value<String?> contractVersion;
  final Value<int?> uptime;
  final Value<String?> hardwareRevision;
  final Value<String?> ipAddress;
  final Value<String?> vendor;
  final Value<String?> model;
  final Value<String?> mac;
  final Value<String?> serial;
  final Value<int?> rssi;
  const DevicesV24Companion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.contractVersion = const Value.absent(),
    this.uptime = const Value.absent(),
    this.hardwareRevision = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.vendor = const Value.absent(),
    this.model = const Value.absent(),
    this.mac = const Value.absent(),
    this.serial = const Value.absent(),
    this.rssi = const Value.absent(),
  });
  DevicesV24Companion.insert({
    this.id = const Value.absent(),
    required int homeId,
    required String deviceId,
    required String role,
    this.status = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.contractVersion = const Value.absent(),
    this.uptime = const Value.absent(),
    this.hardwareRevision = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.vendor = const Value.absent(),
    this.model = const Value.absent(),
    this.mac = const Value.absent(),
    this.serial = const Value.absent(),
    this.rssi = const Value.absent(),
  }) : homeId = Value(homeId),
       deviceId = Value(deviceId),
       role = Value(role);
  static Insertable<DeviceEntity> custom({
    Expression<int>? id,
    Expression<int>? homeId,
    Expression<String>? deviceId,
    Expression<String>? role,
    Expression<String>? status,
    Expression<DateTime>? lastSeen,
    Expression<String>? firmwareVersion,
    Expression<String>? contractVersion,
    Expression<int>? uptime,
    Expression<String>? hardwareRevision,
    Expression<String>? ipAddress,
    Expression<String>? vendor,
    Expression<String>? model,
    Expression<String>? mac,
    Expression<String>? serial,
    Expression<int>? rssi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (homeId != null) 'home_id': homeId,
      if (deviceId != null) 'device_id': deviceId,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (contractVersion != null) 'contract_version': contractVersion,
      if (uptime != null) 'uptime': uptime,
      if (hardwareRevision != null) 'hardware_revision': hardwareRevision,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (vendor != null) 'vendor': vendor,
      if (model != null) 'model': model,
      if (mac != null) 'mac': mac,
      if (serial != null) 'serial': serial,
      if (rssi != null) 'rssi': rssi,
    });
  }

  DevicesV24Companion copyWith({
    Value<int>? id,
    Value<int>? homeId,
    Value<String>? deviceId,
    Value<String>? role,
    Value<String>? status,
    Value<DateTime?>? lastSeen,
    Value<String?>? firmwareVersion,
    Value<String?>? contractVersion,
    Value<int?>? uptime,
    Value<String?>? hardwareRevision,
    Value<String?>? ipAddress,
    Value<String?>? vendor,
    Value<String?>? model,
    Value<String?>? mac,
    Value<String?>? serial,
    Value<int?>? rssi,
  }) {
    return DevicesV24Companion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deviceId: deviceId ?? this.deviceId,
      role: role ?? this.role,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      contractVersion: contractVersion ?? this.contractVersion,
      uptime: uptime ?? this.uptime,
      hardwareRevision: hardwareRevision ?? this.hardwareRevision,
      ipAddress: ipAddress ?? this.ipAddress,
      vendor: vendor ?? this.vendor,
      model: model ?? this.model,
      mac: mac ?? this.mac,
      serial: serial ?? this.serial,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<int>(homeId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (contractVersion.present) {
      map['contract_version'] = Variable<String>(contractVersion.value);
    }
    if (uptime.present) {
      map['uptime'] = Variable<int>(uptime.value);
    }
    if (hardwareRevision.present) {
      map['hardware_revision'] = Variable<String>(hardwareRevision.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (vendor.present) {
      map['vendor'] = Variable<String>(vendor.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (mac.present) {
      map['mac'] = Variable<String>(mac.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (rssi.present) {
      map['rssi'] = Variable<int>(rssi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesV24Companion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('uptime: $uptime, ')
          ..write('hardwareRevision: $hardwareRevision, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('vendor: $vendor, ')
          ..write('model: $model, ')
          ..write('mac: $mac, ')
          ..write('serial: $serial, ')
          ..write('rssi: $rssi')
          ..write(')'))
        .toString();
  }
}

class $ResourcesV24Table extends ResourcesV24
    with TableInfo<$ResourcesV24Table, ResourceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourcesV24Table(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<int> homeId = GeneratedColumn<int>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES homes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capabilityTypeMeta = const VerificationMeta(
    'capabilityType',
  );
  @override
  late final GeneratedColumn<String> capabilityType = GeneratedColumn<String>(
    'capability_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    homeId,
    deviceId,
    resourceId,
    domain,
    kind,
    name,
    label,
    room,
    capabilityType,
    metadataJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resources_v24';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('capability_type')) {
      context.handle(
        _capabilityTypeMeta,
        capabilityType.isAcceptableOrUnknown(
          data['capability_type']!,
          _capabilityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capabilityTypeMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {homeId, resourceId},
  ];
  @override
  ResourceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
      capabilityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capability_type'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ResourcesV24Table createAlias(String alias) {
    return $ResourcesV24Table(attachedDatabase, alias);
  }
}

class ResourceEntity extends DataClass implements Insertable<ResourceEntity> {
  final int id;
  final int homeId;
  final int deviceId;
  final String resourceId;
  final String domain;
  final String kind;
  final String name;
  final String? label;
  final String? room;
  final String capabilityType;
  final String? metadataJson;
  final DateTime updatedAt;
  const ResourceEntity({
    required this.id,
    required this.homeId,
    required this.deviceId,
    required this.resourceId,
    required this.domain,
    required this.kind,
    required this.name,
    this.label,
    this.room,
    required this.capabilityType,
    this.metadataJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['home_id'] = Variable<int>(homeId);
    map['device_id'] = Variable<int>(deviceId);
    map['resource_id'] = Variable<String>(resourceId);
    map['domain'] = Variable<String>(domain);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    map['capability_type'] = Variable<String>(capabilityType);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResourcesV24Companion toCompanion(bool nullToAbsent) {
    return ResourcesV24Companion(
      id: Value(id),
      homeId: Value(homeId),
      deviceId: Value(deviceId),
      resourceId: Value(resourceId),
      domain: Value(domain),
      kind: Value(kind),
      name: Value(name),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      capabilityType: Value(capabilityType),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResourceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceEntity(
      id: serializer.fromJson<int>(json['id']),
      homeId: serializer.fromJson<int>(json['homeId']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      domain: serializer.fromJson<String>(json['domain']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      label: serializer.fromJson<String?>(json['label']),
      room: serializer.fromJson<String?>(json['room']),
      capabilityType: serializer.fromJson<String>(json['capabilityType']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'homeId': serializer.toJson<int>(homeId),
      'deviceId': serializer.toJson<int>(deviceId),
      'resourceId': serializer.toJson<String>(resourceId),
      'domain': serializer.toJson<String>(domain),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'label': serializer.toJson<String?>(label),
      'room': serializer.toJson<String?>(room),
      'capabilityType': serializer.toJson<String>(capabilityType),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResourceEntity copyWith({
    int? id,
    int? homeId,
    int? deviceId,
    String? resourceId,
    String? domain,
    String? kind,
    String? name,
    Value<String?> label = const Value.absent(),
    Value<String?> room = const Value.absent(),
    String? capabilityType,
    Value<String?> metadataJson = const Value.absent(),
    DateTime? updatedAt,
  }) => ResourceEntity(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    deviceId: deviceId ?? this.deviceId,
    resourceId: resourceId ?? this.resourceId,
    domain: domain ?? this.domain,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    label: label.present ? label.value : this.label,
    room: room.present ? room.value : this.room,
    capabilityType: capabilityType ?? this.capabilityType,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ResourceEntity copyWithCompanion(ResourcesV24Companion data) {
    return ResourceEntity(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      domain: data.domain.present ? data.domain.value : this.domain,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      label: data.label.present ? data.label.value : this.label,
      room: data.room.present ? data.room.value : this.room,
      capabilityType: data.capabilityType.present
          ? data.capabilityType.value
          : this.capabilityType,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceEntity(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('resourceId: $resourceId, ')
          ..write('domain: $domain, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('room: $room, ')
          ..write('capabilityType: $capabilityType, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    homeId,
    deviceId,
    resourceId,
    domain,
    kind,
    name,
    label,
    room,
    capabilityType,
    metadataJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceEntity &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.deviceId == this.deviceId &&
          other.resourceId == this.resourceId &&
          other.domain == this.domain &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.label == this.label &&
          other.room == this.room &&
          other.capabilityType == this.capabilityType &&
          other.metadataJson == this.metadataJson &&
          other.updatedAt == this.updatedAt);
}

class ResourcesV24Companion extends UpdateCompanion<ResourceEntity> {
  final Value<int> id;
  final Value<int> homeId;
  final Value<int> deviceId;
  final Value<String> resourceId;
  final Value<String> domain;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> label;
  final Value<String?> room;
  final Value<String> capabilityType;
  final Value<String?> metadataJson;
  final Value<DateTime> updatedAt;
  const ResourcesV24Companion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.domain = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.label = const Value.absent(),
    this.room = const Value.absent(),
    this.capabilityType = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ResourcesV24Companion.insert({
    this.id = const Value.absent(),
    required int homeId,
    required int deviceId,
    required String resourceId,
    required String domain,
    required String kind,
    required String name,
    this.label = const Value.absent(),
    this.room = const Value.absent(),
    required String capabilityType,
    this.metadataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : homeId = Value(homeId),
       deviceId = Value(deviceId),
       resourceId = Value(resourceId),
       domain = Value(domain),
       kind = Value(kind),
       name = Value(name),
       capabilityType = Value(capabilityType);
  static Insertable<ResourceEntity> custom({
    Expression<int>? id,
    Expression<int>? homeId,
    Expression<int>? deviceId,
    Expression<String>? resourceId,
    Expression<String>? domain,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? label,
    Expression<String>? room,
    Expression<String>? capabilityType,
    Expression<String>? metadataJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (homeId != null) 'home_id': homeId,
      if (deviceId != null) 'device_id': deviceId,
      if (resourceId != null) 'resource_id': resourceId,
      if (domain != null) 'domain': domain,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (label != null) 'label': label,
      if (room != null) 'room': room,
      if (capabilityType != null) 'capability_type': capabilityType,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ResourcesV24Companion copyWith({
    Value<int>? id,
    Value<int>? homeId,
    Value<int>? deviceId,
    Value<String>? resourceId,
    Value<String>? domain,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? label,
    Value<String?>? room,
    Value<String>? capabilityType,
    Value<String?>? metadataJson,
    Value<DateTime>? updatedAt,
  }) {
    return ResourcesV24Companion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      deviceId: deviceId ?? this.deviceId,
      resourceId: resourceId ?? this.resourceId,
      domain: domain ?? this.domain,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      label: label ?? this.label,
      room: room ?? this.room,
      capabilityType: capabilityType ?? this.capabilityType,
      metadataJson: metadataJson ?? this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<int>(homeId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (capabilityType.present) {
      map['capability_type'] = Variable<String>(capabilityType.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourcesV24Companion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('deviceId: $deviceId, ')
          ..write('resourceId: $resourceId, ')
          ..write('domain: $domain, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('room: $room, ')
          ..write('capabilityType: $capabilityType, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResourceStatesTable extends ResourceStates
    with TableInfo<$ResourceStatesTable, ResourceStateEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, resourceId, stateJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceStateEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceStateEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceStateEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ResourceStatesTable createAlias(String alias) {
    return $ResourceStatesTable(attachedDatabase, alias);
  }
}

class ResourceStateEntity extends DataClass
    implements Insertable<ResourceStateEntity> {
  final int id;
  final int resourceId;
  final String stateJson;
  final DateTime updatedAt;
  const ResourceStateEntity({
    required this.id,
    required this.resourceId,
    required this.stateJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['state_json'] = Variable<String>(stateJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResourceStatesCompanion toCompanion(bool nullToAbsent) {
    return ResourceStatesCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      stateJson: Value(stateJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResourceStateEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceStateEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'stateJson': serializer.toJson<String>(stateJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResourceStateEntity copyWith({
    int? id,
    int? resourceId,
    String? stateJson,
    DateTime? updatedAt,
  }) => ResourceStateEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    stateJson: stateJson ?? this.stateJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ResourceStateEntity copyWithCompanion(ResourceStatesCompanion data) {
    return ResourceStateEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceStateEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resourceId, stateJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceStateEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.stateJson == this.stateJson &&
          other.updatedAt == this.updatedAt);
}

class ResourceStatesCompanion extends UpdateCompanion<ResourceStateEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<String> stateJson;
  final Value<DateTime> updatedAt;
  const ResourceStatesCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ResourceStatesCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required String stateJson,
    required DateTime updatedAt,
  }) : resourceId = Value(resourceId),
       stateJson = Value(stateJson),
       updatedAt = Value(updatedAt);
  static Insertable<ResourceStateEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<String>? stateJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (stateJson != null) 'state_json': stateJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ResourceStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<String>? stateJson,
    Value<DateTime>? updatedAt,
  }) {
    return ResourceStatesCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      stateJson: stateJson ?? this.stateJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceStatesCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('stateJson: $stateJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResourceDataTable extends ResourceData
    with TableInfo<$ResourceDataTable, ResourceDataEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, resourceId, dataJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceDataEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceDataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceDataEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ResourceDataTable createAlias(String alias) {
    return $ResourceDataTable(attachedDatabase, alias);
  }
}

class ResourceDataEntity extends DataClass
    implements Insertable<ResourceDataEntity> {
  final int id;
  final int resourceId;
  final String dataJson;
  final DateTime updatedAt;
  const ResourceDataEntity({
    required this.id,
    required this.resourceId,
    required this.dataJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['data_json'] = Variable<String>(dataJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResourceDataCompanion toCompanion(bool nullToAbsent) {
    return ResourceDataCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      dataJson: Value(dataJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResourceDataEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceDataEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'dataJson': serializer.toJson<String>(dataJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResourceDataEntity copyWith({
    int? id,
    int? resourceId,
    String? dataJson,
    DateTime? updatedAt,
  }) => ResourceDataEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    dataJson: dataJson ?? this.dataJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ResourceDataEntity copyWithCompanion(ResourceDataCompanion data) {
    return ResourceDataEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceDataEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resourceId, dataJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceDataEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.dataJson == this.dataJson &&
          other.updatedAt == this.updatedAt);
}

class ResourceDataCompanion extends UpdateCompanion<ResourceDataEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<String> dataJson;
  final Value<DateTime> updatedAt;
  const ResourceDataCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ResourceDataCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required String dataJson,
    required DateTime updatedAt,
  }) : resourceId = Value(resourceId),
       dataJson = Value(dataJson),
       updatedAt = Value(updatedAt);
  static Insertable<ResourceDataEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<String>? dataJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (dataJson != null) 'data_json': dataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ResourceDataCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<String>? dataJson,
    Value<DateTime>? updatedAt,
  }) {
    return ResourceDataCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      dataJson: dataJson ?? this.dataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceDataCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('dataJson: $dataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResourceConfigsTable extends ResourceConfigs
    with TableInfo<$ResourceConfigsTable, ResourceConfigEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, resourceId, configJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceConfigEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceConfigEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceConfigEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ResourceConfigsTable createAlias(String alias) {
    return $ResourceConfigsTable(attachedDatabase, alias);
  }
}

class ResourceConfigEntity extends DataClass
    implements Insertable<ResourceConfigEntity> {
  final int id;
  final int resourceId;
  final String configJson;
  final DateTime updatedAt;
  const ResourceConfigEntity({
    required this.id,
    required this.resourceId,
    required this.configJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['config_json'] = Variable<String>(configJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ResourceConfigsCompanion toCompanion(bool nullToAbsent) {
    return ResourceConfigsCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      configJson: Value(configJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ResourceConfigEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceConfigEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      configJson: serializer.fromJson<String>(json['configJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'configJson': serializer.toJson<String>(configJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ResourceConfigEntity copyWith({
    int? id,
    int? resourceId,
    String? configJson,
    DateTime? updatedAt,
  }) => ResourceConfigEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    configJson: configJson ?? this.configJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ResourceConfigEntity copyWithCompanion(ResourceConfigsCompanion data) {
    return ResourceConfigEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceConfigEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resourceId, configJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceConfigEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.configJson == this.configJson &&
          other.updatedAt == this.updatedAt);
}

class ResourceConfigsCompanion extends UpdateCompanion<ResourceConfigEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<String> configJson;
  final Value<DateTime> updatedAt;
  const ResourceConfigsCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.configJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ResourceConfigsCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required String configJson,
    required DateTime updatedAt,
  }) : resourceId = Value(resourceId),
       configJson = Value(configJson),
       updatedAt = Value(updatedAt);
  static Insertable<ResourceConfigEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<String>? configJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (configJson != null) 'config_json': configJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ResourceConfigsCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<String>? configJson,
    Value<DateTime>? updatedAt,
  }) {
    return ResourceConfigsCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      configJson: configJson ?? this.configJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceConfigsCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResourceBindingsTable extends ResourceBindings
    with TableInfo<$ResourceBindingsTable, ResourceBindingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetResourceIdMeta = const VerificationMeta(
    'targetResourceId',
  );
  @override
  late final GeneratedColumn<int> targetResourceId = GeneratedColumn<int>(
    'target_resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bindingTypeMeta = const VerificationMeta(
    'bindingType',
  );
  @override
  late final GeneratedColumn<String> bindingType = GeneratedColumn<String>(
    'binding_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bindingConfigJsonMeta = const VerificationMeta(
    'bindingConfigJson',
  );
  @override
  late final GeneratedColumn<String> bindingConfigJson =
      GeneratedColumn<String>(
        'binding_config_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    targetResourceId,
    bindingType,
    bindingConfigJson,
    priority,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResourceBindingEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('target_resource_id')) {
      context.handle(
        _targetResourceIdMeta,
        targetResourceId.isAcceptableOrUnknown(
          data['target_resource_id']!,
          _targetResourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetResourceIdMeta);
    }
    if (data.containsKey('binding_type')) {
      context.handle(
        _bindingTypeMeta,
        bindingType.isAcceptableOrUnknown(
          data['binding_type']!,
          _bindingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bindingTypeMeta);
    }
    if (data.containsKey('binding_config_json')) {
      context.handle(
        _bindingConfigJsonMeta,
        bindingConfigJson.isAcceptableOrUnknown(
          data['binding_config_json']!,
          _bindingConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResourceBindingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceBindingEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      targetResourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_resource_id'],
      )!,
      bindingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding_type'],
      )!,
      bindingConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding_config_json'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ResourceBindingsTable createAlias(String alias) {
    return $ResourceBindingsTable(attachedDatabase, alias);
  }
}

class ResourceBindingEntity extends DataClass
    implements Insertable<ResourceBindingEntity> {
  final int id;
  final int resourceId;
  final int targetResourceId;
  final String bindingType;
  final String? bindingConfigJson;
  final int priority;
  final bool enabled;
  const ResourceBindingEntity({
    required this.id,
    required this.resourceId,
    required this.targetResourceId,
    required this.bindingType,
    this.bindingConfigJson,
    required this.priority,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['target_resource_id'] = Variable<int>(targetResourceId);
    map['binding_type'] = Variable<String>(bindingType);
    if (!nullToAbsent || bindingConfigJson != null) {
      map['binding_config_json'] = Variable<String>(bindingConfigJson);
    }
    map['priority'] = Variable<int>(priority);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ResourceBindingsCompanion toCompanion(bool nullToAbsent) {
    return ResourceBindingsCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      targetResourceId: Value(targetResourceId),
      bindingType: Value(bindingType),
      bindingConfigJson: bindingConfigJson == null && nullToAbsent
          ? const Value.absent()
          : Value(bindingConfigJson),
      priority: Value(priority),
      enabled: Value(enabled),
    );
  }

  factory ResourceBindingEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceBindingEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      targetResourceId: serializer.fromJson<int>(json['targetResourceId']),
      bindingType: serializer.fromJson<String>(json['bindingType']),
      bindingConfigJson: serializer.fromJson<String?>(
        json['bindingConfigJson'],
      ),
      priority: serializer.fromJson<int>(json['priority']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'targetResourceId': serializer.toJson<int>(targetResourceId),
      'bindingType': serializer.toJson<String>(bindingType),
      'bindingConfigJson': serializer.toJson<String?>(bindingConfigJson),
      'priority': serializer.toJson<int>(priority),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ResourceBindingEntity copyWith({
    int? id,
    int? resourceId,
    int? targetResourceId,
    String? bindingType,
    Value<String?> bindingConfigJson = const Value.absent(),
    int? priority,
    bool? enabled,
  }) => ResourceBindingEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    targetResourceId: targetResourceId ?? this.targetResourceId,
    bindingType: bindingType ?? this.bindingType,
    bindingConfigJson: bindingConfigJson.present
        ? bindingConfigJson.value
        : this.bindingConfigJson,
    priority: priority ?? this.priority,
    enabled: enabled ?? this.enabled,
  );
  ResourceBindingEntity copyWithCompanion(ResourceBindingsCompanion data) {
    return ResourceBindingEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      targetResourceId: data.targetResourceId.present
          ? data.targetResourceId.value
          : this.targetResourceId,
      bindingType: data.bindingType.present
          ? data.bindingType.value
          : this.bindingType,
      bindingConfigJson: data.bindingConfigJson.present
          ? data.bindingConfigJson.value
          : this.bindingConfigJson,
      priority: data.priority.present ? data.priority.value : this.priority,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceBindingEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('targetResourceId: $targetResourceId, ')
          ..write('bindingType: $bindingType, ')
          ..write('bindingConfigJson: $bindingConfigJson, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    resourceId,
    targetResourceId,
    bindingType,
    bindingConfigJson,
    priority,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceBindingEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.targetResourceId == this.targetResourceId &&
          other.bindingType == this.bindingType &&
          other.bindingConfigJson == this.bindingConfigJson &&
          other.priority == this.priority &&
          other.enabled == this.enabled);
}

class ResourceBindingsCompanion extends UpdateCompanion<ResourceBindingEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<int> targetResourceId;
  final Value<String> bindingType;
  final Value<String?> bindingConfigJson;
  final Value<int> priority;
  final Value<bool> enabled;
  const ResourceBindingsCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.targetResourceId = const Value.absent(),
    this.bindingType = const Value.absent(),
    this.bindingConfigJson = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  ResourceBindingsCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required int targetResourceId,
    required String bindingType,
    this.bindingConfigJson = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : resourceId = Value(resourceId),
       targetResourceId = Value(targetResourceId),
       bindingType = Value(bindingType);
  static Insertable<ResourceBindingEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<int>? targetResourceId,
    Expression<String>? bindingType,
    Expression<String>? bindingConfigJson,
    Expression<int>? priority,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (targetResourceId != null) 'target_resource_id': targetResourceId,
      if (bindingType != null) 'binding_type': bindingType,
      if (bindingConfigJson != null) 'binding_config_json': bindingConfigJson,
      if (priority != null) 'priority': priority,
      if (enabled != null) 'enabled': enabled,
    });
  }

  ResourceBindingsCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<int>? targetResourceId,
    Value<String>? bindingType,
    Value<String?>? bindingConfigJson,
    Value<int>? priority,
    Value<bool>? enabled,
  }) {
    return ResourceBindingsCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      targetResourceId: targetResourceId ?? this.targetResourceId,
      bindingType: bindingType ?? this.bindingType,
      bindingConfigJson: bindingConfigJson ?? this.bindingConfigJson,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (targetResourceId.present) {
      map['target_resource_id'] = Variable<int>(targetResourceId.value);
    }
    if (bindingType.present) {
      map['binding_type'] = Variable<String>(bindingType.value);
    }
    if (bindingConfigJson.present) {
      map['binding_config_json'] = Variable<String>(bindingConfigJson.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResourceBindingsCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('targetResourceId: $targetResourceId, ')
          ..write('bindingType: $bindingType, ')
          ..write('bindingConfigJson: $bindingConfigJson, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $CommandResultsTable extends CommandResults
    with TableInfo<$CommandResultsTable, CommandResultEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _commandMeta = const VerificationMeta(
    'command',
  );
  @override
  late final GeneratedColumn<String> command = GeneratedColumn<String>(
    'command',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    command,
    resultJson,
    status,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'command_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommandResultEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('command')) {
      context.handle(
        _commandMeta,
        command.isAcceptableOrUnknown(data['command']!, _commandMeta),
      );
    } else if (isInserting) {
      context.missing(_commandMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommandResultEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommandResultEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      command: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $CommandResultsTable createAlias(String alias) {
    return $CommandResultsTable(attachedDatabase, alias);
  }
}

class CommandResultEntity extends DataClass
    implements Insertable<CommandResultEntity> {
  final int id;
  final int resourceId;
  final String command;
  final String? resultJson;
  final String status;
  final DateTime timestamp;
  const CommandResultEntity({
    required this.id,
    required this.resourceId,
    required this.command,
    this.resultJson,
    required this.status,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['command'] = Variable<String>(command);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    map['status'] = Variable<String>(status);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  CommandResultsCompanion toCompanion(bool nullToAbsent) {
    return CommandResultsCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      command: Value(command),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      status: Value(status),
      timestamp: Value(timestamp),
    );
  }

  factory CommandResultEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommandResultEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      command: serializer.fromJson<String>(json['command']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      status: serializer.fromJson<String>(json['status']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'command': serializer.toJson<String>(command),
      'resultJson': serializer.toJson<String?>(resultJson),
      'status': serializer.toJson<String>(status),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  CommandResultEntity copyWith({
    int? id,
    int? resourceId,
    String? command,
    Value<String?> resultJson = const Value.absent(),
    String? status,
    DateTime? timestamp,
  }) => CommandResultEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    command: command ?? this.command,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
  );
  CommandResultEntity copyWithCompanion(CommandResultsCompanion data) {
    return CommandResultEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      command: data.command.present ? data.command.value : this.command,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      status: data.status.present ? data.status.value : this.status,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommandResultEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('command: $command, ')
          ..write('resultJson: $resultJson, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, resourceId, command, resultJson, status, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandResultEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.command == this.command &&
          other.resultJson == this.resultJson &&
          other.status == this.status &&
          other.timestamp == this.timestamp);
}

class CommandResultsCompanion extends UpdateCompanion<CommandResultEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<String> command;
  final Value<String?> resultJson;
  final Value<String> status;
  final Value<DateTime> timestamp;
  const CommandResultsCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.command = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.status = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  CommandResultsCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required String command,
    this.resultJson = const Value.absent(),
    required String status,
    required DateTime timestamp,
  }) : resourceId = Value(resourceId),
       command = Value(command),
       status = Value(status),
       timestamp = Value(timestamp);
  static Insertable<CommandResultEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<String>? command,
    Expression<String>? resultJson,
    Expression<String>? status,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (command != null) 'command': command,
      if (resultJson != null) 'result_json': resultJson,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  CommandResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<String>? command,
    Value<String?>? resultJson,
    Value<String>? status,
    Value<DateTime>? timestamp,
  }) {
    return CommandResultsCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      command: command ?? this.command,
      resultJson: resultJson ?? this.resultJson,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (command.present) {
      map['command'] = Variable<String>(command.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandResultsCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('command: $command, ')
          ..write('resultJson: $resultJson, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $WaterLevelHistoryTable extends WaterLevelHistory
    with TableInfo<$WaterLevelHistoryTable, WaterLevelHistoryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLevelHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<double> percent = GeneratedColumn<double>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _litersMeta = const VerificationMeta('liters');
  @override
  late final GeneratedColumn<double> liters = GeneratedColumn<double>(
    'liters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertMeta = const VerificationMeta('alert');
  @override
  late final GeneratedColumn<String> alert = GeneratedColumn<String>(
    'alert',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NORMAL'),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    percent,
    liters,
    alert,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_level_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLevelHistoryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    } else if (isInserting) {
      context.missing(_percentMeta);
    }
    if (data.containsKey('liters')) {
      context.handle(
        _litersMeta,
        liters.isAcceptableOrUnknown(data['liters']!, _litersMeta),
      );
    } else if (isInserting) {
      context.missing(_litersMeta);
    }
    if (data.containsKey('alert')) {
      context.handle(
        _alertMeta,
        alert.isAcceptableOrUnknown(data['alert']!, _alertMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLevelHistoryEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLevelHistoryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percent'],
      )!,
      liters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liters'],
      )!,
      alert: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $WaterLevelHistoryTable createAlias(String alias) {
    return $WaterLevelHistoryTable(attachedDatabase, alias);
  }
}

class WaterLevelHistoryEntity extends DataClass
    implements Insertable<WaterLevelHistoryEntity> {
  final int id;
  final int resourceId;
  final double percent;
  final double liters;
  final String alert;
  final DateTime timestamp;
  const WaterLevelHistoryEntity({
    required this.id,
    required this.resourceId,
    required this.percent,
    required this.liters,
    required this.alert,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['percent'] = Variable<double>(percent);
    map['liters'] = Variable<double>(liters);
    map['alert'] = Variable<String>(alert);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WaterLevelHistoryCompanion toCompanion(bool nullToAbsent) {
    return WaterLevelHistoryCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      percent: Value(percent),
      liters: Value(liters),
      alert: Value(alert),
      timestamp: Value(timestamp),
    );
  }

  factory WaterLevelHistoryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLevelHistoryEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      percent: serializer.fromJson<double>(json['percent']),
      liters: serializer.fromJson<double>(json['liters']),
      alert: serializer.fromJson<String>(json['alert']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'percent': serializer.toJson<double>(percent),
      'liters': serializer.toJson<double>(liters),
      'alert': serializer.toJson<String>(alert),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WaterLevelHistoryEntity copyWith({
    int? id,
    int? resourceId,
    double? percent,
    double? liters,
    String? alert,
    DateTime? timestamp,
  }) => WaterLevelHistoryEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    percent: percent ?? this.percent,
    liters: liters ?? this.liters,
    alert: alert ?? this.alert,
    timestamp: timestamp ?? this.timestamp,
  );
  WaterLevelHistoryEntity copyWithCompanion(WaterLevelHistoryCompanion data) {
    return WaterLevelHistoryEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      percent: data.percent.present ? data.percent.value : this.percent,
      liters: data.liters.present ? data.liters.value : this.liters,
      alert: data.alert.present ? data.alert.value : this.alert,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLevelHistoryEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('percent: $percent, ')
          ..write('liters: $liters, ')
          ..write('alert: $alert, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, resourceId, percent, liters, alert, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLevelHistoryEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.percent == this.percent &&
          other.liters == this.liters &&
          other.alert == this.alert &&
          other.timestamp == this.timestamp);
}

class WaterLevelHistoryCompanion
    extends UpdateCompanion<WaterLevelHistoryEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<double> percent;
  final Value<double> liters;
  final Value<String> alert;
  final Value<DateTime> timestamp;
  const WaterLevelHistoryCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.percent = const Value.absent(),
    this.liters = const Value.absent(),
    this.alert = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WaterLevelHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required double percent,
    required double liters,
    this.alert = const Value.absent(),
    required DateTime timestamp,
  }) : resourceId = Value(resourceId),
       percent = Value(percent),
       liters = Value(liters),
       timestamp = Value(timestamp);
  static Insertable<WaterLevelHistoryEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<double>? percent,
    Expression<double>? liters,
    Expression<String>? alert,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (percent != null) 'percent': percent,
      if (liters != null) 'liters': liters,
      if (alert != null) 'alert': alert,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WaterLevelHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<double>? percent,
    Value<double>? liters,
    Value<String>? alert,
    Value<DateTime>? timestamp,
  }) {
    return WaterLevelHistoryCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      percent: percent ?? this.percent,
      liters: liters ?? this.liters,
      alert: alert ?? this.alert,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (percent.present) {
      map['percent'] = Variable<double>(percent.value);
    }
    if (liters.present) {
      map['liters'] = Variable<double>(liters.value);
    }
    if (alert.present) {
      map['alert'] = Variable<String>(alert.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLevelHistoryCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('percent: $percent, ')
          ..write('liters: $liters, ')
          ..write('alert: $alert, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $EnvClimateHistoryTable extends EnvClimateHistory
    with TableInfo<$EnvClimateHistoryTable, EnvClimateHistoryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvClimateHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<double> humidity = GeneratedColumn<double>(
    'humidity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    resourceId,
    temperature,
    humidity,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'env_climate_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvClimateHistoryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    } else if (isInserting) {
      context.missing(_humidityMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvClimateHistoryEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvClimateHistoryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      humidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}humidity'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $EnvClimateHistoryTable createAlias(String alias) {
    return $EnvClimateHistoryTable(attachedDatabase, alias);
  }
}

class EnvClimateHistoryEntity extends DataClass
    implements Insertable<EnvClimateHistoryEntity> {
  final int id;
  final int resourceId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  const EnvClimateHistoryEntity({
    required this.id,
    required this.resourceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['resource_id'] = Variable<int>(resourceId);
    map['temperature'] = Variable<double>(temperature);
    map['humidity'] = Variable<double>(humidity);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  EnvClimateHistoryCompanion toCompanion(bool nullToAbsent) {
    return EnvClimateHistoryCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      temperature: Value(temperature),
      humidity: Value(humidity),
      timestamp: Value(timestamp),
    );
  }

  factory EnvClimateHistoryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvClimateHistoryEntity(
      id: serializer.fromJson<int>(json['id']),
      resourceId: serializer.fromJson<int>(json['resourceId']),
      temperature: serializer.fromJson<double>(json['temperature']),
      humidity: serializer.fromJson<double>(json['humidity']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'resourceId': serializer.toJson<int>(resourceId),
      'temperature': serializer.toJson<double>(temperature),
      'humidity': serializer.toJson<double>(humidity),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  EnvClimateHistoryEntity copyWith({
    int? id,
    int? resourceId,
    double? temperature,
    double? humidity,
    DateTime? timestamp,
  }) => EnvClimateHistoryEntity(
    id: id ?? this.id,
    resourceId: resourceId ?? this.resourceId,
    temperature: temperature ?? this.temperature,
    humidity: humidity ?? this.humidity,
    timestamp: timestamp ?? this.timestamp,
  );
  EnvClimateHistoryEntity copyWithCompanion(EnvClimateHistoryCompanion data) {
    return EnvClimateHistoryEntity(
      id: data.id.present ? data.id.value : this.id,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvClimateHistoryEntity(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, resourceId, temperature, humidity, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvClimateHistoryEntity &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.temperature == this.temperature &&
          other.humidity == this.humidity &&
          other.timestamp == this.timestamp);
}

class EnvClimateHistoryCompanion
    extends UpdateCompanion<EnvClimateHistoryEntity> {
  final Value<int> id;
  final Value<int> resourceId;
  final Value<double> temperature;
  final Value<double> humidity;
  final Value<DateTime> timestamp;
  const EnvClimateHistoryCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  EnvClimateHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int resourceId,
    required double temperature,
    required double humidity,
    required DateTime timestamp,
  }) : resourceId = Value(resourceId),
       temperature = Value(temperature),
       humidity = Value(humidity),
       timestamp = Value(timestamp);
  static Insertable<EnvClimateHistoryEntity> custom({
    Expression<int>? id,
    Expression<int>? resourceId,
    Expression<double>? temperature,
    Expression<double>? humidity,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  EnvClimateHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? resourceId,
    Value<double>? temperature,
    Value<double>? humidity,
    Value<DateTime>? timestamp,
  }) {
    return EnvClimateHistoryCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<double>(humidity.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvClimateHistoryCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $EventsV24Table extends EventsV24
    with TableInfo<$EventsV24Table, EventEntityV24> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsV24Table(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _homeIdMeta = const VerificationMeta('homeId');
  @override
  late final GeneratedColumn<int> homeId = GeneratedColumn<int>(
    'home_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES homes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES resources_v24 (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('info'),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    homeId,
    resourceId,
    domain,
    kind,
    severity,
    payloadJson,
    timestamp,
    read,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events_v24';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventEntityV24> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('home_id')) {
      context.handle(
        _homeIdMeta,
        homeId.isAcceptableOrUnknown(data['home_id']!, _homeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_homeIdMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventEntityV24 map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventEntityV24(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      homeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      ),
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
    );
  }

  @override
  $EventsV24Table createAlias(String alias) {
    return $EventsV24Table(attachedDatabase, alias);
  }
}

class EventEntityV24 extends DataClass implements Insertable<EventEntityV24> {
  final int id;
  final int homeId;
  final int? resourceId;
  final String domain;
  final String kind;
  final String severity;
  final String? payloadJson;
  final DateTime timestamp;
  final bool read;
  const EventEntityV24({
    required this.id,
    required this.homeId,
    this.resourceId,
    required this.domain,
    required this.kind,
    required this.severity,
    this.payloadJson,
    required this.timestamp,
    required this.read,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['home_id'] = Variable<int>(homeId);
    if (!nullToAbsent || resourceId != null) {
      map['resource_id'] = Variable<int>(resourceId);
    }
    map['domain'] = Variable<String>(domain);
    map['kind'] = Variable<String>(kind);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['read'] = Variable<bool>(read);
    return map;
  }

  EventsV24Companion toCompanion(bool nullToAbsent) {
    return EventsV24Companion(
      id: Value(id),
      homeId: Value(homeId),
      resourceId: resourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceId),
      domain: Value(domain),
      kind: Value(kind),
      severity: Value(severity),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      timestamp: Value(timestamp),
      read: Value(read),
    );
  }

  factory EventEntityV24.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventEntityV24(
      id: serializer.fromJson<int>(json['id']),
      homeId: serializer.fromJson<int>(json['homeId']),
      resourceId: serializer.fromJson<int?>(json['resourceId']),
      domain: serializer.fromJson<String>(json['domain']),
      kind: serializer.fromJson<String>(json['kind']),
      severity: serializer.fromJson<String>(json['severity']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      read: serializer.fromJson<bool>(json['read']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'homeId': serializer.toJson<int>(homeId),
      'resourceId': serializer.toJson<int?>(resourceId),
      'domain': serializer.toJson<String>(domain),
      'kind': serializer.toJson<String>(kind),
      'severity': serializer.toJson<String>(severity),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'read': serializer.toJson<bool>(read),
    };
  }

  EventEntityV24 copyWith({
    int? id,
    int? homeId,
    Value<int?> resourceId = const Value.absent(),
    String? domain,
    String? kind,
    String? severity,
    Value<String?> payloadJson = const Value.absent(),
    DateTime? timestamp,
    bool? read,
  }) => EventEntityV24(
    id: id ?? this.id,
    homeId: homeId ?? this.homeId,
    resourceId: resourceId.present ? resourceId.value : this.resourceId,
    domain: domain ?? this.domain,
    kind: kind ?? this.kind,
    severity: severity ?? this.severity,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    timestamp: timestamp ?? this.timestamp,
    read: read ?? this.read,
  );
  EventEntityV24 copyWithCompanion(EventsV24Companion data) {
    return EventEntityV24(
      id: data.id.present ? data.id.value : this.id,
      homeId: data.homeId.present ? data.homeId.value : this.homeId,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      domain: data.domain.present ? data.domain.value : this.domain,
      kind: data.kind.present ? data.kind.value : this.kind,
      severity: data.severity.present ? data.severity.value : this.severity,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      read: data.read.present ? data.read.value : this.read,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventEntityV24(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('resourceId: $resourceId, ')
          ..write('domain: $domain, ')
          ..write('kind: $kind, ')
          ..write('severity: $severity, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    homeId,
    resourceId,
    domain,
    kind,
    severity,
    payloadJson,
    timestamp,
    read,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventEntityV24 &&
          other.id == this.id &&
          other.homeId == this.homeId &&
          other.resourceId == this.resourceId &&
          other.domain == this.domain &&
          other.kind == this.kind &&
          other.severity == this.severity &&
          other.payloadJson == this.payloadJson &&
          other.timestamp == this.timestamp &&
          other.read == this.read);
}

class EventsV24Companion extends UpdateCompanion<EventEntityV24> {
  final Value<int> id;
  final Value<int> homeId;
  final Value<int?> resourceId;
  final Value<String> domain;
  final Value<String> kind;
  final Value<String> severity;
  final Value<String?> payloadJson;
  final Value<DateTime> timestamp;
  final Value<bool> read;
  const EventsV24Companion({
    this.id = const Value.absent(),
    this.homeId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.domain = const Value.absent(),
    this.kind = const Value.absent(),
    this.severity = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.read = const Value.absent(),
  });
  EventsV24Companion.insert({
    this.id = const Value.absent(),
    required int homeId,
    this.resourceId = const Value.absent(),
    required String domain,
    required String kind,
    this.severity = const Value.absent(),
    this.payloadJson = const Value.absent(),
    required DateTime timestamp,
    this.read = const Value.absent(),
  }) : homeId = Value(homeId),
       domain = Value(domain),
       kind = Value(kind),
       timestamp = Value(timestamp);
  static Insertable<EventEntityV24> custom({
    Expression<int>? id,
    Expression<int>? homeId,
    Expression<int>? resourceId,
    Expression<String>? domain,
    Expression<String>? kind,
    Expression<String>? severity,
    Expression<String>? payloadJson,
    Expression<DateTime>? timestamp,
    Expression<bool>? read,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (homeId != null) 'home_id': homeId,
      if (resourceId != null) 'resource_id': resourceId,
      if (domain != null) 'domain': domain,
      if (kind != null) 'kind': kind,
      if (severity != null) 'severity': severity,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (read != null) 'read': read,
    });
  }

  EventsV24Companion copyWith({
    Value<int>? id,
    Value<int>? homeId,
    Value<int?>? resourceId,
    Value<String>? domain,
    Value<String>? kind,
    Value<String>? severity,
    Value<String?>? payloadJson,
    Value<DateTime>? timestamp,
    Value<bool>? read,
  }) {
    return EventsV24Companion(
      id: id ?? this.id,
      homeId: homeId ?? this.homeId,
      resourceId: resourceId ?? this.resourceId,
      domain: domain ?? this.domain,
      kind: kind ?? this.kind,
      severity: severity ?? this.severity,
      payloadJson: payloadJson ?? this.payloadJson,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (homeId.present) {
      map['home_id'] = Variable<int>(homeId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsV24Companion(')
          ..write('id: $id, ')
          ..write('homeId: $homeId, ')
          ..write('resourceId: $resourceId, ')
          ..write('domain: $domain, ')
          ..write('kind: $kind, ')
          ..write('severity: $severity, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreferenceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _selectedTenantIdMeta = const VerificationMeta(
    'selectedTenantId',
  );
  @override
  late final GeneratedColumn<String> selectedTenantId = GeneratedColumn<String>(
    'selected_tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedHomeIdMeta = const VerificationMeta(
    'selectedHomeId',
  );
  @override
  late final GeneratedColumn<String> selectedHomeId = GeneratedColumn<String>(
    'selected_home_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    selectedTenantId,
    selectedHomeId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferenceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('selected_tenant_id')) {
      context.handle(
        _selectedTenantIdMeta,
        selectedTenantId.isAcceptableOrUnknown(
          data['selected_tenant_id']!,
          _selectedTenantIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_home_id')) {
      context.handle(
        _selectedHomeIdMeta,
        selectedHomeId.isAcceptableOrUnknown(
          data['selected_home_id']!,
          _selectedHomeIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreferenceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferenceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      selectedTenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_tenant_id'],
      ),
      selectedHomeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_home_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreferenceEntity extends DataClass
    implements Insertable<UserPreferenceEntity> {
  final int id;
  final String? selectedTenantId;
  final String? selectedHomeId;
  final DateTime updatedAt;
  const UserPreferenceEntity({
    required this.id,
    this.selectedTenantId,
    this.selectedHomeId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || selectedTenantId != null) {
      map['selected_tenant_id'] = Variable<String>(selectedTenantId);
    }
    if (!nullToAbsent || selectedHomeId != null) {
      map['selected_home_id'] = Variable<String>(selectedHomeId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      selectedTenantId: selectedTenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedTenantId),
      selectedHomeId: selectedHomeId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedHomeId),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreferenceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferenceEntity(
      id: serializer.fromJson<int>(json['id']),
      selectedTenantId: serializer.fromJson<String?>(json['selectedTenantId']),
      selectedHomeId: serializer.fromJson<String?>(json['selectedHomeId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'selectedTenantId': serializer.toJson<String?>(selectedTenantId),
      'selectedHomeId': serializer.toJson<String?>(selectedHomeId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreferenceEntity copyWith({
    int? id,
    Value<String?> selectedTenantId = const Value.absent(),
    Value<String?> selectedHomeId = const Value.absent(),
    DateTime? updatedAt,
  }) => UserPreferenceEntity(
    id: id ?? this.id,
    selectedTenantId: selectedTenantId.present
        ? selectedTenantId.value
        : this.selectedTenantId,
    selectedHomeId: selectedHomeId.present
        ? selectedHomeId.value
        : this.selectedHomeId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPreferenceEntity copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreferenceEntity(
      id: data.id.present ? data.id.value : this.id,
      selectedTenantId: data.selectedTenantId.present
          ? data.selectedTenantId.value
          : this.selectedTenantId,
      selectedHomeId: data.selectedHomeId.present
          ? data.selectedHomeId.value
          : this.selectedHomeId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceEntity(')
          ..write('id: $id, ')
          ..write('selectedTenantId: $selectedTenantId, ')
          ..write('selectedHomeId: $selectedHomeId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, selectedTenantId, selectedHomeId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferenceEntity &&
          other.id == this.id &&
          other.selectedTenantId == this.selectedTenantId &&
          other.selectedHomeId == this.selectedHomeId &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreferenceEntity> {
  final Value<int> id;
  final Value<String?> selectedTenantId;
  final Value<String?> selectedHomeId;
  final Value<DateTime> updatedAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.selectedTenantId = const Value.absent(),
    this.selectedHomeId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.selectedTenantId = const Value.absent(),
    this.selectedHomeId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserPreferenceEntity> custom({
    Expression<int>? id,
    Expression<String>? selectedTenantId,
    Expression<String>? selectedHomeId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (selectedTenantId != null) 'selected_tenant_id': selectedTenantId,
      if (selectedHomeId != null) 'selected_home_id': selectedHomeId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String?>? selectedTenantId,
    Value<String?>? selectedHomeId,
    Value<DateTime>? updatedAt,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      selectedTenantId: selectedTenantId ?? this.selectedTenantId,
      selectedHomeId: selectedHomeId ?? this.selectedHomeId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (selectedTenantId.present) {
      map['selected_tenant_id'] = Variable<String>(selectedTenantId.value);
    }
    if (selectedHomeId.present) {
      map['selected_home_id'] = Variable<String>(selectedHomeId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('selectedTenantId: $selectedTenantId, ')
          ..write('selectedHomeId: $selectedHomeId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingCommandsTable extends PendingCommands
    with TableInfo<$PendingCommandsTable, PendingCommandEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingCommandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _correlationIdMeta = const VerificationMeta(
    'correlationId',
  );
  @override
  late final GeneratedColumn<String> correlationId = GeneratedColumn<String>(
    'correlation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    correlationId,
    resourceId,
    action,
    paramsJson,
    origin,
    status,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_commands';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingCommandEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('correlation_id')) {
      context.handle(
        _correlationIdMeta,
        correlationId.isAcceptableOrUnknown(
          data['correlation_id']!,
          _correlationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correlationIdMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {correlationId};
  @override
  PendingCommandEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingCommandEntity(
      correlationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correlation_id'],
      )!,
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $PendingCommandsTable createAlias(String alias) {
    return $PendingCommandsTable(attachedDatabase, alias);
  }
}

class PendingCommandEntity extends DataClass
    implements Insertable<PendingCommandEntity> {
  final String correlationId;
  final String resourceId;
  final String action;
  final String? paramsJson;
  final String origin;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  const PendingCommandEntity({
    required this.correlationId,
    required this.resourceId,
    required this.action,
    this.paramsJson,
    required this.origin,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['correlation_id'] = Variable<String>(correlationId);
    map['resource_id'] = Variable<String>(resourceId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || paramsJson != null) {
      map['params_json'] = Variable<String>(paramsJson);
    }
    map['origin'] = Variable<String>(origin);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  PendingCommandsCompanion toCompanion(bool nullToAbsent) {
    return PendingCommandsCompanion(
      correlationId: Value(correlationId),
      resourceId: Value(resourceId),
      action: Value(action),
      paramsJson: paramsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(paramsJson),
      origin: Value(origin),
      status: Value(status),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory PendingCommandEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingCommandEntity(
      correlationId: serializer.fromJson<String>(json['correlationId']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      action: serializer.fromJson<String>(json['action']),
      paramsJson: serializer.fromJson<String?>(json['paramsJson']),
      origin: serializer.fromJson<String>(json['origin']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'correlationId': serializer.toJson<String>(correlationId),
      'resourceId': serializer.toJson<String>(resourceId),
      'action': serializer.toJson<String>(action),
      'paramsJson': serializer.toJson<String?>(paramsJson),
      'origin': serializer.toJson<String>(origin),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  PendingCommandEntity copyWith({
    String? correlationId,
    String? resourceId,
    String? action,
    Value<String?> paramsJson = const Value.absent(),
    String? origin,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => PendingCommandEntity(
    correlationId: correlationId ?? this.correlationId,
    resourceId: resourceId ?? this.resourceId,
    action: action ?? this.action,
    paramsJson: paramsJson.present ? paramsJson.value : this.paramsJson,
    origin: origin ?? this.origin,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  PendingCommandEntity copyWithCompanion(PendingCommandsCompanion data) {
    return PendingCommandEntity(
      correlationId: data.correlationId.present
          ? data.correlationId.value
          : this.correlationId,
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      action: data.action.present ? data.action.value : this.action,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      origin: data.origin.present ? data.origin.value : this.origin,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingCommandEntity(')
          ..write('correlationId: $correlationId, ')
          ..write('resourceId: $resourceId, ')
          ..write('action: $action, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('origin: $origin, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    correlationId,
    resourceId,
    action,
    paramsJson,
    origin,
    status,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingCommandEntity &&
          other.correlationId == this.correlationId &&
          other.resourceId == this.resourceId &&
          other.action == this.action &&
          other.paramsJson == this.paramsJson &&
          other.origin == this.origin &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class PendingCommandsCompanion extends UpdateCompanion<PendingCommandEntity> {
  final Value<String> correlationId;
  final Value<String> resourceId;
  final Value<String> action;
  final Value<String?> paramsJson;
  final Value<String> origin;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const PendingCommandsCompanion({
    this.correlationId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.action = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.origin = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingCommandsCompanion.insert({
    required String correlationId,
    required String resourceId,
    required String action,
    this.paramsJson = const Value.absent(),
    required String origin,
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : correlationId = Value(correlationId),
       resourceId = Value(resourceId),
       action = Value(action),
       origin = Value(origin),
       createdAt = Value(createdAt);
  static Insertable<PendingCommandEntity> custom({
    Expression<String>? correlationId,
    Expression<String>? resourceId,
    Expression<String>? action,
    Expression<String>? paramsJson,
    Expression<String>? origin,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (correlationId != null) 'correlation_id': correlationId,
      if (resourceId != null) 'resource_id': resourceId,
      if (action != null) 'action': action,
      if (paramsJson != null) 'params_json': paramsJson,
      if (origin != null) 'origin': origin,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingCommandsCompanion copyWith({
    Value<String>? correlationId,
    Value<String>? resourceId,
    Value<String>? action,
    Value<String?>? paramsJson,
    Value<String>? origin,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return PendingCommandsCompanion(
      correlationId: correlationId ?? this.correlationId,
      resourceId: resourceId ?? this.resourceId,
      action: action ?? this.action,
      paramsJson: paramsJson ?? this.paramsJson,
      origin: origin ?? this.origin,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (correlationId.present) {
      map['correlation_id'] = Variable<String>(correlationId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingCommandsCompanion(')
          ..write('correlationId: $correlationId, ')
          ..write('resourceId: $resourceId, ')
          ..write('action: $action, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('origin: $origin, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TenantsTable tenants = $TenantsTable(this);
  late final $HomesTable homes = $HomesTable(this);
  late final $DevicesV24Table devicesV24 = $DevicesV24Table(this);
  late final $ResourcesV24Table resourcesV24 = $ResourcesV24Table(this);
  late final $ResourceStatesTable resourceStates = $ResourceStatesTable(this);
  late final $ResourceDataTable resourceData = $ResourceDataTable(this);
  late final $ResourceConfigsTable resourceConfigs = $ResourceConfigsTable(
    this,
  );
  late final $ResourceBindingsTable resourceBindings = $ResourceBindingsTable(
    this,
  );
  late final $CommandResultsTable commandResults = $CommandResultsTable(this);
  late final $WaterLevelHistoryTable waterLevelHistory =
      $WaterLevelHistoryTable(this);
  late final $EnvClimateHistoryTable envClimateHistory =
      $EnvClimateHistoryTable(this);
  late final $EventsV24Table eventsV24 = $EventsV24Table(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $PendingCommandsTable pendingCommands = $PendingCommandsTable(
    this,
  );
  late final TenantsHomesDao tenantsHomesDao = TenantsHomesDao(
    this as AppDatabase,
  );
  late final DevicesDao devicesDao = DevicesDao(this as AppDatabase);
  late final ResourcesDao resourcesDao = ResourcesDao(this as AppDatabase);
  late final WaterDao waterDao = WaterDao(this as AppDatabase);
  late final EventsV24Dao eventsV24Dao = EventsV24Dao(this as AppDatabase);
  late final CommandResultsDao commandResultsDao = CommandResultsDao(
    this as AppDatabase,
  );
  late final UserPreferencesDao userPreferencesDao = UserPreferencesDao(
    this as AppDatabase,
  );
  late final PendingCommandsDao pendingCommandsDao = PendingCommandsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tenants,
    homes,
    devicesV24,
    resourcesV24,
    resourceStates,
    resourceData,
    resourceConfigs,
    resourceBindings,
    commandResults,
    waterLevelHistory,
    envClimateHistory,
    eventsV24,
    userPreferences,
    pendingCommands,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tenants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('homes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'homes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('devices_v24', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'homes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resources_v24', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devices_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resources_v24', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resource_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resource_data', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resource_configs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resource_bindings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resource_bindings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('command_results', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('water_level_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('env_climate_history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'homes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('events_v24', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'resources_v24',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('events_v24', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TenantsTableCreateCompanionBuilder =
    TenantsCompanion Function({
      Value<int> id,
      required String tenantId,
      required String name,
      Value<String?> email,
      Value<DateTime> createdAt,
    });
typedef $$TenantsTableUpdateCompanionBuilder =
    TenantsCompanion Function({
      Value<int> id,
      Value<String> tenantId,
      Value<String> name,
      Value<String?> email,
      Value<DateTime> createdAt,
    });

final class $$TenantsTableReferences
    extends BaseReferences<_$AppDatabase, $TenantsTable, TenantEntity> {
  $$TenantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HomesTable, List<HomeEntity>> _homesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.homes,
    aliasName: $_aliasNameGenerator(db.tenants.id, db.homes.tenantId),
  );

  $$HomesTableProcessedTableManager get homesRefs {
    final manager = $$HomesTableTableManager(
      $_db,
      $_db.homes,
    ).filter((f) => f.tenantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_homesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TenantsTableFilterComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> homesRefs(
    Expression<bool> Function($$HomesTableFilterComposer f) f,
  ) {
    final $$HomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.tenantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableFilterComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableOrderingComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TenantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> homesRefs<T extends Object>(
    Expression<T> Function($$HomesTableAnnotationComposer a) f,
  ) {
    final $$HomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.tenantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableAnnotationComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenantsTable,
          TenantEntity,
          $$TenantsTableFilterComposer,
          $$TenantsTableOrderingComposer,
          $$TenantsTableAnnotationComposer,
          $$TenantsTableCreateCompanionBuilder,
          $$TenantsTableUpdateCompanionBuilder,
          (TenantEntity, $$TenantsTableReferences),
          TenantEntity,
          PrefetchHooks Function({bool homesRefs})
        > {
  $$TenantsTableTableManager(_$AppDatabase db, $TenantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TenantsCompanion(
                id: id,
                tenantId: tenantId,
                name: name,
                email: email,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tenantId,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TenantsCompanion.insert(
                id: id,
                tenantId: tenantId,
                name: name,
                email: email,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TenantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({homesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (homesRefs) db.homes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (homesRefs)
                    await $_getPrefetchedData<
                      TenantEntity,
                      $TenantsTable,
                      HomeEntity
                    >(
                      currentTable: table,
                      referencedTable: $$TenantsTableReferences._homesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TenantsTableReferences(db, table, p0).homesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tenantId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TenantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenantsTable,
      TenantEntity,
      $$TenantsTableFilterComposer,
      $$TenantsTableOrderingComposer,
      $$TenantsTableAnnotationComposer,
      $$TenantsTableCreateCompanionBuilder,
      $$TenantsTableUpdateCompanionBuilder,
      (TenantEntity, $$TenantsTableReferences),
      TenantEntity,
      PrefetchHooks Function({bool homesRefs})
    >;
typedef $$HomesTableCreateCompanionBuilder =
    HomesCompanion Function({
      Value<int> id,
      required int tenantId,
      required String homeId,
      required String label,
      Value<DateTime> createdAt,
    });
typedef $$HomesTableUpdateCompanionBuilder =
    HomesCompanion Function({
      Value<int> id,
      Value<int> tenantId,
      Value<String> homeId,
      Value<String> label,
      Value<DateTime> createdAt,
    });

final class $$HomesTableReferences
    extends BaseReferences<_$AppDatabase, $HomesTable, HomeEntity> {
  $$HomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) => db.tenants
      .createAlias($_aliasNameGenerator(db.homes.tenantId, db.tenants.id));

  $$TenantsTableProcessedTableManager get tenantId {
    final $_column = $_itemColumn<int>('tenant_id')!;

    final manager = $$TenantsTableTableManager(
      $_db,
      $_db.tenants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DevicesV24Table, List<DeviceEntity>>
  _devicesV24RefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.devicesV24,
    aliasName: $_aliasNameGenerator(db.homes.id, db.devicesV24.homeId),
  );

  $$DevicesV24TableProcessedTableManager get devicesV24Refs {
    final manager = $$DevicesV24TableTableManager(
      $_db,
      $_db.devicesV24,
    ).filter((f) => f.homeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicesV24RefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResourcesV24Table, List<ResourceEntity>>
  _resourcesV24RefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourcesV24,
    aliasName: $_aliasNameGenerator(db.homes.id, db.resourcesV24.homeId),
  );

  $$ResourcesV24TableProcessedTableManager get resourcesV24Refs {
    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.homeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourcesV24RefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsV24Table, List<EventEntityV24>>
  _eventsV24RefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventsV24,
    aliasName: $_aliasNameGenerator(db.homes.id, db.eventsV24.homeId),
  );

  $$EventsV24TableProcessedTableManager get eventsV24Refs {
    final manager = $$EventsV24TableTableManager(
      $_db,
      $_db.eventsV24,
    ).filter((f) => f.homeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsV24RefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HomesTableFilterComposer extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> devicesV24Refs(
    Expression<bool> Function($$DevicesV24TableFilterComposer f) f,
  ) {
    final $$DevicesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devicesV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesV24TableFilterComposer(
            $db: $db,
            $table: $db.devicesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resourcesV24Refs(
    Expression<bool> Function($$ResourcesV24TableFilterComposer f) f,
  ) {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsV24Refs(
    Expression<bool> Function($$EventsV24TableFilterComposer f) f,
  ) {
    final $$EventsV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventsV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsV24TableFilterComposer(
            $db: $db,
            $table: $db.eventsV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HomesTableOrderingComposer
    extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeId => $composableBuilder(
    column: $table.homeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomesTable> {
  $$HomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get homeId =>
      $composableBuilder(column: $table.homeId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantId,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> devicesV24Refs<T extends Object>(
    Expression<T> Function($$DevicesV24TableAnnotationComposer a) f,
  ) {
    final $$DevicesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devicesV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.devicesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resourcesV24Refs<T extends Object>(
    Expression<T> Function($$ResourcesV24TableAnnotationComposer a) f,
  ) {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventsV24Refs<T extends Object>(
    Expression<T> Function($$EventsV24TableAnnotationComposer a) f,
  ) {
    final $$EventsV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventsV24,
      getReferencedColumn: (t) => t.homeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsV24TableAnnotationComposer(
            $db: $db,
            $table: $db.eventsV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HomesTable,
          HomeEntity,
          $$HomesTableFilterComposer,
          $$HomesTableOrderingComposer,
          $$HomesTableAnnotationComposer,
          $$HomesTableCreateCompanionBuilder,
          $$HomesTableUpdateCompanionBuilder,
          (HomeEntity, $$HomesTableReferences),
          HomeEntity,
          PrefetchHooks Function({
            bool tenantId,
            bool devicesV24Refs,
            bool resourcesV24Refs,
            bool eventsV24Refs,
          })
        > {
  $$HomesTableTableManager(_$AppDatabase db, $HomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tenantId = const Value.absent(),
                Value<String> homeId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HomesCompanion(
                id: id,
                tenantId: tenantId,
                homeId: homeId,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tenantId,
                required String homeId,
                required String label,
                Value<DateTime> createdAt = const Value.absent(),
              }) => HomesCompanion.insert(
                id: id,
                tenantId: tenantId,
                homeId: homeId,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HomesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tenantId = false,
                devicesV24Refs = false,
                resourcesV24Refs = false,
                eventsV24Refs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (devicesV24Refs) db.devicesV24,
                    if (resourcesV24Refs) db.resourcesV24,
                    if (eventsV24Refs) db.eventsV24,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tenantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tenantId,
                                    referencedTable: $$HomesTableReferences
                                        ._tenantIdTable(db),
                                    referencedColumn: $$HomesTableReferences
                                        ._tenantIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (devicesV24Refs)
                        await $_getPrefetchedData<
                          HomeEntity,
                          $HomesTable,
                          DeviceEntity
                        >(
                          currentTable: table,
                          referencedTable: $$HomesTableReferences
                              ._devicesV24RefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HomesTableReferences(
                                db,
                                table,
                                p0,
                              ).devicesV24Refs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resourcesV24Refs)
                        await $_getPrefetchedData<
                          HomeEntity,
                          $HomesTable,
                          ResourceEntity
                        >(
                          currentTable: table,
                          referencedTable: $$HomesTableReferences
                              ._resourcesV24RefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HomesTableReferences(
                                db,
                                table,
                                p0,
                              ).resourcesV24Refs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsV24Refs)
                        await $_getPrefetchedData<
                          HomeEntity,
                          $HomesTable,
                          EventEntityV24
                        >(
                          currentTable: table,
                          referencedTable: $$HomesTableReferences
                              ._eventsV24RefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HomesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventsV24Refs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.homeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HomesTable,
      HomeEntity,
      $$HomesTableFilterComposer,
      $$HomesTableOrderingComposer,
      $$HomesTableAnnotationComposer,
      $$HomesTableCreateCompanionBuilder,
      $$HomesTableUpdateCompanionBuilder,
      (HomeEntity, $$HomesTableReferences),
      HomeEntity,
      PrefetchHooks Function({
        bool tenantId,
        bool devicesV24Refs,
        bool resourcesV24Refs,
        bool eventsV24Refs,
      })
    >;
typedef $$DevicesV24TableCreateCompanionBuilder =
    DevicesV24Companion Function({
      Value<int> id,
      required int homeId,
      required String deviceId,
      required String role,
      Value<String> status,
      Value<DateTime?> lastSeen,
      Value<String?> firmwareVersion,
      Value<String?> contractVersion,
      Value<int?> uptime,
      Value<String?> hardwareRevision,
      Value<String?> ipAddress,
      Value<String?> vendor,
      Value<String?> model,
      Value<String?> mac,
      Value<String?> serial,
      Value<int?> rssi,
    });
typedef $$DevicesV24TableUpdateCompanionBuilder =
    DevicesV24Companion Function({
      Value<int> id,
      Value<int> homeId,
      Value<String> deviceId,
      Value<String> role,
      Value<String> status,
      Value<DateTime?> lastSeen,
      Value<String?> firmwareVersion,
      Value<String?> contractVersion,
      Value<int?> uptime,
      Value<String?> hardwareRevision,
      Value<String?> ipAddress,
      Value<String?> vendor,
      Value<String?> model,
      Value<String?> mac,
      Value<String?> serial,
      Value<int?> rssi,
    });

final class $$DevicesV24TableReferences
    extends BaseReferences<_$AppDatabase, $DevicesV24Table, DeviceEntity> {
  $$DevicesV24TableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HomesTable _homeIdTable(_$AppDatabase db) => db.homes.createAlias(
    $_aliasNameGenerator(db.devicesV24.homeId, db.homes.id),
  );

  $$HomesTableProcessedTableManager get homeId {
    final $_column = $_itemColumn<int>('home_id')!;

    final manager = $$HomesTableTableManager(
      $_db,
      $_db.homes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ResourcesV24Table, List<ResourceEntity>>
  _resourcesV24RefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourcesV24,
    aliasName: $_aliasNameGenerator(db.devicesV24.id, db.resourcesV24.deviceId),
  );

  $$ResourcesV24TableProcessedTableManager get resourcesV24Refs {
    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourcesV24RefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesV24TableFilterComposer
    extends Composer<_$AppDatabase, $DevicesV24Table> {
  $$DevicesV24TableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uptime => $composableBuilder(
    column: $table.uptime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hardwareRevision => $composableBuilder(
    column: $table.hardwareRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendor => $composableBuilder(
    column: $table.vendor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnFilters(column),
  );

  $$HomesTableFilterComposer get homeId {
    final $$HomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableFilterComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> resourcesV24Refs(
    Expression<bool> Function($$ResourcesV24TableFilterComposer f) f,
  ) {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesV24TableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesV24Table> {
  $$DevicesV24TableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uptime => $composableBuilder(
    column: $table.uptime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hardwareRevision => $composableBuilder(
    column: $table.hardwareRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendor => $composableBuilder(
    column: $table.vendor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnOrderings(column),
  );

  $$HomesTableOrderingComposer get homeId {
    final $$HomesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableOrderingComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevicesV24TableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesV24Table> {
  $$DevicesV24TableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uptime =>
      $composableBuilder(column: $table.uptime, builder: (column) => column);

  GeneratedColumn<String> get hardwareRevision => $composableBuilder(
    column: $table.hardwareRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get vendor =>
      $composableBuilder(column: $table.vendor, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get mac =>
      $composableBuilder(column: $table.mac, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<int> get rssi =>
      $composableBuilder(column: $table.rssi, builder: (column) => column);

  $$HomesTableAnnotationComposer get homeId {
    final $$HomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableAnnotationComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> resourcesV24Refs<T extends Object>(
    Expression<T> Function($$ResourcesV24TableAnnotationComposer a) f,
  ) {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesV24TableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesV24Table,
          DeviceEntity,
          $$DevicesV24TableFilterComposer,
          $$DevicesV24TableOrderingComposer,
          $$DevicesV24TableAnnotationComposer,
          $$DevicesV24TableCreateCompanionBuilder,
          $$DevicesV24TableUpdateCompanionBuilder,
          (DeviceEntity, $$DevicesV24TableReferences),
          DeviceEntity,
          PrefetchHooks Function({bool homeId, bool resourcesV24Refs})
        > {
  $$DevicesV24TableTableManager(_$AppDatabase db, $DevicesV24Table table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesV24TableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesV24TableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesV24TableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> homeId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<String?> contractVersion = const Value.absent(),
                Value<int?> uptime = const Value.absent(),
                Value<String?> hardwareRevision = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
                Value<String?> vendor = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> mac = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
              }) => DevicesV24Companion(
                id: id,
                homeId: homeId,
                deviceId: deviceId,
                role: role,
                status: status,
                lastSeen: lastSeen,
                firmwareVersion: firmwareVersion,
                contractVersion: contractVersion,
                uptime: uptime,
                hardwareRevision: hardwareRevision,
                ipAddress: ipAddress,
                vendor: vendor,
                model: model,
                mac: mac,
                serial: serial,
                rssi: rssi,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int homeId,
                required String deviceId,
                required String role,
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<String?> contractVersion = const Value.absent(),
                Value<int?> uptime = const Value.absent(),
                Value<String?> hardwareRevision = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
                Value<String?> vendor = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> mac = const Value.absent(),
                Value<String?> serial = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
              }) => DevicesV24Companion.insert(
                id: id,
                homeId: homeId,
                deviceId: deviceId,
                role: role,
                status: status,
                lastSeen: lastSeen,
                firmwareVersion: firmwareVersion,
                contractVersion: contractVersion,
                uptime: uptime,
                hardwareRevision: hardwareRevision,
                ipAddress: ipAddress,
                vendor: vendor,
                model: model,
                mac: mac,
                serial: serial,
                rssi: rssi,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevicesV24TableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({homeId = false, resourcesV24Refs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (resourcesV24Refs) db.resourcesV24],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (homeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.homeId,
                                referencedTable: $$DevicesV24TableReferences
                                    ._homeIdTable(db),
                                referencedColumn: $$DevicesV24TableReferences
                                    ._homeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (resourcesV24Refs)
                    await $_getPrefetchedData<
                      DeviceEntity,
                      $DevicesV24Table,
                      ResourceEntity
                    >(
                      currentTable: table,
                      referencedTable: $$DevicesV24TableReferences
                          ._resourcesV24RefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DevicesV24TableReferences(
                            db,
                            table,
                            p0,
                          ).resourcesV24Refs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deviceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DevicesV24TableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesV24Table,
      DeviceEntity,
      $$DevicesV24TableFilterComposer,
      $$DevicesV24TableOrderingComposer,
      $$DevicesV24TableAnnotationComposer,
      $$DevicesV24TableCreateCompanionBuilder,
      $$DevicesV24TableUpdateCompanionBuilder,
      (DeviceEntity, $$DevicesV24TableReferences),
      DeviceEntity,
      PrefetchHooks Function({bool homeId, bool resourcesV24Refs})
    >;
typedef $$ResourcesV24TableCreateCompanionBuilder =
    ResourcesV24Companion Function({
      Value<int> id,
      required int homeId,
      required int deviceId,
      required String resourceId,
      required String domain,
      required String kind,
      required String name,
      Value<String?> label,
      Value<String?> room,
      required String capabilityType,
      Value<String?> metadataJson,
      Value<DateTime> updatedAt,
    });
typedef $$ResourcesV24TableUpdateCompanionBuilder =
    ResourcesV24Companion Function({
      Value<int> id,
      Value<int> homeId,
      Value<int> deviceId,
      Value<String> resourceId,
      Value<String> domain,
      Value<String> kind,
      Value<String> name,
      Value<String?> label,
      Value<String?> room,
      Value<String> capabilityType,
      Value<String?> metadataJson,
      Value<DateTime> updatedAt,
    });

final class $$ResourcesV24TableReferences
    extends BaseReferences<_$AppDatabase, $ResourcesV24Table, ResourceEntity> {
  $$ResourcesV24TableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HomesTable _homeIdTable(_$AppDatabase db) => db.homes.createAlias(
    $_aliasNameGenerator(db.resourcesV24.homeId, db.homes.id),
  );

  $$HomesTableProcessedTableManager get homeId {
    final $_column = $_itemColumn<int>('home_id')!;

    final manager = $$HomesTableTableManager(
      $_db,
      $_db.homes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DevicesV24Table _deviceIdTable(_$AppDatabase db) =>
      db.devicesV24.createAlias(
        $_aliasNameGenerator(db.resourcesV24.deviceId, db.devicesV24.id),
      );

  $$DevicesV24TableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesV24TableTableManager(
      $_db,
      $_db.devicesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ResourceStatesTable, List<ResourceStateEntity>>
  _resourceStatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourceStates,
    aliasName: $_aliasNameGenerator(
      db.resourcesV24.id,
      db.resourceStates.resourceId,
    ),
  );

  $$ResourceStatesTableProcessedTableManager get resourceStatesRefs {
    final manager = $$ResourceStatesTableTableManager(
      $_db,
      $_db.resourceStates,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourceStatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResourceDataTable, List<ResourceDataEntity>>
  _resourceDataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourceData,
    aliasName: $_aliasNameGenerator(
      db.resourcesV24.id,
      db.resourceData.resourceId,
    ),
  );

  $$ResourceDataTableProcessedTableManager get resourceDataRefs {
    final manager = $$ResourceDataTableTableManager(
      $_db,
      $_db.resourceData,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_resourceDataRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResourceConfigsTable, List<ResourceConfigEntity>>
  _resourceConfigsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.resourceConfigs,
    aliasName: $_aliasNameGenerator(
      db.resourcesV24.id,
      db.resourceConfigs.resourceId,
    ),
  );

  $$ResourceConfigsTableProcessedTableManager get resourceConfigsRefs {
    final manager = $$ResourceConfigsTableTableManager(
      $_db,
      $_db.resourceConfigs,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resourceConfigsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ResourceBindingsTable,
    List<ResourceBindingEntity>
  >
  _sourceResourceBindingsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resourceBindings,
        aliasName: $_aliasNameGenerator(
          db.resourcesV24.id,
          db.resourceBindings.resourceId,
        ),
      );

  $$ResourceBindingsTableProcessedTableManager get sourceResourceBindings {
    final manager = $$ResourceBindingsTableTableManager(
      $_db,
      $_db.resourceBindings,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sourceResourceBindingsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ResourceBindingsTable,
    List<ResourceBindingEntity>
  >
  _targetResourceBindingsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resourceBindings,
        aliasName: $_aliasNameGenerator(
          db.resourcesV24.id,
          db.resourceBindings.targetResourceId,
        ),
      );

  $$ResourceBindingsTableProcessedTableManager get targetResourceBindings {
    final manager = $$ResourceBindingsTableTableManager(
      $_db,
      $_db.resourceBindings,
    ).filter((f) => f.targetResourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _targetResourceBindingsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CommandResultsTable, List<CommandResultEntity>>
  _commandResultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.commandResults,
    aliasName: $_aliasNameGenerator(
      db.resourcesV24.id,
      db.commandResults.resourceId,
    ),
  );

  $$CommandResultsTableProcessedTableManager get commandResultsRefs {
    final manager = $$CommandResultsTableTableManager(
      $_db,
      $_db.commandResults,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_commandResultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WaterLevelHistoryTable,
    List<WaterLevelHistoryEntity>
  >
  _waterLevelHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.waterLevelHistory,
        aliasName: $_aliasNameGenerator(
          db.resourcesV24.id,
          db.waterLevelHistory.resourceId,
        ),
      );

  $$WaterLevelHistoryTableProcessedTableManager get waterLevelHistoryRefs {
    final manager = $$WaterLevelHistoryTableTableManager(
      $_db,
      $_db.waterLevelHistory,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _waterLevelHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EnvClimateHistoryTable,
    List<EnvClimateHistoryEntity>
  >
  _envClimateHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.envClimateHistory,
        aliasName: $_aliasNameGenerator(
          db.resourcesV24.id,
          db.envClimateHistory.resourceId,
        ),
      );

  $$EnvClimateHistoryTableProcessedTableManager get envClimateHistoryRefs {
    final manager = $$EnvClimateHistoryTableTableManager(
      $_db,
      $_db.envClimateHistory,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _envClimateHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsV24Table, List<EventEntityV24>>
  _eventsV24RefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventsV24,
    aliasName: $_aliasNameGenerator(
      db.resourcesV24.id,
      db.eventsV24.resourceId,
    ),
  );

  $$EventsV24TableProcessedTableManager get eventsV24Refs {
    final manager = $$EventsV24TableTableManager(
      $_db,
      $_db.eventsV24,
    ).filter((f) => f.resourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsV24RefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ResourcesV24TableFilterComposer
    extends Composer<_$AppDatabase, $ResourcesV24Table> {
  $$ResourcesV24TableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilityType => $composableBuilder(
    column: $table.capabilityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HomesTableFilterComposer get homeId {
    final $$HomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableFilterComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevicesV24TableFilterComposer get deviceId {
    final $$DevicesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesV24TableFilterComposer(
            $db: $db,
            $table: $db.devicesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> resourceStatesRefs(
    Expression<bool> Function($$ResourceStatesTableFilterComposer f) f,
  ) {
    final $$ResourceStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceStates,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceStatesTableFilterComposer(
            $db: $db,
            $table: $db.resourceStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resourceDataRefs(
    Expression<bool> Function($$ResourceDataTableFilterComposer f) f,
  ) {
    final $$ResourceDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceData,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceDataTableFilterComposer(
            $db: $db,
            $table: $db.resourceData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resourceConfigsRefs(
    Expression<bool> Function($$ResourceConfigsTableFilterComposer f) f,
  ) {
    final $$ResourceConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceConfigs,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceConfigsTableFilterComposer(
            $db: $db,
            $table: $db.resourceConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sourceResourceBindings(
    Expression<bool> Function($$ResourceBindingsTableFilterComposer f) f,
  ) {
    final $$ResourceBindingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceBindings,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceBindingsTableFilterComposer(
            $db: $db,
            $table: $db.resourceBindings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetResourceBindings(
    Expression<bool> Function($$ResourceBindingsTableFilterComposer f) f,
  ) {
    final $$ResourceBindingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceBindings,
      getReferencedColumn: (t) => t.targetResourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceBindingsTableFilterComposer(
            $db: $db,
            $table: $db.resourceBindings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> commandResultsRefs(
    Expression<bool> Function($$CommandResultsTableFilterComposer f) f,
  ) {
    final $$CommandResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commandResults,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommandResultsTableFilterComposer(
            $db: $db,
            $table: $db.commandResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> waterLevelHistoryRefs(
    Expression<bool> Function($$WaterLevelHistoryTableFilterComposer f) f,
  ) {
    final $$WaterLevelHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.waterLevelHistory,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaterLevelHistoryTableFilterComposer(
            $db: $db,
            $table: $db.waterLevelHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> envClimateHistoryRefs(
    Expression<bool> Function($$EnvClimateHistoryTableFilterComposer f) f,
  ) {
    final $$EnvClimateHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envClimateHistory,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvClimateHistoryTableFilterComposer(
            $db: $db,
            $table: $db.envClimateHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsV24Refs(
    Expression<bool> Function($$EventsV24TableFilterComposer f) f,
  ) {
    final $$EventsV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventsV24,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsV24TableFilterComposer(
            $db: $db,
            $table: $db.eventsV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ResourcesV24TableOrderingComposer
    extends Composer<_$AppDatabase, $ResourcesV24Table> {
  $$ResourcesV24TableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilityType => $composableBuilder(
    column: $table.capabilityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HomesTableOrderingComposer get homeId {
    final $$HomesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableOrderingComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevicesV24TableOrderingComposer get deviceId {
    final $$DevicesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesV24TableOrderingComposer(
            $db: $db,
            $table: $db.devicesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourcesV24TableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourcesV24Table> {
  $$ResourcesV24TableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<String> get capabilityType => $composableBuilder(
    column: $table.capabilityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$HomesTableAnnotationComposer get homeId {
    final $$HomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableAnnotationComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevicesV24TableAnnotationComposer get deviceId {
    final $$DevicesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.devicesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> resourceStatesRefs<T extends Object>(
    Expression<T> Function($$ResourceStatesTableAnnotationComposer a) f,
  ) {
    final $$ResourceStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceStates,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resourceDataRefs<T extends Object>(
    Expression<T> Function($$ResourceDataTableAnnotationComposer a) f,
  ) {
    final $$ResourceDataTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceData,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceDataTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resourceConfigsRefs<T extends Object>(
    Expression<T> Function($$ResourceConfigsTableAnnotationComposer a) f,
  ) {
    final $$ResourceConfigsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceConfigs,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceConfigsTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sourceResourceBindings<T extends Object>(
    Expression<T> Function($$ResourceBindingsTableAnnotationComposer a) f,
  ) {
    final $$ResourceBindingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceBindings,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceBindingsTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceBindings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetResourceBindings<T extends Object>(
    Expression<T> Function($$ResourceBindingsTableAnnotationComposer a) f,
  ) {
    final $$ResourceBindingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resourceBindings,
      getReferencedColumn: (t) => t.targetResourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourceBindingsTableAnnotationComposer(
            $db: $db,
            $table: $db.resourceBindings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> commandResultsRefs<T extends Object>(
    Expression<T> Function($$CommandResultsTableAnnotationComposer a) f,
  ) {
    final $$CommandResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commandResults,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommandResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.commandResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> waterLevelHistoryRefs<T extends Object>(
    Expression<T> Function($$WaterLevelHistoryTableAnnotationComposer a) f,
  ) {
    final $$WaterLevelHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.waterLevelHistory,
          getReferencedColumn: (t) => t.resourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WaterLevelHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.waterLevelHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> envClimateHistoryRefs<T extends Object>(
    Expression<T> Function($$EnvClimateHistoryTableAnnotationComposer a) f,
  ) {
    final $$EnvClimateHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.envClimateHistory,
          getReferencedColumn: (t) => t.resourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvClimateHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.envClimateHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> eventsV24Refs<T extends Object>(
    Expression<T> Function($$EventsV24TableAnnotationComposer a) f,
  ) {
    final $$EventsV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventsV24,
      getReferencedColumn: (t) => t.resourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsV24TableAnnotationComposer(
            $db: $db,
            $table: $db.eventsV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ResourcesV24TableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourcesV24Table,
          ResourceEntity,
          $$ResourcesV24TableFilterComposer,
          $$ResourcesV24TableOrderingComposer,
          $$ResourcesV24TableAnnotationComposer,
          $$ResourcesV24TableCreateCompanionBuilder,
          $$ResourcesV24TableUpdateCompanionBuilder,
          (ResourceEntity, $$ResourcesV24TableReferences),
          ResourceEntity,
          PrefetchHooks Function({
            bool homeId,
            bool deviceId,
            bool resourceStatesRefs,
            bool resourceDataRefs,
            bool resourceConfigsRefs,
            bool sourceResourceBindings,
            bool targetResourceBindings,
            bool commandResultsRefs,
            bool waterLevelHistoryRefs,
            bool envClimateHistoryRefs,
            bool eventsV24Refs,
          })
        > {
  $$ResourcesV24TableTableManager(_$AppDatabase db, $ResourcesV24Table table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourcesV24TableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourcesV24TableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourcesV24TableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> homeId = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<String> capabilityType = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ResourcesV24Companion(
                id: id,
                homeId: homeId,
                deviceId: deviceId,
                resourceId: resourceId,
                domain: domain,
                kind: kind,
                name: name,
                label: label,
                room: room,
                capabilityType: capabilityType,
                metadataJson: metadataJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int homeId,
                required int deviceId,
                required String resourceId,
                required String domain,
                required String kind,
                required String name,
                Value<String?> label = const Value.absent(),
                Value<String?> room = const Value.absent(),
                required String capabilityType,
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ResourcesV24Companion.insert(
                id: id,
                homeId: homeId,
                deviceId: deviceId,
                resourceId: resourceId,
                domain: domain,
                kind: kind,
                name: name,
                label: label,
                room: room,
                capabilityType: capabilityType,
                metadataJson: metadataJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourcesV24TableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                homeId = false,
                deviceId = false,
                resourceStatesRefs = false,
                resourceDataRefs = false,
                resourceConfigsRefs = false,
                sourceResourceBindings = false,
                targetResourceBindings = false,
                commandResultsRefs = false,
                waterLevelHistoryRefs = false,
                envClimateHistoryRefs = false,
                eventsV24Refs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (resourceStatesRefs) db.resourceStates,
                    if (resourceDataRefs) db.resourceData,
                    if (resourceConfigsRefs) db.resourceConfigs,
                    if (sourceResourceBindings) db.resourceBindings,
                    if (targetResourceBindings) db.resourceBindings,
                    if (commandResultsRefs) db.commandResults,
                    if (waterLevelHistoryRefs) db.waterLevelHistory,
                    if (envClimateHistoryRefs) db.envClimateHistory,
                    if (eventsV24Refs) db.eventsV24,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (homeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.homeId,
                                    referencedTable:
                                        $$ResourcesV24TableReferences
                                            ._homeIdTable(db),
                                    referencedColumn:
                                        $$ResourcesV24TableReferences
                                            ._homeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (deviceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deviceId,
                                    referencedTable:
                                        $$ResourcesV24TableReferences
                                            ._deviceIdTable(db),
                                    referencedColumn:
                                        $$ResourcesV24TableReferences
                                            ._deviceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (resourceStatesRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          ResourceStateEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._resourceStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).resourceStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resourceDataRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          ResourceDataEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._resourceDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).resourceDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resourceConfigsRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          ResourceConfigEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._resourceConfigsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).resourceConfigsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sourceResourceBindings)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          ResourceBindingEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._sourceResourceBindingsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).sourceResourceBindings,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (targetResourceBindings)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          ResourceBindingEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._targetResourceBindingsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).targetResourceBindings,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetResourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (commandResultsRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          CommandResultEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._commandResultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).commandResultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (waterLevelHistoryRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          WaterLevelHistoryEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._waterLevelHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).waterLevelHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (envClimateHistoryRefs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          EnvClimateHistoryEntity
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._envClimateHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).envClimateHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsV24Refs)
                        await $_getPrefetchedData<
                          ResourceEntity,
                          $ResourcesV24Table,
                          EventEntityV24
                        >(
                          currentTable: table,
                          referencedTable: $$ResourcesV24TableReferences
                              ._eventsV24RefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ResourcesV24TableReferences(
                                db,
                                table,
                                p0,
                              ).eventsV24Refs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.resourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ResourcesV24TableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourcesV24Table,
      ResourceEntity,
      $$ResourcesV24TableFilterComposer,
      $$ResourcesV24TableOrderingComposer,
      $$ResourcesV24TableAnnotationComposer,
      $$ResourcesV24TableCreateCompanionBuilder,
      $$ResourcesV24TableUpdateCompanionBuilder,
      (ResourceEntity, $$ResourcesV24TableReferences),
      ResourceEntity,
      PrefetchHooks Function({
        bool homeId,
        bool deviceId,
        bool resourceStatesRefs,
        bool resourceDataRefs,
        bool resourceConfigsRefs,
        bool sourceResourceBindings,
        bool targetResourceBindings,
        bool commandResultsRefs,
        bool waterLevelHistoryRefs,
        bool envClimateHistoryRefs,
        bool eventsV24Refs,
      })
    >;
typedef $$ResourceStatesTableCreateCompanionBuilder =
    ResourceStatesCompanion Function({
      Value<int> id,
      required int resourceId,
      required String stateJson,
      required DateTime updatedAt,
    });
typedef $$ResourceStatesTableUpdateCompanionBuilder =
    ResourceStatesCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<String> stateJson,
      Value<DateTime> updatedAt,
    });

final class $$ResourceStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResourceStatesTable,
          ResourceStateEntity
        > {
  $$ResourceStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(db.resourceStates.resourceId, db.resourcesV24.id),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResourceStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceStatesTable> {
  $$ResourceStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceStatesTable> {
  $$ResourceStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceStatesTable> {
  $$ResourceStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceStatesTable,
          ResourceStateEntity,
          $$ResourceStatesTableFilterComposer,
          $$ResourceStatesTableOrderingComposer,
          $$ResourceStatesTableAnnotationComposer,
          $$ResourceStatesTableCreateCompanionBuilder,
          $$ResourceStatesTableUpdateCompanionBuilder,
          (ResourceStateEntity, $$ResourceStatesTableReferences),
          ResourceStateEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$ResourceStatesTableTableManager(
    _$AppDatabase db,
    $ResourceStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ResourceStatesCompanion(
                id: id,
                resourceId: resourceId,
                stateJson: stateJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required String stateJson,
                required DateTime updatedAt,
              }) => ResourceStatesCompanion.insert(
                id: id,
                resourceId: resourceId,
                stateJson: stateJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourceStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable: $$ResourceStatesTableReferences
                                    ._resourceIdTable(db),
                                referencedColumn:
                                    $$ResourceStatesTableReferences
                                        ._resourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResourceStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceStatesTable,
      ResourceStateEntity,
      $$ResourceStatesTableFilterComposer,
      $$ResourceStatesTableOrderingComposer,
      $$ResourceStatesTableAnnotationComposer,
      $$ResourceStatesTableCreateCompanionBuilder,
      $$ResourceStatesTableUpdateCompanionBuilder,
      (ResourceStateEntity, $$ResourceStatesTableReferences),
      ResourceStateEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$ResourceDataTableCreateCompanionBuilder =
    ResourceDataCompanion Function({
      Value<int> id,
      required int resourceId,
      required String dataJson,
      required DateTime updatedAt,
    });
typedef $$ResourceDataTableUpdateCompanionBuilder =
    ResourceDataCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<String> dataJson,
      Value<DateTime> updatedAt,
    });

final class $$ResourceDataTableReferences
    extends
        BaseReferences<_$AppDatabase, $ResourceDataTable, ResourceDataEntity> {
  $$ResourceDataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(db.resourceData.resourceId, db.resourcesV24.id),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResourceDataTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceDataTable> {
  $$ResourceDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceDataTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceDataTable> {
  $$ResourceDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceDataTable> {
  $$ResourceDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceDataTable,
          ResourceDataEntity,
          $$ResourceDataTableFilterComposer,
          $$ResourceDataTableOrderingComposer,
          $$ResourceDataTableAnnotationComposer,
          $$ResourceDataTableCreateCompanionBuilder,
          $$ResourceDataTableUpdateCompanionBuilder,
          (ResourceDataEntity, $$ResourceDataTableReferences),
          ResourceDataEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$ResourceDataTableTableManager(_$AppDatabase db, $ResourceDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ResourceDataCompanion(
                id: id,
                resourceId: resourceId,
                dataJson: dataJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required String dataJson,
                required DateTime updatedAt,
              }) => ResourceDataCompanion.insert(
                id: id,
                resourceId: resourceId,
                dataJson: dataJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourceDataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable: $$ResourceDataTableReferences
                                    ._resourceIdTable(db),
                                referencedColumn: $$ResourceDataTableReferences
                                    ._resourceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResourceDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceDataTable,
      ResourceDataEntity,
      $$ResourceDataTableFilterComposer,
      $$ResourceDataTableOrderingComposer,
      $$ResourceDataTableAnnotationComposer,
      $$ResourceDataTableCreateCompanionBuilder,
      $$ResourceDataTableUpdateCompanionBuilder,
      (ResourceDataEntity, $$ResourceDataTableReferences),
      ResourceDataEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$ResourceConfigsTableCreateCompanionBuilder =
    ResourceConfigsCompanion Function({
      Value<int> id,
      required int resourceId,
      required String configJson,
      required DateTime updatedAt,
    });
typedef $$ResourceConfigsTableUpdateCompanionBuilder =
    ResourceConfigsCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<String> configJson,
      Value<DateTime> updatedAt,
    });

final class $$ResourceConfigsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResourceConfigsTable,
          ResourceConfigEntity
        > {
  $$ResourceConfigsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(db.resourceConfigs.resourceId, db.resourcesV24.id),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResourceConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceConfigsTable> {
  $$ResourceConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceConfigsTable> {
  $$ResourceConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceConfigsTable> {
  $$ResourceConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceConfigsTable,
          ResourceConfigEntity,
          $$ResourceConfigsTableFilterComposer,
          $$ResourceConfigsTableOrderingComposer,
          $$ResourceConfigsTableAnnotationComposer,
          $$ResourceConfigsTableCreateCompanionBuilder,
          $$ResourceConfigsTableUpdateCompanionBuilder,
          (ResourceConfigEntity, $$ResourceConfigsTableReferences),
          ResourceConfigEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$ResourceConfigsTableTableManager(
    _$AppDatabase db,
    $ResourceConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ResourceConfigsCompanion(
                id: id,
                resourceId: resourceId,
                configJson: configJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required String configJson,
                required DateTime updatedAt,
              }) => ResourceConfigsCompanion.insert(
                id: id,
                resourceId: resourceId,
                configJson: configJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourceConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable:
                                    $$ResourceConfigsTableReferences
                                        ._resourceIdTable(db),
                                referencedColumn:
                                    $$ResourceConfigsTableReferences
                                        ._resourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResourceConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceConfigsTable,
      ResourceConfigEntity,
      $$ResourceConfigsTableFilterComposer,
      $$ResourceConfigsTableOrderingComposer,
      $$ResourceConfigsTableAnnotationComposer,
      $$ResourceConfigsTableCreateCompanionBuilder,
      $$ResourceConfigsTableUpdateCompanionBuilder,
      (ResourceConfigEntity, $$ResourceConfigsTableReferences),
      ResourceConfigEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$ResourceBindingsTableCreateCompanionBuilder =
    ResourceBindingsCompanion Function({
      Value<int> id,
      required int resourceId,
      required int targetResourceId,
      required String bindingType,
      Value<String?> bindingConfigJson,
      Value<int> priority,
      Value<bool> enabled,
    });
typedef $$ResourceBindingsTableUpdateCompanionBuilder =
    ResourceBindingsCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<int> targetResourceId,
      Value<String> bindingType,
      Value<String?> bindingConfigJson,
      Value<int> priority,
      Value<bool> enabled,
    });

final class $$ResourceBindingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResourceBindingsTable,
          ResourceBindingEntity
        > {
  $$ResourceBindingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(
          db.resourceBindings.resourceId,
          db.resourcesV24.id,
        ),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ResourcesV24Table _targetResourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(
          db.resourceBindings.targetResourceId,
          db.resourcesV24.id,
        ),
      );

  $$ResourcesV24TableProcessedTableManager get targetResourceId {
    final $_column = $_itemColumn<int>('target_resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetResourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResourceBindingsTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceBindingsTable> {
  $$ResourceBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindingConfigJson => $composableBuilder(
    column: $table.bindingConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableFilterComposer get targetResourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetResourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceBindingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceBindingsTable> {
  $$ResourceBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindingConfigJson => $composableBuilder(
    column: $table.bindingConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableOrderingComposer get targetResourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetResourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceBindingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceBindingsTable> {
  $$ResourceBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bindingType => $composableBuilder(
    column: $table.bindingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bindingConfigJson => $composableBuilder(
    column: $table.bindingConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableAnnotationComposer get targetResourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetResourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResourceBindingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResourceBindingsTable,
          ResourceBindingEntity,
          $$ResourceBindingsTableFilterComposer,
          $$ResourceBindingsTableOrderingComposer,
          $$ResourceBindingsTableAnnotationComposer,
          $$ResourceBindingsTableCreateCompanionBuilder,
          $$ResourceBindingsTableUpdateCompanionBuilder,
          (ResourceBindingEntity, $$ResourceBindingsTableReferences),
          ResourceBindingEntity,
          PrefetchHooks Function({bool resourceId, bool targetResourceId})
        > {
  $$ResourceBindingsTableTableManager(
    _$AppDatabase db,
    $ResourceBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceBindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceBindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceBindingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<int> targetResourceId = const Value.absent(),
                Value<String> bindingType = const Value.absent(),
                Value<String?> bindingConfigJson = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => ResourceBindingsCompanion(
                id: id,
                resourceId: resourceId,
                targetResourceId: targetResourceId,
                bindingType: bindingType,
                bindingConfigJson: bindingConfigJson,
                priority: priority,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required int targetResourceId,
                required String bindingType,
                Value<String?> bindingConfigJson = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => ResourceBindingsCompanion.insert(
                id: id,
                resourceId: resourceId,
                targetResourceId: targetResourceId,
                bindingType: bindingType,
                bindingConfigJson: bindingConfigJson,
                priority: priority,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResourceBindingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({resourceId = false, targetResourceId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (resourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.resourceId,
                                    referencedTable:
                                        $$ResourceBindingsTableReferences
                                            ._resourceIdTable(db),
                                    referencedColumn:
                                        $$ResourceBindingsTableReferences
                                            ._resourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetResourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetResourceId,
                                    referencedTable:
                                        $$ResourceBindingsTableReferences
                                            ._targetResourceIdTable(db),
                                    referencedColumn:
                                        $$ResourceBindingsTableReferences
                                            ._targetResourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ResourceBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResourceBindingsTable,
      ResourceBindingEntity,
      $$ResourceBindingsTableFilterComposer,
      $$ResourceBindingsTableOrderingComposer,
      $$ResourceBindingsTableAnnotationComposer,
      $$ResourceBindingsTableCreateCompanionBuilder,
      $$ResourceBindingsTableUpdateCompanionBuilder,
      (ResourceBindingEntity, $$ResourceBindingsTableReferences),
      ResourceBindingEntity,
      PrefetchHooks Function({bool resourceId, bool targetResourceId})
    >;
typedef $$CommandResultsTableCreateCompanionBuilder =
    CommandResultsCompanion Function({
      Value<int> id,
      required int resourceId,
      required String command,
      Value<String?> resultJson,
      required String status,
      required DateTime timestamp,
    });
typedef $$CommandResultsTableUpdateCompanionBuilder =
    CommandResultsCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<String> command,
      Value<String?> resultJson,
      Value<String> status,
      Value<DateTime> timestamp,
    });

final class $$CommandResultsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CommandResultsTable,
          CommandResultEntity
        > {
  $$CommandResultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(db.commandResults.resourceId, db.resourcesV24.id),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommandResultsTableFilterComposer
    extends Composer<_$AppDatabase, $CommandResultsTable> {
  $$CommandResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandResultsTable> {
  $$CommandResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get command => $composableBuilder(
    column: $table.command,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandResultsTable> {
  $$CommandResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get command =>
      $composableBuilder(column: $table.command, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommandResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommandResultsTable,
          CommandResultEntity,
          $$CommandResultsTableFilterComposer,
          $$CommandResultsTableOrderingComposer,
          $$CommandResultsTableAnnotationComposer,
          $$CommandResultsTableCreateCompanionBuilder,
          $$CommandResultsTableUpdateCompanionBuilder,
          (CommandResultEntity, $$CommandResultsTableReferences),
          CommandResultEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$CommandResultsTableTableManager(
    _$AppDatabase db,
    $CommandResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<String> command = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => CommandResultsCompanion(
                id: id,
                resourceId: resourceId,
                command: command,
                resultJson: resultJson,
                status: status,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required String command,
                Value<String?> resultJson = const Value.absent(),
                required String status,
                required DateTime timestamp,
              }) => CommandResultsCompanion.insert(
                id: id,
                resourceId: resourceId,
                command: command,
                resultJson: resultJson,
                status: status,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommandResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable: $$CommandResultsTableReferences
                                    ._resourceIdTable(db),
                                referencedColumn:
                                    $$CommandResultsTableReferences
                                        ._resourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CommandResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommandResultsTable,
      CommandResultEntity,
      $$CommandResultsTableFilterComposer,
      $$CommandResultsTableOrderingComposer,
      $$CommandResultsTableAnnotationComposer,
      $$CommandResultsTableCreateCompanionBuilder,
      $$CommandResultsTableUpdateCompanionBuilder,
      (CommandResultEntity, $$CommandResultsTableReferences),
      CommandResultEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$WaterLevelHistoryTableCreateCompanionBuilder =
    WaterLevelHistoryCompanion Function({
      Value<int> id,
      required int resourceId,
      required double percent,
      required double liters,
      Value<String> alert,
      required DateTime timestamp,
    });
typedef $$WaterLevelHistoryTableUpdateCompanionBuilder =
    WaterLevelHistoryCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<double> percent,
      Value<double> liters,
      Value<String> alert,
      Value<DateTime> timestamp,
    });

final class $$WaterLevelHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WaterLevelHistoryTable,
          WaterLevelHistoryEntity
        > {
  $$WaterLevelHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(
          db.waterLevelHistory.resourceId,
          db.resourcesV24.id,
        ),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WaterLevelHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLevelHistoryTable> {
  $$WaterLevelHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alert => $composableBuilder(
    column: $table.alert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLevelHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLevelHistoryTable> {
  $$WaterLevelHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alert => $composableBuilder(
    column: $table.alert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLevelHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLevelHistoryTable> {
  $$WaterLevelHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<double> get liters =>
      $composableBuilder(column: $table.liters, builder: (column) => column);

  GeneratedColumn<String> get alert =>
      $composableBuilder(column: $table.alert, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaterLevelHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLevelHistoryTable,
          WaterLevelHistoryEntity,
          $$WaterLevelHistoryTableFilterComposer,
          $$WaterLevelHistoryTableOrderingComposer,
          $$WaterLevelHistoryTableAnnotationComposer,
          $$WaterLevelHistoryTableCreateCompanionBuilder,
          $$WaterLevelHistoryTableUpdateCompanionBuilder,
          (WaterLevelHistoryEntity, $$WaterLevelHistoryTableReferences),
          WaterLevelHistoryEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$WaterLevelHistoryTableTableManager(
    _$AppDatabase db,
    $WaterLevelHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLevelHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLevelHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLevelHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<double> liters = const Value.absent(),
                Value<String> alert = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WaterLevelHistoryCompanion(
                id: id,
                resourceId: resourceId,
                percent: percent,
                liters: liters,
                alert: alert,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required double percent,
                required double liters,
                Value<String> alert = const Value.absent(),
                required DateTime timestamp,
              }) => WaterLevelHistoryCompanion.insert(
                id: id,
                resourceId: resourceId,
                percent: percent,
                liters: liters,
                alert: alert,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WaterLevelHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable:
                                    $$WaterLevelHistoryTableReferences
                                        ._resourceIdTable(db),
                                referencedColumn:
                                    $$WaterLevelHistoryTableReferences
                                        ._resourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WaterLevelHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLevelHistoryTable,
      WaterLevelHistoryEntity,
      $$WaterLevelHistoryTableFilterComposer,
      $$WaterLevelHistoryTableOrderingComposer,
      $$WaterLevelHistoryTableAnnotationComposer,
      $$WaterLevelHistoryTableCreateCompanionBuilder,
      $$WaterLevelHistoryTableUpdateCompanionBuilder,
      (WaterLevelHistoryEntity, $$WaterLevelHistoryTableReferences),
      WaterLevelHistoryEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$EnvClimateHistoryTableCreateCompanionBuilder =
    EnvClimateHistoryCompanion Function({
      Value<int> id,
      required int resourceId,
      required double temperature,
      required double humidity,
      required DateTime timestamp,
    });
typedef $$EnvClimateHistoryTableUpdateCompanionBuilder =
    EnvClimateHistoryCompanion Function({
      Value<int> id,
      Value<int> resourceId,
      Value<double> temperature,
      Value<double> humidity,
      Value<DateTime> timestamp,
    });

final class $$EnvClimateHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EnvClimateHistoryTable,
          EnvClimateHistoryEntity
        > {
  $$EnvClimateHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(
          db.envClimateHistory.resourceId,
          db.resourcesV24.id,
        ),
      );

  $$ResourcesV24TableProcessedTableManager get resourceId {
    final $_column = $_itemColumn<int>('resource_id')!;

    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnvClimateHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $EnvClimateHistoryTable> {
  $$EnvClimateHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvClimateHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $EnvClimateHistoryTable> {
  $$EnvClimateHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvClimateHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnvClimateHistoryTable> {
  $$EnvClimateHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvClimateHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnvClimateHistoryTable,
          EnvClimateHistoryEntity,
          $$EnvClimateHistoryTableFilterComposer,
          $$EnvClimateHistoryTableOrderingComposer,
          $$EnvClimateHistoryTableAnnotationComposer,
          $$EnvClimateHistoryTableCreateCompanionBuilder,
          $$EnvClimateHistoryTableUpdateCompanionBuilder,
          (EnvClimateHistoryEntity, $$EnvClimateHistoryTableReferences),
          EnvClimateHistoryEntity,
          PrefetchHooks Function({bool resourceId})
        > {
  $$EnvClimateHistoryTableTableManager(
    _$AppDatabase db,
    $EnvClimateHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvClimateHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvClimateHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvClimateHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> resourceId = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<double> humidity = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => EnvClimateHistoryCompanion(
                id: id,
                resourceId: resourceId,
                temperature: temperature,
                humidity: humidity,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int resourceId,
                required double temperature,
                required double humidity,
                required DateTime timestamp,
              }) => EnvClimateHistoryCompanion.insert(
                id: id,
                resourceId: resourceId,
                temperature: temperature,
                humidity: humidity,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvClimateHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable:
                                    $$EnvClimateHistoryTableReferences
                                        ._resourceIdTable(db),
                                referencedColumn:
                                    $$EnvClimateHistoryTableReferences
                                        ._resourceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EnvClimateHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnvClimateHistoryTable,
      EnvClimateHistoryEntity,
      $$EnvClimateHistoryTableFilterComposer,
      $$EnvClimateHistoryTableOrderingComposer,
      $$EnvClimateHistoryTableAnnotationComposer,
      $$EnvClimateHistoryTableCreateCompanionBuilder,
      $$EnvClimateHistoryTableUpdateCompanionBuilder,
      (EnvClimateHistoryEntity, $$EnvClimateHistoryTableReferences),
      EnvClimateHistoryEntity,
      PrefetchHooks Function({bool resourceId})
    >;
typedef $$EventsV24TableCreateCompanionBuilder =
    EventsV24Companion Function({
      Value<int> id,
      required int homeId,
      Value<int?> resourceId,
      required String domain,
      required String kind,
      Value<String> severity,
      Value<String?> payloadJson,
      required DateTime timestamp,
      Value<bool> read,
    });
typedef $$EventsV24TableUpdateCompanionBuilder =
    EventsV24Companion Function({
      Value<int> id,
      Value<int> homeId,
      Value<int?> resourceId,
      Value<String> domain,
      Value<String> kind,
      Value<String> severity,
      Value<String?> payloadJson,
      Value<DateTime> timestamp,
      Value<bool> read,
    });

final class $$EventsV24TableReferences
    extends BaseReferences<_$AppDatabase, $EventsV24Table, EventEntityV24> {
  $$EventsV24TableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HomesTable _homeIdTable(_$AppDatabase db) => db.homes.createAlias(
    $_aliasNameGenerator(db.eventsV24.homeId, db.homes.id),
  );

  $$HomesTableProcessedTableManager get homeId {
    final $_column = $_itemColumn<int>('home_id')!;

    final manager = $$HomesTableTableManager(
      $_db,
      $_db.homes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ResourcesV24Table _resourceIdTable(_$AppDatabase db) =>
      db.resourcesV24.createAlias(
        $_aliasNameGenerator(db.eventsV24.resourceId, db.resourcesV24.id),
      );

  $$ResourcesV24TableProcessedTableManager? get resourceId {
    final $_column = $_itemColumn<int>('resource_id');
    if ($_column == null) return null;
    final manager = $$ResourcesV24TableTableManager(
      $_db,
      $_db.resourcesV24,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_resourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventsV24TableFilterComposer
    extends Composer<_$AppDatabase, $EventsV24Table> {
  $$EventsV24TableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  $$HomesTableFilterComposer get homeId {
    final $$HomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableFilterComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableFilterComposer get resourceId {
    final $$ResourcesV24TableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableFilterComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsV24TableOrderingComposer
    extends Composer<_$AppDatabase, $EventsV24Table> {
  $$EventsV24TableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  $$HomesTableOrderingComposer get homeId {
    final $$HomesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableOrderingComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableOrderingComposer get resourceId {
    final $$ResourcesV24TableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableOrderingComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsV24TableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsV24Table> {
  $$EventsV24TableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  $$HomesTableAnnotationComposer get homeId {
    final $$HomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeId,
      referencedTable: $db.homes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HomesTableAnnotationComposer(
            $db: $db,
            $table: $db.homes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ResourcesV24TableAnnotationComposer get resourceId {
    final $$ResourcesV24TableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.resourceId,
      referencedTable: $db.resourcesV24,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResourcesV24TableAnnotationComposer(
            $db: $db,
            $table: $db.resourcesV24,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsV24TableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsV24Table,
          EventEntityV24,
          $$EventsV24TableFilterComposer,
          $$EventsV24TableOrderingComposer,
          $$EventsV24TableAnnotationComposer,
          $$EventsV24TableCreateCompanionBuilder,
          $$EventsV24TableUpdateCompanionBuilder,
          (EventEntityV24, $$EventsV24TableReferences),
          EventEntityV24,
          PrefetchHooks Function({bool homeId, bool resourceId})
        > {
  $$EventsV24TableTableManager(_$AppDatabase db, $EventsV24Table table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsV24TableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsV24TableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsV24TableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> homeId = const Value.absent(),
                Value<int?> resourceId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> read = const Value.absent(),
              }) => EventsV24Companion(
                id: id,
                homeId: homeId,
                resourceId: resourceId,
                domain: domain,
                kind: kind,
                severity: severity,
                payloadJson: payloadJson,
                timestamp: timestamp,
                read: read,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int homeId,
                Value<int?> resourceId = const Value.absent(),
                required String domain,
                required String kind,
                Value<String> severity = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                required DateTime timestamp,
                Value<bool> read = const Value.absent(),
              }) => EventsV24Companion.insert(
                id: id,
                homeId: homeId,
                resourceId: resourceId,
                domain: domain,
                kind: kind,
                severity: severity,
                payloadJson: payloadJson,
                timestamp: timestamp,
                read: read,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventsV24TableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({homeId = false, resourceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (homeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.homeId,
                                referencedTable: $$EventsV24TableReferences
                                    ._homeIdTable(db),
                                referencedColumn: $$EventsV24TableReferences
                                    ._homeIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (resourceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.resourceId,
                                referencedTable: $$EventsV24TableReferences
                                    ._resourceIdTable(db),
                                referencedColumn: $$EventsV24TableReferences
                                    ._resourceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventsV24TableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsV24Table,
      EventEntityV24,
      $$EventsV24TableFilterComposer,
      $$EventsV24TableOrderingComposer,
      $$EventsV24TableAnnotationComposer,
      $$EventsV24TableCreateCompanionBuilder,
      $$EventsV24TableUpdateCompanionBuilder,
      (EventEntityV24, $$EventsV24TableReferences),
      EventEntityV24,
      PrefetchHooks Function({bool homeId, bool resourceId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<String?> selectedTenantId,
      Value<String?> selectedHomeId,
      Value<DateTime> updatedAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<String?> selectedTenantId,
      Value<String?> selectedHomeId,
      Value<DateTime> updatedAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedTenantId => $composableBuilder(
    column: $table.selectedTenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedHomeId => $composableBuilder(
    column: $table.selectedHomeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedTenantId => $composableBuilder(
    column: $table.selectedTenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedHomeId => $composableBuilder(
    column: $table.selectedHomeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selectedTenantId => $composableBuilder(
    column: $table.selectedTenantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedHomeId => $composableBuilder(
    column: $table.selectedHomeId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreferenceEntity,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreferenceEntity,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreferenceEntity
            >,
          ),
          UserPreferenceEntity,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> selectedTenantId = const Value.absent(),
                Value<String?> selectedHomeId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                selectedTenantId: selectedTenantId,
                selectedHomeId: selectedHomeId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> selectedTenantId = const Value.absent(),
                Value<String?> selectedHomeId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                id: id,
                selectedTenantId: selectedTenantId,
                selectedHomeId: selectedHomeId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreferenceEntity,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreferenceEntity,
        BaseReferences<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreferenceEntity
        >,
      ),
      UserPreferenceEntity,
      PrefetchHooks Function()
    >;
typedef $$PendingCommandsTableCreateCompanionBuilder =
    PendingCommandsCompanion Function({
      required String correlationId,
      required String resourceId,
      required String action,
      Value<String?> paramsJson,
      required String origin,
      Value<String> status,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$PendingCommandsTableUpdateCompanionBuilder =
    PendingCommandsCompanion Function({
      Value<String> correlationId,
      Value<String> resourceId,
      Value<String> action,
      Value<String?> paramsJson,
      Value<String> origin,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$PendingCommandsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingCommandsTable> {
  $$PendingCommandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingCommandsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingCommandsTable> {
  $$PendingCommandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingCommandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingCommandsTable> {
  $$PendingCommandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get correlationId => $composableBuilder(
    column: $table.correlationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$PendingCommandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingCommandsTable,
          PendingCommandEntity,
          $$PendingCommandsTableFilterComposer,
          $$PendingCommandsTableOrderingComposer,
          $$PendingCommandsTableAnnotationComposer,
          $$PendingCommandsTableCreateCompanionBuilder,
          $$PendingCommandsTableUpdateCompanionBuilder,
          (
            PendingCommandEntity,
            BaseReferences<
              _$AppDatabase,
              $PendingCommandsTable,
              PendingCommandEntity
            >,
          ),
          PendingCommandEntity,
          PrefetchHooks Function()
        > {
  $$PendingCommandsTableTableManager(
    _$AppDatabase db,
    $PendingCommandsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingCommandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingCommandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingCommandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> correlationId = const Value.absent(),
                Value<String> resourceId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> paramsJson = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCommandsCompanion(
                correlationId: correlationId,
                resourceId: resourceId,
                action: action,
                paramsJson: paramsJson,
                origin: origin,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String correlationId,
                required String resourceId,
                required String action,
                Value<String?> paramsJson = const Value.absent(),
                required String origin,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingCommandsCompanion.insert(
                correlationId: correlationId,
                resourceId: resourceId,
                action: action,
                paramsJson: paramsJson,
                origin: origin,
                status: status,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingCommandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingCommandsTable,
      PendingCommandEntity,
      $$PendingCommandsTableFilterComposer,
      $$PendingCommandsTableOrderingComposer,
      $$PendingCommandsTableAnnotationComposer,
      $$PendingCommandsTableCreateCompanionBuilder,
      $$PendingCommandsTableUpdateCompanionBuilder,
      (
        PendingCommandEntity,
        BaseReferences<
          _$AppDatabase,
          $PendingCommandsTable,
          PendingCommandEntity
        >,
      ),
      PendingCommandEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db, _db.tenants);
  $$HomesTableTableManager get homes =>
      $$HomesTableTableManager(_db, _db.homes);
  $$DevicesV24TableTableManager get devicesV24 =>
      $$DevicesV24TableTableManager(_db, _db.devicesV24);
  $$ResourcesV24TableTableManager get resourcesV24 =>
      $$ResourcesV24TableTableManager(_db, _db.resourcesV24);
  $$ResourceStatesTableTableManager get resourceStates =>
      $$ResourceStatesTableTableManager(_db, _db.resourceStates);
  $$ResourceDataTableTableManager get resourceData =>
      $$ResourceDataTableTableManager(_db, _db.resourceData);
  $$ResourceConfigsTableTableManager get resourceConfigs =>
      $$ResourceConfigsTableTableManager(_db, _db.resourceConfigs);
  $$ResourceBindingsTableTableManager get resourceBindings =>
      $$ResourceBindingsTableTableManager(_db, _db.resourceBindings);
  $$CommandResultsTableTableManager get commandResults =>
      $$CommandResultsTableTableManager(_db, _db.commandResults);
  $$WaterLevelHistoryTableTableManager get waterLevelHistory =>
      $$WaterLevelHistoryTableTableManager(_db, _db.waterLevelHistory);
  $$EnvClimateHistoryTableTableManager get envClimateHistory =>
      $$EnvClimateHistoryTableTableManager(_db, _db.envClimateHistory);
  $$EventsV24TableTableManager get eventsV24 =>
      $$EventsV24TableTableManager(_db, _db.eventsV24);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$PendingCommandsTableTableManager get pendingCommands =>
      $$PendingCommandsTableTableManager(_db, _db.pendingCommands);
}
