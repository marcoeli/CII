import 'package:cii/core/database/app_database.dart';
import '../../domain/repositories/i_device_repository.dart';

class DeviceRepositoryImpl implements IDeviceRepository {
  final AppDatabase _db;

  DeviceRepositoryImpl(this._db);

  @override
  Stream<List<DeviceEntity>> watchDevices(int homeId) {
    return _db.devicesDao.watchDevicesByHome(homeId);
  }

  @override
  Stream<DeviceEntity?> watchDevice(String deviceId) {
    return _db.devicesDao.watchDevice(deviceId);
  }

  @override
  Future<DeviceEntity?> getDevice(String deviceId) {
    return _db.devicesDao.getByDeviceId(deviceId);
  }

  @override
  Future<void> markAllOffline(int homeId) {
    return _db.devicesDao.markAllOfflineByHome(homeId);
  }

  @override
  Future<void> deleteAllDevices() {
    return _db.devicesDao.wipeDevicesAndDependencies();
  }

  @override
  Future<void> wipeAllDevices() {
    return _db.devicesDao.wipeDevicesAndDependencies();
  }

  @override
  Future<void> deleteDevice(String deviceId) {
    return _db.devicesDao.deleteDevice(deviceId);
  }

  @override
  Future<void> updateResourceLocalMeta(
    String resourceId, {
    String? label,
    String? room,
  }) {
    return _db.resourcesDao.updateResourceMeta(
      resourceId,
      label: label,
      room: room,
    );
  }
}
