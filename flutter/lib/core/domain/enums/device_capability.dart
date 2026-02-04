/// Capabilities que um dispositivo físico pode suportar
/// Usado para feature gating - ocultar/mostrar funcionalidades baseado no dispositivo
enum DeviceCapability {
  /// Suporte a atualizações OTA (Over-The-Air)
  ota('OTA'),

  /// Suporte a reinicialização remota
  restart('RESTART'),

  /// Suporte a configuração remota
  config('CONFIG'),

  /// Controle de bombas/atuadores de água
  waterControl('WATER_CONTROL'),

  /// Controle de iluminação
  lights('LIGHTS'),

  /// Leitura de sensores (temperatura, umidade, etc.)
  sensors('SENSORS'),

  /// Controle de atuadores genéricos
  actuators('ACTUATORS'),

  /// Leitura de nível de água
  waterLevel('WATER_LEVEL'),

  /// Detecção de gás
  gasSensor('GAS_SENSOR'),

  /// Sensor de presença
  presenceSensor('PRESENCE'),

  /// Campainha/Doorbell
  doorbell('DOORBELL'),

  /// Controle de temperatura/clima
  climate('CLIMATE'),

  /// Suporte a logs remotos
  remoteLogs('REMOTE_LOGS'),

  /// Suporte a diagnósticos
  diagnostics('DIAGNOSTICS');

  const DeviceCapability(this.value);

  /// Valor string da capability
  final String value;

  /// Converte string para DeviceCapability
  /// Retorna null se não encontrar correspondência
  static DeviceCapability? fromString(String value) {
    try {
      return DeviceCapability.values.firstWhere(
        (cap) => cap.value.toUpperCase() == value.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Converte lista de strings para lista de DeviceCapability
  /// Ignora valores inválidos
  static List<DeviceCapability> fromStringList(List<String> values) {
    return values
        .map((v) => fromString(v))
        .where((cap) => cap != null)
        .cast<DeviceCapability>()
        .toList();
  }

  /// Converte para formato JSON
  String toJson() => value;

  @override
  String toString() => value;
}




