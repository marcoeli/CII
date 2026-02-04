import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

/// Serviço para armazenamento seguro de credenciais e dados sensíveis
/// Usa flutter_secure_storage (iOS Keychain / Android Keystore)
class SecureCredentialsService {
  final FlutterSecureStorage _storage;
  final _log = Logger('SecureCredentialsService');

  // Keys para armazenamento
  static const String _mqttUsernameKey = 'mqtt_username';
  static const String _mqttPasswordKey = 'mqtt_password';
  static const String _mqttBrokerKey = 'mqtt_broker';
  static const String _devModePasswordKey = 'dev_mode_password';
  static const String _tenantKey = 'tenant';
  static const String _homeKey = 'home';

  SecureCredentialsService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  // ========== MQTT Credentials ==========

  /// Salva credenciais MQTT
  Future<void> saveMqttCredentials({
    required String username,
    required String password,
    String? broker,
  }) async {
    try {
      await _storage.write(key: _mqttUsernameKey, value: username);
      await _storage.write(key: _mqttPasswordKey, value: password);
      if (broker != null) {
        await _storage.write(key: _mqttBrokerKey, value: broker);
      }
      _log.info('🔐 MQTT credentials saved securely');
    } catch (e) {
      _log.severe('Error saving MQTT credentials: $e');
      rethrow;
    }
  }

  /// Obtém credenciais MQTT
  Future<MqttCredentials?> getMqttCredentials() async {
    try {
      final username = await _storage.read(key: _mqttUsernameKey);
      final password = await _storage.read(key: _mqttPasswordKey);
      final broker = await _storage.read(key: _mqttBrokerKey);

      if (username == null || password == null) {
        return null;
      }

      return MqttCredentials(
        username: username,
        password: password,
        broker: broker,
      );
    } catch (e) {
      _log.severe('Error reading MQTT credentials: $e');
      return null;
    }
  }

  /// Deleta credenciais MQTT
  Future<void> deleteMqttCredentials() async {
    try {
      await _storage.delete(key: _mqttUsernameKey);
      await _storage.delete(key: _mqttPasswordKey);
      await _storage.delete(key: _mqttBrokerKey);
      _log.info('🗑️  MQTT credentials deleted');
    } catch (e) {
      _log.severe('Error deleting MQTT credentials: $e');
      rethrow;
    }
  }

  // ========== Dev Mode Password ==========

  /// Define senha do modo desenvolvedor
  Future<void> setDevModePassword(String password) async {
    try {
      await _storage.write(key: _devModePasswordKey, value: password);
      _log.info('🔐 Dev mode password set');
    } catch (e) {
      _log.severe('Error setting dev mode password: $e');
      rethrow;
    }
  }

  /// Verifica senha do modo desenvolvedor
  Future<bool> verifyDevModePassword(String password) async {
    try {
      final storedPassword = await _storage.read(key: _devModePasswordKey);
      return storedPassword == password;
    } catch (e) {
      _log.severe('Error verifying dev mode password: $e');
      return false;
    }
  }

  /// Verifica se há senha de dev mode definida
  Future<bool> hasDevModePassword() async {
    try {
      final password = await _storage.read(key: _devModePasswordKey);
      return password != null;
    } catch (e) {
      _log.severe('Error checking dev mode password: $e');
      return false;
    }
  }

  /// Deleta senha do modo desenvolvedor
  Future<void> deleteDevModePassword() async {
    try {
      await _storage.delete(key: _devModePasswordKey);
      _log.info('🗑️  Dev mode password deleted');
    } catch (e) {
      _log.severe('Error deleting dev mode password: $e');
      rethrow;
    }
  }

  // ========== Context V2.4 ==========

  /// Salva contexto de inquilino e residência
  Future<void> saveContext({
    required String tenant,
    required String home,
  }) async {
    try {
      await _storage.write(key: _tenantKey, value: tenant);
      await _storage.write(key: _homeKey, value: home);
      _log.info('🔐 Context V2.4 saved: $tenant/$home');
    } catch (e) {
      _log.severe('Error saving context: $e');
      rethrow;
    }
  }

  /// Obtém o contexto atual
  Future<Map<String, String>?> getContext() async {
    try {
      final tenant = await _storage.read(key: _tenantKey);
      final home = await _storage.read(key: _homeKey);

      if (tenant == null || home == null) {
        return null;
      }

      return {'tenant': tenant, 'home': home};
    } catch (e) {
      _log.severe('Error reading context: $e');
      return null;
    }
  }

  // ========== General ==========

  /// Deleta TODAS as credenciais armazenadas
  Future<void> deleteAllCredentials() async {
    try {
      await _storage.deleteAll();
      _log.warning('🗑️  ALL credentials deleted');
    } catch (e) {
      _log.severe('Error deleting all credentials: $e');
      rethrow;
    }
  }

  /// Verifica se há credenciais MQTT salvas
  Future<bool> hasMqttCredentials() async {
    final credentials = await getMqttCredentials();
    return credentials != null;
  }

  /// Salva valor customizado
  Future<void> saveSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      _log.fine('Saved secure value for key: $key');
    } catch (e) {
      _log.severe('Error saving secure value for $key: $e');
      rethrow;
    }
  }

  /// Lê valor customizado
  Future<String?> readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _log.severe('Error reading secure value for $key: $e');
      return null;
    }
  }

  /// Deleta valor customizado
  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      _log.severe('Error deleting secure value for $key: $e');
      rethrow;
    }
  }
}

/// Credenciais MQTT
class MqttCredentials {
  final String username;
  final String password;
  final String? broker;

  const MqttCredentials({
    required this.username,
    required this.password,
    this.broker,
  });

  @override
  String toString() => 'MqttCredentials(username: $username, broker: $broker)';
}




