import 'package:cii/modules/environment/domain/entities/environment.dart';

extension EnvironmentDisplay on Environment {
  String get formattedDisplay {
    final tempStr = '${temperature.toStringAsFixed(1)}°C';
    final humStr = ' | ${humidity.toStringAsFixed(0)}%';
    return '$tempStr$humStr';
  }

  String get comfortLevel {
    if (temperature > 28) return 'hot';
    if (temperature < 18) return 'cold';
    if (humidity > 70) return 'humid';
    return 'comfortable';
  }

  bool get isStale {
    final diff = DateTime.now().difference(lastUpdated);
    return diff.inSeconds > 120;
  }
}
