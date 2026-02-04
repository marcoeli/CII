import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

import '../mqtt/mqtt_client_service.dart';
import 'secure_credentials_service.dart';

class AppProvisioningService {
  final _log = Logger('AppProvisioningService');
  final MqttClientService _mqttService;
  final SecureCredentialsService _secureStorage;

  AppProvisioningService(this._mqttService, this._secureStorage);

  /// Realiza o bootstrap do App para um determinado tenant/home usando um Claim Code
  Future<bool> bootstrapApp({
    required String tenant,
    required String home,
    required String claimCode,
  }) async {
    _log.info('Starting App Bootstrap for $tenant/$home...');

    // 1. Conectar como setup
    final setupUser = dotenv.get('MQTT_SETUP_USER', fallback: 'setup');
    final setupPass = dotenv.get(
      'MQTT_SETUP_PASS',
      fallback: 'BOOTSTRAP_PASSWORD_PLACEHOLDER',
    );

    try {
      await _mqttService.connect(username: setupUser, password: setupPass);
    } catch (e) {
      _log.severe('Failed to connect for App bootstrap: $e');
      return false;
    }

    if (_mqttService.connectionStatus?.state != MqttConnectionState.connected) {
      return false;
    }

    final correlationId = const Uuid().v4().substring(0, 8);
    final responseTopic = 'setup/$tenant/$home/resposta/$correlationId';
    final registrationTopic = 'setup/$tenant/$home/registro';

    final completer = Completer<Map<String, dynamic>>();

    _log.info('Subscribing to response topic: $responseTopic');
    _mqttService.subscribe(responseTopic);

    final subscription = _mqttService.updates?.listen((messages) {
      for (final msg in messages) {
        if (msg.topic == responseTopic) {
          final recMess = msg.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          _log.info('Received bootstrap response: $payload');
          completer.complete(jsonDecode(payload));
        }
      }
    });

    // 2. Enviar Registro do App
    final appRegistrationPayload = {
      'type': 'app',
      'claim_code': claimCode,
      'correlation_id': correlationId,
      'app_id': 'flutter_app_${const Uuid().v4().substring(0, 8)}',
    };

    _log.info('Sending app registration to $registrationTopic');
    _mqttService.publish(registrationTopic, jsonEncode(appRegistrationPayload));

    try {
      final response = await completer.future.timeout(
        const Duration(seconds: 30),
      );
      await subscription?.cancel();
      _mqttService.disconnect();

      if (response['ok'] == true || response['status'] == 'SUCCESS') {
        final username =
            response['username'] ?? response['credentials']?['username'];
        final password =
            response['password'] ?? response['credentials']?['password'];

        if (username != null && password != null) {
          // 3. Salvar credenciais recebidas (Tenant-Scoped)
          await _secureStorage.saveMqttCredentials(
            username: username,
            password: password,
          );
          await _secureStorage.saveContext(tenant: tenant, home: home);
          _log.info('App provisioned successfully for $tenant/$home');
          return true;
        }
      }
      _log.warning(
        'App provisioning failed: ${response['error'] ?? 'Unknown error'}',
      );
      return false;
    } catch (e) {
      _log.severe('App bootstrap timed out or failed: $e');
      await subscription?.cancel();
      _mqttService.disconnect();
      return false;
    }
  }
}
