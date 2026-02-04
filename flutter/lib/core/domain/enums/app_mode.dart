/// Modo de operação do aplicativo
/// Controla complexidade da UI e features disponíveis
enum AppMode {
  /// Modo simples - UI minimalista, apenas recursos essenciais
  simple('SIMPLE', 'Simples'),

  /// Modo avançado - Todas as features para usuários experientes
  advanced('ADVANCED', 'Avançado'),

  /// Modo desenvolvedor - Debug tools, logs, diagnósticos
  dev('DEV', 'Desenvolvedor');

  const AppMode(this.value, this.displayName);

  /// Valor para persistência
  final String value;

  /// Nome para exibição
  final String displayName;

  /// Converte string para AppMode
  static AppMode fromString(String value) {
    try {
      return AppMode.values.firstWhere(
        (mode) => mode.value.toUpperCase() == value.toUpperCase(),
      );
    } catch (e) {
      return AppMode.simple; // Default
    }
  }

  /// Retorna true se modo permite features avançadas
  bool get allowsAdvancedFeatures => this == advanced || this == dev;

  /// Retorna true se modo permite debug tools
  bool get allowsDebugTools => this == dev;

  /// Retorna ícone para o modo
  String get icon {
    switch (this) {
      case AppMode.simple:
        return '📱';
      case AppMode.advanced:
        return '⚙️';
      case AppMode.dev:
        return '🔧';
    }
  }

  String toJson() => value;
}




