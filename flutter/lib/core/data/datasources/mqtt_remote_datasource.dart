import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cii/core/mqtt/mqtt_client_service.dart';
import 'package:cii/core/utils/mqtt_payload_parser.dart';
import 'package:cii/modules/water/domain/entities/water_level.dart';
import 'package:cii/modules/water/domain/entities/pump.dart';
import 'package:cii/core/domain/entities/device_status.dart';
import 'package:cii/core/domain/entities/device_error.dart';
import 'package:cii/modules/environment/domain/entities/environment.dart';
import 'package:cii/modules/environment/domain/entities/gas_sensor.dart';
import 'package:cii/modules/events/domain/entities/presence.dart';
import 'package:cii/modules/events/domain/entities/doorbell_event.dart';
import 'package:cii/core/domain/entities/device_config.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';

/// Data Source responsible for raw MQTT interactions and parsing
class MqttRemoteDataSource {
  final MqttClientService _clientService;
  final MqttPayloadParser _parser;
  final _log = Logger('MqttRemoteDataSource');

  // Stream Controllers
  final _deviceStatusController = StreamController<DeviceStatus>.broadcast();
  final _deviceErrorController = StreamController<DeviceError>.broadcast();
  final _pumpController = StreamController<Pump>.broadcast();
  final _waterLevelController = StreamController<WaterLevel>.broadcast();
  final _environmentController = StreamController<Environment>.broadcast();
  final _gasSensorController = StreamController<GasSensor>.broadcast();
  final _doorbellController = StreamController<DoorbellEvent>.broadcast();
  final _presenceController = StreamController<Presence>.broadcast();
  final _deviceConfigController = StreamController<DeviceConfig>.broadcast();
  final _resourceMetaController =
      StreamController<Map<String, dynamic>>.broadcast();

  // ✅ FIX A2: Stream para command results (fecha comandos pendentes)
  final _commandResultController =
      StreamController<Map<String, dynamic>>.broadcast();

  // ✅ FIX A3: Stream para events genéricos (V2.4)
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription? _mqttSubscription;

  MqttRemoteDataSource(this._clientService) : _parser = MqttPayloadParser();

  // Exposed Streams
  Stream<DeviceStatus> get deviceStatusStream => _deviceStatusController.stream;
  Stream<DeviceError> get deviceErrorStream => _deviceErrorController.stream;
  Stream<Pump> get pumpStream => _pumpController.stream;
  Stream<WaterLevel> get waterLevelStream => _waterLevelController.stream;
  Stream<Environment> get environmentStream => _environmentController.stream;
  Stream<GasSensor> get gasSensorStream => _gasSensorController.stream;
  Stream<DoorbellEvent> get doorbellStream => _doorbellController.stream;
  Stream<Presence> get presenceStream => _presenceController.stream;
  Stream<DeviceConfig> get deviceConfigStream => _deviceConfigController.stream;
  Stream<Map<String, dynamic>> get resourceMetaStream =>
      _resourceMetaController.stream;

  // ✅ FIX A2+A3: Novos streams
  Stream<Map<String, dynamic>> get commandResultStream =>
      _commandResultController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  Stream<BrokerConnectionState> get connectionStateStream {
    return _clientService.connectionStateStream.map((state) {
      if (state == MqttConnectionState.connected) {
        return BrokerConnectionState.connected;
      }
      if (state == MqttConnectionState.connecting) {
        return BrokerConnectionState.connecting;
      }
      if (state == MqttConnectionState.faulted) {
        return BrokerConnectionState.failed;
      }
      return BrokerConnectionState.disconnected;
    });
  }

  // Expose current state properly
  BrokerConnectionState get currentConnectionState {
    final state = _clientService.connectionStatus?.state;
    if (state == MqttConnectionState.connected) {
      return BrokerConnectionState.connected;
    }
    if (state == MqttConnectionState.connecting) {
      return BrokerConnectionState.connecting;
    }
    if (state == MqttConnectionState.faulted) {
      return BrokerConnectionState.failed;
    }
    return BrokerConnectionState.disconnected;
  }

  /// Initialize and start listening
  void initialize() {
    _log.info('Initializing MqttRemoteDataSource...');
    _listenToMessages();
  }

  void _listenToMessages() {
    if (_clientService.updates == null) {
      _log.warning(
        'Client updates stream is null. Ensure client is connected.',
      );
      return;
    }

    _mqttSubscription?.cancel();
    _mqttSubscription = _clientService.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage>> c) {
        // ✅ FIX A1: Processar TODAS as mensagens do batch (retained burst)
        for (final message in c) {
          final recMess = message.payload as MqttPublishMessage;
          final pt = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          final topic = message.topic;
          _parseMessage(topic, pt);
        }
      },
      onError: (e) {
        _log.severe('Error in MQTT stream: $e');
      },
    );
  }

  void _parseMessage(String topic, String payload) {
    try {
      final parts = topic.split('/');
      if (parts.length < 5) return; // home/{tenant}/{home}/... length >= 4+?

      // 1. Identificar Prefixo de Contexto
      // home/{tenant}/{home}/...
      if (parts[0] != 'home') return;

      // (Tenant e Home identificados via partes[1] e partes[2] se necessário)

      // 2. Descoberta de Metadados (V2.4 UX Layer)
      // home/{tenant}/{home}/meta/resource/{resource_id}
      if (parts[3] == 'meta' && parts[4] == 'resource' && parts.length == 6) {
        final resourceId = parts[5];
        final result = _parser.parseJson(payload, topic: topic);
        if (result.success) {
          final meta = Map<String, dynamic>.from(result.data!);
          meta['resource_id'] = resourceId;
          _resourceMetaController.add(meta);
          _log.info('Meta discovered for $resourceId: $payload');
        }
        return;
      }

      // 3. Dados Operacionais de Recursos (V2.4 Operational Layer)
      // home/{tenant}/{home}/r/{resource_id}/{leaf}
      if (parts[3] == 'r' && parts.length == 6) {
        final resourceId = parts[4];
        final leaf = parts[5];

        if (leaf == 'data' || leaf == 'state') {
          // Identify type by resourceId prefix or metadata cache
          // For now, mapping by pattern
          if (resourceId.contains('level')) {
            final result = _parser.parseWaterLevel(payload, topic);
            if (result.success) {
              final entity = WaterLevel.fromJson(result.data!, resourceId);
              _waterLevelController.add(entity);
            }
          } else if (resourceId.contains('pump')) {
            final result = _parser.parsePumpState(payload, topic);
            if (result.success) {
              final entity = Pump.fromJson(result.data!, resourceId);
              _pumpController.add(entity);
            }
          } else if (resourceId.contains('env') ||
              resourceId.contains('climate')) {
            final result = _parser.parseEnvironment(payload, topic);
            if (result.success) {
              final entity = Environment.fromJson(result.data!, resourceId);
              _environmentController.add(entity);
            }
          }
        }
        return;
      }

      // 4. Status do Dispositivo Físico
      // home/{tenant}/{home}/device/{device_id}/status
      if (parts[3] == 'device' && parts.length == 6 && parts[5] == 'status') {
        final deviceId = parts[4];
        final result = _parser.parseDeviceStatus(payload, topic);
        if (result.success) {
          final entity = DeviceStatus.fromJson(result.data!, deviceId);
          _deviceStatusController.add(entity);
        }
        return;
      }

      // 5. Erros do Dispositivo
      // home/{tenant}/{home}/device/{device_id}/errors
      if (parts[3] == 'device' && parts.length == 6 && parts[5] == 'errors') {
        final deviceId = parts[4];
        final result = _parser.parseDeviceError(payload, topic);
        if (result.success) {
          final entity = DeviceError.fromJson(result.data!, deviceId);
          _deviceErrorController.add(entity);
        }
        return;
      }

      // 6. Config do Dispositivo
      // home/{tenant}/{home}/device/{device_id}/config
      if (parts[3] == 'device' && parts.length == 6 && parts[5] == 'config') {
        final deviceId = parts[4];
        final result = _parser.parseDeviceConfig(payload, topic);
        if (result.success) {
          final entity = DeviceConfig.fromJson(result.data!, deviceId);
          _deviceConfigController.add(entity);
        }
        return;
      }

      // ✅ FIX A2: Command Result (fecha comandos pendentes)
      // home/{tenant}/{home}/r/{resource_id}/result
      if (parts[3] == 'r' && parts.length >= 6 && parts[5] == 'result') {
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          data['topic'] = topic;
          data['resource_id'] = parts[4];
          _commandResultController.add(data);
        } catch (e) {
          _log.warning('Failed to parse command result: $e');
        }
        return;
      }

      // ✅ FIX A3: Events (V2.4)
      // home/{tenant}/{home}/event/{domain}/{kind}/{resource_id}
      if (parts[3] == 'event' && parts.length >= 7) {
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          data['topic'] = topic;
          data['domain'] = parts[4];
          data['kind'] = parts[5];
          data['resource_id'] = parts[6];
          _eventController.add(data);
        } catch (e) {
          _log.warning('Failed to parse event: $e');
        }
        return;
      }

      // Legacy Fallback (for other projects not yet V2.4)
      _parseLegacyMessage(topic, payload, parts);
    } catch (e, s) {
      _log.severe('Error parsing message $topic: $e', e, s);
    }
  }

  void _parseLegacyMessage(String topic, String payload, List<String> parts) {
    // 🗑️ LEGACY REMOVED: Strict V2.4 Enforcement
    // Tópicos antigos (home/water/...) são ignorados para evitar comportamento zumbi.
    _log.finest('Ignored legacy/unknown topic: $topic');
  }

  Future<void> publishCommand(
    String topic,
    Map<String, dynamic> payload, {
    bool retain = false,
  }) async {
    _clientService.publish(topic, jsonEncode(payload), retain: retain);
  }

  // ✅ FIX A4: publishConfig deve usar retain (config é estado persistente)
  Future<void> publishConfig(
    String topic,
    Map<String, dynamic> payload, {
    bool retain = true, // Config deve persistir no broker
  }) async {
    _clientService.publish(topic, jsonEncode(payload), retain: retain);
  }

  Future<void> connect({
    String? username,
    String? password,
    String? broker,
    int? port,
  }) async {
    await _clientService.connect(
      username: username,
      password: password,
      broker: broker,
      port: port,
    );
    _listenToMessages();
  }

  /// Forces a refresh of all subscriptions to trigger retained messages from broker
  void refreshSubscriptions(List<String> topics) {
    // 1. Clear ALL existing subscriptions first (The Ghost Buster 👻)
    _clientService.unsubscribeAll();

    // 2. Subscribe to new topics
    for (final topic in topics) {
      _clientService.subscribe(topic);
    }
    _log.info('Refreshed subscriptions. Active topics: ${topics.length}');
  }

  Future<void> disconnect() async {
    _clientService.disconnect();
  }

  void subscribe(String topic) {
    _clientService.subscribe(topic);
  }

  // ✅ FIX A6: Fechar TODOS os controllers (memory leak fix)
  void dispose() {
    _mqttSubscription?.cancel();
    _deviceStatusController.close();
    _deviceErrorController.close();
    _pumpController.close();
    _waterLevelController.close();
    _environmentController.close();
    _gasSensorController.close();
    _doorbellController.close();
    _presenceController.close();
    _deviceConfigController.close();
    _resourceMetaController.close(); // FIX: Estava faltando!
    _commandResultController.close(); // FIX A2: Novo controller
    _eventController.close(); // FIX A3: Novo controller
  }
}
