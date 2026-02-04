import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:cii/modules/water/presentation/providers/water_providers.dart';
import 'package:cii/modules/water/presentation/viewmodels/water_level_view_model.dart';
import 'package:cii/modules/water/presentation/viewmodels/pump_view_model.dart';
import 'package:cii/modules/water/presentation/widgets/command_status_indicator.dart';

class WaterTabContent extends ConsumerWidget {
  const WaterTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return const Center(
            child: Text('Nenhum recurso de água nesta residência.'),
          );
        }

        int kindRank(String k) => switch (k) {
          'level' => 0,
          'pump' => 1,
          'valve' => 2,
          _ => 99,
        };

        final sortedResources = resources.toList()
          ..sort((a, b) => kindRank(a.kind).compareTo(kindRank(b.kind)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedResources.length,
          itemBuilder: (context, index) {
            final res = sortedResources[index];
            if (res.kind == 'level') {
              return _buildWaterLevelCardV24(context, ref, res);
            } else if (res.kind == 'pump' || res.kind == 'valve') {
              return _buildPumpCardV24(context, ref, res);
            }
            return const SizedBox.shrink();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erro ao carregar recursos: $e')),
    );
  }

  Widget _buildWaterLevelCardV24(
    BuildContext context,
    WidgetRef ref,
    ResourceEntity res,
  ) {
    final vm = ref.watch(waterLevelNotifierProvider(res.resourceId));

    if (vm.isLoading && vm.percent == null) {
      return const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final percent = vm.percent ?? 0;
    final color = percent < 30
        ? Colors.red
        : (percent < 60 ? Colors.orange : Colors.blue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: LiquidCircularProgressIndicator(
            value: percent / 100,
            valueColor: AlwaysStoppedAnimation(color),
            backgroundColor: Colors.transparent,
            borderColor: color,
            borderWidth: 2.0,
            direction: Axis.vertical,
            center: Text(
              '${percent.toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                res.label ?? res.resourceId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            CommandStatusIndicator(
              isLoading: vm.isLoading,
              isStale: vm.isStale,
              lastUpdate: vm.lastUpdate,
            ),
          ],
        ),
        subtitle: Text('ID: ${res.resourceId}'),
        trailing: Icon(
          percent < 20 ? Icons.warning : Icons.check_circle_outline,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPumpCardV24(
    BuildContext context,
    WidgetRef ref,
    ResourceEntity res,
  ) {
    final vm = ref.watch(pumpNotifierProvider(res.resourceId));
    final pumpNotifier = ref.read(
      pumpNotifierProvider(res.resourceId).notifier,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.water_damage,
          color: vm.isRunning ? Colors.blue : Colors.grey,
          size: 32,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                res.label ?? res.resourceId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            CommandStatusIndicator(
              isLoading: vm.isLoading,
              isStale: vm.isStale,
              lastUpdate: vm.lastUpdate,
              loadingMessage: 'Enviando...',
            ),
          ],
        ),
        subtitle: Text(
          vm.isRunning ? 'ATIVO' : 'DESLIGADO',
          style: TextStyle(
            color: vm.isRunning ? Colors.green : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Switch(
          value: vm.isRunning,
          onChanged: vm.isLoading
              ? null
              : (_) => pumpNotifier.toggle(force: false),
        ),
      ),
    );
  }
}
