import 'package:cii/modules/environment/domain/entities/air_quality.dart';

extension AirQualityDisplay on AirQuality {
  String get formattedDisplay {
    if (ppm != null) return 'Concentração: $ppm ppm | $qualityLevel';
    if (pm25 == null) return 'Sem dados';
    return 'PM2.5: $pm25 µg/m³ | $qualityLevel';
  }

  String get qualityLevel {
    if (ppm != null) {
      if (ppm! <= 50) return 'normal';
      if (ppm! <= 200) return 'warning';
      return 'critical';
    }
    if (pm25 == null) return 'unknown';
    if (pm25! <= 12) return 'good';
    if (pm25! <= 35) return 'moderate';
    if (pm25! <= 55) return 'unhealthy';
    return 'hazardous';
  }

  (int, int, int) get qualityColorRGB {
    final level = qualityLevel;
    switch (level) {
      case 'good':
      case 'normal':
        return (76, 175, 80);
      case 'moderate':
      case 'warning':
        return (255, 193, 7);
      case 'unhealthy':
      case 'hazardous':
      case 'critical':
        return (244, 67, 54);
      default:
        return (128, 128, 128);
    }
  }

  bool get isStale {
    final diff = DateTime.now().difference(lastUpdated);
    return diff.inSeconds > 90;
  }
}
