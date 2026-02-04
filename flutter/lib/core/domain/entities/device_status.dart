import 'package:equatable/equatable.dart';

class DeviceHardwareInfo extends Equatable {
  final String vendor;
  final String model;
  final String rev;
  final String serial;

  const DeviceHardwareInfo({
    this.vendor = '',
    this.model = '',
    this.rev = '',
    this.serial = '',
  });

  factory DeviceHardwareInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeviceHardwareInfo();
    return DeviceHardwareInfo(
      vendor: json['vendor'] ?? '',
      model: json['model'] ?? '',
      rev: json['rev'] ?? '',
      serial: json['serial'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'vendor': vendor,
    'model': model,
    'rev': rev,
    'serial': serial,
  };

  @override
  List<Object?> get props => [vendor, model, rev, serial];
}

class DeviceStatus extends Equatable {
  final String deviceId;
  final String state; // ONLINE, OFFLINE
  final String fw;
  final int uptime;
  final int rssi;
  final String role;
  final String ip;
  final DeviceHardwareInfo hw;
  final List<dynamic>
  capabilities; // V2.4 simplified as List of Resource groups
  final DateTime lastUpdated;
  final String contract;

  const DeviceStatus({
    required this.deviceId,
    required this.state,
    required this.fw,
    required this.uptime,
    required this.rssi,
    required this.role,
    required this.lastUpdated,
    this.ip = '',
    this.hw = const DeviceHardwareInfo(),
    this.capabilities = const [],
    this.contract = '2.4',
  });

  @override
  List<Object?> get props => [
    deviceId,
    state,
    fw,
    uptime,
    rssi,
    role,
    lastUpdated,
    ip,
    hw,
    capabilities,
    contract,
  ];

  factory DeviceStatus.fromJson(Map<String, dynamic> json, String deviceId) {
    // V2.4 Enrichment: HW and Capabilities
    final hwJson = json['hw'] as Map<String, dynamic>?;
    final caps = json['capabilities'] as List<dynamic>? ?? [];

    return DeviceStatus(
      deviceId: deviceId,
      state: json['state'] ?? 'UNKNOWN',
      fw: json['fw'] ?? '',
      uptime: json['uptime'] ?? 0,
      rssi: json['rssi'] ?? 0,
      role: json['role'] ?? '',
      ip: json['ip'] ?? '',
      hw: DeviceHardwareInfo.fromJson(hwJson),
      capabilities: caps,
      contract: json['contract'] ?? '2.4',
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'state': state,
      'fw': fw,
      'uptime': uptime,
      'rssi': rssi,
      'role': role,
      'ip': ip,
      'hw': hw.toJson(),
      'capabilities': capabilities,
      'contract': contract,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}




