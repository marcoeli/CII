import 'dart:convert';

class NormalizedResourceData {
  final Map<String, dynamic> data;
  final String alert; // NORMAL, WARN, CRITICAL
  final String? severity; // warning, critical, info

  NormalizedResourceData({
    required this.data,
    required this.alert,
    this.severity,
  });

  String get payloadJson => jsonEncode({...data, 'alert': alert});
}

class ResourceDataSanitizer {
  /// Normaliza o payload de telemetria (data/state)
  static NormalizedResourceData sanitize(Map<String, dynamic> raw) {
    final alertStr = (raw['alert']?.toString() ?? 'NORMAL').toUpperCase();

    String normalizedAlert = 'NORMAL';
    String? severity;

    // Mapeamento Robusto de Alertas
    if (alertStr == 'CRITICAL' ||
        alertStr == 'ALARM' ||
        alertStr == 'SMOKE_DETECTED' ||
        alertStr == 'GAS_DETECTED') {
      normalizedAlert = 'CRITICAL';
      severity = 'critical';
    } else if (alertStr == 'WARN' ||
        alertStr == 'WARNING' ||
        alertStr == 'ALERT') {
      normalizedAlert = 'WARN';
      severity = 'warning';
    } else {
      normalizedAlert = 'NORMAL';
      severity = 'info';
    }

    // Limpeza de campos desnecessários e padronização de tipos
    final cleanData = Map<String, dynamic>.from(raw);

    return NormalizedResourceData(
      data: cleanData,
      alert: normalizedAlert,
      severity: severity,
    );
  }

  /// Normaliza o kind do recurso para evitar discrepâncias entre simulador/firmware e app
  static String normalizeKind(String kind) {
    final k = kind.toLowerCase();
    if (k == 'air' || k == 'air_quality' || k == 'quality_ar') {
      return 'air_quality';
    }
    if (k == 'presence' || k == 'motion' || k == 'occupancy') return 'presence';
    return k;
  }
}
