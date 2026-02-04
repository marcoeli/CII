import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/global_providers.dart';

// Export selectedHomeProvider from Core
export 'package:cii/core/providers/session_state.dart'
    show selectedHomeProvider;

final allHomesProvider = StreamProvider<List<HomeEntity>>((ref) {
  final tenant = ref.watch(selectedTenantProvider);
  if (tenant == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.tenantsHomesDao.watchHomesByTenant(tenant.id);
});

// Deprecated: Logic moved to SessionViewModel (Core)
// class SelectedHomeNotifier... removed.
