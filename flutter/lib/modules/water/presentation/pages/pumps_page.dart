import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/water/presentation/providers/water_providers.dart';
import 'package:cii/modules/water/presentation/viewmodels/pump_view_model.dart';

/// RCO-2401: Página de bombas usando PumpViewModel (DB-First + UX Pessimista)
class PumpsPage extends ConsumerWidget {
  const PumpsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bombas e Válvulas')),
      body: resourcesAsync.when(
        data: (resources) {
          final pumps = resources
              .where((r) => r.kind == 'pump' || r.kind == 'valve')
              .toList();
          if (pumps.isEmpty) {
            return const Center(child: Text('Nenhuma bomba nesta residência.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pumps.length,
            itemBuilder: (context, index) => _PumpTile(resource: pumps[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}

/// RCO-2401: Widget individual de bomba com ViewModel
class _PumpTile extends ConsumerWidget {
  final dynamic resource;

  const _PumpTile({required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar PumpNotifier via provider family
    final viewModel = ref.watch(pumpNotifierProvider(resource.resourceId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.water_damage,
          color: viewModel.isRunning ? Colors.blue : Colors.grey,
          size: 32,
        ),
        title: Text(
          resource.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            // Status
            Text(
              viewModel.isRunning ? 'ATIVO' : 'DESLIGADO',
              style: TextStyle(
                color: viewModel.isRunning ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            // RCO-2401: Indicador de stale
            if (viewModel.isStale)
              const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // RCO-2401: Spinner durante loading
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            // Switch
            Switch(
              value: viewModel.isRunning,
              onChanged: viewModel.isLoading
                  ? null // Desabilita durante loading
                  : (val) {
                      ref
                          .read(
                            pumpNotifierProvider(resource.resourceId).notifier,
                          )
                          .toggle(force: false);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
