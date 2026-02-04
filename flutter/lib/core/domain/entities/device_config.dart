import 'package:equatable/equatable.dart';

class DeviceConfig extends Equatable {
  final String deviceId;
  final int? reportInterval;
  final Map<String, dynamic>? tank;
  final List<String>? pumpNames;
  final List<String>? levelNames;
  final Map<String, dynamic> rawConfig;

  const DeviceConfig({
    required this.deviceId,
    this.reportInterval,
    this.tank,
    this.pumpNames,
    this.levelNames,
    required this.rawConfig,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json, String deviceId) {
    // Parse tank
    Map<String, dynamic>? tankMap;
    if (json.containsKey('tank') && json['tank'] is Map) {
      tankMap = json['tank'] as Map<String, dynamic>;
    }

    // Parse pump_names
    List<String>? pumps;
    if (json.containsKey('pump_names') && json['pump_names'] is List) {
      pumps = (json['pump_names'] as List).map((e) => e.toString()).toList();
    }

    // Parse level_names
    List<String>? levels;
    if (json.containsKey('level_names') && json['level_names'] is List) {
      levels = (json['level_names'] as List).map((e) => e.toString()).toList();
    }

    return DeviceConfig(
      deviceId: deviceId,
      reportInterval: json['report_interval'] as int?,
      tank: tankMap,
      pumpNames: pumps,
      levelNames: levels,
      rawConfig: json,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'deviceId': deviceId, ...rawConfig};
    return map;
  }

  @override
  List<Object?> get props => [
    deviceId,
    reportInterval,
    tank,
    pumpNames,
    levelNames,
    rawConfig,
  ];
}




