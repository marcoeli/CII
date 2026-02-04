// Core models for the IoT Simulator

enum ResourceDomain { water, security, climate, light, power, env }

enum ResourceKind {
  level,
  pump,
  doorbell,
  presence,
  smoke,
  camera,
  climate,
  lamp,
  outlet,
  valve,
  gas,
  air,
}

enum AutomationMode { none, ramp, random, sine }

class AutomationConfig {
  final AutomationMode mode;
  final double min;
  final double max;
  final double step;
  final int intervalMs;
  final bool burstMode;
  final double anomalyRate;

  AutomationConfig({
    this.mode = AutomationMode.none,
    this.min = 0,
    this.max = 100,
    this.step = 1.0,
    this.intervalMs = 5000,
    this.burstMode = false,
    this.anomalyRate = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'min': min,
    'max': max,
    'step': step,
    'intervalMs': intervalMs,
    'burstMode': burstMode,
    'anomalyRate': anomalyRate,
  };

  factory AutomationConfig.fromJson(Map<String, dynamic> json) =>
      AutomationConfig(
        mode: AutomationMode.values.firstWhere(
          (e) => e.name == json['mode'],
          orElse: () => AutomationMode.none,
        ),
        min: (json['min'] ?? 0).toDouble(),
        max: (json['max'] ?? 100).toDouble(),
        step: (json['step'] ?? 1.0).toDouble(),
        intervalMs: json['intervalMs'] ?? 5000,
        burstMode: json['burstMode'] ?? false,
        anomalyRate: (json['anomalyRate'] ?? 0.0).toDouble(),
      );
}

class ResourceModel {
  final String id;
  final String label;
  final ResourceDomain domain;
  final ResourceKind kind;
  Map<String, dynamic> state;
  Map<String, dynamic> data;
  Map<String, dynamic> config;
  AutomationConfig automation;
  Map<String, dynamic> internalState = {}; // Dados de controle interno (V2.4)

  // Tracking para Edge-Triggering (V2.4)
  String? lastPublishedStateHash;
  String? lastPublishedDataHash;
  DateTime? lastStatePublishTs;
  DateTime? lastDataPublishTs;

  ResourceModel({
    required this.id,
    required this.label,
    required this.domain,
    required this.kind,
    this.state = const {},
    this.data = const {},
    this.config = const {},
    AutomationConfig? automation,
  }) : automation = automation ?? AutomationConfig();

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'domain': domain.name,
    'kind': '${domain.name}.${kind.name}',
  };

  // V2.4 Config Helpers (Pumps & Valves)
  Map<String, dynamic> get rules => config['rules'] ?? {};
  Map<String, dynamic> get bindings => config['bindings'] ?? {};
  Map<String, dynamic> get safety => config['safety'] ?? {};

  // Legacy/Alias for compatibility
  Map<String, dynamic> get pumpRules => rules;
  Map<String, dynamic> get pumpBindings => bindings;

  /// Arredonda valores numéricos para reduzir ruído no MQTT (V2.4)
  dynamic roundValue(dynamic value) {
    if (value is num) {
      if (id.contains('percent') || id.contains('level')) {
        return double.parse(value.toStringAsFixed(2));
      }
      return double.parse(value.toStringAsFixed(1));
    }
    return value;
  }
}

class VirtualNode {
  final String id;
  final String role;
  final String fwVersion;
  final String model;
  final List<ResourceModel> resources;
  bool isOnline;
  int uptimeSeconds;

  VirtualNode({
    required this.id,
    required this.role,
    this.fwVersion = '2.4.0-sim',
    this.model = 'SIMULATOR_V1',
    required this.resources,
    this.isOnline = false,
    this.uptimeSeconds = 0,
  });

  Map<String, dynamic> toStatusJson() => {
    'contract': '2.4',
    'state': isOnline ? 'ONLINE' : 'OFFLINE',
    'role': role,
    'fw': fwVersion,
    'uptime': uptimeSeconds,
    'rssi': -20,
    'hw': {
      'vendor': 'icodz-sim',
      'model': model,
      'rev': '1.0',
      'serial': 'SIM-${id.toUpperCase()}',
    },
    'capabilities': resources
        .map(
          (r) => {
            'type':
                '${r.domain.name.toUpperCase()}_${r.kind.name.toUpperCase()}',
            'resources': [r.toJson()],
          },
        )
        .toList(),
  };
}
