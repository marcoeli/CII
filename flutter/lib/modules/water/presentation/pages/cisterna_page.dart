import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/water/presentation/providers/water_providers.dart';
import 'package:cii/modules/water/presentation/viewmodels/water_level_view_model.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class CisternaPage extends ConsumerWidget {
  const CisternaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cisterna')),
      body: resourcesAsync.when(
        data: (resources) {
          final cisterna = resources
              .where((r) => r.resourceId.contains('cistern'))
              .firstOrNull;
          if (cisterna == null) {
            return const Center(child: Text('Cisterna não encontrada.'));
          }

          return _buildCisternaDetail(context, ref, cisterna);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildCisternaDetail(
    BuildContext context,
    WidgetRef ref,
    dynamic res,
  ) {
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
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                backgroundColor: Colors.transparent,
                borderColor: Colors.blue,
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
                    const Text('Cisterna'),
                  ],
                ),
              ),
            ),
          ),
        // Adicionaremos histórico e mais detalhes na Fase 3
      ],
    );
  }
}
