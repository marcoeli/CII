class HomeContext {
  final String tenantId;
  final String homeId;
  final String label;
  final bool isActive;

  const HomeContext({
    required this.tenantId,
    required this.homeId,
    required this.label,
    this.isActive = false,
  });

  HomeContext copyWith({
    String? tenantId,
    String? homeId,
    String? label,
    bool? isActive,
  }) {
    return HomeContext(
      tenantId: tenantId ?? this.tenantId,
      homeId: homeId ?? this.homeId,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'HomeContext(tenantId: $tenantId, homeId: $homeId, label: $label, isActive: $isActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeContext &&
          other.tenantId == tenantId &&
          other.homeId == homeId &&
          other.label == label &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      tenantId.hashCode ^ homeId.hashCode ^ label.hashCode ^ isActive.hashCode;
}
