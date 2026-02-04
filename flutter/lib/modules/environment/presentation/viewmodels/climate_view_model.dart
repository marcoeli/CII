import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/core/providers/global_providers.dart';

// --- STATE ---
class ClimateState {
  final double? temperature;
  final double? humidity;
  final DateTime? lastUpdate;
  final bool isLoading;
  final bool isStale;

  const ClimateState({
    this.temperature,
    this.humidity,
    this.lastUpdate,
    this.isLoading = true,
    this.isStale = true,
  });

  ClimateState copyWith({
    double? temperature,
    double? humidity,
    DateTime? lastUpdate,
    bool? isLoading,
    bool? isStale,
  }) {
    return ClimateState(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClimateState &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          humidity == other.humidity &&
          lastUpdate == other.lastUpdate &&
          isLoading == other.isLoading &&
          isStale == other.isStale;

  @override
  int get hashCode =>
      temperature.hashCode ^
      humidity.hashCode ^
      lastUpdate.hashCode ^
      isLoading.hashCode ^
      isStale.hashCode;
}

// --- NOTIFIER (Riverpod 3.0 SKILL Spec) ---
class ClimateNotifier extends Notifier<ClimateState> {
  // Constructor Injection
  ClimateNotifier(this.resourceId);
  final String resourceId;

  StreamSubscription? _subscription;

  @override
  ClimateState build() {
    final db = ref.watch(databaseProvider);
    final home = ref.watch(selectedHomeProvider);

    ref.onDispose(() => _subscription?.cancel());

    if (home == null) {
      _subscription?.cancel();
      return const ClimateState(isLoading: false, isStale: true);
    }

    _listenToDatabase(db, home.id, resourceId);

    return const ClimateState(isLoading: true, isStale: true);
  }

  void _listenToDatabase(AppDatabase db, int homeId, String resourceId) {
    _subscription?.cancel();

    _subscription = db.resourcesDao
        .watchDataByTechnicalId(homeId, resourceId)
        .listen((dataEntity) {
          if (dataEntity == null) {
            state = state.copyWith(isLoading: true, isStale: true);
            return;
          }

          final parsed = _parseClimate(dataEntity.dataJson);
          if (parsed == null) {
            state = state.copyWith(isLoading: false);
            return;
          }

          final lastUpdate = parsed.lastUpdate;
          final isStale = lastUpdate != null
              ? DateTime.now().difference(lastUpdate).inSeconds > 120
              : true;

          state = ClimateState(
            temperature: parsed.temperature,
            humidity: parsed.humidity,
            lastUpdate: lastUpdate,
            isLoading: false,
            isStale: isStale,
          );
        });
  }

  _ClimateParsed? _parseClimate(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr);
      if (data is! Map<String, dynamic>) return null;

      final ts = data['ts'];
      DateTime? lastUpdate;
      if (ts is int) {
        lastUpdate = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      }

      return _ClimateParsed(
        temperature: (data['temperature'] as num?)?.toDouble(),
        humidity: (data['humidity'] as num?)?.toDouble(),
        lastUpdate: lastUpdate,
      );
    } catch (_) {
      return null;
    }
  }
}

class _ClimateParsed {
  final double? temperature;
  final double? humidity;
  final DateTime? lastUpdate;

  const _ClimateParsed({
    required this.temperature,
    required this.humidity,
    required this.lastUpdate,
  });
}

// --- PROVIDER ---
final climateNotifierProvider = NotifierProvider.autoDispose
    .family<ClimateNotifier, ClimateState, String>(ClimateNotifier.new);
