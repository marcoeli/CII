import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/domain/entities/system_status.dart';
import 'package:cii/core/providers/global_providers.dart';
import 'package:cii/core/domain/repositories/mqtt_repository_interface.dart';
import 'package:cii/modules/home/presentation/providers/home_providers.dart';

/// Provider que calcula o status do sistema baseado nos dados disponíveis
final systemStatusProvider = Provider<SystemStatus>((ref) {
  final home = ref.watch(selectedHomeProvider);
  final connectionAsync = ref.watch(brokerConnectionStateProvider);
  final healthAsync = ref.watch(homeHealthProvider);

  final health = healthAsync.value;
  final isOnline = connectionAsync.value == BrokerConnectionState.connected;
  final hasCritical = (health?.criticalEvents ?? 0) > 0;
  final hasWarning = (health?.warningEvents ?? 0) > 0;

  // Logging para debug de reatividade
  debugPrint(
    'SystemStatusUpdate: isOnline=$isOnline, hasCritical=$hasCritical, hasWarning=$hasWarning, healthLoading=${healthAsync.isLoading}',
  );

  return SystemStatus(
    isOnline: isOnline,
    lastUpdate: DateTime.now(),
    hasCriticalError: hasCritical,
    hasWarning: hasWarning,
    isDoorbellRecent: false,
    activeHomeLabel: home?.label ?? 'Sem Casa Selecionada',
    statusMessage: connectionAsync.when(
      data: (state) => state == BrokerConnectionState.connected
          ? (healthAsync.isLoading
                ? 'Validando saúde...'
                : (hasCritical
                      ? 'ALERTA CRÍTICO DETECTADO'
                      : (hasWarning ? 'AVISOS NO SISTEMA' : 'Tudo em ordem')))
          : 'Desconectado',
      loading: () => 'Conectando...',
      error: (_, _) => 'Erro de Conexão',
    ),
  );
});
