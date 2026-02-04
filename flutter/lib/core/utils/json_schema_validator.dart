import 'dart:convert';

class JsonSchemaValidator {
  /// Valida se o payload segue o schema esperado para o domínio e tipo de recurso
  static bool validate(String domain, String kind, String payloadJson) {
    try {
      final Map<String, dynamic> data = jsonDecode(payloadJson);

      if (domain == 'water') {
        if (kind == 'pump' || kind == 'valve') {
          // Schema de Atuador: deve ter 'running' e 'mode'
          return data.containsKey('running') && data.containsKey('mode');
        }
        if (kind == 'level') {
          // Schema de Nível: deve ter 'percent'
          return data.containsKey('percent');
        }
      }

      if (domain == 'env') {
        if (kind == 'climate') {
          // Schema de Clima: deve ter 'temperature' (ou temp) e 'humidity'
          return (data.containsKey('temperature') ||
                  data.containsKey('temp')) &&
              data.containsKey('humidity');
        }
      }

      // Se não reconhecer o tipo, aceita se for um JSON válido (Flexibilidade)
      return true;
    } catch (e) {
      return false;
    }
  }
}
