import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier para expor erros globais à UI
///
/// **Uso:**
/// - ViewModels disparam erros via callback `onError`
/// - Provider adapter intercepta e publica aqui
/// - MainScaffold escuta e mostra SnackBar
class ErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Define mensagem de erro (dispara rebuild dos listeners)
  void setError(String message) {
    state = message;
  }

  /// Limpa erro atual
  void clear() {
    state = null;
  }
}

final errorNotifierProvider = NotifierProvider<ErrorNotifier, String?>(
  () => ErrorNotifier(),
);
