import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cii/app/app_module.dart';
import 'package:cii/app/app_widget.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';
import 'package:cii/core/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");
      final prefs = await SharedPreferences.getInstance();

      // Configure Logging
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        debugPrint(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
        );
      });

      // Inicializar serviço de notificações
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Solicitar permissões de notificação
      await notificationService.requestPermissions();

      // ✅ DEFINITIVO: Bridge Riverpod + Modular
      // Container criado aqui e passado para AppModule → CoreModule
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: ModularApp(
            module: AppModule(container),
            child: const AppWidget(),
          ),
        ),
      );
    },
    (error, stack) {
      // Log fatal errors to console/service instead of crashing
      debugPrint('🔴 GLOBAL ERROR CAUGHT: $error');
      debugPrint(stack.toString());
    },
  );
}
