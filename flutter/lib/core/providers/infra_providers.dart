import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/database/daos/user_preferences_dao.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/core/mqtt/command_manager.dart';
import 'package:cii/core/mqtt/mqtt_sync_service.dart';
import 'package:cii/core/mqtt/mqtt_client_service.dart';
import 'package:cii/core/data/datasources/mqtt_remote_datasource.dart';
import 'package:cii/core/services/app_provisioning_service.dart';
import 'package:cii/core/services/secure_credentials_service.dart';
import 'package:cii/core/services/alert_service.dart';
import 'package:cii/core/services/provisioning_service.dart';

/// ✅ DEFINITIVO: Providers Riverpod que expõem singletons do Modular
///
/// Garante uma única instância gerenciada por Modular.
/// Riverpod é usado apenas para estado/efeitos, não para DI de infra.

final databaseProvider = Provider<AppDatabase>(
  (ref) => Modular.get<AppDatabase>(),
);

final userPreferencesDaoProvider = Provider<UserPreferencesDao>(
  (ref) => UserPreferencesDao(ref.watch(databaseProvider)),
);

final mqttClientServiceProvider = Provider<MqttClientService>(
  (ref) => Modular.get<MqttClientService>(),
);

final mqttRemoteDataSourceProvider = Provider<MqttRemoteDataSource>(
  (ref) => Modular.get<MqttRemoteDataSource>(),
);

final mqttRepositoryProvider = Provider<MqttRepository>(
  (ref) => Modular.get<MqttRepository>(),
);

final commandManagerProvider = Provider<CommandManager>(
  (ref) => Modular.get<CommandManager>(),
);

final mqttSyncServiceProvider = Provider<MqttSyncService>(
  (ref) => Modular.get<MqttSyncService>(),
);

final appProvisioningServiceProvider = Provider<AppProvisioningService>(
  (ref) => Modular.get<AppProvisioningService>(),
);

final secureCredentialsServiceProvider = Provider<SecureCredentialsService>(
  (ref) => Modular.get<SecureCredentialsService>(),
);

final alertServiceProvider = Provider<AlertService>((ref) => AlertService());

final provisioningServiceProvider = Provider<ProvisioningService>(
  (ref) => ProvisioningService(),
);
