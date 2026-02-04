class ResourceIdInfo {
  final String domain;
  final String kind;
  final String name;

  ResourceIdInfo({
    required this.domain,
    required this.kind,
    required this.name,
  });

  @override
  String toString() => '$domain.$kind.$name';
}

class ResourceIdParser {
  /// Parseia um resourceId no formato {domain}.{kind}.{name}
  /// Exemplo: water.level.cisterna -> domain: 'water', kind: 'level', name: 'cisterna'
  static ResourceIdInfo parse(String resourceId) {
    final parts = resourceId.split('.');

    if (parts.length < 3) {
      // Fallback para IDs malformados mantendo o original no name
      return ResourceIdInfo(
        domain: 'unknown',
        kind: 'unknown',
        name: resourceId,
      );
    }

    return ResourceIdInfo(
      domain: parts[0],
      kind: parts[1],
      name: parts.sublist(2).join('.'),
    );
  }
}
