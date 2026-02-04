import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';

enum AlertType { none, warning, critical }

class AlertState {
  final AlertType activeType;
  final bool isSilenced;
  final int criticalCount;
  final int warningCount;

  AlertState({
    this.activeType = AlertType.none,
    this.isSilenced = false,
    this.criticalCount = 0,
    this.warningCount = 0,
  });

  AlertState copyWith({
    AlertType? activeType,
    bool? isSilenced,
    int? criticalCount,
    int? warningCount,
  }) {
    return AlertState(
      activeType: activeType ?? this.activeType,
      isSilenced: isSilenced ?? this.isSilenced,
      criticalCount: criticalCount ?? this.criticalCount,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}

class AlertNotifier extends Notifier<AlertState> {
  @override
  AlertState build() {
    // Escuta o status de saúde da casa (Active Alerts baseados em ResourceData)
    // Isso garante consistência com o Header e ignora eventos históricos
    ref.listen(homeHealthProvider, (previous, next) {
      next.whenData((health) {
        final criticals = health.criticalEvents;

        // Warnings logic: We don't have a direct 'warning' count in health yet.
        // For now, we focus on CRITICAL which drives the alarm loop.
        final warnings = 0;

        final newType = criticals > 0
            ? AlertType.critical
            : (warnings > 0 ? AlertType.warning : AlertType.none);

        // Se surgiu um novo erro crítico, desilencia automaticamente
        if (criticals > state.criticalCount && state.isSilenced) {
          state = state.copyWith(isSilenced: false);
          _updateAudio();
        }

        if (newType != state.activeType ||
            criticals != state.criticalCount ||
            warnings != state.warningCount) {
          state = state.copyWith(
            activeType: newType,
            criticalCount: criticals,
            warningCount: warnings,
          );
          _updateAudio();
        }
      });
    });

    return AlertState();
  }

  void toggleSilence() {
    state = state.copyWith(isSilenced: !state.isSilenced);
    _updateAudio();
  }

  void setSilenced(bool value) {
    if (state.isSilenced == value) return;
    state = state.copyWith(isSilenced: value);
    _updateAudio();
  }

  void _updateAudio() {
    final alertService = ref.read(alertServiceProvider);

    if (state.isSilenced || state.activeType == AlertType.none) {
      alertService.stop();
      return;
    }

    if (state.activeType == AlertType.critical) {
      alertService.playCriticalLoop();
    } else if (state.activeType == AlertType.warning) {
      // Warnings tocam apenas uma vez
      alertService.playAlert();
    }
  }
}

final alertProvider = NotifierProvider<AlertNotifier, AlertState>(
  AlertNotifier.new,
);
