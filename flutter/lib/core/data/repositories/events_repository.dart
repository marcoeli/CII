import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/mqtt/mqtt_client_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

/// Repository responsável por escutar eventos MQTT e salvá-los no banco de dados
class EventsRepository {
  final AppDatabase _db;
  final MqttClientService _mqtt;
  StreamSubscription? _mqttSub;
  bool _isListening = false;

  EventsRepository(this._db, this._mqtt);

  /// Inicia escuta de eventos MQTT quando MQTT estiver conectado
  void startListening() {
    debugPrint('[EventsRepository] ========================================');
    debugPrint('[EventsRepository] startListening() called');
    debugPrint(
      '[EventsRepository] Connection state: ${_mqtt.connectionStatus?.state}',
    );
    debugPrint('[EventsRepository] ========================================');

    // Verificar se já está conectado
    final status = _mqtt.connectionStatus;
    if (status?.state == MqttConnectionState.connected) {
      debugPrint(
        '[EventsRepository] ✓ MQTT already connected, subscribing now...',
      );
      _subscribeToTopics();
    } else {
      debugPrint(
        '[EventsRepository] ✗ MQTT not connected yet (state: ${status?.state}), will retry...',
      );
      // Retry após delay
      Future.delayed(const Duration(seconds: 3), () {
        debugPrint('[EventsRepository] Retrying initial check after delay...');
        startListening();
      });
    }
  }

  void _subscribeToTopics() {
    if (_isListening) {
      debugPrint('[EventsRepository] Already listening, skipping...');
      return;
    }

    final status = _mqtt.connectionStatus;
    if (status?.state != MqttConnectionState.connected) {
      debugPrint('[EventsRepository] ⚠ MQTT not connected, waiting...');
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isListening) _subscribeToTopics();
      });
      return;
    }

    try {
      // V2.4 Subscriptions
      // Tópicos de Eventos: home/{tenant}/{home}/event/{domain}/{kind}/{resource_id}
      _mqtt.subscribe('home/+/+/event/#');

      // Tópicos de Erros de Dispositivo: home/{tenant}/{home}/device/{device_id}/errors
      _mqtt.subscribe('home/+/+/device/+/errors');

      _mqttSub = _mqtt.updates?.listen((messages) {
        for (final m in messages) {
          final topic = m.topic;
          final payload = MqttPublishPayload.bytesToStringAsString(
            (m.payload as MqttPublishMessage).payload.message,
          );
          _handleV24Message(topic, payload);
        }
      });

      _isListening = true;
      debugPrint('[EventsRepository] ✅ Subscribed to V2.4 event topics');
    } catch (e) {
      debugPrint('[EventsRepository] ❌ Error: $e');
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isListening) _subscribeToTopics();
      });
    }
  }

  Future<void> _handleV24Message(String topic, String payload) async {
    try {
      final parts = topic.split('/');
      if (parts.length < 4) return;

      final tenantId = parts[1];
      final homeIdStr = parts[2];
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // 1. Resolver Home Internal ID
      final home = await _db.tenantsHomesDao.getHomeByTenantAndHomeId(
        tenantId,
        homeIdStr,
      );
      if (home == null) {
        debugPrint(
          '[EventsRepository] ⚠ Home not found in DB: $tenantId/$homeIdStr',
        );
        return;
      }

      if (parts[3] == 'event' && parts.length >= 7) {
        // home/{tenant}/{home}/event/{domain}/{kind}/{resource_id}
        final domain = parts[4];
        final kind = parts[5];
        final resourceId = parts[6];

        // 2. Resolver Resource Internal ID
        final resource = await _db.resourcesDao.getResourceByTechnicalId(
          home.id,
          resourceId,
        );

        await _db.eventsV24Dao.insertEvent(
          EventsV24Companion.insert(
            homeId: home.id,
            resourceId: Value(resource?.id),
            domain: domain,
            kind: kind,
            severity: Value(
              data['severity']?.toString().toLowerCase() ?? 'info',
            ),
            payloadJson: Value(payload),
            timestamp: DateTime.now(),
            read: const Value(false),
          ),
        );
        debugPrint('[EventsRepository] ✓ Event saved: $domain.$kind');
      } else if (parts[3] == 'device' &&
          parts.length >= 6 &&
          parts[5] == 'errors') {
        // home/{tenant}/{home}/device/{device_id}/errors
        final deviceId = parts[4];

        await _db.eventsV24Dao.insertEvent(
          EventsV24Companion.insert(
            homeId: home.id,
            domain: 'device',
            kind: 'error',
            severity: Value(
              data['severity']?.toString().toLowerCase() ?? 'critical',
            ),
            payloadJson: Value(payload),
            timestamp: DateTime.now(),
            read: const Value(false),
          ),
        );
        debugPrint('[EventsRepository] ✓ Device error saved for: $deviceId');
      }
    } catch (e) {
      debugPrint('[EventsRepository] ❌ Error handling message: $e');
    }
  }

  void dispose() {
    debugPrint('[EventsRepository] Disposing...');
    _mqttSub?.cancel();
    _isListening = false;
  }
}
