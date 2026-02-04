import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';
import 'package:cii/core/providers/navigation_provider.dart';
// import 'package:cii/modules/main_scaffold.dart'; // Removido (Provider movido para Core)
import 'package:cii/core/database/app_database.dart'; // [NEW] For ResourceEntity
import 'package:cii/modules/water/presentation/providers/water_providers.dart';
import 'package:cii/modules/environment/presentation/providers/climate_providers.dart';
import 'package:cii/modules/environment/presentation/viewmodels/climate_view_model.dart';
import 'package:cii/modules/water/presentation/viewmodels/water_level_view_model.dart';
import 'package:cii/core/widgets/staleness_indicator.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:cii/modules/home/presentation/pages/analytics_page.dart';

/// Card Base para o Dashboard
class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Widget? extraContent;
  final DateTime? lastUpdate;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    this.extraContent,
    this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  if (lastUpdate != null)
                    StalenessIndicator(
                      lastUpdate: lastUpdate,
                      shortFormat: true,
                    ),
                ],
              ),
              if (extraContent != null) ...[
                const SizedBox(height: 16),
                extraContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WaterStatusCard extends ConsumerWidget {
  const WaterStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(waterResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        final levels = resources.where((r) => r.kind == 'level').toList();
        final pumps = resources.where((r) => r.kind == 'pump').toList();

        // Ordenação estável por ID (ou outro critério determinístico)
        levels.sort((a, b) => a.resourceId.compareTo(b.resourceId));
        final primaryLevel = levels.firstOrNull;

        // Otimização: .select para evitar rebuild do card inteiro se o VM mudar outras props
        final lastUpdate = primaryLevel != null
            ? ref.watch(
                waterLevelNotifierProvider(
                  primaryLevel.resourceId,
                ).select((vm) => vm.lastUpdate),
              )
            : null;

        return _DashboardCard(
          title: 'Água',
          subtitle: '${levels.length} Reservatórios | ${pumps.length} Bombas',
          icon: Icons.water_drop,
          color: Colors.blue,
          backgroundColor: Colors.blue.withValues(alpha: 0.05),
          onTap: () => ref
              .read(navigationTabProvider.notifier)
              .setTab(NavigationTab.water),
          extraContent: levels.isEmpty
              ? null
              : _buildLevelResumo(context, ref, levels),
          lastUpdate: lastUpdate,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Icon(Icons.error)),
    );
  }

  Widget _buildLevelResumo(
    BuildContext context,
    WidgetRef ref,
    List<ResourceEntity> levels,
  ) {
    // Show up to 3 levels to avoid overflow
    final displayLevels = levels.take(3).toList();

    return Column(
      children: displayLevels.map((res) {
        final vm = ref.watch(waterLevelNotifierProvider(res.resourceId));
        final percent = vm.percent ?? 0;

        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                res.label ?? res.resourceId.split('.').last,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 6,
                  child: LiquidLinearProgressIndicator(
                    value: percent / 100,
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),

                    borderColor: Colors.blue,
                    borderWidth: 0.0,
                    borderRadius: 3.0,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class EnvironmentStatusCard extends ConsumerWidget {
  const EnvironmentStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(climateResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        final sensors = resources.where((r) => r.kind == 'climate').toList();

        // Critério estável: ID alfa-num
        sensors.sort((a, b) => a.resourceId.compareTo(b.resourceId));
        final firstSensor = sensors.firstOrNull;

        // Otimização: .select + ViewModel padronizado (lastUpdate DateTime?)
        final lastUpdate = firstSensor != null
            ? ref.watch(
                climateNotifierProvider(
                  firstSensor.resourceId,
                ).select((vm) => vm.lastUpdate),
              )
            : null;

        return _DashboardCard(
          title: 'Ambiente',
          subtitle: '${resources.length} Sensores Ativos',
          icon: Icons.thermostat,
          color: Colors.orange,
          backgroundColor: Colors.orange.withValues(alpha: 0.05),
          onTap: () => ref
              .read(navigationTabProvider.notifier)
              .setTab(NavigationTab.environment),
          extraContent: firstSensor == null
              ? null
              : _buildClimateResumo(context, ref, firstSensor.resourceId),
          lastUpdate: lastUpdate,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Icon(Icons.error)),
    );
  }

  Widget _buildClimateResumo(
    BuildContext context,
    WidgetRef ref,
    String resourceId,
  ) {
    // Uso direto do ViewModel para consistência
    final vm = ref.watch(climateNotifierProvider(resourceId));

    // Evita flash de zeros enquanto carrega
    if (vm.isLoading && vm.temperature == null) return const SizedBox.shrink();

    final temp = vm.temperature ?? 0;
    final hum = vm.humidity ?? 0;

    return Row(
      children: [
        const Icon(Icons.device_thermostat, size: 14, color: Colors.orange),
        Text(
          ' ${temp.toStringAsFixed(1)}°C',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.water_drop, size: 14, color: Colors.blue),
        Text(
          ' ${hum.toStringAsFixed(0)}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class EventsStatusCard extends ConsumerWidget {
  const EventsStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(homeHealthProvider);

    return healthAsync.when(
      data: (health) {
        final isSafe = health.criticalEvents == 0 && health.offlineDevices == 0;
        return _DashboardCard(
          title: 'Eventos',
          subtitle: isSafe
              ? 'Sistema Seguro'
              : '${health.criticalEvents} Alertas | ${health.offlineDevices} Offline',
          icon: isSafe ? Icons.check_circle : Icons.warning,
          color: isSafe ? Colors.green : Colors.red,
          backgroundColor: (isSafe ? Colors.green : Colors.red).withValues(
            alpha: 0.05,
          ),

          onTap: () => ref
              .read(navigationTabProvider.notifier)
              .setTab(NavigationTab.events),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Icon(Icons.error)),
    );
  }
}

class AnalyticsStatusCard extends StatelessWidget {
  const AnalyticsStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      title: 'Gráficos',
      subtitle: 'Histórico & Tendências',
      icon: Icons.show_chart,
      color: Colors.purple,
      backgroundColor: Colors.purple.withValues(alpha: 0.05),
      onTap: () {
        // Navegação para página de Analytics
        // Como não temos rota nomeada ainda, usamos push direto ou Modular se registrado
        // Para simplificar, assumindo push direto por enquanto ou Modular se quisermos
        // Vamos usar Modular.to.push se registrarmos, ou Navigator.push
        // Por hora, vou usar MaterialPageRoute para garantir funcionamento imediato
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AnalyticsPage()));
      },
    );
  }
}
