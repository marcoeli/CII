/// Severidade de um evento
enum EventSeverity {
  /// Crítico - requer atenção imediata
  critical('CRITICAL'),

  /// Aviso - importante mas não urgente
  warning('WARNING'),

  /// Informação - apenas informativo
  info('INFO');

  const EventSeverity(this.value);
  final String value;

  static EventSeverity? fromString(String value) {
    try {
      return EventSeverity.values.firstWhere(
        (s) => s.value.toUpperCase() == value.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  String toJson() => value;
}




