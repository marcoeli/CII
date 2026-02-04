import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/data/repositories/events_repository.dart';
import 'package:cii/core/services/alert_service.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Provider que assiste eventos do sistema no DB para a Home ativa
final allSystemEventsProvider = StreamProvider<List<EventEntityV24>>((ref) {
  debugPrint('[EventsProvider] allSystemEventsProvider initializing...');
  final db = ref.watch(databaseProvider);

  // Fix: Obter homeId dinâmico da Home selecionada
  // Usando global_providers para selectedHomeProvider
  final activeHome = ref.watch(selectedHomeProvider);

  if (activeHome == null) {
    // Se não tem home, retornamos uma stream vazia para não quebrar a UI
    debugPrint(
      '[EventsProvider] No active home selected. Emitting empty stream.',
    );
    return const Stream.empty();
  }

  // Usa o ID da home selecionada
  final stream = db.eventsV24Dao.watchEventsByHome(activeHome.id, limit: 50);

  return stream.map((events) {
    debugPrint(
      '[EventsProvider] 📡 Provider emitting ${events.length} events to UI',
    );
    return events;
  });
});

/// Provider do repository (NÃO inicializa automaticamente)
/// EventsMonitor chama startListening() quando apropriado
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final mqtt = ref.watch(mqttClientServiceProvider);

  final repo = EventsRepository(db, mqtt);
  // NÃO chama startListening() aqui para evitar race condition

  ref.onDispose(() => repo.dispose());

  return repo;
});

/// Provider que gerencia AlertService
final alertServiceProvider = Provider<AlertService>((ref) {
  final service = AlertService();
  ref.onDispose(() => service.dispose());
  return service;
});
