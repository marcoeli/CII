import 'package:equatable/equatable.dart';

enum PumpState { on, off, unknown }

class Pump extends Equatable {
  final String id;
  final PumpState state;
  final String? mode; // AUTO, MANUAL
  final String? reason; // e.g., safety_violation
  final DateTime lastUpdated;

  const Pump({
    required this.id,
    required this.state,
    this.mode,
    this.reason,
    this.bindings,
    this.rules,
    this.safety,
    required this.lastUpdated,
  });

  final Map<String, dynamic>? bindings;
  final Map<String, dynamic>? rules;
  final Map<String, dynamic>? safety;

  @override
  List<Object?> get props => [
    id,
    state,
    mode,
    reason,
    bindings,
    rules,
    safety,
    lastUpdated,
  ];

  factory Pump.fromJson(
    Map<String, dynamic> json,
    String id, {
    DateTime? timestamp,
  }) {
    final isRunning = json['running'] == true;
    return Pump(
      id: id,
      state: isRunning ? PumpState.on : PumpState.off,
      mode: json['mode'] as String?,
      reason: json['reason'] as String?,
      bindings: json['bindings'] as Map<String, dynamic>?,
      rules: json['rules'] as Map<String, dynamic>?,
      safety: json['safety'] as Map<String, dynamic>?,
      lastUpdated: timestamp ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state.index,
      'running': state == PumpState.on,
      'mode': mode,
      'reason': reason,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toCommandJson(bool turnOn) {
    return {
      'action': turnOn ? 'START' : 'STOP',
      'origin': 'app',
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
  }
}
