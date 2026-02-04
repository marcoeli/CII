/// Níveis de status do sistema
enum SystemStatusLevel { ok, warning, critical, offline }

/// Dados consolidados do status do sistema para UI de Header
class SystemStatus {
  final bool isOnline;
  final DateTime lastUpdate;
  final bool hasCriticalError;
  final bool hasWarning;
  final bool isDoorbellRecent;
  final String activeHomeLabel;
  final String? statusMessage;

  const SystemStatus({
    required this.isOnline,
    required this.lastUpdate,
    required this.hasCriticalError,
    required this.hasWarning,
    required this.isDoorbellRecent,
    required this.activeHomeLabel,
    this.statusMessage,
  });

  /// Calcula o nível geral de status baseado nos indicadores
  SystemStatusLevel get level {
    if (!isOnline) {
      return SystemStatusLevel.offline;
    }
    if (hasCriticalError) {
      return SystemStatusLevel.critical;
    }
    if (hasWarning || isDoorbellRecent) {
      return SystemStatusLevel.warning;
    }
    return SystemStatusLevel.ok;
  }

  factory SystemStatus.initial() {
    return SystemStatus(
      isOnline: false,
      lastUpdate: DateTime.now(),
      hasCriticalError: false,
      hasWarning: false,
      isDoorbellRecent: false,
      activeHomeLabel: 'Iniciando...',
      statusMessage: 'Conectando...',
    );
  }

  SystemStatus copyWith({
    bool? isOnline,
    DateTime? lastUpdate,
    bool? hasCriticalError,
    bool? hasWarning,
    bool? isDoorbellRecent,
    String? activeHomeLabel,
    String? statusMessage,
  }) {
    return SystemStatus(
      isOnline: isOnline ?? this.isOnline,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      hasCriticalError: hasCriticalError ?? this.hasCriticalError,
      hasWarning: hasWarning ?? this.hasWarning,
      isDoorbellRecent: isDoorbellRecent ?? this.isDoorbellRecent,
      activeHomeLabel: activeHomeLabel ?? this.activeHomeLabel,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
