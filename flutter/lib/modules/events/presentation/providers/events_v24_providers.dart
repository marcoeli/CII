import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';

final homeEventsProvider = StreamProvider<List<EventEntityV24>>((ref) {
  final db = ref.watch(databaseProvider);
  final home = ref.watch(selectedHomeProvider);

  if (home == null) return Stream.value([]);

  return db.eventsV24Dao.watchEventsByHome(home.id);
});

final unreadEventsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final home = ref.watch(selectedHomeProvider);

  if (home == null) return Stream.value(0);

  return db.eventsV24Dao.watchUnreadCount(home.id);
});
