import 'package:flutter_modular/flutter_modular.dart';
import 'package:cii/core/services/secure_credentials_service.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/core/data/repositories/mqtt_repository_impl.dart';
import 'package:cii/core/mqtt/mqtt_client_service.dart';
import 'package:cii/core/mqtt/mqtt_sync_service.dart';
import 'package:cii/core/data/datasources/mqtt_remote_datasource.dart';
import 'package:cii/core/mqtt/command_manager.dart';
import 'package:cii/core/session/session_context.dart';
import 'package:cii/core/session/riverpod_session_context_provider.dart';
import 'package:cii/core/services/app_provisioning_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CoreModule gerencia toda infr aestrutura via Modular
/// Riverpod apenas expõe esses singletons (via providers que fazem Modular.get)
class CoreModule extends Module {
  final ProviderContainer container;

  CoreModule(this.container);

  @override
  void binds(Injector i) {
    // Database
    i.addSingleton<AppDatabase>(AppDatabase.new);

    // Services
    i.addSingleton<SecureCredentialsService>(SecureCredentialsService.new);
    i.addSingleton<AppProvisioningService>(
      () => AppProvisioningService(
        i.get<MqttClientService>(),
        i.get<SecureCredentialsService>(),
      ),
    );

    // MQTT Infrastructure
    i.addSingleton<MqttClientService>(MqttClientService.new);

    i.addSingleton<MqttRemoteDataSource>(
      () => MqttRemoteDataSource(i.get<MqttClientService>()),
    );

    // Session Context Provider (ponte Riverpod para Modular)
    i.addSingleton<SessionContextProvider>(
      () => RiverpodSessionContextProvider(container),
    );

    // Command Manager
    i.addSingleton<CommandManager>(() => CommandManager(i.get<AppDatabase>()));

    // MQTT Sync Service (persiste mensagens MQTT no DB)
    i.addSingleton<MqttSyncService>(
      () => MqttSyncService(i.get<MqttClientService>(), i.get<AppDatabase>()),
    );

    // MQTT Repository (Interface + Implementação)
    i.addSingleton<MqttRepository>(
      () => MqttRepositoryImpl(
        remoteDataSource: i.get<MqttRemoteDataSource>(),
        contextProvider: i.get<SessionContextProvider>(),
        commandManager: i.get<CommandManager>(),
        secureStorage: i.get<SecureCredentialsService>(),
      ),
    );
  }
}
