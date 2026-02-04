import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/alert_provider.dart';

/// Monitor de Sistema Global
/// Agora apenas garante que o [alertProvider] seja inicializado e mantido ativo.
class SystemMonitor extends ConsumerWidget {
  final Widget child;
  const SystemMonitor({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o alertProvider para garantir que a lógica de áudio rode
    // mesmo que o widget não use o estado diretamente.
    ref.watch(alertProvider);

    return child;
  }
}
