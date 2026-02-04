/// Validador de Timestamps conforme Protocolo V2.4
///
/// Regras:
/// - Timestamps são inteiros (Unix Epoch Seconds).
/// - Mensagens com timestamp <= último conhecido são descartadas (fora de ordem).
/// - Opcionalmente, mensagens muito antigas (stale) podem ser rejeitadas.
class TimestampValidator {
  /// Valida se o novo timestamp é mais recente que o atual
  bool isNewer(int newTs, int? currentTs) {
    if (currentTs == null) return true;
    return newTs > currentTs;
  }

  /// Converte timestamp Unix Epoch (seconds) para DateTime
  DateTime parseEpoch(int ts) {
    return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  }

  /// Retorna o timestamp atual em Unix Epoch Seconds (padrão V2.4)
  int now() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Verifica se um timestamp é muito antigo (ex: > 1 hora atrás)
  bool isStale(int ts, {int maxAgeSeconds = 3600}) {
    final currentTs = now();
    return (currentTs - ts) > maxAgeSeconds;
  }

  /// Verifica se um timestamp está no futuro (com tolerância de 5 min)
  bool isFuture(int ts, {int toleranceSeconds = 300}) {
    final currentTs = now();
    return ts > (currentTs + toleranceSeconds);
  }
}
