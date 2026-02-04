import 'package:cii/core/database/app_database.dart';

abstract class IDeviceRepository {
  /// Monitora lista de dispositivos de uma casa
  Stream<List<DeviceEntity>> watchDevices(int homeId);

  /// Monitora um dispositivo específico
  Stream<DeviceEntity?> watchDevice(String deviceId);

  /// Obtém um dispositivo específico uma única vez
  Future<DeviceEntity?> getDevice(String deviceId);

  /// Marca todos os dispositivos da casa especificada como OFFLINE (Soft Reset)
  Future<void> markAllOffline(int homeId);

  /// ⚠️ DEPRECATED: Use wipeAllDevices para evitar FK errors
  @Deprecated('Use wipeAllDevices')
  Future<void> deleteAllDevices();

  /// Limpa TODOS os devices e dependências (com FK temporariamente OFF)
  Future<void> wipeAllDevices();

  /// Remove um dispositivo específico
  Future<void> deleteDevice(String deviceId);

  /// Atualiza meta de um Resource LOCALMENTE (não publica MQTT)
  Future<void> updateResourceLocalMeta(
    String resourceId, {
    String? label,
    String? room,
  });
}
