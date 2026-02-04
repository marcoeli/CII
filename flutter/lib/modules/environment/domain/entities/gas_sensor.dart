import 'package:equatable/equatable.dart';

class GasSensor extends Equatable {
  final String locationId;
  final int value;
  final bool alert;
  final DateTime lastUpdated;

  const GasSensor({
    required this.locationId,
    required this.value,
    required this.alert,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [locationId, value, alert, lastUpdated];

  factory GasSensor.fromJson(Map<String, dynamic> json, String locationId) {
    final int? timestamp = json['ts'] as int?;
    return GasSensor(
      locationId: locationId,
      value: (json['val'] as num? ?? json['co2_ppm'] as num?)?.toInt() ?? 0,
      alert: json['alert'] == true || json['gas_detected'] == true,
      lastUpdated: timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'val': value,
      'alert': alert,
      'ts': lastUpdated.millisecondsSinceEpoch ~/ 1000,
    };
  }
}




