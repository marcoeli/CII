import 'package:equatable/equatable.dart';

class DeviceError extends Equatable {
  final String deviceId;
  final String code;
  final String severity; // WARN, ERROR, CRITICAL
  final String detail;
  final DateTime timestamp;

  const DeviceError({
    required this.deviceId,
    required this.code,
    required this.severity,
    required this.detail,
    required this.timestamp,
  });

  factory DeviceError.fromJson(Map<String, dynamic> json, String deviceId) {
    return DeviceError(
      deviceId: deviceId,
      code: json['code'] as String? ?? 'UNKNOWN',
      severity: json['severity'] as String? ?? 'WARN',
      detail: json['detail'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['ts'] as int? ?? 0) * 1000,
      ),
    );
  }

  bool get isCritical => severity == 'CRITICAL' || severity == 'ERROR';

  @override
  List<Object?> get props => [deviceId, code, severity, detail, timestamp];

  DeviceError copyWith({
    String? deviceId,
    String? code,
    String? severity,
    String? detail,
    DateTime? timestamp,
  }) {
    return DeviceError(
      deviceId: deviceId ?? this.deviceId,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      detail: detail ?? this.detail,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'code': code,
      'severity': severity,
      'detail': detail,
      'ts': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
  }
}




