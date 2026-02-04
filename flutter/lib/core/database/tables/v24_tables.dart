import 'package:drift/drift.dart';

// 1. Tenants e Homes (Multi-tenancy)
@DataClassName('TenantEntity')
class Tenants extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId =>
      text().unique()(); // UNIQUE ID do inquilino (ex: 'marco')
  TextColumn get name => text()(); // Nome amigável
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('HomeEntity')
class Homes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tenantId =>
      integer().references(Tenants, #id, onDelete: KeyAction.cascade)();
  TextColumn get homeId => text()(); // ID da residência (ex: 'casa_principal')
  TextColumn get label => text()(); // Nome amigável
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {tenantId, homeId}, // tenantId + homeId deve ser único
  ];
}

// 2. Devices (Hardware físico vinculado a uma residência)
@DataClassName('DeviceEntity')
class DevicesV24 extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get homeId =>
      integer().references(Homes, #id, onDelete: KeyAction.cascade)();
  TextColumn get deviceId =>
      text().unique()(); // UNIQUE globalmente (ex: 'cistern-node-33443f')
  TextColumn get role => text()(); // enum roles oficiais
  TextColumn get status =>
      text().withDefault(const Constant('UNKNOWN'))(); // online/offline/error
  DateTimeColumn get lastSeen => dateTime().nullable()();
  TextColumn get firmwareVersion => text().nullable()();
  TextColumn get contractVersion =>
      text().nullable()(); // V2.4 Contract version
  IntColumn get uptime => integer().nullable()(); // Device uptime in seconds
  TextColumn get hardwareRevision =>
      text().nullable()(); // Hardware revision (rev)
  TextColumn get ipAddress => text().nullable()();
  TextColumn get vendor => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get mac => text().nullable()();
  TextColumn get serial => text().nullable()();
  IntColumn get rssi => integer().nullable()();
}

// 4. Resources (Núcleo do sistema V2.4)
@DataClassName('ResourceEntity')
class ResourcesV24 extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get homeId =>
      integer().references(Homes, #id, onDelete: KeyAction.cascade)();
  IntColumn get deviceId =>
      integer().references(DevicesV24, #id, onDelete: KeyAction.cascade)();
  TextColumn get resourceId => text()(); // {domain}.{kind}.{name}
  TextColumn get domain => text()(); // water, env, security, hmi
  TextColumn get kind => text()(); // level, pump, climate, etc
  TextColumn get name => text()(); // nome técnico
  TextColumn get label => text().nullable()(); // nome humano (do meta)
  TextColumn get room => text().nullable()();
  TextColumn get capabilityType =>
      text()(); // WATER_SENSOR, WATER_ACTUATOR, etc
  TextColumn get metadataJson => text().nullable()(); // JSON do meta completo
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {homeId, resourceId}, // resourceId único por home
  ];
}

// 5, 6, 7. Estados, Dados e Configurações (Relacionamento 1:1 com Resource)
@DataClassName('ResourceStateEntity')
class ResourceStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId => integer()
      .references(ResourcesV24, #id, onDelete: KeyAction.cascade)
      .unique()();
  TextColumn get stateJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('ResourceDataEntity')
class ResourceData extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId => integer()
      .references(ResourcesV24, #id, onDelete: KeyAction.cascade)
      .unique()();
  TextColumn get dataJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('ResourceConfigEntity')
class ResourceConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId => integer()
      .references(ResourcesV24, #id, onDelete: KeyAction.cascade)
      .unique()();
  TextColumn get configJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

// 12. Histórico de Nível de Água (Especializado)
@DataClassName('WaterLevelHistoryEntity')
class WaterLevelHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId =>
      integer().references(ResourcesV24, #id, onDelete: KeyAction.cascade)();
  RealColumn get percent => real()();
  RealColumn get liters => real()();
  TextColumn get alert => text().withDefault(const Constant('NORMAL'))();
  DateTimeColumn get timestamp => dateTime()();
}

// 13. Histórico de Clima (Especializado)
@DataClassName('EnvClimateHistoryEntity')
class EnvClimateHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId =>
      integer().references(ResourcesV24, #id, onDelete: KeyAction.cascade)();
  RealColumn get temperature => real()();
  RealColumn get humidity => real()();
  DateTimeColumn get timestamp => dateTime()();
}

// 10. Eventos (Genéricos e Segurança)
@DataClassName('EventEntityV24')
class EventsV24 extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get homeId =>
      integer().references(Homes, #id, onDelete: KeyAction.cascade)();
  IntColumn get resourceId => integer().nullable().references(
    ResourcesV24,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get domain => text()();
  TextColumn get kind => text()();
  TextColumn get severity =>
      text().withDefault(const Constant('info'))(); // info, warning, critical
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
}

// 8. Resource Bindings (Dependências entre Resources - CRÍTICO)
@DataClassName('ResourceBindingEntity')
class ResourceBindings extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName("sourceResourceBindings")
  IntColumn get resourceId =>
      integer().references(ResourcesV24, #id, onDelete: KeyAction.cascade)();
  @ReferenceName("targetResourceBindings")
  IntColumn get targetResourceId =>
      integer().references(ResourcesV24, #id, onDelete: KeyAction.cascade)();
  TextColumn get bindingType => text()(); // enum SOURCE_LEVEL, etc
  TextColumn get bindingConfigJson => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

// 11. Command Results (Para feedback de execução)
@DataClassName('CommandResultEntity')
class CommandResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get resourceId =>
      integer().references(ResourcesV24, #id, onDelete: KeyAction.cascade)();
  TextColumn get command => text()();
  TextColumn get resultJson => text().nullable()();
  TextColumn get status => text()(); // success, failed, timeout
  DateTimeColumn get timestamp => dateTime()();
}

// 14. Preferências do Usuário (Local State Persistence)
@DataClassName('UserPreferenceEntity')
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get selectedTenantId =>
      text().nullable()(); // tenantId (technical)
  TextColumn get selectedHomeId => text().nullable()(); // homeId (technical)
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 15. Comandos Pendentes (Outbox Pattern para UX Pessimista)
@DataClassName('PendingCommandEntity')
class PendingCommands extends Table {
  TextColumn get correlationId => text()(); // UUID v4
  TextColumn get resourceId =>
      text()(); // Referência lógica (FK removida para evitar erro de UNIQUE constraint)
  TextColumn get action => text()(); // START, STOP, SET_MODE
  TextColumn get paramsJson => text().nullable()();
  TextColumn get origin => text()(); // 'app'
  // status: pending, success, failed, timeout
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {correlationId};
}
