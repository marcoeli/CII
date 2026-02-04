import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/devices/data/repositories/device_repository_impl.dart';
import 'package:cii/modules/devices/domain/repositories/i_device_repository.dart';

/// Repository Provider
final deviceRepositoryProvider = Provider<IDeviceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DeviceRepositoryImpl(db);
});

/// StreamProvider para um único dispositivo
final deviceStreamProvider = StreamProvider.autoDispose
    .family<DeviceEntity?, String>((ref, deviceId) {
      final repository = ref.watch(deviceRepositoryProvider);
      return repository.watchDevice(deviceId);
    });

/// ⚠️ DEPRECATED: Duplicado de allPhysicalDevicesProvider (global_providers.dart)
/// Use allPhysicalDevicesProvider em vez deste
@Deprecated('Duplicado. Use allPhysicalDevicesProvider de global_providers')
final deviceListProvider = StreamProvider.autoDispose<List<DeviceEntity>>((
  ref,
) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);

  final repository = ref.watch(deviceRepositoryProvider);
  return repository.watchDevices(home.id);
});
