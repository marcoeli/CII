import 'package:equatable/equatable.dart';

class AirQuality extends Equatable {
  final String id;
  final int? pm25;
  final int? pm10;
  final int? co2;
  final int? voc;
  final int? ppm;
  final DateTime lastUpdated;

  const AirQuality({
    required this.id,
    this.pm25,
    this.pm10,
    this.co2,
    this.voc,
    this.ppm,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [id, pm25, pm10, co2, voc, ppm, lastUpdated];

  factory AirQuality.fromJson(
    Map<String, dynamic> json,
    String id, {
    DateTime? timestamp,
  }) {
    final tsJson = json['ts'] as int?;
    final lastUpdated =
        timestamp ??
        (tsJson != null
            ? DateTime.fromMillisecondsSinceEpoch(tsJson * 1000)
            : DateTime.now());

    return AirQuality(
      id: id,
      pm25: json['pm25'] as int?,
      pm10: json['pm10'] as int?,
      co2: json['co2'] as int?,
      voc: json['voc'] as int?,
      ppm: json['ppm'] as int?,
      lastUpdated: lastUpdated,
    );
  }
}
