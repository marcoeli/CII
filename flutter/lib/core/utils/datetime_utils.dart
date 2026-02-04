class DateTimeUtils {
  /// Retorna a diferença em minutos
  static int minutesSince(DateTime? lastUpdated) {
    if (lastUpdated == null) return 999999;
    return DateTime.now().difference(lastUpdated).inMinutes;
  }

  /// Retorna true se a data for anterior ao threshold (default 5 minutos)
  static bool isStale(DateTime? lastUpdated, {int minutes = 5}) {
    return minutesSince(lastUpdated) >= minutes;
  }

  /// Retorna uma string amigável de tempo decorrido
  static String timeSince(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'N/A';
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  /// Formatação relativa completa para eventos
  static String formatRelative(DateTime? date) {
    if (date == null) return 'Data desconhecida';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'Há ${diff.inHours} horas';
    if (diff.inDays == 1) {
      return 'Ontem às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
