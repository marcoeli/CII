import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'devices_dao.g.dart';

@DriftAccessor(tables: [DevicesV24])
class DevicesDao extends DatabaseAccessor<AppDatabase> with _$DevicesDaoMixin {
  final _log = Logger('DevicesDao');
  DevicesDao(super.db);

  /// Upsert device usando UNIQUE constraint de deviceId
  /// ✅ FIX: Especifica deviceId como target do conflito, não id (PK)
  Future<int> upsertDevice(DevicesV24Companion device) async {
    _log.fine(
      '🔧 upsertDevice: deviceId=${device.deviceId.value}, homeId=${device.homeId.value}, role=${device.role.value}',
    );

    // ✅ FIX CRÍTICO: Usar deviceId (UNIQUE) como target, não id (PK)
    return await into(devicesV24).insert(
      device,
      onConflict: DoUpdate(
        (_) => device,
        target: [devicesV24.deviceId], // ← UNIQUE constraint column
      ),
    );
  }

  Future<DeviceEntity?> getByDeviceId(String deviceId) {
    return (select(
      devicesV24,
    )..where((d) => d.deviceId.equals(deviceId))).getSingleOrNull();
  }

  Stream<DeviceEntity?> watchDevice(String deviceId) {
    return (select(
      devicesV24,
    )..where((d) => d.deviceId.equals(deviceId))).watchSingleOrNull();
  }

  Stream<List<DeviceEntity>> watchDevicesByHome(int homeId) {
    return (select(devicesV24)..where((d) => d.homeId.equals(homeId))).watch();
  }

  /// Deleta device e seus recursos dependentes
  /// ⚠️ CRITICAL: Deve deletar pending_commands primeiro por causa da FK
  Future<int> deleteDevice(String deviceId) async {
    return await transaction(() async {
      // 1. Buscar device
      final device = await getByDeviceId(deviceId);
      if (device == null) return 0;

      // 2. Buscar resources deste device
      final resources = await (select(
        db.resourcesV24,
      )..where((r) => r.deviceId.equals(device.id))).get();

      // 3. Deletar pending_commands que referenciam esses resources
      for (final resource in resources) {
        await (delete(
          db.pendingCommands,
        )..where((pc) => pc.resourceId.equals(resource.resourceId))).go();
      }

      // 4. Agora pode deletar device (CASCADE deleta resources automaticamente)
      return await (delete(
        devicesV24,
      )..where((d) => d.deviceId.equals(deviceId))).go();
    });
  }

  /// Deleta TODOS os devices de TODAS as homes
  /// ⚠️ DEPRECATED: Use wipeDevicesAndDependencies para evitar FK errors
  @Deprecated('Use wipeDevicesAndDependencies')
  Future<int> deleteAllDevices() async {
    return await transaction(() async {
      // 1. Deletar TODOS os pending_commands (mais simples)
      await delete(db.pendingCommands).go();

      // 2. Agora deletar todos os devices (CASCADE deleta resources)
      return await delete(devicesV24).go();
    });
  }

  /// Limpa TODOS os devices e dependências com FK temporariamente desabilitado
  /// ✅ FIX: PRAGMA foreign_keys OFF para evitar "foreign key mismatch"
  /// devido a pending_commands.resourceId (TEXT FK)
  Future<void> wipeDevicesAndDependencies() async {
    return await transaction(() async {
      // ✅ FIX: Não usar PRAGMA FK OFF dentro de transação (no-op).
      // A ordem de deleção deve respeitar as chaves estrangeiras.

      // 1. Deletar na ordem inversa de dependências (Leafs first)
      await delete(db.pendingCommands).go();
      await delete(db.commandResults).go();
      await delete(db.resourceStates).go();
      await delete(db.resourceData).go();
      await delete(db.resourceConfigs).go();
      await delete(db.resourceBindings).go();
      await delete(db.waterLevelHistory).go();
      await delete(db.envClimateHistory).go();
      await delete(db.eventsV24).go();

      // 2. Deletar Resources (agora livres de referências)
      await delete(db.resourcesV24).go();

      // 3. Deletar Devices
      await delete(devicesV24).go();
    });
  }

  /// Marca como OFFLINE apenas os dispositivos da casa especificada
  Future<int> markAllOfflineByHome(int homeId) {
    return (update(devicesV24)..where((d) => d.homeId.equals(homeId))).write(
      const DevicesV24Companion(status: Value('OFFLINE')),
    );
  }

  Stream<List<DeviceWithHardware>> watchDevicesWithHardware(int homeId) {
    return (select(
      devicesV24,
    )..where((d) => d.homeId.equals(homeId))).watch().map((devices) {
      return devices
          .map((device) => DeviceWithHardware(device: device))
          .toList();
    });
  }

  /// Remove dispositivos "Stub" ou "Orfãos" que não possuem mais recursos vinculados.
  /// Isso limpa os "Ghost Devices" que sobram após o re-parenting.
  Future<void> deleteEmptyStubs(int homeId) async {
    final emptyStubsQuery = select(devicesV24).join([
      leftOuterJoin(
        db.resourcesV24,
        db.resourcesV24.deviceId.equalsExp(devicesV24.id),
      ),
    ]);

    // Filtra: Dispositivos da casa atual que não tem recursos E (são orfãos ou UNKNOWN)
    emptyStubsQuery.where(
      devicesV24.homeId.equals(homeId) &
          db.resourcesV24.id.isNull() &
          (devicesV24.deviceId.like('orphan-%') |
              devicesV24.role.equals('UNKNOWN')),
    );

    final results = await emptyStubsQuery.get();
    for (final row in results) {
      final dev = row.readTable(devicesV24);
      _log.info('👻 deleteEmptyStubs: Removing ghost device ${dev.deviceId}');
      await (delete(devicesV24)..where((d) => d.id.equals(dev.id))).go();
    }
  }
}

/// Classe auxiliar para unir Device Lógico e Físico (V18: Unificados em DevicesV24)
class DeviceWithHardware {
  final DeviceEntity device;

  DeviceWithHardware({required this.device});

  // Getters helpers para facilitar acesso na UI
  String get deviceId => device.deviceId;
  String get status => device.status;
  String? get ipAddress => device.ipAddress;
  String? get role => device.role;
  String? get firmwareVersion => device.firmwareVersion;
  String? get vendor => device.vendor;
  String? get model => device.model;
  int? get rssi => device.rssi;
  DateTime? get lastSeen => device.lastSeen;
}
