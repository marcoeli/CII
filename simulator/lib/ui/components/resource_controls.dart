import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/iot_models.dart';
import '../../core/providers/simulator_provider.dart';

class LevelControl extends ConsumerWidget {
  final String nodeId;
  final ResourceModel resource;

  const LevelControl({super.key, required this.nodeId, required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawPercent = (resource.data['percent'] ?? 0.0).toDouble();
    final percent = rawPercent.isFinite ? rawPercent.clamp(0.0, 100.0) : 0.0;

    return Row(
      children: [
        // Vertical Slider (Tank visual)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 20,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: percent,
                      min: 0,
                      max: 100,
                      onChanged: (val) => _updateData(ref, val),
                    ),
                  ),
                ),
              ),
              const Text(
                'NÍVEL',
                style: TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Numeric Input & Details
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumericInput(
                value: percent,
                label: '%',
                onChanged: (val) => _updateData(ref, val),
              ),
              const SizedBox(height: 4),
              Text(
                '${(percent * (resource.id.contains('cistern') ? 100 : 10)).toInt()} L',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${(100 - percent).toInt()}cm',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateData(WidgetRef ref, double val) {
    final maxLiters = resource.id.contains('cistern') ? 10000.0 : 1000.0;
    ref
        .read(simulatorProvider.notifier)
        .updateResourceData(nodeId, resource.id, {
          'percent': val,
          'liters': (val / 100.0) * maxLiters,
          'distance_cm': (1.0 - (val / 100.0)) * 200.0,
        });
  }
}

class ActuatorControl extends ConsumerWidget {
  final String nodeId;
  final ResourceModel resource;

  const ActuatorControl({
    super.key,
    required this.nodeId,
    required this.resource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPump = resource.kind == ResourceKind.pump;
    final isRunning = isPump
        ? resource.state['running'] == true
        : resource.state['open'] == true;

    final actionOn = resource.kind == ResourceKind.valve ? 'OPEN' : 'START';
    final actionOff = resource.kind == ResourceKind.valve ? 'CLOSE' : 'STOP';
    final labelOn = resource.kind == ResourceKind.valve ? 'ABRIR' : 'LIGAR';
    final labelOff = resource.kind == ResourceKind.valve ? 'FECH' : 'DESL';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              label: labelOn,
              color: Colors.green,
              isActive: isRunning,
              onPressed: () => _sendCommand(ref, actionOn),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: labelOff,
              color: Colors.red,
              isActive: !isRunning,
              onPressed: () => _sendCommand(ref, actionOff),
            ),
          ],
        ),
        if (isPump || resource.kind == ResourceKind.valve) ...[
          const SizedBox(height: 8),
          // Seletor de Modo
          Row(
            children: [
              _ModeButton(
                label: 'AUTO',
                isSelected: resource.state['mode'] == 'AUTO',
                onPressed: () => _setMode(ref, 'AUTO'),
              ),
              const SizedBox(width: 4),
              _ModeButton(
                label: 'MANUAL',
                isSelected: resource.state['mode'] == 'MANUAL',
                onPressed: () => _setMode(ref, 'MANUAL'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status de Automação / Safety
          _buildAutomationStatus(resource),
        ],
      ],
    );
  }

  Widget _buildAutomationStatus(ResourceModel resource) {
    final isPump = resource.kind == ResourceKind.pump;
    final isValve = resource.kind == ResourceKind.valve;
    if (!isPump && !isValve) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STATUS:',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                resource.state['reason']?.toString() ?? 'IDLE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: _getReasonColor(resource.state['reason']),
                ),
              ),
            ],
          ),
          if (isPump) ...[
            const SizedBox(height: 4),
            Consumer(
              builder: (context, ref, _) {
                return _buildTargetLevelInfo(
                  ref,
                  resource.pumpBindings['target_level'],
                );
              },
            ),
          ],
          if (isValve) ...[
            const SizedBox(height: 4),
            Consumer(
              builder: (context, ref, _) {
                final hasNoWater =
                    resource.state['reason'] == 'NO_EXTERNAL_WATER';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FONTE: REDE EXTERNA',
                          style: TextStyle(fontSize: 8, color: Colors.white38),
                        ),
                        Text(
                          hasNoWater ? 'SEM ÁGUA' : 'PRESENÇA OK',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: hasNoWater ? Colors.redAccent : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildTargetLevelInfo(
                      ref,
                      resource.bindings['target_level'],
                    ),
                    if (resource.state['open'] == true && !hasNoWater) ...[
                      const SizedBox(height: 4),
                      const LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ABASTECENDO RECIPIENTE',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetLevelInfo(WidgetRef ref, dynamic targetId) {
    if (targetId == null) return const SizedBox.shrink();

    final simulatorState = ref.watch(simulatorProvider);
    ResourceModel? target;
    for (final node in simulatorState.nodes) {
      target = node.resources.where((r) => r.id == targetId).firstOrNull;
      if (target != null) break;
    }

    if (target == null) {
      return Text(
        'ALVO: $targetId',
        style: const TextStyle(fontSize: 8, color: Colors.white24),
      );
    }

    final pct = (target.data['percent'] ?? 0.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ALVO: ${target.label}',
              style: const TextStyle(fontSize: 8, color: Colors.white38),
            ),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: pct > 85 ? Colors.orange : Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 2,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct > 85 ? Colors.orange : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  void _setMode(WidgetRef ref, String mode) {
    ref.read(simulatorProvider.notifier).sendCommand(nodeId, resource.id, {
      'action': 'SET_MODE',
      'params': {'mode': mode},
    });
  }

  Color _getReasonColor(dynamic reason) {
    switch (reason?.toString()) {
      case 'DRY_RUN_PROT':
      case 'BINDING_ERROR':
        return Colors.redAccent;
      case 'TARGET_FULL':
      case 'LEVEL_OK':
        return Colors.orangeAccent;
      case 'LEVEL_LOW':
      case 'FILLING':
        return Colors.greenAccent;
      default:
        return Colors.blueGrey;
    }
  }

  void _sendCommand(WidgetRef ref, String action) {
    ref.read(simulatorProvider.notifier).sendCommand(nodeId, resource.id, {
      'action': action,
      'params': {},
    });
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withAlpha(60) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.white10,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}

class SecurityControl extends ConsumerWidget {
  final String nodeId;
  final ResourceModel resource;

  const SecurityControl({
    super.key,
    required this.nodeId,
    required this.resource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (resource.kind == ResourceKind.presence) {
      final isAlarm = resource.id.contains('alarm');
      if (isAlarm) {
        final isArmed = resource.state['armed'] == true;
        final isTriggered = resource.state['triggered'] == true;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: isArmed ? 'DESARMAR' : 'ARMAR',
                  color: isArmed ? Colors.orange : Colors.blue,
                  isActive: true,
                  onPressed: () =>
                      _sendCommand(ref, isArmed ? 'DISARM' : 'ARM'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isTriggered
                    ? Colors.red.withAlpha(40)
                    : (isArmed
                          ? Colors.blue.withAlpha(40)
                          : Colors.grey.withAlpha(20)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTriggered
                      ? Colors.red
                      : (isArmed ? Colors.blue : Colors.grey),
                ),
              ),
              child: Text(
                isTriggered ? 'DISPARADO!' : (isArmed ? 'ARMADO' : 'DESARMADO'),
                style: TextStyle(
                  color: isTriggered
                      ? Colors.red
                      : (isArmed ? Colors.blue : Colors.grey),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      } else {
        final detected = resource.state['detected'] == true;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                detected ? Icons.directions_run : Icons.accessibility_new,
                color: detected ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                detected ? 'MOVIMENTO' : 'LIMPO',
                style: TextStyle(
                  color: detected ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
    }

    if (resource.kind == ResourceKind.doorbell) {
      final isPanic = resource.id.contains('panic');
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => _sendCommand(ref, 'PRESS'),
          icon: Icon(isPanic ? Icons.warning : Icons.notifications),
          label: Text(isPanic ? 'PÂNICO!' : 'TOCAR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isPanic ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (resource.kind == ResourceKind.camera) {
      final online = resource.state['online'] == true;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            color: online ? Colors.green : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            online ? 'LIVE STREAM' : 'OFFLINE',
            style: TextStyle(
              color: online ? Colors.green : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        resource.state.toString(),
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  void _sendCommand(WidgetRef ref, String action) {
    ref.read(simulatorProvider.notifier).sendCommand(nodeId, resource.id, {
      'action': action,
      'params': {},
    });
  }
}

class EnvironmentControl extends ConsumerWidget {
  final String nodeId;
  final ResourceModel resource;

  const EnvironmentControl({
    super.key,
    required this.nodeId,
    required this.resource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ppm = (resource.data['ppm'] ?? 0).toDouble();
    final alert = resource.data['alert'] ?? 'NORMAL';
    final isDanger = alert != 'NORMAL' && alert != 'CLEAR';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${ppm.toInt()} PPM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDanger ? Colors.red : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red.withAlpha(40)
                  : Colors.green.withAlpha(40),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              alert,
              style: TextStyle(
                color: isDanger ? Colors.red : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResourceSettingsDialog extends ConsumerStatefulWidget {
  final String nodeId;
  final String resourceId;
  final AutomationConfig initialConfig;
  final Map<String, dynamic> physicalConfig;

  const ResourceSettingsDialog({
    super.key,
    required this.nodeId,
    required this.resourceId,
    required this.initialConfig,
    required this.physicalConfig,
  });

  @override
  ConsumerState<ResourceSettingsDialog> createState() =>
      _ResourceSettingsDialogState();
}

class _ResourceSettingsDialogState
    extends ConsumerState<ResourceSettingsDialog> {
  late AutomationMode _mode;
  late double _min;
  late double _max;
  late double _step;
  late bool _burstMode;
  late double _anomalyRate;
  String? _targetTank;
  String? _sourceTank;
  late double _startBelow;
  late double _stopAbove;
  late double _minSource;
  late int _checkPeriod;
  late double _minIncrease;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialConfig.mode;
    _min = widget.initialConfig.min;
    _max = widget.initialConfig.max;
    _step = widget.initialConfig.step;
    _burstMode = widget.initialConfig.burstMode;
    _anomalyRate = widget.initialConfig.anomalyRate;
    final pumpRules = widget.physicalConfig['rules'] ?? {};
    final pumpBindings = widget.physicalConfig['bindings'] ?? {};
    _targetTank =
        pumpBindings['target_level'] ?? widget.physicalConfig['target_tank'];
    _sourceTank = pumpBindings['source_level'];
    _startBelow = (pumpRules['start_below_percent'] ?? 30.0).toDouble();
    _stopAbove = (pumpRules['stop_above_percent'] ?? 85.0).toDouble();
    _minSource = (pumpRules['min_source_percent'] ?? 15.0).toDouble();
    _checkPeriod = (pumpRules['check_period_s'] ?? 10).toInt();
    _minIncrease = (pumpRules['min_increase_percent'] ?? 0.5).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final simulatorState = ref.watch(simulatorProvider);
    final isPump = widget.resourceId.contains('pump');
    final isValve = widget.resourceId.contains('valve');

    // List all level resources in any node
    final availableTanks = simulatorState.nodes
        .expand((n) => n.resources)
        .where((r) => r.kind == ResourceKind.level)
        .toList();

    return AlertDialog(
      title: const Text('Configurações do Recurso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPump || isValve) ...[
              const Text(
                'ACOPLAMENTO FÍSICO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _targetTank,
                decoration: const InputDecoration(
                  labelText: 'Tanque Destino',
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12, color: Colors.white),
                items: availableTanks.map((tank) {
                  return DropdownMenuItem(
                    value: tank.id,
                    child: Text(
                      tank.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _targetTank = val),
              ),
              if (isPump) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _sourceTank,
                  decoration: const InputDecoration(
                    labelText: 'Tanque Origem (Cisterna)',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  items: availableTanks.map((tank) {
                    return DropdownMenuItem(
                      value: tank.id,
                      child: Text(
                        tank.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _sourceTank = val),
                ),
              ],
              const SizedBox(height: 16),
            ],
            if (isPump) ...[
              const Text(
                'REGRAS DE NÍVEL (%)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              _buildSlider(
                'Ligar abaixo de',
                _startBelow,
                0,
                100,
                (v) => setState(() => _startBelow = v),
              ),
              _buildSlider(
                'Desligar acima de',
                _stopAbove,
                0,
                100,
                (v) => setState(() => _stopAbove = v),
              ),
              _buildSlider(
                'Nível mín. cisterna',
                _minSource,
                0,
                100,
                (v) => setState(() => _minSource = v),
              ),
              const Divider(height: 32),
            ],
            if (widget.resourceId.contains('valve')) ...[
              const Text(
                'AUTOMAÇÃO DE ENTRADA (MALEÁVEL)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              _buildSlider(
                'Abrir abaixo de',
                _startBelow,
                0,
                100,
                (v) => setState(() => _startBelow = v),
              ),
              _buildSlider(
                'Fechar acima de',
                _stopAbove,
                0,
                100,
                (v) => setState(() => _stopAbove = v),
              ),
              const SizedBox(height: 16),
              const Text(
                'SEGURANÇA (NO-FLOW)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 8),
              _buildSlider(
                'Período de Checagem (s)',
                _checkPeriod.toDouble(),
                5,
                60,
                (v) => setState(() => _checkPeriod = v.toInt()),
              ),
              _buildSlider(
                'Aumento Mínimo (%)',
                _minIncrease,
                0.1,
                5.0,
                (v) => setState(() => _minIncrease = v),
              ),
              const Divider(height: 32),
            ],
            const Text(
              'AUTO-PILOT (GERADOR DE SINAL)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AutomationMode>(
              initialValue: _mode,
              decoration: const InputDecoration(
                labelText: 'Modo de Onda',
                isDense: true,
              ),
              items: AutomationMode.values.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(
                    m.name.toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (m) => setState(() => _mode = m!),
            ),
            if (_mode != AutomationMode.none) ...[
              const SizedBox(height: 16),
              _buildSlider(
                'Mínimo',
                _min,
                0,
                100,
                (v) => setState(() => _min = v),
              ),
              _buildSlider(
                'Máximo',
                _max,
                0,
                100,
                (v) => setState(() => _max = v),
              ),
              if (_mode == AutomationMode.ramp)
                _buildSlider(
                  'Passo (Step)',
                  _step,
                  0.1,
                  10,
                  (v) => setState(() => _step = v),
                ),
            ],
            const Divider(height: 32),
            const Text(
              'STRESS & ANOMALIAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text(
                'Burst Mode (1Hz)',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              subtitle: const Text(
                'Alta frequência de publicação',
                style: TextStyle(fontSize: 10, color: Colors.white38),
              ),
              value: _burstMode,
              dense: true,
              onChanged: (val) => setState(() => _burstMode = val),
            ),
            _buildSlider(
              'Taxa de Anomalias',
              _anomalyRate * 100,
              0,
              10, // Max 10% de anomalia pra não quebrar tudo
              (v) => setState(() => _anomalyRate = v / 100),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            // Save Automation
            ref
                .read(simulatorProvider.notifier)
                .updateAutomation(
                  widget.nodeId,
                  widget.resourceId,
                  AutomationConfig(
                    mode: _mode,
                    min: _min,
                    max: _max,
                    step: _step,
                    burstMode: _burstMode,
                    anomalyRate: _anomalyRate,
                  ),
                );

            // Save Physical Config if applicable
            if (isPump) {
              ref.read(simulatorProvider.notifier).updateResourceConfig(
                widget.nodeId,
                widget.resourceId,
                {
                  'bindings': {
                    'source_level': _sourceTank,
                    'target_level': _targetTank,
                  },
                  'rules': {
                    'start_below_percent': _startBelow,
                    'stop_above_percent': _stopAbove,
                    'min_source_percent': _minSource,
                  },
                  'target_tank': _targetTank, // Backwards compat
                },
              );
            }

            if (widget.resourceId.contains('valve')) {
              ref.read(simulatorProvider.notifier).updateResourceConfig(
                widget.nodeId,
                widget.resourceId,
                {
                  'bindings': {'target_level': _targetTank},
                  'rules': {
                    'start_below_percent': _startBelow,
                    'stop_above_percent': _stopAbove,
                    'check_period_s': _checkPeriod,
                    'min_increase_percent': _minIncrease,
                  },
                },
              );
            }

            Navigator.pop(context);
          },
          child: const Text('SALVAR'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _NumericInput extends StatefulWidget {
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  const _NumericInput({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<_NumericInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toInt().toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          suffixText: widget.label,
          suffixStyle: const TextStyle(color: Colors.white38, fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          filled: true,
          fillColor: Colors.black.withAlpha(50),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (val) {
          final newValue = double.tryParse(val);
          if (newValue != null) widget.onChanged(newValue.clamp(0.0, 100.0));
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : color.withAlpha(40),
          foregroundColor: Colors.white,
          elevation: isActive ? 4 : 0,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
