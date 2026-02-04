import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/water/presentation/viewmodels/base/base_sensor_notifier.dart';

// --- STATE ---
class WaterLevelState extends SensorState {
  final double? percent;
  final double? liters;
  final String? alert;

  const WaterLevelState({
    this.percent,
    this.liters,
    this.alert,
    super.isLoading = true,
    super.isStale = true,
    super.lastUpdate,
    super.data,
  });

  @override
  WaterLevelState copyWith({
    double? percent,
    double? liters,
    String? alert,
    bool? isLoading,
    bool? isStale,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return WaterLevelState(
      percent: percent ?? this.percent,
      liters: liters ?? this.liters,
      alert: alert ?? this.alert,
      isLoading: isLoading ?? this.isLoading,
      isStale: isStale ?? this.isStale,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }
}

// --- NOTIFIER ---
class WaterLevelNotifier extends BaseSensorNotifier<WaterLevelState> {
  WaterLevelNotifier(super.resourceId);

  @override
  WaterLevelState build() {
    debugPrint('🔧 [WaterLevelNotifier] Building for $resourceId');
    listenToDatabase();
    return const WaterLevelState(isLoading: true, isStale: true);
  }

  @override
  void handleDataUpdate(Map<String, dynamic> json) {
    final ts = json['ts'] as int?;
    final lastUpdate = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
        : null;

    state = WaterLevelState(
      percent: (json['percent'] as num?)?.toDouble(),
      liters: (json['liters'] as num?)?.toDouble(),
      alert: json['alert'] as String?,
      lastUpdate: lastUpdate,
      isLoading: false,
      isStale: calculateStaleness(lastUpdate),
      data: json,
    );
  }

  @override
  void handleError(String message) {
    debugPrint('❌ [WaterLevelNotifier] $message');
  }
}

// --- PROVIDER ---
final waterLevelNotifierProvider = NotifierProvider.autoDispose
    .family<WaterLevelNotifier, WaterLevelState, String>(
      WaterLevelNotifier.new,
    );
