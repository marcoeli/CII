import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/constants/timeouts.dart';
import 'package:cii/core/providers/global_providers.dart';

/// RCO-2401: Estado base para Sensores
class SensorState {
  final bool isLoading;
  final bool isStale;
  final DateTime? lastUpdate;
  final Map<String, dynamic>? data;

  const SensorState({
    this.isLoading = true,
    this.isStale = true,
    this.lastUpdate,
    this.data,
  });

  SensorState copyWith({
    bool? isLoading,
    bool? isStale,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return SensorState(
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }
}

/// RCO-2401: Notifier Base para Sensores (DB-First)
/// Usando Notifier com Injeção de Construtor para compatibilidade Riverpod 3.x
abstract class BaseSensorNotifier<S extends SensorState> extends Notifier<S> {
  final String resourceId;
  BaseSensorNotifier(this.resourceId);

  StreamSubscription? _subscription;

  @override
  S build();

  void listenToDatabase() {
    final db = ref.watch(databaseProvider);
    final home = ref.watch(selectedHomeProvider);

    if (home == null) return;

    _subscription?.cancel();
    _subscription = db.resourcesDao
        .watchDataByTechnicalId(home.id, resourceId)
        .listen((dataEntity) {
          if (dataEntity == null) {
            handleNoData();
            return;
          }

          try {
            final json = jsonDecode(dataEntity.dataJson);
            handleDataUpdate(json);
          } catch (e) {
            handleError('Erro ao decodificar dados: $e');
          }
        });

    ref.onDispose(() => _subscription?.cancel());
  }

  void handleNoData() {
    state = state.copyWith(isLoading: false, isStale: true) as S;
  }

  void handleDataUpdate(Map<String, dynamic> json);

  void handleError(String message);

  bool calculateStaleness(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    final age = DateTime.now().difference(lastUpdate).inSeconds;
    return age > SystemTimeouts.sensorStaleThresholdSeconds;
  }
}
