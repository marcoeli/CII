import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/theme/app_themes.dart';
import 'package:cii/core/theme/theme_provider.dart';
import 'package:cii/core/widgets/events_monitor.dart';
import 'package:cii/core/providers/session_effects.dart';

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final theme = AppThemes.getTheme(themeMode);

    // ✅ FASE 1: Ativar side-effects centralizados (MQTT start/stop)
    ref.watch(sessionEffectsProvider);

    return EventsMonitor(
      child: MaterialApp.router(
        title: 'Casa Inteligente Icodz',
        debugShowCheckedModeBanner: false,
        theme: theme,
        routerConfig: Modular.routerConfig,
      ),
    );
  }
}
