import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/global_providers.dart';

// Export from Core
export 'package:cii/core/providers/session_state.dart'
    show selectedTenantProvider;

final allTenantsProvider = StreamProvider<List<TenantEntity>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.tenantsHomesDao.watchAllTenants();
});

// Deprecated: Logic moved to SessionViewModel (Core)
// class SelectedTenantNotifier... removed.
