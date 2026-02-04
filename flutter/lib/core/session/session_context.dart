/// Contexto da sessão atual (Tenant + Home)
///
/// ValueObject imutável que representa o contexto ativo.
/// Não depende de nenhum framework (Riverpod, Modular, etc).
class SessionContext {
  final String tenantId;
  final String homeId;
  final int homeInternalId;

  const SessionContext({
    required this.tenantId,
    required this.homeId,
    required this.homeInternalId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionContext &&
          runtimeType == other.runtimeType &&
          tenantId == other.tenantId &&
          homeId == other.homeId &&
          homeInternalId == other.homeInternalId;

  @override
  int get hashCode =>
      tenantId.hashCode ^ homeId.hashCode ^ homeInternalId.hashCode;

  @override
  String toString() =>
      'SessionContext(tenant: $tenantId, home: $homeId, id: $homeInternalId)';
}

/// Interface para obter contexto da sessão atual
///
/// Permite que repositories e services obtenham tenant/home
/// sem depender diretamente de Riverpod ou estado global.
///
/// Implementações:
/// - RiverpodSessionContextProvider: lê de sessionProvider
/// - TestSessionContextProvider: mock para testes
abstract class SessionContextProvider {
  /// Retorna o contexto atual, ou null se nenhum tenant/home selecionado
  SessionContext? get current;
}
