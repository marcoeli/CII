import '../app_database.dart';

/// Extension para DeviceEntity com getters computados
extension DeviceEntityExtensions on DeviceEntity {
  /// Calcula se o device está online baseado em lastSeen
  /// Um device é considerado online se reportou nos últimos 5 minutos
  bool get isOnline {
    if (lastSeen == null) return false;
    final age = DateTime.now().difference(lastSeen!);
    return age.inMinutes < 5;
  }

  /// Retorna a idade do último heartbeat em minutos
  int? get lastHeartbeatAgeMinutes {
    if (lastSeen == null) return null;
    return DateTime.now().difference(lastSeen!).inMinutes;
  }

  /// Retorna string para status visual
  String get statusLabel {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Nunca visto';
    final age = lastHeartbeatAgeMinutes!;
    if (age < 60) return 'Offline ${age}m';
    if (age < 1440) return 'Offline ${(age / 60).floor()}h';
    return 'Offline ${(age / 1440).floor()}d';
  }
}
