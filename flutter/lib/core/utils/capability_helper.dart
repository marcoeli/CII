import 'dart:convert';
import 'package:cii/core/domain/enums/device_capability.dart';

/// Utilitário para trabalhar com capabilities de dispositivos
/// Fornece métodos para parsing, verificação e validação de capabilities
class CapabilityHelper {
  /// Converte JSON string de capabilities para lista de DeviceCapability
  ///
  /// Suporta múltiplos formatos:
  /// - Array JSON: ["OTA", "RESTART", "CONFIG"]
  /// - String separada por vírgula: "OTA,RESTART,CONFIG"
  /// - String separada por ponto-e-vírgula: "OTA;RESTART;CONFIG"
  ///
  /// Retorna lista vazia se JSON inválido ou null
  static List<DeviceCapability> parseCapabilities(String? capabilitiesJson) {
    if (capabilitiesJson == null || capabilitiesJson.trim().isEmpty) {
      return [];
    }

    try {
      // Tentar parse como JSON array
      final dynamic parsed = jsonDecode(capabilitiesJson);

      if (parsed is List) {
        return DeviceCapability.fromStringList(
          parsed.map((e) => e.toString()).toList(),
        );
      } else if (parsed is String) {
        // String única
        final cap = DeviceCapability.fromString(parsed);
        return cap != null ? [cap] : [];
      }
    } catch (e) {
      // Se falhar JSON parse, tentar como string separada por vírgula ou ponto-e-vírgula
      if (capabilitiesJson.contains(',')) {
        return DeviceCapability.fromStringList(
          capabilitiesJson.split(',').map((s) => s.trim()).toList(),
        );
      } else if (capabilitiesJson.contains(';')) {
        return DeviceCapability.fromStringList(
          capabilitiesJson.split(';').map((s) => s.trim()).toList(),
        );
      } else {
        // String única sem separador
        final cap = DeviceCapability.fromString(capabilitiesJson.trim());
        return cap != null ? [cap] : [];
      }
    }

    return [];
  }

  /// Verifica se um dispositivo possui uma capability específica
  ///
  /// [capabilitiesJson] - String JSON com as capabilities do dispositivo
  /// [capability] - Capability a verificar
  ///
  /// Retorna true se o dispositivo possui a capability
  static bool hasCapability(
    String? capabilitiesJson,
    DeviceCapability capability,
  ) {
    final capabilities = parseCapabilities(capabilitiesJson);
    return capabilities.contains(capability);
  }

  /// Verifica se um dispositivo possui todas as capabilities especificadas
  ///
  /// [capabilitiesJson] - String JSON com as capabilities do dispositivo
  /// [requiredCapabilities] - Lista de capabilities requeridas
  ///
  /// Retorna true apenas se todas as capabilities requeridas estiverem presentes
  static bool hasAllCapabilities(
    String? capabilitiesJson,
    List<DeviceCapability> requiredCapabilities,
  ) {
    if (requiredCapabilities.isEmpty) return true;

    final capabilities = parseCapabilities(capabilitiesJson);
    return requiredCapabilities.every(
      (required) => capabilities.contains(required),
    );
  }

  /// Verifica se um dispositivo possui pelo menos uma das capabilities especificadas
  ///
  /// [capabilitiesJson] - String JSON com as capabilities do dispositivo
  /// [anyOfCapabilities] - Lista de capabilities (pelo menos uma deve estar presente)
  ///
  /// Retorna true se pelo menos uma capability estiver presente
  static bool hasAnyCapability(
    String? capabilitiesJson,
    List<DeviceCapability> anyOfCapabilities,
  ) {
    if (anyOfCapabilities.isEmpty) return false;

    final capabilities = parseCapabilities(capabilitiesJson);
    return anyOfCapabilities.any((required) => capabilities.contains(required));
  }

  /// Converte lista de DeviceCapability para JSON string
  ///
  /// [capabilities] - Lista de capabilities
  ///
  /// Retorna JSON array string: ["OTA", "RESTART"]
  static String toJson(List<DeviceCapability> capabilities) {
    return jsonEncode(capabilities.map((c) => c.value).toList());
  }

  /// Retorna uma descrição legível da capability em português
  static String getCapabilityDescription(DeviceCapability capability) {
    switch (capability) {
      case DeviceCapability.ota:
        return 'Atualização Over-The-Air';
      case DeviceCapability.restart:
        return 'Reinicialização Remota';
      case DeviceCapability.config:
        return 'Configuração Remota';
      case DeviceCapability.waterControl:
        return 'Controle de Água';
      case DeviceCapability.lights:
        return 'Controle de Iluminação';
      case DeviceCapability.sensors:
        return 'Leitura de Sensores';
      case DeviceCapability.actuators:
        return 'Controle de Atuadores';
      case DeviceCapability.waterLevel:
        return 'Sensor de Nível de Água';
      case DeviceCapability.gasSensor:
        return 'Sensor de Gás';
      case DeviceCapability.presenceSensor:
        return 'Sensor de Presença';
      case DeviceCapability.doorbell:
        return 'Campainha';
      case DeviceCapability.climate:
        return 'Controle de Clima';
      case DeviceCapability.remoteLogs:
        return 'Logs Remotos';
      case DeviceCapability.diagnostics:
        return 'Diagnósticos';
    }
  }

  /// Retorna lista de capabilities formatada para exibição
  ///
  /// Exemplo: ["OTA", "RESTART"] → "Atualização OTA, Reinicialização Remota"
  static String formatCapabilitiesList(String? capabilitiesJson) {
    final capabilities = parseCapabilities(capabilitiesJson);

    if (capabilities.isEmpty) {
      return 'Nenhuma capability';
    }

    return capabilities.map((cap) => getCapabilityDescription(cap)).join(', ');
  }

  /// Verifica se as capabilities JSON são válidas
  ///
  /// Retorna true se o JSON pode ser parseado sem erros
  static bool isValidCapabilitiesJson(String? capabilitiesJson) {
    if (capabilitiesJson == null || capabilitiesJson.trim().isEmpty) {
      return true; // null/empty é válido (sem capabilities)
    }

    try {
      parseCapabilities(capabilitiesJson);
      return true;
    } catch (e) {
      return false;
    }
  }
}




