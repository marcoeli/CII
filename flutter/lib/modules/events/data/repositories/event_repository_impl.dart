import 'package:cii/core/database/app_database.dart';

import 'package:cii/modules/events/domain/repositories/i_event_repository.dart';

class EventRepositoryImpl implements IEventRepository {
  final AppDatabase _db;

  EventRepositoryImpl(this._db);

  @override
  Stream<List<EventEntityV24>> watchEvents(int homeId, {int limit = 100}) {
    // Note: EventsV24Dao.watchEventsByHome already exists and handles this
    return _db.eventsV24Dao.watchEventsByHome(homeId, limit: limit);
  }

  @override
  Stream<List<dynamic>> watchEventsWithResources(int homeId, {int limit = 50}) {
    return _db.eventsV24Dao.watchEventsWithResources(homeId, limit: limit);
  }

  @override
  Stream<int> watchUnreadCount(int homeId) {
    return _db.eventsV24Dao.watchUnreadCount(homeId);
  }

  @override
  Future<void> markAsRead(int eventId) {
    return _db.eventsV24Dao.markAsRead(eventId);
  }

  @override
  Future<void> markAllAsRead(int homeId) {
    return _db.eventsV24Dao.markAllAsRead(homeId);
  }
}
