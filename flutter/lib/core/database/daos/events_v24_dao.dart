import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/v24_tables.dart';

part 'events_v24_dao.g.dart';

@DriftAccessor(tables: [EventsV24])
class EventsV24Dao extends DatabaseAccessor<AppDatabase>
    with _$EventsV24DaoMixin {
  EventsV24Dao(super.db);

  Future<int> insertEvent(EventsV24Companion event) =>
      into(eventsV24).insert(event);

  Stream<List<EventEntityV24>> watchEventsByHome(int homeId, {int limit = 50}) {
    return (select(eventsV24)
          ..where((e) => e.homeId.equals(homeId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<int> watchUnreadCount(int homeId) {
    return (select(eventsV24)
          ..where((e) => e.homeId.equals(homeId) & e.read.equals(false)))
        .watch()
        .map((list) => list.length);
  }

  Stream<List<EventEntityV24>> watchHomeErrors(int homeId) {
    return (select(eventsV24)
          ..where(
            (e) =>
                e.homeId.equals(homeId) &
                (e.severity.equals('critical') | e.severity.equals('warning')),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<TypedResult>> watchEventsWithResources(
    int homeId, {
    int limit = 50,
  }) {
    final query =
        select(eventsV24).join([
            leftOuterJoin(
              resourcesV24,
              resourcesV24.id.equalsExp(eventsV24.resourceId),
            ),
          ])
          ..where(eventsV24.homeId.equals(homeId))
          ..orderBy([
            OrderingTerm(
              expression: eventsV24.timestamp,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit);

    return query.watch();
  }

  Future<List<EventEntityV24>> getRecentEvents(int homeId, {int limit = 10}) {
    return (select(eventsV24)
          ..where((e) => e.homeId.equals(homeId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> markAsRead(int eventId) async {
    await (update(eventsV24)..where((e) => e.id.equals(eventId))).write(
      const EventsV24Companion(read: Value(true)),
    );
  }

  Future<void> markAllAsRead(int homeId) async {
    await (update(eventsV24)..where((e) => e.homeId.equals(homeId))).write(
      const EventsV24Companion(read: Value(true)),
    );
  }

  Future<EventEntityV24?> getLastEvent(int resourceId) {
    return (select(eventsV24)
          ..where((e) => e.resourceId.equals(resourceId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
