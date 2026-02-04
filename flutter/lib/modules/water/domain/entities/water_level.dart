import 'package:equatable/equatable.dart';

class WaterLevel extends Equatable {
  final String reservoirId;
  final double
  level; // Percentage or Liters? Assuming percentage 0-100 based on usage
  final double volume; // Optional volume
  final DateTime lastUpdated;

  const WaterLevel({
    required this.reservoirId,
    required this.level,
    this.volume = 0.0,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [reservoirId, level, volume, lastUpdated];

  factory WaterLevel.fromJson(
    Map<String, dynamic> json,
    String reservoirId, {
    DateTime? timestamp,
  }) {
    return WaterLevel(
      reservoirId: reservoirId,
      level:
          (json['level'] as num? ?? json['percent'] as num?)?.toDouble() ?? 0.0,
      volume:
          (json['volume'] as num? ?? json['liters'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: timestamp ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservoirId': reservoirId,
      'level': level,
      'volume': volume,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
