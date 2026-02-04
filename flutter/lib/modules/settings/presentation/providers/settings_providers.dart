import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/settings/data/repositories/settings_repository_impl.dart';
import 'package:cii/modules/settings/domain/repositories/i_settings_repository.dart';

/// Repository Provider
final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepositoryImpl(db);
});
