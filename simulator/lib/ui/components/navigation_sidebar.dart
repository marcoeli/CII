import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/iot_models.dart';
import '../../core/providers/simulator_provider.dart';

class NavigationSidebar extends ConsumerWidget {
  final VirtualNode? selectedNode;
  final Function(VirtualNode) onNodeSelected;

  const NavigationSidebar({
    super.key,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulatorProvider);

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(200),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(50),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.hub,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: state.nodes.length,
              itemBuilder: (context, index) {
                final node = state.nodes[index];
                final isSelected = selectedNode?.id == node.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Tooltip(
                    message: '${node.id} (${node.role})',
                    child: InkWell(
                      onTap: () => onNodeSelected(node),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(40)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              _getIconForRole(node.role),
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: node.isOnline
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          _buildActionItem(context, Icons.settings, 'Configurações', () {
            // TODO: Global Settings
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  IconData _getIconForRole(String role) {
    if (role.contains('CISTERN')) return Icons.water_drop;
    if (role.contains('TANK')) return Icons.storage;
    if (role.contains('SECURITY')) return Icons.security;
    if (role.contains('CLIMATE')) return Icons.thermostat;
    if (role.contains('AUTOMATION')) return Icons.auto_mode;
    return Icons.device_hub;
  }
}
