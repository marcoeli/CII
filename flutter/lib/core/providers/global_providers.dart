import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/infra_providers.dart';
import 'package:cii/core/providers/session_state.dart'; // selectedHomeProvider, sessionProvider
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/database/daos/devices_dao.dart'; // ✅ Import DeviceWithHardware

export 'package:cii/core/providers/infra_providers.dart';

export 'package:cii/core/providers/session_state.dart';

// ✅ DEFINITIVO: Providers apenas para estado e efeitos
// Infra (DB, MQTT, CommandManager) vem de infra_providers (via Modular)

/// Broker Connection State Stream
final brokerConnectionStateProvider = StreamProvider<BrokerConnectionState>((
  ref,
) async* {
  final repo = ref.watch(mqttRepositoryProvider);
  yield repo.currentConnectionState;
  yield* repo.connectionState;
});

/// Home Events Provider (Global)
final homeEventsProvider = StreamProvider<List<EventEntityV24>>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);
  return ref.watch(databaseProvider).eventsV24Dao.watchEventsByHome(home.id);
});

/// Home Errors Provider (Global)
final allErrorsProvider = StreamProvider<List<EventEntityV24>>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);
  return ref.watch(databaseProvider).eventsV24Dao.watchHomeErrors(home.id);
});

/// Physical Devices Provider (Global) - Retorna DeviceWithHardware
final allPhysicalDevicesProvider = StreamProvider<List<DeviceWithHardware>>((
  ref,
) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);
  return ref
      .watch(databaseProvider)
      .devicesDao
      .watchDevicesWithHardware(home.id);
});

/// Resources by Home Provider (V2.4)
final resourcesByHomeProvider = StreamProvider<List<ResourceEntity>>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);
  return ref.watch(databaseProvider).resourcesDao.watchResourcesByHome(home.id);
});

/// Resource state by technical ID provider
final resourceStateByTechnicalIdProvider = StreamProvider.autoDispose
    .family<ResourceStateEntity?, (int, String)>((ref, arg) {
      final homeId = arg.$1;
      final resourceId = arg.$2;
      return ref
          .watch(databaseProvider)
          .resourcesDao
          .watchStateByTechnicalId(homeId, resourceId);
    });
