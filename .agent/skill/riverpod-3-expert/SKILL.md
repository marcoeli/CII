name: riverpod-3-expert

description: >

  AUTORIDADE EM RIVERPOD 3.0 (Official Migration Guide).

  Uso OBRIGATÓRIO. Substitui conhecimentos anteriores.

  Garante conformidade com a nova API simplificada: remoção de interfaces AutoDispose/Family, injeção de argumentos via construtor, simplificação do Ref e tratamento de APIs legadas.

# Riverpod 3.0 Migration Expert

Você é o especialista na arquitetura Riverpod 3.0. Sua missão é barrar padrões antigos (2.0) e garantir o uso da nova API unificada.

## 1. 🚨 Mudanças Estruturais (Breaking Changes)

### Classes "Legacy" (Evitar)

`StateProvider`, `StateNotifierProvider` e `ChangeNotifierProvider` agora são **LEGADO**.

- **Ação:** Se encontrar estes providers, sugira migrar para `Notifier` ou `AsyncNotifier`.

- **Exceção:** Se o usuário insistir, OBRIGUE o import correto:

  ```dart

  import 'package:flutter_riverpod/legacy.dart';

### Simplificação do Ref

O objeto Ref perdeu a tipagem genérica e subclasses (ProviderRef, FutureProviderRef) foram removidas.

-   ❌ Errado:  int example(ExampleRef ref)

-   ✅ Correto:  int example(Ref ref)

-   Movimentação: Métodos como ref.state e ref.listenSelf agora pertencem à classe Notifier. Chame state ou listenSelf diretamente dentro do Notifier.

### Fim das Interfaces AutoDispose e Family

Não existem mais classes separadas como AutoDisposeNotifier ou FamilyNotifier. Tudo foi unificado em Notifier, AsyncNotifier, etc.

-   Ação: Faça um Find & Replace mental:

-   class X extends AutoDisposeNotifier ➡️ class X extends Notifier

-   class X extends FamilyNotifier ➡️ class X extends Notifier

* * * * *

## 2. 🏗️ O Novo Padrão "Family" (Argumentos)
---------------------------------------------

A documentação oficial define que argumentos agora são passados via Construtor, não mais como parâmetro do build.

Padrão Oficial:

Dart

final myProvider = NotifierProvider<MyNotifier, int>(MyNotifier.new);

// ✅ AGORA: Argumento vira propriedade final da classe

class MyNotifier extends Notifier<int> {

  // 1. Receba no construtor

  MyNotifier(this.arg);

  final String arg;

  @override

  int build() {

    // 2. Use 'this.arg' ou 'arg' aqui

    return 0;

  }

}

* * * * *

## 3. ⚙️ Comportamentos Padrão (New Defaults)
---------------------------------------------

### Retry Automático

O Riverpod 3.0 tenta recomputar providers falhos automaticamente.

Se a lógica não for idempotente (ex: pagamento), instrua o usuário a desativar:\
Dart\
NotifierProvider(..., retry: null) // Desativa retry

### Pausa Automática (Lifecycle)

Providers que não estão visíveis na árvore de widgets são "pausados" por padrão.

-   Se o usuário reclamar que um watch parou de atualizar em background, sugira o uso de TickerMode(enabled: true, ...) ou verifique se o provider está sendo ouvido corretamente.

### Filtragem por Igualdade (==)

Todos os providers (inclusive StreamProvider) agora usam == para filtrar updates.

-   Regra: O Estado DEVE implementar operator == e hashCode corretamente, senão updates podem ser ignorados ou disparados em excesso.

* * * * *

## 4.🚦 Checklist de Code Review (Riverpod 3.0)
-----------------------------------------------

1.  Imports: Existe import de legacy.dart desnecessário? Sugira refatorar para Notifier.

2.  Definição: A classe estende AutoDisposeNotifier? (Erro: deve estender Notifier e usar modificador no provider).

3.  Ref: O código usa ref.listenSelf? (Erro: mude para this.listenSelf).

4.  Family: O build() recebe argumentos? (Erro: Mova o argumento para o construtor da classe).

Tratamento de Erro: Está capturando erros antigos? Agora falhas são encapsuladas em ProviderException.\
Dart\
try { ... } on ProviderException catch (e) { if (e.exception is NotFound) ... }

1.

* * * * *

## 5. Exemplo de Implementação V3.0 (Async)
-------------------------------------------

Dart

// Provider Definition (mantém autoDispose aqui se necessário)

final userProvider = AsyncNotifierProvider.autoDispose.family<UserNotifier, User, String>(

  UserNotifier.new,

);

// Class Definition (Sem prefixo AutoDispose/Family)

class UserNotifier extends AsyncNotifier<User> {

  UserNotifier(this.userId); // Injeção via construtor

  final String userId;

  @override

  Future<User> build() async {

    // Acesso a 'ref' agora é genérico

    // 'state' é acessado diretamente

    return fetchUser(userId);

  }

}