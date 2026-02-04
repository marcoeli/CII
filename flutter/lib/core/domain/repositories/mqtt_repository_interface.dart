import 'package:cii/core/database/app_database.dart';

abstract class MqttRepository {
  Stream<BrokerConnectionState> get connectionState;
  BrokerConnectionState get currentConnectionState;

  // Actions
  Future<void> connect();
  Future<void> disconnect();

  // Command Actions
  Future<bool> sendPumpCommand(
    String pumpId,
    bool turnOn, {
    bool force = false,
  });
  Future<bool> setPumpMode(String pumpId, String mode);

  // ✅ FIX B2: Métodos separados para device vs resource config
  Future<bool> sendDeviceConfig(String deviceId, Map<String, dynamic> config);
  Future<bool> sendResourceConfig(
    String resourceId,
    Map<String, dynamic> config,
  );

  Future<void> refreshDevices({TenantEntity? tenant, HomeEntity? home});

  Future<bool> updateResourceMeta({
    required String resourceId,
    String? label,
    String? room,
    String? icon,
  });

  void clearSubscriptions();
  void dispose();
}

enum BrokerConnectionState { connected, disconnected, connecting, failed }
