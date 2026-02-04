import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';

// Provider definition for ViewModel has been moved to climate_view_model.dart

/// Provider para listar todos os recursos do domínio ENV na residência ativa
final climateResourcesProvider = StreamProvider<List<ResourceEntity>>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.resourcesDao.watchResourcesByHomeAndDomain(home.id, 'env');
});

/// Provider de Telemetria de Clima (Temperatura e Umidade) - Legacy/Raw
final climateDataProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, resourceId) {
      final home = ref.watch(selectedHomeProvider);
      if (home == null) return Stream.value(null);

      final db = ref.watch(databaseProvider);
      return db.resourcesDao.watchDataByTechnicalId(home.id, resourceId).map((
        data,
      ) {
        if (data == null) return null;
        final payload = jsonDecode(data.dataJson) as Map<String, dynamic>;
        payload['timestamp'] =
            data.updatedAt; // Injetar timestamp real do banco
        return payload;
      });
    });

/// Provider para listar todos os recursos do domínio ENV (GÁS) na residência ativa
final gasResourcesProvider = StreamProvider<List<ResourceEntity>>((ref) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.resourcesDao
      .watchResourcesByHomeAndDomain(home.id, 'env')
      .map((list) => list.where((r) => r.kind == 'gas').toList());
});

/// Provider de Telemetria de Gás
final gasDataProvider = StreamProvider.family<Map<String, dynamic>?, String>((
  ref,
  resourceId,
) {
  final home = ref.watch(selectedHomeProvider);
  if (home == null) return Stream.value(null);

  final db = ref.watch(databaseProvider);
  return db.resourcesDao.watchDataByTechnicalId(home.id, resourceId).map((
    data,
  ) {
    if (data == null) return null;
    return jsonDecode(data.dataJson) as Map<String, dynamic>;
  });
});
