# Checklist Geral (todo device)

> [!IMPORTANT]
> **Nota Arquitetural V2.4 — Leia antes de implementar**
>
> 1. **O contrato MQTT é a fonte da verdade.** O firmware não descobre tópicos; ele obedece ao array `acls[]` recebido no provisionamento.
> 2. **`tenant/home` não são inferidos pelo device.** Devem ser injetados no boot (SoftAP + HTTP local). Se não existirem, o device não pode iniciar MQTT.
> 3. **Resource IDs são imutáveis.** Qualquer renomeação, label ou organização visual ocorre exclusivamente via `meta/`.
> 4. **Sem wildcard em resource.** Se o firmware tentar publicar fora dos tópicos listados em `acls[]`, o erro é de implementação.
>
> **Ordem correta de boot:**
> 1. Bootstrap (Wi-Fi + tenant/home)
> 2. Provisionamento MQTT (`setup/...`)
> 3. Operação normal (`home/...`)
>
> *Se algo parecer “ovo e galinha” → o contexto está faltando. Pare e revise o fluxo; não crie exceções.*

### Identidade / Provisionamento

- <input disabled="" type="checkbox"> `device_id` é estável e único (não muda com label).
- <input disabled="" type="checkbox"> Conecta via **MQTTS** com credenciais únicas.
- <input disabled="" type="checkbox"> Implementa reconexão com backoff (ex.: 1s, 2s, 4s… até teto).
- <input disabled="" type="checkbox"> Publica `status` retained em `home/{tenant}/{home}/device/{device_id}/status`.
- <input disabled="" type="checkbox"> Usa **LWT** para marcar OFFLINE (retain SIM) no mesmo tópico de status.

### MQTT (contrato)

- <input disabled="" type="checkbox"> QoS=1 em tudo.
- <input disabled="" type="checkbox"> Retain correto:

    - <input disabled="" type="checkbox"> `status/state/data/config/meta` com retain SIM quando aplicável
    - <input disabled="" type="checkbox"> `command/result/event/ota/setup` com retain NÃO
- <input disabled="" type="checkbox"> Nunca publica em tópicos fora dos seus resources (sem wildcard “inventado”).
- <input disabled="" type="checkbox"> Ignora payload inválido (JSON parse + validação mínima de campos).

### Segurança

- <input disabled="" type="checkbox"> Nunca loga senha/token em serial.
- <input disabled="" type="checkbox"> Não aceita `force=true` se policy local desabilitar (flag compile-time ou config).
- <input disabled="" type="checkbox"> `origin` e `correlation_id` são tratados como informativos (não autenticação).

### Robustez / Operação

- <input disabled="" type="checkbox"> Watchdog ativo e alimentado com critério.
- <input disabled="" type="checkbox"> Boot reason registrado (para debug).
- <input disabled="" type="checkbox"> Se MQTT cair: automação crítica continua localmente (ou entra em modo seguro).
- <input disabled="" type="checkbox"> Rate limit de publish (não flooda broker).
- <input disabled="" type="checkbox"> Timestamps coerentes (se não tiver NTP, ainda publica `ts` baseado em uptime ou marca `time_sync=false` no status).

* * *

# Checklist por Resource (state/data)

Para cada `resource_id` publicado:

### Publicação

- <input disabled="" type="checkbox"> Publica `state` e/ou `data` nos tópicos:

    - <input disabled="" type="checkbox"> `home/{tenant}/{home}/r/{resource_id}/state`
    - <input disabled="" type="checkbox"> `home/{tenant}/{home}/r/{resource_id}/data`
- <input disabled="" type="checkbox"> Payload contém `ts` (unix seconds).
- <input disabled="" type="checkbox"> Campos são estáveis (não muda nomes sem bump de versão do contrato).
- <input disabled="" type="checkbox"> Publica **somente** quando muda (state) ou por intervalo (data).

### Qualidade de dados

- <input disabled="" type="checkbox"> `alert`/`severity` padronizado (ex.: `NORMAL|WARN|CRITICAL`).
- <input disabled="" type="checkbox"> Valores fora do range geram `alert` e não “lixo silencioso”.

* * *

# Checklist de Command/Result (atuadores)

Para cada resource que aceita comando:

### Subscribe/Validate

- <input disabled="" type="checkbox"> Assina `home/{tenant}/{home}/r/{resource_id}/command`.
- <input disabled="" type="checkbox"> Valida `action`, `params`, `ts`, `correlation_id`.
- <input disabled="" type="checkbox"> Rejeita comando inválido publicando `result` com `status="REJECTED"`.

### Execução/Confirmação

- <input disabled="" type="checkbox"> Executa localmente com trava de segurança (fail-safe).
- <input disabled="" type="checkbox"> Publica `result` SEMPRE (OK/REJECTED/FAILED/TIMEOUT).
- <input disabled="" type="checkbox"> Atualiza `state` após executar (fonte de verdade).

### Segurança operacional

- <input disabled="" type="checkbox"> Comando repetido com mesmo `correlation_id` não causa efeitos duplicados (idempotência simples: cache curto).
- <input disabled="" type="checkbox"> `force` só bypassa o que você permitir (ex.: não bypassa “nível crítico” se isso é regra de segurança).

* * *

# Checklist de Config por Recurso (bindings)

Para cada resource que lê dependências (ex.: bomba lendo níveis):

### Aplicação de config

- <input disabled="" type="checkbox"> Assina (ou lê retained) `home/{tenant}/{home}/r/{resource_id}/config`.
- <input disabled="" type="checkbox"> Valida schema e ranges (`min_source_percent` etc.).
- <input disabled="" type="checkbox"> Aplica sem reboot quando possível; se precisar reboot, registra no `status`.

### Bindings / Dependências

- <input disabled="" type="checkbox"> Ao receber `bindings.source_level/target_level`, assina os tópicos correspondentes (`.../data` ou `.../state`).
- <input disabled="" type="checkbox"> Implementa “stale timeout”: se dependência não atualiza em X segundos → entra em fail-safe (desliga).
- <input disabled="" type="checkbox"> Se dependência vier com `alert=CRITICAL` → fail-safe.

* * *

# Checklist específico (exemplos)

## WATER.PUMP.\*

- <input disabled="" type="checkbox"> Nunca liga se `source_level` &lt; limite.
- <input disabled="" type="checkbox"> Nunca liga se `target_level` &gt; limite (overflow).
- <input disabled="" type="checkbox"> Em modo MANUAL, ainda aplica proteções mínimas (anti-seco/overflow).
- <input disabled="" type="checkbox"> Se sensor falhar: desliga e publica `errors` + `state.reason`.

## WATER.LEVEL.\*

- <input disabled="" type="checkbox"> Calibração validada (shape/height/offset).
- <input disabled="" type="checkbox"> Se leitura inválida: publica `alert="SENSOR_FAIL"` e `errors`.
- <input disabled="" type="checkbox"> Publica `percent` e/ou `liters` de forma consistente.

## LIGHT.LAMP.\*

- <input disabled="" type="checkbox"> Suporta `SET {on, brightness}`.
- <input disabled="" type="checkbox"> Atualiza state imediatamente após comando.

## POWER.OUTLET.\*

- <input disabled="" type="checkbox"> `locked=true` impede comando remoto de ligar/desligar.
- <input disabled="" type="checkbox"> Data elétrica é opcional; se presente, valida range.

## SECURITY.CAMERA.\*

- <input disabled="" type="checkbox"> MQTT não carrega vídeo.
- <input disabled="" type="checkbox"> Eventos (motion) sempre retain NÃO.

* * *
