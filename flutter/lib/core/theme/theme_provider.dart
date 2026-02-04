import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/theme/app_themes.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Notifier para gerenciar a mudança e persistência do tema
class ThemeNotifier extends Notifier<AppThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.nebula; // Default
  }

  /// Carrega o tema salvo no armazenamento seguro
  Future<void> _loadTheme() async {
    try {
      final secureStorage = ref.read(secureCredentialsServiceProvider);
      final savedTheme = await secureStorage.readSecure(_themeModeKey);
      if (savedTheme != null) {
        state = AppThemeMode.values.firstWhere(
          (m) => m.name == savedTheme,
          orElse: () => AppThemeMode.nebula,
        );
      }
    } catch (_) {
      // Mantém default
    }
  }

  /// Altera o tema e persiste a escolha
  Future<void> setTheme(AppThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    try {
      final secureStorage = ref.read(secureCredentialsServiceProvider);
      await secureStorage.saveSecure(_themeModeKey, mode.name);
    } catch (_) {
      // Ignora erro de persistência
    }
  }
}

/// Provider para o tema atual do aplicativo
final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});
