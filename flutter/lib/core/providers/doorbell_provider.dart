import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Provider que observa eventos de campainha recentes (últimos 2 minutos)
/// Utilizado pelo status global do sistema para alertas no cabeçalho.
final recentDoorbellProvider = Provider<String?>((ref) {
  // Observa todos os eventos do sistema via DB (reativo)
  final eventsAsync = ref.watch(homeEventsProvider);

  return eventsAsync.when(
    data: (events) {
      // Filtrar apenas eventos de campainha
      final doorbells = events.where((e) => e.kind == 'doorbell').toList();
      if (doorbells.isEmpty) return null;

      // Ordenar por timestamp (mais recente primeiro)
      doorbells.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latest = doorbells.first;

      // Se o evento ocorreu nos últimos 2 minutos, consideramos "recente"
      final diff = DateTime.now().difference(latest.timestamp);
      if (diff.inMinutes < 2) {
        // Nome amigável do local (fallback para payload ou desconhecido)
        final location = _getFriendlyLocation(latest.payloadJson ?? 'unknown');
        return 'Campainha tocada: $location';
      }

      return null;
    },
    loading: () => null,
    error: (e, s) => null,
  );
});

/// Converte ID do local para nome amigável (copiado de utilitários de UI)
String _getFriendlyLocation(String id) {
  switch (id.toLowerCase()) {
    case 'entrance':
    case 'entradaprincipal':
      return 'Entrada Principal';
    case 'gate':
    case 'portao':
      return 'Portão';
    case 'backdoor':
    case 'fundos':
      return 'Fundos';
    default:
      return id;
  }
}
