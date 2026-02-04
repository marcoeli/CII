import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/iot_models.dart';
import 'resource_controls.dart';

class ResourceGrid extends ConsumerWidget {
  final VirtualNode node;

  const ResourceGrid({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separa os recursos em Cockpit (Atuadores) e Monitoring (Sensores)
    final actuators = node.resources.where((r) => _isActuator(r.kind)).toList();
    final sensors = node.resources.where((r) => !_isActuator(r.kind)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (actuators.isNotEmpty) ...[
          _buildSectionHeader(context, 'COCKPIT', Icons.bolt),
          _buildGrid(context, actuators, true),
          const SizedBox(height: 24),
        ],
        if (sensors.isNotEmpty) ...[
          _buildSectionHeader(context, 'MONITORING', Icons.visibility),
          _buildGrid(context, sensors, false),
        ],
      ],
    );
  }

  bool _isActuator(ResourceKind kind) {
    return kind == ResourceKind.pump ||
        kind == ResourceKind.valve ||
        kind == ResourceKind.lamp ||
        kind == ResourceKind.outlet;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<ResourceModel> resources,
    bool isCockpit,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) => _ResourceCard(
        resource: resources[index],
        nodeId: node.id,
        isCockpit: isCockpit,
      ),
    );
  }
}

class _ResourceCard extends ConsumerWidget {
  final ResourceModel resource;
  final String nodeId;
  final bool isCockpit;

  const _ResourceCard({
    required this.resource,
    required this.nodeId,
    required this.isCockpit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withAlpha(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header: Icon + Label + Automation
            Row(
              children: [
                _getIcon(resource.kind, context),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (resource.kind == ResourceKind.level ||
                    resource.kind == ResourceKind.climate ||
                    resource.kind == ResourceKind.pump ||
                    resource.kind == ResourceKind.valve)
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      size: 16,
                      color:
                          resource.automation.mode != AutomationMode.none ||
                              resource.config.containsKey('target_tank') ||
                              resource.config.containsKey('rules')
                          ? Colors.blue
                          : Colors.grey.withAlpha(100),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Configurações do Simulador',
                    onPressed: () =>
                        _showSettingsDialog(context, ref, nodeId, resource),
                  ),
                if (isCockpit)
                  const Icon(Icons.flash_on, size: 14, color: Colors.amber),
              ],
            ),
            const Divider(height: 16),
            // Controls
            Expanded(child: _buildControls(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref) {
    switch (resource.kind) {
      case ResourceKind.level:
        return LevelControl(nodeId: nodeId, resource: resource);
      case ResourceKind.pump:
      case ResourceKind.valve:
      case ResourceKind.lamp:
      case ResourceKind.outlet:
        return ActuatorControl(nodeId: nodeId, resource: resource);
      case ResourceKind.climate:
        final temp = resource.data['temperature'] ?? 0.0;
        final hum = resource.data['humidity'] ?? 0.0;
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric(
                'TEMP',
                '${temp.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
              _buildMetric(
                'HUM',
                '${hum.toStringAsFixed(0)}%',
                Icons.water_drop,
              ),
            ],
          ),
        );
      case ResourceKind.presence:
      case ResourceKind.doorbell:
      case ResourceKind.camera:
        return SecurityControl(nodeId: nodeId, resource: resource);
      case ResourceKind.smoke:
      case ResourceKind.gas:
      case ResourceKind.air:
        return EnvironmentControl(nodeId: nodeId, resource: resource);
    }
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _getIcon(ResourceKind kind, BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    switch (kind) {
      case ResourceKind.level:
        return Icon(Icons.waves, color: color, size: 18);
      case ResourceKind.pump:
        return Icon(Icons.settings_input_component, color: color, size: 18);
      case ResourceKind.valve:
        return Icon(Icons.door_sliding, color: color, size: 18);
      case ResourceKind.lamp:
        return Icon(Icons.lightbulb, color: color, size: 18);
      case ResourceKind.climate:
        return Icon(Icons.thermostat, color: color, size: 18);
      case ResourceKind.presence:
        return Icon(Icons.sensors, color: color, size: 18);
      case ResourceKind.doorbell:
        return Icon(Icons.notification_important, color: color, size: 18);
      case ResourceKind.camera:
        return Icon(Icons.videocam, color: color, size: 18);
      case ResourceKind.smoke:
        return Icon(Icons.smoke_free, color: color, size: 18);
      case ResourceKind.gas:
        return Icon(Icons.gas_meter, color: color, size: 18);
      case ResourceKind.air:
        return Icon(Icons.air, color: color, size: 18);
      default:
        return Icon(Icons.device_hub, color: color, size: 18);
    }
  }

  void _showSettingsDialog(
    BuildContext context,
    WidgetRef ref,
    String nodeId,
    ResourceModel resource,
  ) {
    showDialog(
      context: context,
      builder: (context) => ResourceSettingsDialog(
        nodeId: nodeId,
        resourceId: resource.id,
        initialConfig: resource.automation,
        physicalConfig: resource.config,
      ),
    );
  }
}
