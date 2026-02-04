import 'package:cii/core/database/app_database.dart';

abstract class IEventRepository {
  /// Monitora eventos de uma casa
  Stream<List<EventEntityV24>> watchEvents(int homeId, {int limit = 100});

  /// Monitora eventos com dados do recurso (para labels amigáveis)
  Stream<List<dynamic>> watchEventsWithResources(int homeId, {int limit = 50});

  /// Monitora apenas contagem de não lidos
  Stream<int> watchUnreadCount(int homeId);

  /// Marca evento como lido
  Future<void> markAsRead(int eventId);

  /// Marca todos eventos da casa como lidos
  Future<void> markAllAsRead(int homeId);
}
