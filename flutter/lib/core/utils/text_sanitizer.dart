/// Utilitário para normalização e sanitização de nomes de recursos e locais
class TextSanitizer {
  /// Converte texto para um formato seguro para tópicos MQTT e IDs
  /// Ex: "Área de Serviço" -> "area_de_servico"
  static String sanitize(String input) {
    if (input.isEmpty) return '';

    var str = input.toLowerCase().trim();

    // Mapeamento de acentos comuns (PT-BR)
    const accents = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const withoutAccents = 'aaaaaeeeeeiiiiooooouuuuc';

    for (int i = 0; i < accents.length; i++) {
      str = str.replaceAll(accents[i], withoutAccents[i]);
    }

    // Remover caracteres especiais, manter apenas letras, números, espaços e hífens/underscores
    str = str.replaceAll(RegExp(r'[^a-z0-9\s_-]'), '');

    // Substituir múltiplos espaços por um único underscore
    str = str.replaceAll(RegExp(r'\s+'), '_');

    // Remover underscores/hífens repetidos
    str = str.replaceAll(RegExp(r'[-_]{2,}'), '_');

    return str;
  }

  /// Alias para manter compatibilidade se usado com outro nome
  static String normalize(String input) => sanitize(input);
}
