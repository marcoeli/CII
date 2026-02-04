import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/infra_providers.dart';
import 'package:cii/modules/water/presentation/viewmodels/base/base_actuator_notifier.dart';

// --- STATE ---
class PumpState extends ActuatorState {
  final bool isRunning;
  final String mode;

  const PumpState({
    this.isRunning = false,
    this.mode = 'auto',
    super.isLoading = true,
    super.isStale = true,
    super.lastUpdate,
    super.data,
  });

  @override
  PumpState copyWith({
    bool? isRunning,
    String? mode,
    bool? isLoading,
    bool? isStale,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return PumpState(
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PumpState &&
          runtimeType == other.runtimeType &&
          isRunning == other.isRunning &&
          mode == other.mode &&
          lastUpdate == other.lastUpdate &&
          isLoading == other.isLoading &&
          isStale == other.isStale &&
          mapEquals(data, other.data);

  @override
  int get hashCode =>
      isRunning.hashCode ^
      mode.hashCode ^
      lastUpdate.hashCode ^
      isLoading.hashCode ^
      isStale.hashCode ^
      data.hashCode;
}

// --- NOTIFIER (Riverpod 3.0 SKILL Spec) ---
// Extends Notifier (Not AutoDisposeNotifier, per SKILL)
class PumpNotifier extends BaseActuatorNotifier<PumpState> {
  PumpNotifier(super.resourceId);

  // Build has NO arguments (per SKILL)
  @override
  PumpState build() {
    debugPrint('🔧 [PumpNotifier] Building for $resourceId');

    // Inicia a escuta do banco de dados (DB-First)
    listenToDatabase();

    return const PumpState(isLoading: true, isStale: true);
  }

  @override
  void handleStateUpdate(Map<String, dynamic> json) {
    final ts = json['last_update'] as int?;
    final lastUpdate = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
        : null;

    state = PumpState(
      isRunning: json['running'] == true,
      mode: json['mode']?.toString() ?? 'auto',
      lastUpdate: lastUpdate,
      isLoading: false,
      isStale: calculateStaleness(lastUpdate),
      data: json,
    );
  }

  @override
  void handleError(String message) {
    debugPrint('❌ [PumpNotifier] $message');
    // Futuro: Adicionar ao SystemNotificationProvider
  }

  // --- ACTIONS ---

  Future<void> toggle({bool force = false}) async {
    final newState = !state.isRunning;
    final actionName = newState ? "LIGAR" : "DESLIGAR";

    await executeCommand(
      () => ref
          .read(mqttRepositoryProvider)
          .sendPumpCommand(resourceId, newState, force: force),
      description: '$actionName bomba $resourceId',
    );
  }

  Future<void> setMode(String newMode) async {
    await executeCommand(
      () => ref.read(mqttRepositoryProvider).setPumpMode(resourceId, newMode),
      description: 'Alterar modo para $newMode na bomba $resourceId',
    );
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

// --- PROVIDER ---
// SKILL: "final myProvider = NotifierProvider<MyNotifier, int>(MyNotifier.new);"
// Here we use autoDispose variant.
final pumpNotifierProvider = NotifierProvider.autoDispose
    .family<PumpNotifier, PumpState, String>(PumpNotifier.new);

// --- COMPUTED PROVIDERS ---
final canControlPumpProvider = Provider.autoDispose.family<bool, String>((
  ref,
  resourceId,
) {
  final pumpState = ref.watch(pumpNotifierProvider(resourceId));
  return !pumpState.isLoading && !pumpState.isStale;
});
