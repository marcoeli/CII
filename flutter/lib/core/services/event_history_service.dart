import 'dart:convert';
import 'package:cii/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

/// Serviço de Histórico de Eventos V2.4
class EventHistoryService {
  final AppDatabase _db;
  final _log = Logger('EventHistoryService');

  /// Limite padrão de eventos armazenados
  static const int defaultMaxEvents = 500;

  EventHistoryService(this._db);

  /// Adiciona um novo evento ao histórico (V2.4)
  Future<int> addEvent({
    required int homeId,
    required String domain,
    required String kind,
    required String severity,
    int? resourceId,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final id = await _db.eventsV24Dao.insertEvent(
        EventsV24Companion.insert(
          homeId: homeId,
          domain: domain,
          kind: kind,
          severity: Value(severity),
          resourceId: Value(resourceId),
          payloadJson: Value(payload != null ? jsonEncode(payload) : null),
          timestamp: DateTime.now(),
          read: const Value(false),
        ),
      );

      _log.info('📝 Event added: $domain.$kind (Home: $homeId)');
      return id;
    } catch (e) {
      _log.severe('Error adding event: $e');
      rethrow;
    }
  }

  /// Stream de eventos recentes por Home
  Stream<List<EventEntityV24>> watchEvents(int homeId, {int limit = 50}) {
    return _db.eventsV24Dao.watchEventsByHome(homeId, limit: limit);
  }

  /// Marca evento como lido
  Future<void> markAsRead(int eventId) => _db.eventsV24Dao.markAsRead(eventId);

  /// Marca todos de uma home como lidos
  Future<void> markAllAsRead(int homeId) =>
      _db.eventsV24Dao.markAllAsRead(homeId);

  /// Limpa todos os eventos de uma home
  Future<void> clearAllEvents(int homeId) async {
    try {
      await (_db.delete(
        _db.eventsV24,
      )..where((e) => e.homeId.equals(homeId))).go();
      _log.info('🗑️ All events cleared for home $homeId');
    } catch (e) {
      _log.severe('Error clearing events: $e');
    }
  }
}
