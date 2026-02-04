import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Monitor que escuta eventos do sistema e toca sons apropriados
class EventsMonitor extends ConsumerStatefulWidget {
  final Widget child;

  const EventsMonitor({required this.child, super.key});

  @override
  ConsumerState<EventsMonitor> createState() => _EventsMonitorState();
}

class _EventsMonitorState extends ConsumerState<EventsMonitor> {
  int? _lastEventId;
  bool _repositoryStarted = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[EventsMonitor] ========================================');
    debugPrint('[EventsMonitor] initState() - scheduling monitor start');
    debugPrint('[EventsMonitor] ========================================');

    // Mqtt connection is handled by mqttRemoteDataSourceProvider initialization
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_repositoryStarted) {
        _repositoryStarted = true;
        debugPrint('[EventsMonitor] ✅ Monitor active');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta novos eventos do DB
    ref.listen(homeEventsProvider, (previous, next) {
      next.whenData((events) {
        if (events.isEmpty) return;

        final latestEvent = events.first;

        // Inicializa _lastEventId na primeira execução (evita tocar som de eventos antigos)
        if (_lastEventId == null) {
          _lastEventId = latestEvent.id;
          debugPrint(
            '[EventsMonitor] Initialized with latest event ID: ${latestEvent.id} (no sound)',
          );
          return;
        }

        // Evitar tocar o mesmo evento múltiplas vezes (usa ID do DB)
        if (latestEvent.id == _lastEventId) return;

        debugPrint(
          '[EventsMonitor] New event detected! Old ID: $_lastEventId, New ID: ${latestEvent.id}',
        );
        _lastEventId = latestEvent.id;

        final alertService = ref.read(alertServiceProvider);

        // Tocar som baseado no tipo de evento
        switch (latestEvent.kind) {
          case 'doorbell':
            debugPrint('[EventsMonitor] 🔔 Doorbell pressed');
            alertService.playDoorbell();
            break;
          case 'alarm':
            debugPrint(
              '[EventsMonitor] 🚨 Alarm event received (Handled by AlertNotifier)',
            );
            // Fix: remove direct playCriticalLoop().
            // AlertNotifier watches homeHealthProvider and handles the loop state.
            // If we play it here, it might conflict or play when it shouldn't (e.g. resolved event).
            break;
          default:
            debugPrint('[EventsMonitor] Event: ${latestEvent.kind}');
        }
      });
    });

    return widget.child;
  }
}
