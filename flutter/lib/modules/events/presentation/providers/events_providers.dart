import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/events/data/repositories/event_repository_impl.dart';
import 'package:cii/modules/events/domain/repositories/i_event_repository.dart';

/// Repository Provider
final eventRepositoryProvider = Provider<IEventRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EventRepositoryImpl(db);
});

/// Stream of events for the current home
final eventsStreamProvider = StreamProvider.autoDispose<List<EventEntityV24>>((
  ref,
) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEvents(home.id);
});

/// Stream of events with resource metadata (for friendly names)
final eventsWithResourcesStreamProvider =
    StreamProvider.autoDispose<List<dynamic>>((ref) {
      final home = ref.watch(selectedHomeProvider);
      if (home == null) return Stream.value([]);

      final repository = ref.watch(eventRepositoryProvider);
      return repository.watchEventsWithResources(home.id);
    });

/// Stream of unread count for the current home
final eventsUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(0);

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchUnreadCount(home.id);
});

/// Stream of occupancy (presence/doorbell) resources
final occupancyResourcesProvider =
    StreamProvider.autoDispose<List<ResourceEntity>>((ref) {
      final home = ref.watch(selectedHomeProvider);
      if (home == null) return Stream.value([]);

      final db = ref.watch(databaseProvider);
      return db.resourcesDao.watchResourcesByMultipleKinds(home.id, [
        'presence',
        'doorbell',
      ]);
    });
