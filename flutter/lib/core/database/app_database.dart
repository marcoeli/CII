import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/v24_tables.dart';

// DAOs V2.4
import 'daos/tenants_homes_dao.dart';
import 'daos/devices_dao.dart';
import 'daos/resources_dao.dart';
import 'daos/water_dao.dart';
import 'daos/events_v24_dao.dart';
import 'daos/command_results_dao.dart';
import 'daos/user_preferences_dao.dart';
import 'daos/pending_commands_dao.dart';

part 'app_database.g.dart';

// --- Tabelas Legadas Removidas em V18 ---

@DriftDatabase(
  tables: [
    // V2.4 Tables
    Tenants,
    Homes,
    DevicesV24,
    ResourcesV24,
    ResourceStates,
    ResourceData,
    ResourceConfigs,
    ResourceBindings,
    CommandResults,
    WaterLevelHistory,
    EnvClimateHistory,
    EventsV24,
    UserPreferences,
    PendingCommands,
  ],
  daos: [
    TenantsHomesDao,
    DevicesDao,
    ResourcesDao,
    WaterDao,
    EventsV24Dao,
    CommandResultsDao,
    UserPreferencesDao,
    PendingCommandsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 19;

  @override
  EventsV24Dao get eventsV24Dao => EventsV24Dao(this);
  @override
  DevicesDao get devicesDao => DevicesDao(this);
  @override
  ResourcesDao get resourcesDao => ResourcesDao(this);
  @override
  TenantsHomesDao get tenantsHomesDao => TenantsHomesDao(this);
  @override
  WaterDao get waterDao => WaterDao(this);
  @override
  CommandResultsDao get commandResultsDao => CommandResultsDao(this);
  @override
  PendingCommandsDao get pendingCommandsDao => PendingCommandsDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => await m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      // Migrações legadas corrigidas para evitar referências a getters removidos
      if (from < 2) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS physical_devices (username TEXT PRIMARY KEY, last_heartbeat INTEGER, model TEXT, mac TEXT);',
        );
      }
      if (from < 3) {
        await customStatement(
          'ALTER TABLE devices ADD COLUMN source_device TEXT;',
        );
        await customStatement(
          'ALTER TABLE physical_devices ADD COLUMN capabilities TEXT;',
        );
      }
      if (from < 4) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS sensor_readings (id INTEGER PRIMARY KEY AUTOINCREMENT, device_id TEXT, type TEXT, value REAL, timestamp INTEGER);',
        );
        await customStatement(
          'ALTER TABLE devices ADD COLUMN last_reading_data TEXT;',
        );
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE devices ADD COLUMN friendly_room TEXT;',
        );
      }
      if (from < 6) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, type TEXT, timestamp INTEGER, is_read INTEGER);',
        );
      }
      if (from < 7) {
        await customStatement(
          'ALTER TABLE devices ADD COLUMN capabilities TEXT;',
        );
      }
      if (from < 8) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS system_events (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, content TEXT, timestamp INTEGER);',
        );
      }
      if (from < 10) {
        await customStatement(
          'ALTER TABLE system_events ADD COLUMN event_id TEXT;',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_system_events_event_id ON system_events (event_id);',
        );
      }
      if (from < 11) {
        await customStatement(
          'ALTER TABLE physical_devices ADD COLUMN serial TEXT;',
        );
        await customStatement(
          'ALTER TABLE physical_devices ADD COLUMN vendor TEXT;',
        );
      }

      // V12, V13, V14: Refatoração V2.4
      if (from < 14) {
        // Drop tables if exist
        await m.drop(tenants);
        await m.drop(homes);
        await m.drop(devicesV24);
        await m.drop(resourcesV24);
        await m.drop(resourceStates);
        await m.drop(resourceData);
        await m.drop(resourceConfigs);
        await m.drop(resourceBindings);
        await m.drop(commandResults);
        await m.drop(waterLevelHistory);
        await m.drop(envClimateHistory);
        await m.drop(eventsV24);

        // Criar novas versões V14
        await m.createTable(tenants);
        await m.createTable(homes);
        await m.createTable(devicesV24);
        await m.createTable(resourcesV24);
        await m.createTable(resourceStates);
        await m.createTable(resourceData);
        await m.createTable(resourceConfigs);
        await m.createTable(resourceBindings);
        await m.createTable(commandResults);
        await m.createTable(waterLevelHistory);
        await m.createTable(envClimateHistory);
        await m.createTable(eventsV24);

        // Criar Índices de Performance
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_resources_v24_home_id_domain_kind ON resources_v24 (home_id, domain, kind);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_resource_data_resource_id ON resource_data (resource_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_resource_states_resource_id ON resource_states (resource_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_events_v24_home_id_timestamp ON events_v24 (home_id, timestamp);',
        );
      } else if (from < 15) {
        // Só tenta adicionar a coluna 'read' se NÃO veio do bloco 'from < 14',
        // pois o m.createTable(eventsV24) já a inclui.
        await m.addColumn(eventsV24, eventsV24.read);
      }

      if (from < 16) {
        await m.createTable(userPreferences);
      }

      if (from < 17) {
        await m.createTable(pendingCommands);
      }

      if (from < 18) {
        // 1. Remover Tabelas Legadas Permanentemente
        // Nota: Tabelas que não estão mais no @DriftDatabase não podem ser acessadas via m.drop(table)
        // Usamos customStatement para garantir a remoção.
        await customStatement('DROP TABLE IF EXISTS devices;');
        await customStatement('DROP TABLE IF EXISTS device_configs;');
        await customStatement('DROP TABLE IF EXISTS physical_devices;');
        await customStatement('DROP TABLE IF EXISTS sensor_readings;');
        await customStatement('DROP TABLE IF EXISTS events;');
        await customStatement('DROP TABLE IF EXISTS system_events;');

        // 2. Adicionar colunas faltantes em DevicesV24
        await m.addColumn(devicesV24, devicesV24.vendor);
        await m.addColumn(devicesV24, devicesV24.model);
        await m.addColumn(devicesV24, devicesV24.mac);
        await m.addColumn(devicesV24, devicesV24.serial);
        await m.addColumn(devicesV24, devicesV24.rssi);
      }

      if (from < 19) {
        // v19: Adicionar metadados detalhados de hardware V2.4
        await m.addColumn(devicesV24, devicesV24.contractVersion);
        await m.addColumn(devicesV24, devicesV24.uptime);
        await m.addColumn(devicesV24, devicesV24.hardwareRevision);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> wipeEverything() async {
    await transaction(() async {
      // Deletar em ordem inversa de dependências se houver FKs restritivas
      // Ou desativar temporariamente as FKs
      await customStatement('PRAGMA foreign_keys = OFF');
      for (final table in allTables) {
        await delete(table).go();
      }
      await customStatement('PRAGMA foreign_keys = ON');
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cii_app.db'));
    return NativeDatabase(file);
  });
}
