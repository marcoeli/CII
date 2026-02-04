import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/providers/global_providers.dart';

/// Provider que escuta mudanças de sessão e dispara side-effects de MQTT
///
/// ⚠️ IMPORTANTE: Este provider DEVE ser ativado no AppWidget via ref.watch
///
/// **Responsabilidade:** Reagir a mudanças de contexto (tenant/home) e disparar:
/// - Stop do MQTT sync antigo (se contexto mudou/foi removido)
/// - Start do MQTT sync novo (se contexto válido existe)
/// - Refresh de devices e subscriptions
final sessionEffectsProvider = Provider<void>((ref) {
  // Escutar mudanças de contexto
  ref.listen<SessionState>(sessionProvider, (prev, next) {
    final prevCtx = prev?.hasContext ?? false;
    final nextCtx = next.hasContext;

    final sync = ref.read(mqttSyncServiceProvider);
    final repo = ref.read(mqttRepositoryProvider);

    // STOP: Se havia contexto e agora não tem, OU se contexto mudou
    if (prevCtx &&
        (!nextCtx ||
            prev!.home!.id != next.home!.id ||
            prev.tenant!.tenantId != next.tenant!.tenantId)) {
      sync.stopSync();
      // Opcional: repo.clearSubscriptions() se método existir
    }

    // START: Se agora tem contexto válido
    if (nextCtx) {
      sync.startSync(next.home!.id, next.tenant!.tenantId, next.home!.homeId);
      repo.refreshDevices(tenant: next.tenant!, home: next.home!);
    }
  });
});
