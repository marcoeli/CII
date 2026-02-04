import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/mqtt/mqtt_client_service.dart';
import 'package:intl/intl.dart';

class MqttLogNotifier extends Notifier<List<MqttLogEntry>> {
  @override
  List<MqttLogEntry> build() => [];

  void addLog(MqttLogEntry log) {
    state = [log, ...state].take(200).toList();
  }

  void clear() => state = [];
}

final mqttLogListProvider =
    NotifierProvider<MqttLogNotifier, List<MqttLogEntry>>(MqttLogNotifier.new);

/// StreamProvider que escuta o serviço de MQTT e atualiza a lista
final mqttLogStreamObserverProvider = StreamProvider<MqttLogEntry>((ref) {
  final service = ref.watch(mqttClientServiceProvider);
  final stream = service.logStream;

  stream.listen((log) {
    ref.read(mqttLogListProvider.notifier).addLog(log);
  });

  return stream;
});

class MqttInspectorPage extends ConsumerWidget {
  const MqttInspectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garante que o observer está rodando
    ref.watch(mqttLogStreamObserverProvider);
    final logs = ref.watch(mqttLogListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Inspector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(mqttLogListProvider.notifier).clear(),
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_heart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aguardando tráfego MQTT...'),
                ],
              ),
            )
          : ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _MqttLogTile(log: log);
              },
            ),
    );
  }
}

class _MqttLogTile extends StatelessWidget {
  final MqttLogEntry log;

  const _MqttLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss.SSS').format(log.timestamp);
    final color = log.isOutgoing ? Colors.blue : Colors.green;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.03)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.isOutgoing ? 'OUTGOING' : 'INCOMING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              const Icon(Icons.copy, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.topic,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              log.payload,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
