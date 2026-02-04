import 'dart:async';
import 'package:logging/logging.dart';

import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/core/data/datasources/mqtt_remote_datasource.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/session/session_context.dart';
import 'package:cii/core/mqtt/command_manager.dart';
import 'package:cii/core/services/secure_credentials_service.dart';

/// ✅ DEFINITIVO: MqttRepository sem dependência de Riverpod
///
/// Usa SessionContextProvider para obter tenant/home quando necessário,
/// permitindo que seja instanciado pelo Modular de forma limpa.
class MqttRepositoryImpl implements MqttRepository {
  final MqttRemoteDataSource _remoteDataSource;
  final SessionContextProvider _contextProvider;
  final CommandManager _commandManager;
  final SecureCredentialsService _secureStorage;

  final _log = Logger('MqttRepository');

  final _connectionStateController =
      StreamController<BrokerConnectionState>.broadcast();

  MqttRepositoryImpl({
    required MqttRemoteDataSource remoteDataSource,
    required SessionContextProvider contextProvider,
    required CommandManager commandManager,
    required SecureCredentialsService secureStorage,
  }) : _remoteDataSource = remoteDataSource,
       _contextProvider = contextProvider,
       _commandManager = commandManager,
       _secureStorage = secureStorage {
    _init();
  }

  void _init() {
    _remoteDataSource.connectionStateStream.listen((state) {
      _connectionStateController.add(_mapConnectionState(state));
    });
  }

  /// Obtém contexto obrigatório ou lança StateError
  SessionContext _requireContext() {
    final ctx = _contextProvider.current;
    if (ctx == null) {
      throw StateError(
        'No active session context. Please select a tenant and home.',
      );
    }
    return ctx;
  }

  BrokerConnectionState _mapConnectionState(dynamic state) {
    if (state == BrokerConnectionState.connected) {
      return BrokerConnectionState.connected;
    }
    if (state == BrokerConnectionState.connecting) {
      return BrokerConnectionState.connecting;
    }
    if (state == BrokerConnectionState.failed) {
      return BrokerConnectionState.failed;
    }
    return BrokerConnectionState.disconnected;
  }

  @override
  BrokerConnectionState get currentConnectionState =>
      _mapConnectionState(_remoteDataSource.currentConnectionState);

  @override
  Stream<BrokerConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Future<void> connect() async {
    final credentials = await _secureStorage.getMqttCredentials();
    if (credentials != null) {
      _log.info(
        'Connecting with stored credentials for ${credentials.username}',
      );
      await _remoteDataSource.connect(
        username: credentials.username,
        password: credentials.password,
        broker: credentials.broker,
      );
    } else {
      _log.warning('No stored credentials found. MQTT connection skipped.');
    }
  }

  @override
  Future<void> disconnect() => _remoteDataSource.disconnect();

  @override
  Future<bool> sendPumpCommand(
    String pumpId,
    bool turnOn, {
    bool force = false,
  }) async {
    final ctx = _requireContext();
    final action = turnOn ? 'START' : 'STOP';

    // 1. Criar Comando Gerenciado (Persistência Imediata)
    String correlationId;
    try {
      correlationId = await _commandManager.createCommand(
        resourceId: pumpId,
        action: action,
        params: {'force': force},
        origin: 'app',
      );
    } catch (e) {
      _log.severe('Failed to create command: $e');
      return false;
    }

    final topic = 'home/${ctx.tenantId}/${ctx.homeId}/r/$pumpId/command';

    // 2. Payload V2.4 Strict
    final payload = {
      'action': action,
      'params': {'force': force},
      'origin': 'app',
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'correlation_id': correlationId,
    };

    // 3. Envio com Retry (Backoff Exponencial)
    int attempt = 0;
    bool published = false;
    while (attempt < 3) {
      try {
        await _remoteDataSource.publishCommand(topic, payload);
        published = true;
        break;
      } catch (e) {
        attempt++;
        _log.warning('Attempt $attempt failed to send command: $e');
        if (attempt >= 3) {
          await _commandManager.complete(correlationId, success: false);
          return false;
        }
        await Future.delayed(Duration(seconds: 1 * attempt));
      }
    }

    if (!published) return false;

    // 4. Aguardar Confirmação
    return await _commandManager.waitForCompletion(correlationId);
  }

  @override
  Future<bool> setPumpMode(String pumpId, String mode) async {
    final ctx = _requireContext();

    String correlationId;
    try {
      correlationId = await _commandManager.createCommand(
        resourceId: pumpId,
        action: 'SET_MODE',
        params: {'mode': mode},
        origin: 'app',
      );
    } catch (e) {
      _log.severe('Failed to create command: $e');
      return false;
    }

    final topic = 'home/${ctx.tenantId}/${ctx.homeId}/r/$pumpId/command';

    final payload = {
      'action': 'SET_MODE',
      'params': {'mode': mode},
      'origin': 'app',
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'correlation_id': correlationId,
    };

    int attempt = 0;
    bool published = false;
    while (attempt < 3) {
      try {
        await _remoteDataSource.publishCommand(topic, payload);
        published = true;
        break;
      } catch (e) {
        attempt++;
        if (attempt >= 3) {
          await _commandManager.complete(correlationId, success: false);
          return false;
        }
        await Future.delayed(Duration(seconds: 1 * attempt));
      }
    }

    if (!published) return false;

    return await _commandManager.waitForCompletion(correlationId);
  }

  // ✅ FIX B2: Separar device config vs resource config (tópicos diferentes + retain)
  @override
  Future<bool> sendDeviceConfig(
    String deviceId,
    Map<String, dynamic> config,
  ) async {
    try {
      final ctx = _requireContext();
      final topic =
          'home/${ctx.tenantId}/${ctx.homeId}/device/$deviceId/config';
      await _remoteDataSource.publishConfig(topic, config, retain: true);
      return true;
    } catch (e) {
      _log.severe('Failed to send device config: $e');
      return false;
    }
  }

  @override
  Future<bool> sendResourceConfig(
    String resourceId,
    Map<String, dynamic> config,
  ) async {
    try {
      final ctx = _requireContext();
      final topic = 'home/${ctx.tenantId}/${ctx.homeId}/r/$resourceId/config';
      await _remoteDataSource.publishConfig(topic, config, retain: true);
      return true;
    } catch (e) {
      _log.severe('Failed to send resource config: $e');
      return false;
    }
  }

  @override
  Future<void> refreshDevices({TenantEntity? tenant, HomeEntity? home}) async {
    // Permite override de contexto (útil para testes ou casos especiais)
    // Se não fornecido, usa o contexto atual
    final ctx = _contextProvider.current;

    String? tenantId = tenant?.tenantId ?? ctx?.tenantId;
    String? homeId = home?.homeId ?? ctx?.homeId;

    _log.info('Refreshing devices/subscriptions...');
    _log.info('Tenant: $tenantId, Home: $homeId');

    if (tenantId == null || homeId == null) {
      _log.warning('⚠ Cannot refresh: Tenant or Home is null');
      return;
    }

    // ✅ FIX B1: Delegar subscriptions para MqttSyncService (via SessionViewModel)
    // O Repository não deve mais gerenciar subscriptions de dados para evitar conflito de wildcards
    // e "unsubscribeAll" agressivo.
    _log.info(
      '✅ Repository refresh requested (No-Op for Subs). SyncService handles "home/$tenantId/$homeId/#"',
    );
    // _remoteDataSource.refreshSubscriptions(topics); // REMOVIDO
  }

  @override
  Future<bool> updateResourceMeta({
    required String resourceId,
    String? label,
    String? room,
    String? icon,
  }) async {
    try {
      final ctx = _requireContext();
      final topic =
          'home/${ctx.tenantId}/${ctx.homeId}/meta/resource/$resourceId';

      final payload = {
        'resource_id': resourceId,
        'label': label,
        'room': room,
        'icon': icon,
        'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'updated_by': 'app',
      };

      await _remoteDataSource.publishCommand(topic, payload, retain: true);
      return true;
    } catch (e) {
      _log.severe('Failed to update resource meta: $e');
      return false;
    }
  }

  @override
  void clearSubscriptions() {
    _log.info('Clearing all subscriptions...');
    _remoteDataSource.refreshSubscriptions([]);
  }

  @override
  void dispose() {
    _connectionStateController.close();
  }
}
