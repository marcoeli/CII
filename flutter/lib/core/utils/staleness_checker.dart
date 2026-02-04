/// Níveis de expiração de dados
enum StalenessLevel {
  /// Dados recentes e confiáveis
  fresh,

  /// Dados começando a ficar antigos (ex: > 1 min)
  slightlyStale,

  /// Dados muito antigos, possivelmente offline (ex: > 5 min)
  veryStale,

  /// Estado de atualização desconhecido
  unknown,
}

/// Utilitário para verificar a "frescura" (staleness) dos dados de telemetria
/// Baseado nos requisitos de UI Pessimista e Verdade Asíncrona (V2.4)
class StalenessChecker {
  static const Duration defaultFreshnessThreshold = Duration(minutes: 1);
  static const Duration defaultStalenessThreshold = Duration(minutes: 5);

  /// Verifica se o dado é considerado expirado (stale)
  static bool isStale(
    DateTime? lastUpdated, {
    Duration threshold = defaultStalenessThreshold,
  }) {
    if (lastUpdated == null) return true;
    final now = DateTime.now();
    return now.difference(lastUpdated) > threshold;
  }

  /// Retorna a duração desde a última atualização
  static Duration? getStalenessDuration(DateTime? lastUpdated) {
    if (lastUpdated == null) return null;
    return DateTime.now().difference(lastUpdated);
  }

  /// Formata o tempo decorrido em string amigável (ex: "5 minutos atrás")
  static String formatRelativeTime(
    DateTime? lastUpdated, {
    bool short = false,
  }) {
    if (lastUpdated == null) return short ? 'N/A' : 'Nunca atualizado';

    final diff = DateTime.now().difference(lastUpdated);

    if (diff.inSeconds < 5) return short ? 'agora' : 'agora mesmo';

    if (short) {
      if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}sem';
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return '${diff.inSeconds}s';
    } else {
      if (diff.inDays >= 60) {
        return formatAbsoluteTime(lastUpdated);
      }
      if (diff.inDays >= 7) {
        final weeks = (diff.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
      }
      if (diff.inDays > 0) {
        return '${diff.inDays} ${diff.inDays == 1 ? 'dia' : 'dias'} atrás';
      }
      if (diff.inHours > 0) {
        return '${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'} atrás';
      }
      if (diff.inMinutes > 0) {
        return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
      }
      return '${diff.inSeconds} ${diff.inSeconds == 1 ? 'segundo' : 'segundos'} atrás';
    }
  }

  /// Determina o nível de expiração baseado em limiares
  static StalenessLevel getStalenessLevel(
    DateTime? lastUpdated, {
    Duration freshnessThreshold = defaultFreshnessThreshold,
    Duration stalenessThreshold = defaultStalenessThreshold,
  }) {
    if (lastUpdated == null) return StalenessLevel.unknown;

    final diff = DateTime.now().difference(lastUpdated);

    if (diff <= freshnessThreshold) return StalenessLevel.fresh;
    if (diff <= stalenessThreshold) return StalenessLevel.slightlyStale;
    return StalenessLevel.veryStale;
  }

  /// Formata o timestamp de forma absoluta (ex: "16/01/2026 20:30:00")
  static String formatAbsoluteTime(
    DateTime? timestamp, {
    bool includeTime = true,
  }) {
    if (timestamp == null) return 'N/A';

    final d = timestamp.day.toString().padLeft(2, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    final y = timestamp.year;

    if (!includeTime) return '$d/$m/$y';

    final h = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');

    return '$d/$m/$y $h:$min:$s';
  }
}
