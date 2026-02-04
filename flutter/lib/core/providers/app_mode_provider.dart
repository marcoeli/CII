import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/domain/enums/app_mode.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Notifier para gerenciar a mudança e persistência do modo
class AppModeNotifier extends Notifier<AppMode> {
  static const String _appModeKey = 'app_mode';

  @override
  AppMode build() {
    _loadMode();
    return AppMode.simple;
  }

  /// Carrega o modo salvo no armazenamento seguro
  Future<void> _loadMode() async {
    try {
      final secureStorage = ref.read(secureCredentialsServiceProvider);
      final savedMode = await secureStorage.readSecure(_appModeKey);
      if (savedMode != null) {
        state = AppMode.fromString(savedMode);
      }
    } catch (_) {
      // Mantém default em caso de erro
    }
  }

  /// Altera o modo e persiste a escolha
  Future<void> setMode(AppMode mode) async {
    if (state == mode) return;
    state = mode;
    try {
      final secureStorage = ref.read(secureCredentialsServiceProvider);
      await secureStorage.saveSecure(_appModeKey, mode.value);
    } catch (_) {
      // Ignora erro de persistência na troca imediata
    }
  }
}

/// Provider que controla o modo de operação do aplicativo
final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  () => AppModeNotifier(),
);
