import 'dart:convert';
import 'dart:io';
import 'package:cii/core/database/app_database.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service para Backup e Restore de Configurações V2.4
class ConfigBackupService {
  final AppDatabase _db;
  final _log = Logger('ConfigBackupService');

  static const String configVersion = '2.4';

  ConfigBackupService(this._db);

  /// Exporta todas as configurações V2.4 para JSON
  Future<Map<String, dynamic>> exportConfig() async {
    try {
      _log.info('🔄 Starting config export V2.4...');

      final tenants = await _db.select(_db.tenants).get();
      final homes = await _db.select(_db.homes).get();
      final devices = await _db.select(_db.devicesV24).get();
      final resources = await _db.select(_db.resourcesV24).get();
      final configs = await _db.select(_db.resourceConfigs).get();

      final config = {
        'version': configVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'tenants': tenants.map((t) => t.toJson()).toList(),
          'homes': homes.map((h) => h.toJson()).toList(),
          'devices': devices.map((d) => d.toJson()).toList(),
          'resources': resources.map((r) => r.toJson()).toList(),
          'resourceConfigs': configs.map((c) => c.toJson()).toList(),
        },
      };

      _log.info('✅ Config V2.4 exported successfully');
      return config;
    } catch (e) {
      _log.severe('❌ Error exporting config: $e');
      rethrow;
    }
  }

  /// Exporta config e salva em arquivo
  Future<String> exportToFile() async {
    try {
      final config = await exportConfig();
      final jsonString = const JsonEncoder.withIndent('  ').convert(config);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = '${directory.path}/cii_backup_v24_$timestamp.json';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      _log.info('📁 Config exported to: $filePath');
      return filePath;
    } catch (e) {
      _log.severe('❌ Error exporting to file: $e');
      rethrow;
    }
  }

  /// Compartilha config via share sheet
  Future<void> shareConfig() async {
    try {
      final filePath = await exportToFile();
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'CII App Backup V2.4',
        text: 'Configurações exportadas do CII (V2.4)',
      );
    } catch (e) {
      _log.severe('❌ Error sharing config: $e');
      rethrow;
    }
  }

  /// Importa configurações de JSON
  Future<ImportResult> importConfig(Map<String, dynamic> config) async {
    try {
      _log.info('🔄 Starting config import V2.4...');

      final version = config['version'] as String?;
      if (version != configVersion) {
        return ImportResult(
          success: false,
          error: 'Versão incompatível: $version (esperado: $configVersion)',
        );
      }

      final data = config['data'] as Map<String, dynamic>;

      // Para simplificar o import e evitar violação de FK, limpamos (opcional) ou fazemos upsert ordenado
      // Aqui usaremos upsert ordenado: Tenants -> Homes -> Devices -> Resources -> Configs

      int tenantsImported = 0;
      int homesImported = 0;
      int devicesImported = 0;
      int resourcesImported = 0;

      final tenantsData = data['tenants'] as List<dynamic>?;
      if (tenantsData != null) {
        for (final t in tenantsData) {
          await _db
              .into(_db.tenants)
              .insertOnConflictUpdate(TenantEntity.fromJson(t));
          tenantsImported++;
        }
      }

      final homesData = data['homes'] as List<dynamic>?;
      if (homesData != null) {
        for (final h in homesData) {
          await _db
              .into(_db.homes)
              .insertOnConflictUpdate(HomeEntity.fromJson(h));
          homesImported++;
        }
      }

      final devicesData = data['devices'] as List<dynamic>?;
      if (devicesData != null) {
        for (final d in devicesData) {
          await _db
              .into(_db.devicesV24)
              .insertOnConflictUpdate(DeviceEntity.fromJson(d));
          devicesImported++;
        }
      }

      final resourcesData = data['resources'] as List<dynamic>?;
      if (resourcesData != null) {
        for (final r in resourcesData) {
          await _db
              .into(_db.resourcesV24)
              .insertOnConflictUpdate(ResourceEntity.fromJson(r));
          resourcesImported++;
        }
      }

      _log.info('✅ Import complete: $resourcesImported resources');

      return ImportResult(
        success: true,
        resourcesImported: resourcesImported,
        devicesImported: devicesImported,
        tenantsImported: tenantsImported,
        homesImported: homesImported,
      );
    } catch (e) {
      _log.severe('❌ Error importing config: $e');
      return ImportResult(success: false, error: e.toString());
    }
  }

  /// Importa de arquivo JSON
  Future<ImportResult> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final config = jsonDecode(jsonString) as Map<String, dynamic>;

      return await importConfig(config);
    } catch (e) {
      _log.severe('❌ Error importing from file: $e');
      return ImportResult(success: false, error: e.toString());
    }
  }
}

class ImportResult {
  final bool success;
  final String? error;
  final int devicesImported;
  final int resourcesImported;
  final int tenantsImported;
  final int homesImported;

  ImportResult({
    required this.success,
    this.error,
    this.devicesImported = 0,
    this.resourcesImported = 0,
    this.tenantsImported = 0,
    this.homesImported = 0,
  });

  String get summary {
    if (!success) return 'Erro: $error';

    return 'Importado: $devicesImported dispositivos, '
        '$resourcesImported recursos, '
        '$tenantsImported inquilinos, '
        '$homesImported residências';
  }
}
