import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/core/session/session_context.dart';
import 'package:cii/core/providers/session_state.dart';

/// Implementação Riverpod do SessionContextProvider
///
/// ✅ DEFINITIVO: Usa ProviderContainer (não Ref!)
/// Permite que Modular leia o contexto atual via adapter
class RiverpodSessionContextProvider implements SessionContextProvider {
  final ProviderContainer container;

  RiverpodSessionContextProvider(this.container);

  @override
  SessionContext? get current {
    final state = container.read(sessionProvider);

    if (!state.hasContext) {
      return null;
    }

    return SessionContext(
      tenantId: state.tenant!.tenantId,
      homeId: state.home!.homeId,
      homeInternalId: state.home!.id,
    );
  }
}
