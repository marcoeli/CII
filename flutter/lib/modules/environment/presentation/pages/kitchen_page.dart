import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/modules/environment/presentation/providers/climate_providers.dart';

class KitchenPage extends ConsumerWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No V2.4, usamos resourceId (technicalId)
    const climateResourceId = 'env.climate.kitchen';
    final climateAsync = ref.watch(climateDataProvider(climateResourceId));

    return Scaffold(
      appBar: AppBar(title: const Text('COZINHA V2.4')),
      body: Center(
        child: climateAsync.when(
          data: (data) => Text('Temp: ${data?['temperature']}°C'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Erro: $e'),
        ),
      ),
    );
  }
}
