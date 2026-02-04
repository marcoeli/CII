import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/iot_models.dart';
import '../core/providers/simulator_provider.dart';
import 'components/navigation_sidebar.dart';
import 'components/resource_grid.dart';
import 'components/log_inspector.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  VirtualNode? _selectedNode;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simulatorProvider);

    // Sync _selectedNode with the latest state
    if (_selectedNode != null) {
      final nodeIndex = state.nodes.indexWhere(
        (n) => n.id == _selectedNode!.id,
      );

      if (nodeIndex != -1) {
        final freshNode = state.nodes[nodeIndex];
        if (freshNode != _selectedNode) {
          _selectedNode = freshNode;
        }
      } else {
        _selectedNode = null;
      }
    }

    // Default to the first node if none selected
    if (_selectedNode == null && state.nodes.isNotEmpty) {
      _selectedNode = state.nodes.first;
    }

    return Scaffold(
      body: Row(
        children: [
          // 1. Navigation Sidebar (Rail)
          NavigationSidebar(
            selectedNode: _selectedNode,
            onNodeSelected: (node) => setState(() => _selectedNode = node),
          ),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header / Top Bar
                _buildHeader(context, _selectedNode, state),

                // Content (Grid + Logs)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scrollable Resource Grid
                      Expanded(
                        flex: 3,
                        child: _selectedNode == null
                            ? const Center(child: Text('Selecione um nó'))
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: ResourceGrid(node: _selectedNode!),
                              ),
                      ),

                      // Right Panel: Advanced Log Inspector
                      Expanded(
                        flex: 2,
                        child: LogInspector(selectedNodeId: _selectedNode?.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    VirtualNode? node,
    SimulatorState state,
  ) {
    if (node == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(30),
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.id,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                node.role,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 8),
          _buildExternalWaterToggle(context, state),
          const SizedBox(width: 16),
          _buildStatusBadge(node),
          const SizedBox(width: 16),
          Switch(
            value: node.isOnline,
            activeThumbColor: Colors.green,
            onChanged: (_) =>
                ref.read(simulatorProvider.notifier).toggleNode(node.id),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange, size: 20),
            tooltip: 'Factory Reset',
            onPressed: () => _showFactoryResetDialog(node.id),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalWaterToggle(BuildContext context, SimulatorState state) {
    return InkWell(
      onTap: () => ref.read(simulatorProvider.notifier).toggleExternalWater(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: state.hasExternalWater
              ? Colors.blue.withAlpha(20)
              : Colors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: state.hasExternalWater
                ? Colors.blue.withAlpha(100)
                : Colors.red.withAlpha(100),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.hasExternalWater ? Icons.water_drop : Icons.blur_off,
              size: 16,
              color: state.hasExternalWater ? Colors.blue : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              state.hasExternalWater ? 'REDE OK' : 'REDE SECA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: state.hasExternalWater ? Colors.blue : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VirtualNode node) {
    final color = node.isOnline ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        node.isOnline ? 'ONLINE' : 'OFFLINE',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFactoryResetDialog(String nodeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Factory Reset?'),
        content: const Text(
          'Isso limpará as credenciais provisionadas (NVS) e resetará os estados para o padrão de fábrica.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(simulatorProvider.notifier).factoryReset(nodeId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('RESETAR'),
          ),
        ],
      ),
    );
  }
}
