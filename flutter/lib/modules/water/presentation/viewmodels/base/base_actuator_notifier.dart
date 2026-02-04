import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/constants/timeouts.dart';
import 'package:cii/core/providers/global_providers.dart';

/// RCO-2401: Estado base para Atuadores
class ActuatorState {
  final bool isLoading;
  final bool isStale;
  final DateTime? lastUpdate;
  final Map<String, dynamic>? data;

  const ActuatorState({
    this.isLoading = true,
    this.isStale = true,
    this.lastUpdate,
    this.data,
  });

  ActuatorState copyWith({
    bool? isLoading,
    bool? isStale,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return ActuatorState(
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }
}

/// RCO-2401: Notifier Base para Atuadores (DB-First + UX Pessimista)
/// Usando Notifier com Injeção de Construtor para compatibilidade Riverpod 3.x
abstract class BaseActuatorNotifier<S extends ActuatorState>
    extends Notifier<S> {
  final String resourceId;
  BaseActuatorNotifier(this.resourceId);

  StreamSubscription? _subscription;
  Timer? _commandTimeout;

  @override
  S build();

  /// Inicia a escuta do banco de dados
  void listenToDatabase() {
    final db = ref.watch(databaseProvider);
    final home = ref.watch(selectedHomeProvider);

    if (home == null) return;

    _subscription?.cancel();
    _subscription = db.resourcesDao
        .watchStateByTechnicalId(home.id, resourceId)
        .listen((stateEntity) {
          if (stateEntity == null) {
            handleNoState();
            return;
          }

          try {
            final json = jsonDecode(stateEntity.stateJson);
            _cancelTimeout();
            handleStateUpdate(json);
          } catch (e) {
            handleError('Erro ao decodificar estado: $e');
          }
        });

    ref.onDispose(() {
      _subscription?.cancel();
      _commandTimeout?.cancel();
    });
  }

  void handleNoState() {
    state = state.copyWith(isLoading: false, isStale: true) as S;
  }

  void handleStateUpdate(Map<String, dynamic> json);

  Future<void> executeCommand(
    Future<bool> Function() commandFn, {
    String? description,
  }) async {
    state = state.copyWith(isLoading: true) as S;
    _startTimeout(description);

    try {
      final success = await commandFn();
      if (!success) {
        _cancelTimeout();
        state = state.copyWith(isLoading: false) as S;
        handleError(
          'Falha ao enviar comando${description != null ? ": $description" : ""}',
        );
      }
    } catch (e) {
      _cancelTimeout();
      state = state.copyWith(isLoading: false) as S;
      handleError('Erro na execução do comando: $e');
    }
  }

  void _startTimeout(String? description) {
    _cancelTimeout();
    _commandTimeout = Timer(
      const Duration(seconds: SystemTimeouts.commandTimeoutSeconds),
      () {
        if (state.isLoading) {
          state = state.copyWith(isLoading: false) as S;
          handleError(
            'Timeout: O dispositivo não confirmou o comando ${description ?? ""}',
          );
        }
      },
    );
  }

  void _cancelTimeout() {
    _commandTimeout?.cancel();
    _commandTimeout = null;
  }

  void handleError(String message);

  bool calculateStaleness(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    final age = DateTime.now().difference(lastUpdate).inSeconds;
    return age > SystemTimeouts.actuatorStaleThresholdSeconds;
  }
}
