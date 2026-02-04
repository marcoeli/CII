import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttLogEntry {
  final DateTime timestamp;
  final String topic;
  final String payload;
  final bool isOutgoing;

  MqttLogEntry({
    required this.timestamp,
    required this.topic,
    required this.payload,
    this.isOutgoing = false,
  });
}

class MqttClientService {
  final _log = Logger('MqttClientService');
  late MqttServerClient _client;
  bool _isInitialized = false;

  // Stable controller for updates (Pipes events from _client.updates)
  final _updatesController =
      StreamController<List<MqttReceivedMessage<MqttMessage>>>.broadcast();
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates =>
      _updatesController.stream;

  final _connectionStateController =
      StreamController<MqttConnectionState>.broadcast();
  Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  final _logController = StreamController<MqttLogEntry>.broadcast();
  Stream<MqttLogEntry> get logStream => _logController.stream;

  // Subscription tracking
  final Set<String> _subscribedTopics = {};

  // Pipe subscription
  StreamSubscription? _updatesSubscription;

  // MQTT broker configuration
  final String _server = dotenv.get('MQTT_HOST', fallback: 'mqtt.icodz.com.br');
  final int _port =
      int.tryParse(dotenv.get('MQTT_PORT', fallback: '8084')) ?? 8084;
  final String _clientIdentifier =
      'flutter_app_${const Uuid().v4().substring(0, 8)}';

  MqttClientConnectionStatus? get connectionStatus =>
      _isInitialized ? _client.connectionStatus : null;

  MqttServerClient? get client => _isInitialized ? _client : null;

  /// Get list of subscribed topics (immutable)
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);

  bool _isConnecting = false;

  Future<void> connect({
    String? username,
    String? password,
    String? broker,
    int? port,
  }) async {
    if (_isConnecting) {
      _log.info('MQTT connection already in progress, skipping...');
      return;
    }

    if (_isInitialized &&
        _client.connectionStatus?.state == MqttConnectionState.connected) {
      _log.info('MQTT already connected, skipping...');
      return;
    }

    _isConnecting = true;
    _log.info('═══════════════════════════════════════');
    _log.info('Initializing MQTT connection (WSS)');
    _log.info('Server: ${broker ?? _server}');
    _log.info('Port: ${port ?? _port}');
    _log.info('Client ID: $_clientIdentifier');
    _log.info('═══════════════════════════════════════');

    // Load ISRG Root X1 Certificate
    final context = SecurityContext.defaultContext;
    try {
      final byteData = await rootBundle.load('assets/ca/isrg_root_x1.pem');
      context.setTrustedCertificatesBytes(byteData.buffer.asUint8List());
      _log.info('✓ Loaded Trusted Certificate: ISRG Root X1');
    } catch (e) {
      _log.severe('✗ Failed to load certificate: $e');
      throw Exception('Failed to load MQTT certificate');
    }

    // WebSocket Secure URL
    final wsServer = 'wss://${broker ?? _server}/mqtt';
    _log.info('📡 Connecting to: $wsServer (WebSocket Secure)');

    _client = MqttServerClient.withPort(
      wsServer,
      _clientIdentifier,
      port ?? _port,
    );
    _isInitialized = true;

    // Configure WebSocket mode
    _client.useWebSocket = true;
    _client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    // Set MQTT protocol version
    _client.setProtocolV311();

    // Enable logging to see connection details
    _client.logging(on: true);
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;

    // Connection timeout
    _client.connectTimeoutPeriod = 10000;

    _client.onBadCertificate = (dynamic certificate) => true;

    // Event handlers
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;

    // Connection message
    final connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .startClean();
    _client.connectionMessage = connMess;

    try {
      _log.info(
        '→ Attempting connection with user: ${username ?? 'ANONYMOUS'}',
      );
      final status = await _client.connect(username, password);

      // Note: _onConnected is called inside connect if successful
      // But we check status here too for safety/logging
      if (status != null && status.state != MqttConnectionState.connected) {
        _connectionStateController.add(status.state);
        _log.severe(
          '✗ Connection failed! Status: ${status.state}, Return Code: ${status.returnCode}',
        );
      }
    } catch (e) {
      _log.severe('✗ Unexpected exception: $e');
      _client.disconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _setupUpdatesPipe() {
    _updatesSubscription?.cancel();
    if (_client.updates != null) {
      _updatesSubscription = _client.updates!.listen(
        (messages) {
          if (!_updatesController.isClosed) {
            _updatesController.add(messages);

            // Also log
            for (final c in messages) {
              final recMess = c.payload as MqttPublishMessage;
              final payload = MqttPublishPayload.bytesToStringAsString(
                recMess.payload.message,
              );
              _logController.add(
                MqttLogEntry(
                  timestamp: DateTime.now(),
                  topic: c.topic,
                  payload: payload,
                ),
              );
            }
          }
        },
        onError: (e) {
          _log.warning('Error in client updates stream: $e');
        },
      );
      _log.info('✓ Updates stream pipe established');
    }
  }

  void _onConnected() {
    _log.info('✓✓✓ MQTT CONNECTED (Callback) ✓✓✓');
    _setupUpdatesPipe(); // Ensure pipe is set up immediately
    _connectionStateController.add(MqttConnectionState.connected);
    // Process queued subscriptions
    resubscribeAll();
  }

  void _onDisconnected() {
    _log.warning('✗✗✗ MQTT DISCONNECTED ✗✗✗');
    _log.warning('Last status: ${connectionStatus?.state}');
    _connectionStateController.add(MqttConnectionState.disconnected);
  }

  void _onSubscribed(String topic) {
    _log.info('✓ Subscribed to: $topic');
  }

  void _onAutoReconnect() {
    _log.info('⟳ Auto-reconnecting...');
  }

  void _onAutoReconnected() {
    _log.info('✓ Auto-reconnected successfully');
    _setupUpdatesPipe(); // Ensure pipe is restored
    Future.delayed(const Duration(seconds: 2), () {
      resubscribeAll();
    });
  }

  void subscribe(String topic) {
    _subscribedTopics.add(topic);
    if (connectionStatus?.state != MqttConnectionState.connected) {
      _log.info('⏳ Queueing subscription for $topic (Client not connected)');
      return;
    }
    try {
      _log.info('→ Subscribing to: $topic');
      _client.subscribe(topic, MqttQos.atLeastOnce);
    } catch (e) {
      _log.severe('✗ Error subscribing to $topic: $e');
    }
  }

  void unsubscribe(String topic) {
    _subscribedTopics.remove(topic);
    if (connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    try {
      _log.info('← Unsubscribing from: $topic');
      _client.unsubscribe(topic);
    } catch (e) {
      _log.severe('✗ Error unsubscribing from $topic: $e');
    }
  }

  void resubscribeAll() {
    if (_subscribedTopics.isEmpty) return;

    _log.info('📝 Resubscribing to ${_subscribedTopics.length} topics...');
    final topics = _subscribedTopics.toList();
    for (final topic in topics) {
      try {
        _client.subscribe(topic, MqttQos.atLeastOnce);
        _log.info('✓ Resubscribed to: $topic');
      } catch (e) {
        _log.severe('✗ Error resubscribing to $topic: $e');
      }
    }
  }

  void unsubscribeAll() {
    if (_subscribedTopics.isEmpty) return;

    _log.info('Clearing all ${_subscribedTopics.length} subscriptions...');
    final topics = _subscribedTopics.toList();
    for (final topic in topics) {
      unsubscribe(topic);
    }
  }

  void publish(String topic, String payload, {bool retain = false}) {
    if (connectionStatus?.state != MqttConnectionState.connected) {
      _log.warning('⚠ Cannot publish to $topic: Client not connected');
      return;
    }
    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);
      _client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: retain,
      );
      _logController.add(
        MqttLogEntry(
          timestamp: DateTime.now(),
          topic: topic,
          payload: payload,
          isOutgoing: true,
        ),
      );
      _log.info('→ Published to $topic: $payload');
    } catch (e) {
      _log.severe('✗ Error publishing to $topic: $e');
    }
  }

  void disconnect() {
    try {
      _log.info('Disconnecting from MQTT broker...');
      if (_isInitialized) _client.disconnect();
    } catch (e) {
      _log.warning('⚠ Error during disconnect: $e');
    }
  }
}
