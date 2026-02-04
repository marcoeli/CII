import 'package:cii/modules/environment/domain/entities/environment.dart';
import 'package:cii/modules/environment/domain/entities/air_quality.dart';

abstract class IEnvironmentRepository {
  /// Monitora dados de clima (temperatura/umidade) de um recurso
  Stream<Environment?> watchClimate(String id);

  /// Monitora dados de qualidade do ar (PM2.5, CO2, etc)
  Stream<AirQuality?> watchAirQuality(String id);
}
