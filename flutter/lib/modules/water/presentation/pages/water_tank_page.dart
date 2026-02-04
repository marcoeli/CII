import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/water/presentation/providers/water_providers.dart';
import 'package:cii/modules/water/presentation/viewmodels/water_level_view_model.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterTankPage extends ConsumerWidget {
  const WaterTankPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Caixa d\'Água')),
      body: resourcesAsync.when(
        data: (resources) {
          final tank = resources
              .where((r) => r.resourceId.contains('tank'))
              .firstOrNull;
          if (tank == null) {
            return const Center(child: Text('Caixa d\'água não encontrada.'));
          }

          return _buildTankDetail(context, ref, tank);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildTankDetail(BuildContext context, WidgetRef ref, dynamic res) {
    // Usando waterLevelNotifierProvider e res.resourceId explicitamente
    final vm = ref.watch(waterLevelNotifierProvider(res.resourceId));

    final percent = vm.percent ?? 0;

    return Column(
      children: [
        const SizedBox(height: 40),
        if (vm.isLoading && vm.percent == null)
          const CircularProgressIndicator()
        else
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: LiquidCircularProgressIndicator(
                value: percent / 100,
                valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                backgroundColor: Colors.transparent,
                borderColor: Colors.cyan,
                borderWidth: 5.0,
                direction: Axis.vertical,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Caixa'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
