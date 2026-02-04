import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/iot_models.dart';
import '../models/log_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/log_provider.dart';

class MqttSimulatorService {
  final Ref ref;
  final String server = dotenv.get('MQTT_HOST', fallback: 'mqtt.icodz.com.br');
  final int port =
      int.tryParse(dotenv.get('MQTT_PORT', fallback: '8084')) ?? 8084;
  final String tenant = 'marcoeli';
  final String home = 'casa_teste';

  final _log = Logger('MqttSimulatorService');
  final Map<String, MqttServerClient> _clients = {};
  final Map<String, String> _nodeToProvisionedId = {};

  MqttSimulatorService(this.ref);

  void _logActivity(
    String nodeId,
    String message, {
    String? topic,
    String? payload,
    LogType type = LogType.mqtt,
    bool isError = false,
    bool isOutgoing = false,
  }) {
    ref
        .read(logProvider.notifier)
        .addLog(
          LogMessage(
            timestamp: DateTime.now(),
            nodeId: nodeId,
            message: message,
            topic: topic,
            payload: payload,
            type: type,
            isError: isError,
            isOutgoing: isOutgoing,
          ),
        );
    if (isError) {
      _log.severe('[$nodeId] $message');
    } else {
      _log.info('[$nodeId] $message');
    }
  }

  Future<void> startNode(VirtualNode node) async {
    if (_clients.containsKey(node.id)) return;

    _logActivity(
      node.id,
      'Iniciando fase de BOOT (carregando memória)...',
      type: LogType.tel, // System/Telemetry status
    );

    // 1. Tentar carregar credenciais salvas (NVS Simulation)
    final savedCreds = await _loadNodeCredentials(node.id);
    if (savedCreds != null) {
      final username = savedCreds['user']!;
      _logActivity(
        node.id,
        'Credenciais encontradas na memória ($username). Tentando conexão operacional...',
        type: LogType.tel,
      );

      final realClient = await _connectClient(
        nodeId: node.id,
        username: username,
        password: savedCreds['pass']!,
        clientIdSuffix: 'real',
      );

      if (realClient != null) {
        _clients[node.id] = realClient;
        _nodeToProvisionedId[node.id] = username;
        node.isOnline = true;
        _logActivity(
          node.id,
          '✓ Conectado usando memória (Flash/NVS)',
          type: LogType.tel,
        );
        _startHeartbeat(realClient, node);
        _startTelemetry(realClient, node);
        _listenForCommands(realClient, node);
        return; // Pula SETUP
      } else {
        _logActivity(
          node.id,
          '⚠ Credenciais na memória falharam ou expiraram. Iniciando SETUP...',
          type: LogType.tel,
        );
        await _clearNodeCredentials(node.id);
      }
    }

    _logActivity(
      node.id,
      'Iniciando fase de SETUP (Provisionamento)...',
      type: LogType.tel,
    );

    final setupClient = await _connectClient(
      nodeId: node.id,
      username: dotenv.get('MQTT_SETUP_USER', fallback: 'setup'),
      password: dotenv.get(
        'MQTT_SETUP_PASS',
        fallback: 'BOOTSTRAP_PASSWORD_PLACEHOLDER',
      ),
      clientIdSuffix: 'setup',
    );

    if (setupClient == null) {
      _logActivity(
        node.id,
        'Falha ao conectar para SETUP',
        isError: true,
        type: LogType.err,
      );
      return;
    }

    final correlationId = const Uuid().v4().substring(0, 8);
    final responseTopic = 'setup/$tenant/$home/resposta/$correlationId';

    _logActivity(
      node.id,
      'Aguardando provisionamento no tópico...',
      topic: responseTopic,
      type: LogType.system,
    );

    setupClient.subscribe(responseTopic, MqttQos.atLeastOnce);

    final completer = Completer<Map<String, dynamic>>();
    final subscription = setupClient.updates!.listen((messages) {
      for (var msg in messages) {
        final recMess = msg.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        _logActivity(
          node.id,
          'Mensagem recebida no SETUP: $payload',
          topic: msg.topic,
          type: LogType.mqtt,
        );

        if (msg.topic == responseTopic) {
          _logActivity(
            node.id,
            '✓ Resposta de provisionamento casou com o correlation_id!',
            type: LogType.tel,
          );
          completer.complete(jsonDecode(payload));
        }
      }
    });

    // Enviar Registro
    final regTopic = 'setup/$tenant/$home/registro';

    // Gerar um MAC fixo baseado no nodeId para consistência
    // Usa 3 bytes do hash para garantir unicidade simples no simulador
    final hash = node.id.hashCode;
    final b1 = (hash & 0xFF0000) >> 16;
    final b2 = (hash & 0x00FF00) >> 8;
    final b3 = (hash & 0x0000FF);

    final String mac =
        '00:11:22:${b1.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${b2.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${b3.toRadixString(16).padLeft(2, '0').toUpperCase()}';

    final regPayload = jsonEncode({
      'mac': mac,
      'type': node.role,
      'fw': '2.4',
      'mode': 'dev',
      'dev_token': dotenv.get('DEV_TOKEN', fallback: 'ICODZ-DEV-SECRET-2026'),
      'correlation_id': correlationId,

      'resources': node.resources.map((r) => r.toJson()).toList(),
    });

    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(
      regPayload,
    ); // ✅ FIX: Use addUTF8String for proper encoding
    _log.info('PAYLOAD ENVIADO: $regPayload');
    setupClient.publishMessage(regTopic, MqttQos.atLeastOnce, builder.payload!);
    _logActivity(
      node.id,
      'Registro enviado',
      topic: regTopic,
      isOutgoing: true,
      type: LogType.tel,
    );

    try {
      final response = await completer.future.timeout(
        const Duration(seconds: 30),
      );
      await subscription.cancel();
      setupClient.disconnect();

      final isSuccess =
          response['ok'] == true ||
          response['status'] == 'OK' ||
          response['status'] == 'SUCCESS';

      if (isSuccess) {
        // As credenciais podem vir na raiz (como no log do usuário) ou em sub-objetos
        final username =
            response['username'] ??
            response['user'] ??
            response['credentials']?['username'] ??
            response['mqtt']?['username'] ??
            response['wss']?['username'];

        final password =
            response['password'] ??
            response['credentials']?['password'] ??
            response['mqtt']?['password'] ??
            response['wss']?['password'];

        if (username == null || password == null) {
          throw Exception('Credenciais não encontradas na resposta: $response');
        }

        _logActivity(
          node.id,
          'Provisionamento realizado com sucesso!',
          type: LogType.tel,
        );

        final realClient = await _connectClient(
          nodeId: node.id,
          username: username,
          password: password,
          clientIdSuffix: 'real',
        );

        if (realClient != null) {
          _clients[node.id] = realClient;
          _nodeToProvisionedId[node.id] = username;
          node.isOnline = true;

          // Salvar credenciais (Persistência)
          await _saveNodeCredentials(node.id, username, password);

          _logActivity(
            node.id,
            'Conectado com credenciais reais e salvas na memória',
            type: LogType.tel,
          );

          _startHeartbeat(realClient, node);
          _startTelemetry(realClient, node);
          _listenForCommands(realClient, node);
        }
      } else {
        _logActivity(
          node.id,
          'Erro no provisionamento: ${response['error']}',
          isError: true,
          type: LogType.err,
        );
      }
    } catch (e, s) {
      final errorMsg = e is TimeoutException
          ? 'Timeout no provisionamento'
          : 'Erro no provisionamento: $e';

      _logActivity(node.id, errorMsg, isError: true, type: LogType.err);
      _log.severe('Erro em startNode: $e', e, s);
      await subscription.cancel();
      setupClient.disconnect();
    }
  }

  Future<MqttServerClient?> _connectClient({
    required String nodeId,
    required String username,
    required String password,
    String? clientIdSuffix,
  }) async {
    final effectiveClientId = clientIdSuffix == 'setup'
        ? 'sim_${nodeId}_setup'
        : username;

    final client = MqttServerClient.withPort(
      'wss://$server/mqtt',
      effectiveClientId,
      port,
    );
    client.useWebSocket = true;
    client.port = port;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.onBadCertificate = (dynamic cert) => true;
    client.onDisconnected = () => _onDisconnected(nodeId);
    client.keepAlivePeriod = 20;
    client.setProtocolV311();

    // Configure connection message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(effectiveClientId)
        .startClean();
    client.connectionMessage = connMess;

    try {
      _log.info('→ Simulador tentando conectar: $username');
      final status = await client.connect(username, password);
      if (status?.state == MqttConnectionState.connected) {
        return client;
      } else {
        _log.warning(
          '✗ Falha na conexão: ${status?.state}, returnCode: ${status?.returnCode}',
        );
      }
    } catch (e) {
      _log.severe('✗ Exceção ao conectar $nodeId: $e');
      _logActivity(
        nodeId,
        'Erro técnico: $e',
        isError: true,
        type: LogType.system,
      );
    }
    return null;
  }

  // Placeholder removed, replaced by logic in startNode

  void _startHeartbeat(MqttServerClient client, VirtualNode node) {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!node.isOnline) {
        timer.cancel();
        return;
      }
      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        _log.warning('Heartbeat skipped: Client ${node.id} not connected');
        return;
      }
      node.uptimeSeconds += 30;
      final provisionedId = _nodeToProvisionedId[node.id] ?? node.id;
      final statusTopic = 'home/$tenant/$home/device/$provisionedId/status';
      final builder = MqttClientPayloadBuilder();
      final payload = jsonEncode(node.toStatusJson());
      builder.addUTF8String(payload); // ✅ FIX: Use addUTF8String
      client.publishMessage(
        statusTopic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
      _logActivity(
        node.id,
        'Heartbeat enviado',
        topic: statusTopic,
        payload: payload,
        isOutgoing: true,
      );
    });
  }

  void _startTelemetry(MqttServerClient client, VirtualNode node) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!node.isOnline) {
        timer.cancel();
        return;
      }
      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        return;
      }

      for (final resource in node.resources) {
        final config = resource.automation;

        // Normalização Numérica e Preparação de Dados (V2.4)
        Map<String, dynamic> currentData = {};
        resource.data.forEach((k, v) {
          currentData[k] = resource.roundValue(v);
        });

        // Injeção de Anomalias
        if (config.anomalyRate > 0 &&
            math.Random().nextDouble() < config.anomalyRate) {
          currentData['alert'] = 'SENSOR_FAIL';
          currentData['status'] = 'CORRUPTED';
        }

        final now = DateTime.now();
        final secondsSinceLastDataPublish = resource.lastDataPublishTs == null
            ? 9999
            : now.difference(resource.lastDataPublishTs!).inSeconds;
        final secondsSinceLastStatePublish = resource.lastStatePublishTs == null
            ? 9999
            : now.difference(resource.lastStatePublishTs!).inSeconds;

        // 1. Lógica de TELEMETRIA (/data)
        bool isActuator =
            resource.kind == ResourceKind.pump ||
            resource.kind == ResourceKind.valve;
        bool hasMeaningfulData =
            currentData.isNotEmpty &&
            !(currentData.length == 1 && currentData.containsKey('ts'));

        if (!isActuator && hasMeaningfulData) {
          // Calcula Hash excluindo metadados de transporte (ts) para evitar loop
          final dataForHash = Map<String, dynamic>.from(currentData)
            ..remove('ts')
            ..remove('reason');
          final dataHash = jsonEncode(dataForHash);

          bool dataChanged = dataHash != resource.lastPublishedDataHash;

          // Lógica de Delta (V2.4): Evita publicar ruído insignificante
          bool significantChange = true;
          if (resource.lastPublishedDataHash != null) {
            try {
              final lastData =
                  jsonDecode(resource.lastPublishedDataHash!)
                      as Map<String, dynamic>;

              if (resource.kind == ResourceKind.climate) {
                final tDiff =
                    ((currentData['temperature'] ?? 0.0) -
                            (lastData['temperature'] ?? 0.0))
                        .abs();
                final hDiff =
                    ((currentData['humidity'] ?? 0.0) -
                            (lastData['humidity'] ?? 0.0))
                        .abs();
                // Temperatura >= 0.2 ou Humid >= 1.0 para disparar
                significantChange = tDiff >= 0.2 || hDiff >= 1.0;
              } else if (resource.kind == ResourceKind.level) {
                final lastPct = (lastData['percent'] ?? 0.0).toDouble();
                final currentPct = (currentData['percent'] ?? 0.0).toDouble();
                // Nível >= 0.5% para disparar
                significantChange = (currentPct - lastPct).abs() >= 0.5;
              }
            } catch (_) {
              significantChange = true;
            }
          }

          bool shouldPublishData =
              config.burstMode ||
              (dataChanged && significantChange) ||
              secondsSinceLastDataPublish >= 300;

          if (shouldPublishData) {
            // Cria cópia para envio com timestamp, mas não polui o resource.data original
            final publishMap = Map<String, dynamic>.from(currentData);
            publishMap['ts'] = now.millisecondsSinceEpoch ~/ 1000;

            final payloadStr = jsonEncode(publishMap);
            final telemetryTopic = 'home/$tenant/$home/r/${resource.id}/data';
            final builder = MqttClientPayloadBuilder();
            builder.addUTF8String(payloadStr);

            client.publishMessage(
              telemetryTopic,
              MqttQos.atMostOnce,
              builder.payload!,
              retain: true,
            );
            resource.lastPublishedDataHash = dataHash;
            resource.lastDataPublishTs = now;

            _logActivity(
              node.id,
              config.burstMode
                  ? 'Telemetry (BURST MODE)'
                  : 'Telemetria enviada',
              topic: telemetryTopic,
              payload: payloadStr,
              isOutgoing: true,
              type: config.burstMode ? LogType.mqtt : LogType.tel,
            );
          }
        }

        // 2. Lógica de ESTADO (/state)
        if (resource.state.isNotEmpty) {
          Map<String, dynamic> currentState = {};
          resource.state.forEach((k, v) {
            currentState[k] = resource.roundValue(v);
          });

          // Hash de estado exclui metadados transitórios (ts, reasoning interno)
          final stateForHash = Map<String, dynamic>.from(currentState)
            ..remove('ts')
            ..remove('correlation_id');
          final stateHash = jsonEncode(stateForHash);

          bool stateChanged = stateHash != resource.lastPublishedStateHash;
          bool shouldPublishState =
              stateChanged || secondsSinceLastStatePublish >= 300;

          if (shouldPublishState) {
            final publishState = Map<String, dynamic>.from(currentState);
            publishState['ts'] = now.millisecondsSinceEpoch ~/ 1000;

            final statePayload = jsonEncode(publishState);
            final stateTopic = 'home/$tenant/$home/r/${resource.id}/state';
            final stateBuilder = MqttClientPayloadBuilder();
            stateBuilder.addUTF8String(statePayload);

            client.publishMessage(
              stateTopic,
              MqttQos.atLeastOnce,
              stateBuilder.payload!,
              retain: true,
            );
            resource.lastPublishedStateHash = stateHash;
            resource.lastStatePublishTs = now;

            _logActivity(
              node.id,
              'Estado atualizado',
              topic: stateTopic,
              payload: statePayload,
              isOutgoing: true,
              type: LogType.tel,
            );
          }
        }
      }
    });
  }

  void _listenForCommands(MqttServerClient client, VirtualNode node) {
    // Subscrição específica por recurso para evitar "Resource not found" de outros nós
    for (final resource in node.resources) {
      final commandTopic = 'home/$tenant/$home/r/${resource.id}/command';
      client.subscribe(commandTopic, MqttQos.atLeastOnce);
    }

    client.updates?.listen((messages) {
      for (var msg in messages) {
        final topic = msg.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (msg.payload as MqttPublishMessage).payload.message,
        );

        _logActivity(
          node.id,
          'Comando recebido',
          topic: topic,
          payload: payload,
          type: LogType.cmd,
        );
        _handleCommand(client, node, topic, payload);
      }
    });
  }

  void _handleCommand(
    MqttServerClient client,
    VirtualNode node,
    String topic,
    String payload,
  ) {
    try {
      final data = jsonDecode(payload);
      final parts = topic.split('/');
      if (parts.length < 5) return;
      final resourceId = parts[4];
      final action = data['action'];

      _log.info('Node ${node.id} received command for $resourceId: $action');

      // Find the resource using a loop to avoid exception
      ResourceModel? resource;
      for (final res in node.resources) {
        if (res.id == resourceId) {
          resource = res;
          break;
        }
      }

      if (resource == null) {
        _log.warning('Resource $resourceId not found in node ${node.id}');

        // Send error result back
        final resultTopic = 'home/$tenant/$home/r/$resourceId/result';
        final resultPayload = jsonEncode({
          'correlation_id': data['correlation_id'],
          'status': 'ERROR',
          'detail': 'Resource not found',
          'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });

        final builder = MqttClientPayloadBuilder();
        builder.addUTF8String(resultPayload);
        client.publishMessage(
          resultTopic,
          MqttQos.atLeastOnce,
          builder.payload!,
        );

        _logActivity(
          node.id,
          'Resultado enviado: ERROR - Resource not found',
          topic: resultTopic,
          isOutgoing: true,
          type: LogType.err,
        );
        return; // Exit early since resource wasn't found
      }

      // Update state based on action and resource type
      switch (action) {
        case 'START':
        case 'ON':
          resource.state['running'] = true;
          resource.state['on'] = true;
          break;
        case 'STOP':
        case 'OFF':
          resource.state['running'] = false;
          resource.state['on'] = false;
          break;
        case 'OPEN':
          resource.state['open'] = true;
          break;
        case 'CLOSE':
          resource.state['open'] = false;
          break;
        case 'SET':
          // Handle SET commands with parameters
          final params = data['params'] as Map<String, dynamic>?;
          if (params != null) {
            if (params.containsKey('on')) {
              resource.state['on'] = params['on'] as bool;
            }
            if (params.containsKey('brightness')) {
              resource.state['brightness'] = params['brightness'] as int;
            }
            if (params.containsKey('watts')) {
              resource.state['watts'] = params['watts'] as double;
            }
          }
          break;
        case 'TRIGGER':
          // For sensors that can trigger events
          if (resource.kind == ResourceKind.presence ||
              resource.kind == ResourceKind.doorbell) {
            resource.state['detected'] = true;

            // Publish EVENT (V2.4 asynchronous event)
            final eventTopic =
                'home/$tenant/$home/event/${resource.domain.name}/${resource.kind.name}/${resource.id}';
            final eventPayload = jsonEncode({
              'alert': resource.kind == ResourceKind.doorbell
                  ? 'DOORBELL'
                  : 'MOTION',
              'severity': 'info',
              'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            });

            final eb = MqttClientPayloadBuilder();
            eb.addUTF8String(eventPayload);
            client.publishMessage(eventTopic, MqttQos.atLeastOnce, eb.payload!);
            _logActivity(
              node.id,
              'Evento enviado',
              topic: eventTopic,
              isOutgoing: true,
              type: LogType.tel,
            );

            // Reset after a delay
            final currentResource = resource;
            Future.delayed(const Duration(seconds: 5), () {
              currentResource.state['detected'] = false;
            });
          }
          break;
        default:
          _log.warning('Unknown action: $action for resource $resourceId');
      }

      // Publish result
      final resultTopic = 'home/$tenant/$home/r/$resourceId/result';
      final resultPayload = jsonEncode({
        'correlation_id': data['correlation_id'],
        'status': 'OK',
        'detail': 'Command processed successfully',
        'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(resultPayload);
      client.publishMessage(resultTopic, MqttQos.atLeastOnce, builder.payload!);

      _logActivity(
        node.id,
        'Resultado enviado: OK',
        topic: resultTopic,
        payload: resultPayload,
        isOutgoing: true,
        type: LogType.ack,
      );
    } catch (e, s) {
      _log.severe('Error handling command: $e', s);
      _logActivity(
        node.id,
        'Erro ao processar comando: $e',
        isError: true,
        type: LogType.err,
      );
    }
  }

  void _onDisconnected(String nodeId) {
    _log.warning('Node $nodeId disconnected');
    _clients.remove(nodeId);
  }

  // --- Persistence Methods (NVS Emulation) ---

  Future<void> _saveNodeCredentials(
    String nodeId,
    String user,
    String pass,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('node_${nodeId}_user', user);
    await prefs.setString('node_${nodeId}_pass', pass);
  }

  Future<Map<String, String>?> _loadNodeCredentials(String nodeId) async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('node_${nodeId}_user');
    final pass = prefs.getString('node_${nodeId}_pass');

    if (user != null && pass != null) {
      return {'user': user, 'pass': pass};
    }
    return null;
  }

  Future<void> _clearNodeCredentials(String nodeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('node_${nodeId}_user');
    await prefs.remove('node_${nodeId}_pass');
  }

  Future<void> factoryReset(String nodeId) async {
    _logActivity(
      nodeId,
      'Executando Factory Reset (Limpando NVS)...',
      type: LogType.system,
    );
    await stopNode(nodeId);
    await _clearNodeCredentials(nodeId);
  }

  Future<void> stopNode(String nodeId) async {
    _clients[nodeId]?.disconnect();
    _clients.remove(nodeId);
  }

  void sendCommand(
    String nodeId,
    String resourceId,
    Map<String, dynamic> command,
  ) {
    final client = _clients[nodeId];
    if (client == null) {
      _log.warning('Cliente não encontrado para $nodeId');
      return;
    }

    final commandTopic = 'home/$tenant/$home/r/$resourceId/command';
    final builder = MqttClientPayloadBuilder();

    // Adicionar timestamp se não existir
    if (!command.containsKey('ts')) {
      command['ts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    builder.addUTF8String(jsonEncode(command)); // ✅ FIX: Use addUTF8String
    client.publishMessage(commandTopic, MqttQos.atLeastOnce, builder.payload!);

    _logActivity(
      nodeId,
      'Comando enviado: ${command['action']}',
      topic: commandTopic,
      isOutgoing: true,
    );
  }

  void publishResourceUpdate(
    String nodeId,
    String resourceId, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? state,
  }) {
    final client = _clients[nodeId];
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (data != null) {
      final topic = 'home/$tenant/$home/r/$resourceId/data';
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(jsonEncode({...data, 'ts': ts}));
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
    }

    if (state != null) {
      final topic = 'home/$tenant/$home/r/$resourceId/state';
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(jsonEncode({...state, 'ts': ts}));
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true,
      );
    }
  }
}
