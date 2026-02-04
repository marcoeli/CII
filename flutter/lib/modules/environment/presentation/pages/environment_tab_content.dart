import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/environment/presentation/providers/environment_providers.dart';
import 'package:cii/modules/environment/presentation/extensions/environment_display_extension.dart';
import 'package:cii/modules/environment/presentation/extensions/air_quality_display_extension.dart';

class EnvironmentTabContent extends ConsumerWidget {
  const EnvironmentTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(environmentResourcesProvider);

    return resourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return const Center(
            child: Text('Nenhum sensor de ambiente nesta residência.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            final kind = res.kind.toLowerCase();
            if (kind == 'climate') {
              return _ClimateCard(resourceId: res.resourceId, label: res.label);
            } else if (kind == 'air_quality' ||
                kind == 'air' ||
                kind == 'gas' ||
                kind == 'smoke' ||
                kind == 'co2' ||
                kind == 'gas_leak') {
              return _AirQualityCard(
                resourceId: res.resourceId,
                label: res.label,
              );
            }
            return ListTile(title: Text(res.label ?? res.resourceId));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erro ao carregar sensores: $e')),
    );
  }
}

class _ClimateCard extends ConsumerWidget {
  final String resourceId;
  final String? label;

  const _ClimateCard({required this.resourceId, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(climateStreamProvider(resourceId));
    final env = asyncValue.asData?.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  label ?? 'Sensor Climático',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (env != null && env.isStale)
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              ],
            ),
            const Divider(),
            if (asyncValue.isLoading && env == null)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (env == null)
              const Text('Aguardando dados...')
            else
              Text(
                env.formattedDisplay,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}

class _AirQualityCard extends ConsumerWidget {
  final String resourceId;
  final String? label;

  const _AirQualityCard({required this.resourceId, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(airQualityStreamProvider(resourceId));
    final aq = asyncValue.asData?.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.air, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  label ?? 'Qualidade do Ar',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (aq != null && aq.isStale)
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              ],
            ),
            const Divider(),
            if (asyncValue.isLoading && aq == null)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (aq == null)
              const Text('Aguardando dados...')
            else
              Text(
                aq.formattedDisplay,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
