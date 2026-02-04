import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(brokerConnectionStateProvider);

    return statusAsync.when(
      data: (status) {
        Color color = Colors.grey;
        IconData icon = Icons.help;
        switch (status) {
          case BrokerConnectionState.connected:
            color = Colors.green;
            icon = Icons.cloud_done;
            break;
          case BrokerConnectionState.connecting:
            color = Colors.orange;
            icon = Icons.cloud_sync;
            break;
          case BrokerConnectionState.disconnected:
            color = Colors.grey;
            icon = Icons.cloud_off;
            break;
          case BrokerConnectionState.failed:
            color = Colors.red;
            icon = Icons.error;
            break;
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const Icon(Icons.error_outline, color: Colors.red),
    );
  }
}
