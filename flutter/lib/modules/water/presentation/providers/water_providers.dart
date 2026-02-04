import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/session_state.dart';

import 'package:cii/core/providers/infra_providers.dart';

/// RCO-2401: Providers para ViewModels do módulo Water
///
/// ✅ FASE 1: Arquitetura refatorada
/// - NotifierProvider (Riverpod 2/3)
/// - Imutabilidade e padrão Family correto

// Providers for Pump and WaterLevel have been moved to their respective ViewModel files.

/// Provider para listar recursos de água (bombas, válvulas, sensores)
final waterResourcesProvider = StreamProvider<List<ResourceEntity>>((ref) {
  final db = ref.watch(databaseProvider);
  final home = ref.watch(selectedHomeProvider);

  if (home == null) {
    return Stream.value([]);
  }

  // Escuta recursos cuja domain = 'water' (Filtered by Home)
  return db.resourcesDao.watchResourcesByDomain(home.id, 'water');
});

/// Provider para Bindings de um recurso
final resourceBindingsProvider = StreamProvider.autoDispose
    .family<List<ResourceBindingEntity>, String>((ref, resourceIdStr) {
      final db = ref.watch(databaseProvider);

      final query = db.select(db.resourceBindings).join([
        innerJoin(
          db.resourcesV24,
          db.resourcesV24.id.equalsExp(db.resourceBindings.resourceId),
        ),
      ]);

      query.where(db.resourcesV24.resourceId.equals(resourceIdStr));

      return query.map((row) => row.readTable(db.resourceBindings)).watch();
    });
