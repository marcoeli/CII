import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../models/iot_models.dart';
import '../services/mqtt_simulator_service.dart';

final _log = Logger('SimulatorProvider');

final mqttSimulatorServiceProvider = Provider(
  (ref) => MqttSimulatorService(ref),
);

class SimulatorState {
  final List<VirtualNode> nodes;
  final bool hasExternalWater;

  SimulatorState({required this.nodes, this.hasExternalWater = true});

  SimulatorState copyWith({List<VirtualNode>? nodes, bool? hasExternalWater}) {
    return SimulatorState(
      nodes: nodes ?? this.nodes,
      hasExternalWater: hasExternalWater ?? this.hasExternalWater,
    );
  }
}

class SimulatorNotifier extends Notifier<SimulatorState> {
  late final MqttSimulatorService _mqttService;
  Timer? _simulationTimer;

  @override
  SimulatorState build() {
    _mqttService = ref.read(mqttSimulatorServiceProvider);
    _startSimulationTimer();

    ref.onDispose(() {
      _simulationTimer?.cancel();
    });

    return _initializeDefaultNodes();
  }

  void _startSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _runPhysics();
      _runAutomation();
    });
  }

  void _runPhysics() {
    bool stateChanged = false;
    final nodes = state.nodes;

    // 1. Localizar Cisterna
    final cisternNode = nodes.firstWhere(
      (n) => n.id == 'cistern-node-sim',
      orElse: () => nodes.first,
    );
    final cisternLevel = cisternNode.resources.firstWhere(
      (r) => r.id == 'water.level.cistern',
    );
    final pumps = cisternNode.resources.where(
      (r) => r.kind == ResourceKind.pump,
    );
    final valve = cisternNode.resources.firstWhere(
      (r) => r.id == 'water.valve.main_inlet',
    );

    double cisternLiters = (cisternLevel.data['liters'] ?? 0.0).toDouble();
    const double basePumpFlow = 0.42; // ~25 L/min (1/2 HP)
    const double baseValveFlow = 0.40;
    const double maxCistern = 10000.0;
    const double leakRate = 0.005; // 0.005 L/s = 0.3 L/min

    // A. Válvula de Entrada (V2.4 Local Logic com Bindings)
    final valveMode = valve.state['mode'] ?? 'AUTO';
    if (valveMode == 'AUTO') {
      _processAutoValveLogic(valve, nodes);
    }

    if (valve.state['open'] == true && state.hasExternalWater) {
      final targetId = valve.bindings['target_level'];
      if (targetId != null) {
        ResourceModel? targetLevel;
        for (final node in nodes) {
          final res = node.resources.where((r) => r.id == targetId).firstOrNull;
          if (res != null) {
            targetLevel = res;
            break;
          }
        }

        if (targetLevel != null) {
          double targetLiters = (targetLevel.data['liters'] ?? 0.0).toDouble();
          final maxTarget = targetLevel.id.contains('cistern')
              ? 10000.0
              : 1000.0;

          if (targetLiters < maxTarget) {
            // Simulação de Pressão da Rede (Oscilação de 10%)
            final jitter = 0.95 + (math.Random().nextDouble() * 0.1);
            final effectiveValveFlow = baseValveFlow * jitter;

            targetLiters = math.min(
              maxTarget,
              targetLiters + effectiveValveFlow,
            );
            _updateResourceLiters(targetLevel, targetLiters, maxTarget);
            stateChanged = true;
          }
        }
      }
    }

    // B. Bombas (Lógica V2.4)
    for (final pump in pumps) {
      final mode = pump.state['mode'] ?? 'MANUAL';

      if (mode == 'AUTO') {
        _processAutoPumpLogic(pump, nodes);
      }

      // Física: Se a bomba está rodando e temos água, transfere litros
      if (pump.state['running'] == true && cisternLiters > 0) {
        final targetId = pump.pumpBindings['target_level'];
        if (targetId == null) continue;

        // Tentar encontrar o tanque alvo em qualquer nó
        ResourceModel? targetLevel;
        for (final node in nodes) {
          final res = node.resources.where((r) => r.id == targetId).firstOrNull;
          if (res != null) {
            targetLevel = res;
            break;
          }
        }

        if (targetLevel != null) {
          double targetLiters = (targetLevel.data['liters'] ?? 0.0).toDouble();
          const double maxTarget = 1000.0;

          // Perda de carga: Bombas perdem rendimento se o nível estiver baixo
          final headEfficiency = 0.8 + (0.2 * (cisternLiters / maxCistern));
          final effectivePumpFlow = basePumpFlow * headEfficiency;

          if (targetLiters < maxTarget) {
            cisternLiters -= effectivePumpFlow;
            targetLiters = math.min(
              maxTarget,
              targetLiters + effectivePumpFlow,
            );

            _updateResourceLiters(targetLevel, targetLiters, maxTarget);
            stateChanged = true;
          }
        }
      }
    }

    // C. Leakage (Realismo)
    if (cisternLiters > 0) {
      cisternLiters -= leakRate;
      stateChanged = true;
    }

    // 2. Simular Eventos Aleatórios (Segurança)
    final random = math.Random();
    if (random.nextDouble() < 0.05) {
      // 5% de chance a cada segundo
      final secureNode = nodes
          .where((n) => n.id == 'secure-node-sim')
          .firstOrNull;
      if (secureNode != null) {
        final presence = secureNode.resources
            .where((r) => r.kind == ResourceKind.presence)
            .firstOrNull;
        if (presence != null) {
          presence.state['detected'] = !presence.state['detected'];
          presence.state['ts'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          stateChanged = true;

          // Se detectou presença, publica evento se estiver online
          if (secureNode.isOnline) {
            _mqttService.publishResourceUpdate(
              secureNode.id,
              presence.id,
              state: presence.state,
            );
          }
        }
      }
    }

    if (stateChanged) {
      _updateResourceLiters(cisternLevel, cisternLiters, maxCistern);
      state = state.copyWith(nodes: List.from(state.nodes));
    }
  }

  void toggleExternalWater() {
    state = state.copyWith(hasExternalWater: !state.hasExternalWater);
    _log.info(
      'Água externa: ${state.hasExternalWater ? "DISPONÍVEL" : "INDISPONÍVEL"}',
    );
  }

  void _processAutoValveLogic(ResourceModel valve, List<VirtualNode> nodes) {
    final rules = valve.rules;
    final targetId = valve.bindings['target_level'];

    ResourceModel? targetLevel;
    for (final node in nodes) {
      targetLevel = node.resources.where((r) => r.id == targetId).firstOrNull;
      if (targetLevel != null) break;
    }

    if (targetLevel == null) {
      valve.state['reason'] = 'BINDING_ERROR';
      return;
    }

    final targetPct = (targetLevel.data['percent'] ?? 0.0).toDouble();
    final startBelow = (rules['start_below_percent'] ?? 50.0).toDouble();
    final stopAbove = (rules['stop_above_percent'] ?? 95.0).toDouble();
    final checkPeriod = (rules['check_period_s'] ?? 10).toInt();
    final minIncrease = (rules['min_increase_percent'] ?? 0.2).toDouble();

    // 1. Travas de Transbordamento (Prioridade Máxima)
    if (targetPct >= stopAbove) {
      if (valve.state['open'] == true) {
        valve.state['open'] = false;
        valve.state['reason'] = 'CISTERN_FULL';
      }
      return;
    }

    // 2. Lógica de Segurança "Pump-Aware" (Net Flow)
    if (valve.state['open'] == true) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final lastCheckTime = valve.internalState['last_check_ts'] ?? now;
      final lastCheckLevel =
          (valve.internalState['last_check_level'] ?? targetPct).toDouble();

      if (now - lastCheckTime >= checkPeriod) {
        // Calcular variação de nível real
        final actualIncrease = targetPct - lastCheckLevel;

        // Calcular consumo das bombas no período (se estiverem puxando deste tanque)
        double estimatedPumpOutflowPct = 0.0;
        final cisternCapacity = targetLevel.id.contains('cistern')
            ? 10000.0
            : 1000.0;

        // Procuramos por bombas que tenham este tanque como "source_level"
        for (final node in nodes) {
          for (final res in node.resources) {
            if (res.kind == ResourceKind.pump &&
                res.state['running'] == true &&
                res.pumpBindings['source_level'] == targetId) {
              // Cada bomba consome 0.42 L/s -> transformamos em % por checkPeriod
              final consumedLiters = 0.42 * (now - lastCheckTime);
              estimatedPumpOutflowPct +=
                  (consumedLiters / cisternCapacity) * 100.0;
            }
          }
        }

        // Net Flow: Aumento Real + Consumo das Bombas
        final netIncrease = actualIncrease + estimatedPumpOutflowPct;

        if (netIncrease < minIncrease) {
          // Bloqueio por falta de água externa (Rede Seca)
          valve.state['open'] = false;
          valve.state['reason'] = 'NO_EXTERNAL_WATER';
          valve.internalState['last_check_ts'] = now;
          valve.internalState['last_check_level'] = targetPct;
          return;
        } else {
          // Água fluindo, reseta timer
          valve.internalState['last_check_ts'] = now;
          valve.internalState['last_check_level'] = targetPct;
        }
      }
    } else {
      // Se fechada e não estiver em erro de falta d'água, reseta os marcadores
      if (valve.state['reason'] != 'NO_EXTERNAL_WATER') {
        valve.internalState['last_check_ts'] =
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        valve.internalState['last_check_level'] = targetPct;
      }
    }

    // 3. Lógica de Histerese
    if (targetPct < startBelow) {
      if (valve.state['open'] == false &&
          valve.state['reason'] != 'NO_EXTERNAL_WATER') {
        valve.state['open'] = true;
        valve.state['reason'] = 'LEVEL_LOW';
      }
    } else if (targetPct >= stopAbove) {
      // Já tratado acima, mas mantemos para consistência se necessário
    } else {
      // Entre start e stop
      if (valve.state['open'] == true) {
        valve.state['reason'] = 'FILLING';
      } else {
        if (valve.state['reason'] != 'NO_EXTERNAL_WATER') {
          valve.state['reason'] = 'IDLE';
        }
      }
    }
  }

  void _processAutoPumpLogic(ResourceModel pump, List<VirtualNode> nodes) {
    final rules = pump.pumpRules;
    final bindings = pump.pumpBindings;

    final sourceId = bindings['source_level'];
    final targetId = bindings['target_level'];

    ResourceModel? source;
    ResourceModel? target;

    for (final node in nodes) {
      source ??= node.resources.where((r) => r.id == sourceId).firstOrNull;
      target ??= node.resources.where((r) => r.id == targetId).firstOrNull;
    }

    if (source == null || target == null) {
      pump.state['reason'] = 'BINDING_ERROR';
      return;
    }

    final sourcePct = (source.data['percent'] ?? 0.0).toDouble();
    final targetPct = (target.data['percent'] ?? 0.0).toDouble();

    final minSource = (rules['min_source_percent'] ?? 15.0).toDouble();
    final startBelow = (rules['start_below_percent'] ?? 30.0).toDouble();
    final stopAbove = (rules['stop_above_percent'] ?? 85.0).toDouble();

    // 1. Travas de Segurança
    if (sourcePct < minSource) {
      pump.state['running'] = false;
      pump.state['reason'] = 'DRY_RUN_PROT';
      return;
    }

    if (targetPct >= stopAbove) {
      pump.state['running'] = false;
      pump.state['reason'] = 'TARGET_FULL';
      return;
    }

    // 2. Lógica de Histerese (Garra)
    if (targetPct < startBelow) {
      if (pump.state['running'] == false) {
        pump.state['running'] = true;
        pump.state['reason'] = 'LEVEL_LOW';
      }
    } else if (targetPct >= stopAbove) {
      if (pump.state['running'] == true) {
        pump.state['running'] = false;
        pump.state['reason'] = 'LEVEL_OK';
      }
    } else {
      // Entre start e stop -> Mantém o que estiver
      if (pump.state['running'] == true) {
        pump.state['reason'] = 'FILLING';
      } else {
        pump.state['reason'] = 'IDLE';
      }
    }
  }

  void _updateResourceLiters(
    ResourceModel resource,
    double liters,
    double max,
  ) {
    resource.data['liters'] = liters;
    resource.data['percent'] = (liters / max) * 100.0;
    resource.data['distance_cm'] =
        (1.0 - (liters / max)) * 200.0; // Ex: 2 metros de altura
  }

  void _runAutomation() {
    bool stateChanged = false;
    for (final node in state.nodes) {
      for (final resource in node.resources) {
        if (resource.automation.mode == AutomationMode.none) continue;

        final config = resource.automation;
        double currentVal = 0.0;

        // Determinar valor base dependendo do tipo de recurso
        if (resource.kind == ResourceKind.level ||
            resource.kind == ResourceKind.climate) {
          final key = resource.kind == ResourceKind.level
              ? 'percent'
              : 'temperature';
          currentVal = (resource.data[key] ?? config.min).toDouble();

          double newVal = currentVal;
          switch (config.mode) {
            case AutomationMode.ramp:
              newVal += config.step;
              if (newVal > config.max) newVal = config.min;
              break;
            case AutomationMode.random:
              newVal =
                  config.min +
                  math.Random().nextDouble() * (config.max - config.min);
              break;
            case AutomationMode.sine:
              final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
              newVal =
                  config.min +
                  (math.sin(time / 10.0) + 1.0) /
                      2.0 *
                      (config.max - config.min);
              break;
            default:
              break;
          }

          resource.data[key] = newVal;
          if (resource.kind == ResourceKind.level) {
            final maxLiters = resource.id.contains('cistern')
                ? 10000.0
                : 1000.0;
            resource.data['liters'] = (newVal / 100.0) * maxLiters;
          }
          stateChanged = true;
        }
      }
    }

    if (stateChanged) {
      state = SimulatorState(nodes: List.from(state.nodes));
    }
  }

  SimulatorState _initializeDefaultNodes() {
    return SimulatorState(
      nodes: [
        _createCisternNode(),
        _createTankNode(1, 'Caixa Superior 1'),
        _createTankNode(2, 'Caixa Superior 2'),
        _createSecurityNode(),
        _createClimateNode(),
      ],
    );
  }

  VirtualNode _createCisternNode() {
    return VirtualNode(
      id: 'cistern-node-sim',
      role: 'CISTERN_CONTROLLER',
      resources: [
        ResourceModel(
          id: 'water.level.cistern',
          label: 'Cisterna Principal',
          domain: ResourceDomain.water,
          kind: ResourceKind.level,
          data: {'liters': 5000, 'percent': 50.0, 'distance_cm': 50},
          state: {'alert': 'NORMAL'},
        ),
        ResourceModel(
          id: 'water.pump.cistern_1',
          label: 'Bomba de Recalque 1',
          domain: ResourceDomain.water,
          kind: ResourceKind.pump,
          state: {'running': false, 'mode': 'AUTO', 'reason': 'INITIALIZING'},
          config: {
            'bindings': {
              'source_level': 'water.level.cistern',
              'target_level': 'water.level.tank_1',
            },
            'rules': {
              'min_source_percent': 15,
              'start_below_percent': 30,
              'stop_above_percent': 85,
            },
          },
        ),
        ResourceModel(
          id: 'water.pump.cistern_2',
          label: 'Bomba de Recalque 2',
          domain: ResourceDomain.water,
          kind: ResourceKind.pump,
          state: {'running': false, 'mode': 'AUTO', 'reason': 'INITIALIZING'},
          config: {
            'bindings': {
              'source_level': 'water.level.cistern',
              'target_level': 'water.level.tank_2',
            },
            'rules': {
              'min_source_percent': 15,
              'start_below_percent': 30,
              'stop_above_percent': 85,
            },
          },
        ),
        ResourceModel(
          id: 'water.valve.main_inlet',
          label: 'Válvula de Entrada',
          domain: ResourceDomain.water,
          kind: ResourceKind.valve,
          state: {'open': false, 'mode': 'AUTO', 'reason': 'INITIALIZING'},
          config: {
            'bindings': {'target_level': 'water.level.cistern'},
            'rules': {
              'start_below_percent': 50,
              'stop_above_percent': 95,
              'check_period_s': 10,
              'min_increase_percent': 0.2,
            },
          },
        ),
      ],
    );
  }

  VirtualNode _createTankNode(int index, String label) {
    return VirtualNode(
      id: 'tank-node-$index-sim',
      role: 'TANK_CONTROLLER',
      resources: [
        ResourceModel(
          id: 'water.level.tank_$index',
          label: label,
          domain: ResourceDomain.water,
          kind: ResourceKind.level,
          data: {'liters': 500, 'percent': 50.0, 'distance_cm': 50},
          state: {'alert': 'NORMAL'},
        ),
      ],
    );
  }

  VirtualNode _createSecurityNode() {
    return VirtualNode(
      id: 'secure-node-sim',
      role: 'SECURITY_HUB',
      resources: [
        ResourceModel(
          id: 'security.doorbell.entrance',
          label: 'Campainha Entrada',
          domain: ResourceDomain.security,
          kind: ResourceKind.doorbell,
        ),
        ResourceModel(
          id: 'security.presence.garage',
          label: 'Garagem',
          domain: ResourceDomain.security,
          kind: ResourceKind.presence,
          state: {'detected': false, 'ts': 1710000000},
        ),
        ResourceModel(
          id: 'env.air_quality.kitchen',
          label: 'Sensor de Ar Cozinha',
          domain: ResourceDomain.env,
          kind: ResourceKind.air,
          data: {'ppm': 10, 'alert': 'NORMAL'},
        ),
        ResourceModel(
          id: 'security.camera.front_door',
          label: 'Câmera Porta Frontal',
          domain: ResourceDomain.security,
          kind: ResourceKind.camera,
          state: {'online': true, 'motion': false},
        ),
        ResourceModel(
          id: 'security.alarm.main',
          label: 'Sistema de Alarme',
          domain: ResourceDomain.security,
          kind: ResourceKind
              .presence, // Usando presence para alarm state por enquanto
          state: {'armed': true, 'triggered': false},
        ),
        ResourceModel(
          id: 'hmi.button.panic',
          label: 'Botão de Pânico',
          domain: ResourceDomain.security,
          kind: ResourceKind.doorbell,
          state: {'pressed': false},
        ),
        ResourceModel(
          id: 'hmi.buzzer.alarm',
          label: 'Sirene Portaria',
          domain: ResourceDomain.security,
          kind: ResourceKind.pump, // Usando pump para buzzer state (on/off)
          state: {'on': false},
        ),
        ResourceModel(
          id: 'env.smoke.garage',
          label: 'Sensor de Fumaça Garagem',
          domain: ResourceDomain.env,
          kind: ResourceKind.smoke,
          data: {'ppm': 5, 'alert': 'CLEAR'},
        ),
      ],
    );
  }

  VirtualNode _createClimateNode() {
    return VirtualNode(
      id: 'climate-node-sim',
      role: 'CLIMATE_STATION',
      resources: [
        ResourceModel(
          id: 'env.climate.living_room',
          label: 'Clima Sala',
          domain: ResourceDomain.env,
          kind: ResourceKind.climate,
          data: {'temperature': 24.5, 'humidity': 60.0},
        ),
        ResourceModel(
          id: 'light.lamp.living_room',
          label: 'Luz Sala de Estar',
          domain: ResourceDomain.light,
          kind: ResourceKind.lamp,
          state: {'on': false, 'brightness': 0},
        ),
        ResourceModel(
          id: 'power.outlet.bedroom_tv',
          label: 'Tomada TV Quarto',
          domain: ResourceDomain.power,
          kind: ResourceKind.outlet,
          state: {'on': false, 'watts': 0},
        ),
      ],
    );
  }

  VirtualNode _createAutomationNode() {
    return VirtualNode(
      id: 'automation-node-sim',
      role: 'AUTOMATION_CONTROLLER',
      resources: [
        ResourceModel(
          id: 'env.gas.kitchen',
          label: 'Sensor de Gás Cozinha',
          domain: ResourceDomain.env,
          kind: ResourceKind.gas,
          data: {'ppm': 0, 'alert': 'NORMAL'},
        ),
        ResourceModel(
          id: 'light.relay.garage',
          label: 'Rele Garagem',
          domain: ResourceDomain.light,
          kind: ResourceKind.lamp,
          state: {'on': false},
        ),
      ],
    );
  }

  Future<void> toggleNode(String nodeId) async {
    final nodeIndex = state.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) {
      _log.warning('Node $nodeId not found');
      return;
    }

    final node = state.nodes[nodeIndex];
    if (node.isOnline) {
      _mqttService.stopNode(nodeId);
      node.isOnline = false;
    } else {
      await _mqttService.startNode(node);
    }
    state = SimulatorState(nodes: List.from(state.nodes));
  }

  Future<void> factoryReset(String nodeId) async {
    await _mqttService.factoryReset(nodeId);

    // Replace the node with a fresh one to reset its state
    late VirtualNode freshNode;
    if (nodeId == 'cistern-node-sim') {
      freshNode = _createCisternNode();
    } else if (nodeId.startsWith('tank-node')) {
      final index = int.parse(nodeId.split('-')[2]);
      freshNode = _createTankNode(index, 'Caixa Superior $index');
    } else if (nodeId == 'secure-node-sim') {
      freshNode = _createSecurityNode();
    } else if (nodeId == 'climate-node-sim') {
      freshNode = _createClimateNode();
    } else if (nodeId == 'automation-node-sim') {
      freshNode = _createAutomationNode();
    } else {
      return; // Should not happen
    }

    final index = state.nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      state.nodes[index] = freshNode;
      // Ensure it stays offline after reset
      freshNode.isOnline = false;
      state = SimulatorState(nodes: List.from(state.nodes));
    }
  }

  void updateResourceData(
    String nodeId,
    String resourceId,
    Map<String, dynamic> newData,
  ) {
    final nodeIndex = state.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) {
      _log.warning('Node $nodeId not found');
      return;
    }

    final node = state.nodes[nodeIndex];
    final resourceIndex = node.resources.indexWhere((r) => r.id == resourceId);
    if (resourceIndex == -1) {
      _log.warning('Resource $resourceId not found in node $nodeId');
      return;
    }

    final resource = node.resources[resourceIndex];
    resource.data = {...resource.data, ...newData};
    state = SimulatorState(nodes: List.from(state.nodes));
  }

  void sendCommand(
    String nodeId,
    String resourceId,
    Map<String, dynamic> command,
  ) {
    final nodeIndex = state.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) {
      _log.warning('Node $nodeId not found');
      return;
    }

    final node = state.nodes[nodeIndex];
    final resourceIndex = node.resources.indexWhere((r) => r.id == resourceId);
    if (resourceIndex == -1) {
      _log.warning('Resource $resourceId not found in node $nodeId');
      return;
    }

    final resource = node.resources[resourceIndex];

    // Atualizar o estado localmente para refletir o comando
    if (command['action'] == 'START' ||
        command['action'] == 'ON' ||
        command['action'] == 'OPEN') {
      if (command['action'] == 'OPEN') {
        resource.state['open'] = true;
      } else {
        resource.state['running'] = true;
        resource.state['on'] = true;
      }
      // Se mandar comando manual, muda o modo da bomba/válvula para MANUAL
      if (resource.kind == ResourceKind.pump ||
          resource.kind == ResourceKind.valve) {
        resource.state['mode'] = 'MANUAL';
        resource.state['reason'] = 'MANUAL_CMD';
      }
    } else if (command['action'] == 'STOP' ||
        command['action'] == 'OFF' ||
        command['action'] == 'CLOSE') {
      if (command['action'] == 'CLOSE') {
        resource.state['open'] = false;
      } else {
        resource.state['running'] = false;
        resource.state['on'] = false;
      }
      if (resource.kind == ResourceKind.pump ||
          resource.kind == ResourceKind.valve) {
        resource.state['mode'] = 'MANUAL';
        resource.state['reason'] = 'MANUAL_CMD';
      }
    } else if (command['action'] == 'SET_MODE') {
      final newMode = command['params']?['mode'];
      if (newMode != null) {
        resource.state['mode'] = newMode;
      }
    }

    // Atualizar o estado do nó para forçar rebuild da UI
    state = SimulatorState(nodes: List.from(state.nodes));

    // Enviar o comando via MQTT
    _mqttService.sendCommand(nodeId, resourceId, command);
  }

  void updateAutomation(
    String nodeId,
    String resourceId,
    AutomationConfig config,
  ) {
    final nodeIndex = state.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;

    final node = state.nodes[nodeIndex];
    final resIndex = node.resources.indexWhere((r) => r.id == resourceId);
    if (resIndex == -1) return;

    node.resources[resIndex].automation = config;
    state = SimulatorState(nodes: List.from(state.nodes));
  }

  void updateResourceConfig(
    String nodeId,
    String resourceId,
    Map<String, dynamic> newConfig,
  ) {
    final nodeIndex = state.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;

    final node = state.nodes[nodeIndex];
    final resIndex = node.resources.indexWhere((r) => r.id == resourceId);
    if (resIndex == -1) return;

    node.resources[resIndex].config = {
      ...node.resources[resIndex].config,
      ...newConfig,
    };
    state = SimulatorState(nodes: List.from(state.nodes));
  }
}

final simulatorProvider = NotifierProvider<SimulatorNotifier, SimulatorState>(
  () {
    return SimulatorNotifier();
  },
);
