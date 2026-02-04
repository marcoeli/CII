/// Timeouts e Thresholds do Sistema (V2.4)
///
/// Centraliza todas as constantes de tempo usadas no app para facilitar manutenção
class SystemTimeouts {
  SystemTimeouts._(); // Private constructor - utility class

  // ========== Comandos MQTT ==========

  /// Timeout para aguardar confirmação de comando (via result ou state change)
  static const int commandTimeoutSeconds = 10;

  /// Número máximo de tentativas de retry para comandos
  static const int commandRetryAttempts = 3;

  /// Intervalo inicial de backoff para retry (em milissegundos)
  /// Aumenta exponencialmente: 1s, 2s, 4s...
  static const int commandRetryBackoffMs = 1000;

  // ========== Staleness de Dados ==========

  /// Threshold padrão para considerar dados de sensores "stale" (desatualizados)
  static const int sensorStaleThresholdSeconds = 120; // 2 minutos

  /// Threshold para sensores críticos (ex: nível de água)
  static const int criticalSensorStaleThresholdSeconds = 60; // 1 minuto

  /// Threshold para atuadores (bombas, válvulas, etc)
  static const int actuatorStaleThresholdSeconds = 180; // 3 minutos

  // ========== MQTT Connection ==========

  /// Timeout para estabelecer conexão MQTT
  static const int mqttConnectTimeoutSeconds = 10;

  /// Intervalo de ping keep-alive
  static const int mqttPingIntervalSeconds = 60;

  /// Timeout para reconexão após desconexão
  static const int mqttReconnectDelaySeconds = 5;
}
