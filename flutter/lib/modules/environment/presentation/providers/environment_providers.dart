import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/environment/data/repositories/environment_repository_impl.dart';
import 'package:cii/modules/environment/domain/entities/environment.dart';
import 'package:cii/modules/environment/domain/entities/air_quality.dart';

/// Provider para ClimateViewModel
/// Provider para ClimateViewModel (Notifier)
/// StreamProvider para Sensor de Clima
/// Substitui ClimateViewModel usando Extensions para lógica de apresentação
final climateStreamProvider = StreamProvider.autoDispose
    .family<Environment?, String>((ref, resourceId) {
      final db = ref.watch(databaseProvider);
      final home = ref.watch(selectedHomeProvider);

      if (home == null) return Stream.value(null);

      final repository = EnvironmentRepositoryImpl(db, home.id);
      return repository.watchClimate(resourceId);
    });

/// StreamProvider para Sensor de Qualidade do Ar
/// Substitui AirQualityViewModel usando Extensions
final airQualityStreamProvider = StreamProvider.autoDispose
    .family<AirQuality?, String>((ref, resourceId) {
      final db = ref.watch(databaseProvider);
      final home = ref.watch(selectedHomeProvider);

      if (home == null) return Stream.value(null);

      final repository = EnvironmentRepositoryImpl(db, home.id);
      return repository.watchAirQuality(resourceId);
    });

/// Provider para listar recursos ambientais
final environmentResourcesProvider = StreamProvider<List<ResourceEntity>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  final home = ref.watch(selectedHomeProvider);

  if (home == null) {
    return Stream.value([]);
  }

  return db.resourcesDao.watchResourcesByMultipleDomains(home.id, [
    'env',
    'climate',
  ]);
});
