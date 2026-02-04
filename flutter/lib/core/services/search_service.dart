import 'package:cii/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Serviço de Busca para V2.4
class SearchService {
  final AppDatabase _db;

  SearchService(this._db);

  /// Busca global em dispositivos, recursos e eventos
  Future<SearchResults> globalSearch(String query) async {
    if (query.isEmpty) {
      return SearchResults.empty();
    }

    final devices = await _searchDevices(query);
    final resources = await _searchResources(query);
    final events = await _searchEvents(query);

    return SearchResults(
      devices: devices,
      resources: resources,
      events: events,
    );
  }

  /// Busca em dispositivos
  Future<List<DeviceEntity>> _searchDevices(String query) async {
    final searchPattern = '%${query.toLowerCase()}%';

    return await (_db.select(_db.devicesV24)
          ..where(
            (d) =>
                d.deviceId.lower().like(searchPattern) |
                d.vendor.lower().like(searchPattern) |
                d.model.lower().like(searchPattern),
          )
          ..limit(20))
        .get();
  }

  /// Busca em recursos
  Future<List<ResourceEntity>> _searchResources(String query) async {
    final searchPattern = '%${query.toLowerCase()}%';

    return await (_db.select(_db.resourcesV24)
          ..where(
            (r) =>
                r.resourceId.lower().like(searchPattern) |
                r.label.lower().like(searchPattern) |
                r.room.lower().like(searchPattern) |
                r.domain.lower().like(searchPattern) |
                r.kind.lower().like(searchPattern),
          )
          ..limit(20))
        .get();
  }

  /// Busca em eventos V2.4
  Future<List<EventEntityV24>> _searchEvents(String query) async {
    final searchPattern = '%${query.toLowerCase()}%';

    return await (_db.select(_db.eventsV24)
          ..where(
            (e) =>
                e.domain.lower().like(searchPattern) |
                e.kind.lower().like(searchPattern) |
                e.payloadJson.lower().like(searchPattern),
          )
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.timestamp, mode: OrderingMode.desc),
          ])
          ..limit(20))
        .get();
  }

  /// Filtra recursos por domínio
  Future<List<ResourceEntity>> filterByDomain(String domain) async {
    return await (_db.select(_db.resourcesV24)
          ..where((r) => r.domain.equals(domain))
          ..orderBy([(r) => OrderingTerm(expression: r.label)]))
        .get();
  }

  /// Filtra recursos por sala
  Future<List<ResourceEntity>> filterByRoom(String room) async {
    return await (_db.select(_db.resourcesV24)
          ..where((r) => r.room.equals(room))
          ..orderBy([(r) => OrderingTerm(expression: r.label)]))
        .get();
  }

  /// Obtém lista de salas únicas
  Future<List<String>> getRooms() async {
    final resources = await _db.select(_db.resourcesV24).get();
    return resources.map((r) => r.room).whereType<String>().toSet().toList()
      ..sort();
  }

  /// Obtém lista de domínios
  Future<List<String>> getDomains() async {
    final resources = await _db.select(_db.resourcesV24).get();
    return resources.map((r) => r.domain).toSet().toList()..sort();
  }
}

/// Resultado de busca global V2.4
class SearchResults {
  final List<DeviceEntity> devices;
  final List<ResourceEntity> resources;
  final List<EventEntityV24> events;

  const SearchResults({
    required this.devices,
    required this.resources,
    required this.events,
  });

  factory SearchResults.empty() {
    return const SearchResults(devices: [], resources: [], events: []);
  }

  bool get isEmpty => devices.isEmpty && resources.isEmpty && events.isEmpty;

  int get totalResults => devices.length + resources.length + events.length;
}
