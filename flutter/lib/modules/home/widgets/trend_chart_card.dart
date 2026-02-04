import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/database/app_database.dart';
import 'package:cii/modules/water/presentation/providers/water_providers.dart'; // waterResourcesProvider

/// Sliver que exibe o gráfico se houver um sensor de nível
class WaterTrendSliver extends ConsumerWidget {
  const WaterTrendSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        final levels = resources.where((r) => r.kind == 'level').toList();
        if (levels.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        // Ordenação estável
        levels.sort((a, b) => a.resourceId.compareTo(b.resourceId));
        final primaryLevel = levels.first;

        return SliverToBoxAdapter(
          child: TrendChartCard(
            resourceId: primaryLevel.resourceId,
            label: 'Nível da Cisterna (24h)',
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

/// Widget que exibe um gráfico "Sparkline" do histórico de nível de água
class TrendChartCard extends ConsumerWidget {
  final String resourceId;
  final String label;

  const TrendChartCard({
    super.key,
    required this.resourceId,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyStream = ref
        .watch(databaseProvider)
        .waterDao
        .watchWaterLevelHistory(resourceId);

    return StreamBuilder<List<WaterLevelHistoryEntity>>(
      stream: historyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Não mostra nada se sem dados
        }

        final history = snapshot.data!;
        // Converter para spots do fl_chart
        // X = índice reverso (0 é o mais recente), Y = level (0-100)
        final spots = history.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value.percent;
          return FlSpot(
            history.length - 1 - index.toDouble(),
            value.toDouble(),
          );
        }).toList();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('24h', style: Theme.of(context).textTheme.bodySmall),
                    Text('Agora', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
