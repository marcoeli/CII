import 'dart:convert';

/// Resultado de uma tentativa de parsing de payload MQTT
class ParseResult<T> {
  /// Indica se o parsing foi bem sucedido
  final bool success;

  /// Dados processados (Map ou Entity)
  final T? data;

  /// Mensagem de erro caso falhe
  final String? error;

  const ParseResult({required this.success, this.data, this.error});

  /// Atalho para resultado de sucesso
  factory ParseResult.success(T data) => ParseResult(success: true, data: data);

  /// Atalho para resultado de falha
  factory ParseResult.failure(String error) =>
      ParseResult(success: false, error: error);
}

/// Utilitário central para decodificar payloads MQTT
/// Suporta contratos V2.4 (operacional) e Legados
class MqttPayloadParser {
  /// Decodificação JSON genérica
  ParseResult<Map<String, dynamic>> parseJson(String payload, {String? topic}) {
    try {
      if (payload.isEmpty) return ParseResult.failure('Payload vazio');
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        return ParseResult.success(data);
      }
      return ParseResult.failure('JSON não é um objeto (Map)');
    } catch (e) {
      return ParseResult.failure('Falha no decode JSON: $e');
    }
  }

  /// Parser para telemetria de nível de água
  ParseResult<Map<String, dynamic>> parseWaterLevel(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para telemetria de bombas
  ParseResult<Map<String, dynamic>> parsePumpState(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para telemetria ambiental (Temp/Hum)
  ParseResult<Map<String, dynamic>> parseEnvironment(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para status vital do dispositivo (Heartbeat)
  ParseResult<Map<String, dynamic>> parseDeviceStatus(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para registros de erro de hardware
  ParseResult<Map<String, dynamic>> parseDeviceError(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para leitura de configuração atual do firmware
  ParseResult<Map<String, dynamic>> parseDeviceConfig(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para sensores de gás e qualidade do ar
  ParseResult<Map<String, dynamic>> parseGasSensor(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para sensores de presença (PIR/Radar)
  ParseResult<Map<String, dynamic>> parsePresence(
    String payload,
    String topic,
  ) {
    return parseJson(payload, topic: topic);
  }

  /// Parser para eventos de campainha
  ParseResult<Map<String, dynamic>> parseDoorbell(
    String payload,
    String topic,
  ) {
    // Campainha pode enviar JSON ou apenas um trigger (true/1)
    try {
      final lower = payload.toLowerCase();
      if (lower == 'true' ||
          lower == '1' ||
          lower == 'on' ||
          lower == 'pressed') {
        return ParseResult.success({
          'active': true,
          'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
      }
      return parseJson(payload, topic: topic);
    } catch (_) {
      return ParseResult.success({
        'raw': payload,
        'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    }
  }
}
