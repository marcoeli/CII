import 'package:equatable/equatable.dart';

class Environment extends Equatable {
  final String remoteId; // e.g. 'cozinha', 'quarto'
  final double temperature;
  final double humidity;
  final DateTime lastUpdated;

  const Environment({
    required this.remoteId,
    required this.temperature,
    required this.humidity,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [remoteId, temperature, humidity, lastUpdated];

  factory Environment.fromJson(
    Map<String, dynamic> json,
    String remoteId, {
    DateTime? timestamp,
  }) {
    // Tenta pegar timestamp do JSON se não for passado
    final tsJson = json['ts'] as int?;
    final lastUpdated =
        timestamp ??
        (tsJson != null
            ? DateTime.fromMillisecondsSinceEpoch(tsJson * 1000)
            : DateTime.now());

    return Environment(
      remoteId: remoteId,
      temperature:
          (json['t'] as num? ??
                  json['temp'] as num? ??
                  json['temperature'] as num?)
              ?.toDouble() ??
          0.0,
      humidity:
          (json['h'] as num? ?? json['hum'] as num? ?? json['humidity'] as num?)
              ?.toDouble() ??
          0.0,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remoteId': remoteId,
      'temp': temperature,
      'hum': humidity,
      'ts': lastUpdated.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
