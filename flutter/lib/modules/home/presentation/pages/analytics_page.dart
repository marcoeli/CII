import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/home/widgets/trend_chart_card.dart';
import 'package:cii/ui/widgets/reactive_header.dart'; // Reuse header if pushing full screen
import 'package:cii/modules/water/presentation/providers/water_providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Reusamos ReactiveHeader para consistência visual na navegação
          const ReactiveHeader(),

          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'Análise de Dados',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Histórico e Tendências dos últimos 24h',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Gráfico de Nível de Água (Reutilizando a lógica do Sliver/Card)
                      const _WaterTrendSection(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterTrendSection extends ConsumerWidget {
  const _WaterTrendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        final levels = resources.where((r) => r.kind == 'level').toList();
        if (levels.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text("Nenhum sensor de nível encontrado."),
            ),
          );
        }

        // Ordenação estável
        levels.sort((a, b) => a.resourceId.compareTo(b.resourceId));

        return Column(
          children: levels
              .map(
                (l) => TrendChartCard(
                  resourceId: l.resourceId,
                  label: 'Nível: ${l.label ?? l.name}',
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erro ao carregar sensores: $e'),
    );
  }
}
