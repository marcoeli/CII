# Perfis oficiais ACL— Contrato MQTT V2.4 (baseado no V2.3)

Este documento centraliza:

- Perfis oficiais de capability (capabilities[].type)
- JSON Schemas normativos
- Mapeamento role(type firmware) → cap
- Regras de ACL (device, app, provisionamento, automação)
- Regras de segurança, escalabilidade e fail-safe

====================================================================

## 0. Convenções Gerais

### 0.1 Namespace (MULTICASA — OBRIGATÓRIO)

Todos os tópicos produtivos DEVEM estar sob:

home/{tenant}/{home}/...

Exemplo:

- home/marco/casa_principal/...
- home/cliente_x/apto_302/...

Provisionamento fica fora do namespace `home/`:

- setup/{tenant}/{home}/...

---

### 0.2 Identidades

- device_id  
  - Identidade técnica MQTT
  - É o `username` do device
  - Único e estável

- resource_id  
  - Identificador técnico imutável
  - Formato: `{domain}.{kind}.{name}`

- label  
  - Nome humano
  - Mutável
  - Nunca entra em tópico MQTT

---

### 0.3 QoS / Retain (norma única)

- QoS: **1 (sempre)**

- Retain:
  - SIM: status, state, data, config, meta
  - NÃO: command, result, event, ota, setup

---

## 1. Domínios MQTT Oficiais

### 1.1 Device management

- home/{tenant}/{home}/device/{device_id}/status   (retain SIM)
- home/{tenant}/{home}/device/{device_id}/errors   (retain SIM)
- home/{tenant}/{home}/device/{device_id}/config   (retain SIM, opcional)
- home/{tenant}/{home}/device/{device_id}/ota      (retain NÃO)

---

### 1.2 Resource domain (núcleo do sistema)

- home/{tenant}/{home}/r/{resource_id}/state    (retain SIM)
- home/{tenant}/{home}/r/{resource_id}/data     (retain SIM)
- home/{tenant}/{home}/r/{resource_id}/config   (retain SIM)
- home/{tenant}/{home}/r/{resource_id}/command  (retain NÃO)
- home/{tenant}/{home}/r/{resource_id}/result   (retain NÃO)

---

### 1.3 Eventos

- home/{tenant}/{home}/event/{domain}/{kind}/{resource_id} (retain NÃO)

---

### 1.4 Meta / Registry (UI, labels)

- home/{tenant}/{home}/meta/resource/{resource_id} (retain SIM)

---

### 1.5 Provisionamento (isolado)

- setup/{tenant}/{home}/registro
- setup/{tenant}/{home}/resposta/{correlation_id}

====================================================================

## 2. Provisionamento (ACL e Norma)

### 2.1 Usuário MQTT: setup

Usado exclusivamente para onboarding de devices.

| Action | Permission | Topic |
|------|-----------|------|
| Publish | Allow | setup/{tenant}/{home}/registro |
| Subscribe | Allow | setup/{tenant}/{home}/resposta/+ |

Normas:

- Retain NÃO em setup
- correlation_id é obrigatório
- Após provisionado, o device **NÃO usa mais setup**

---

====================================================================

## 3. Mapeamento padrão role(type firmware) → cap

Usado quando o campo `cap` não vier no payload de provisionamento.

| role (firmware) | cap aplicadas (capabilities[].type) |
|-----------------|-------------------------------------|
| CISTERN_NODE | ["WATER_SENSOR", "WATER_ACTUATOR"] |
| WATER_CONTROLLER (legado) | ["WATER_SENSOR", "WATER_ACTUATOR"] |
| LEVEL_SENSOR | ["WATER_SENSOR"] |
| WATER_SENSOR | ["WATER_SENSOR"] |
| WATER_ACTUATOR | ["WATER_ACTUATOR"] |
| ENV_SENSOR | ["ENV_SENSOR"] |
| PRESENCE_SENSOR | ["PRESENCE_SENSOR"] |
| DOORBELL | ["EVENT_NODE"] |
| ALARM | ["EVENT_NODE"] |
| EVENT_NODE | ["EVENT_NODE"] |
| HMI_NODE | ["HMI_NODE"] |
| APP_CLIENT | ["APP_CLIENT"] |
| SYSTEM_AUTOMATION | ["SYSTEM_AUTOMATION"] |

====================================================================

## 4. Profiles Oficiais por CAP (capabilities[].type)

Regra:

- Cada `capabilities[].type` DEVE mapear 1:1 para um profile abaixo.
- Um device pode declarar múltiplos resources por cap.

--------------------------------------------------------------------

### 4.1 CAP: WATER_SENSOR

**Objetivo:** publicar medições hidráulicas (nível e/ou fluxo).

**Resources permitidos:**

- water.level.*
- water.flow.*

**Tópicos:**

- data: home/.../r/{resource_id}/data

#### Schema — water.level.*

{
  "required": ["percent", "ts"],
  "properties": {
    "liters": { "type": ["number", "null"] },
    "percent": { "type": "number", "minimum": 0, "maximum": 100 },
    "distance_cm": { "type": ["number", "null"] },
    "alert": { "type": "string", "enum": ["NORMAL","WARN","CRITICAL","SENSOR_FAIL"] },
    "ts": { "type": "integer" }
  }
}
#### Schema — water.flow.\*

    { "required": ["lpm", "ts"], "properties": { "lpm": { "type": "number", "minimum": 0 }, "liters_total": { "type": ["number", "null"] }, "alert": { "type": "string", "enum": ["NORMAL","WARN","CRITICAL","SENSOR_FAIL"] }, "ts": { "type": "integer" } }}

Normas:

- Nunca aceita command
- SENSOR\_FAIL ⇒ publicar device/.../errors

* * *

### 4.2 CAP: WATER\_ACTUATOR

**Objetivo:** atuar em bombas e válvulas.

**Resources permitidos:**

- water.pump.\*
- water.valve.\*

**Tópicos:** state, command, config, result

#### water.pump.\* — State

    { "required": ["running","mode","ts"], "properties": { "running": { "type": "boolean" }, "mode": { "type": "string", "enum": ["MANUAL","AUTO","LOCKED"] }, "reason": { "type": ["string","null"] }, "ts": { "type": "integer" } }}

Commands:

- START
- STOP
- SET\_MODE

Config (AUTO recomendado):

- bindings.source\_level
- bindings.target\_level
- regras de mínimo / máximo
- stale timeout

Fail-safe obrigatório:

- anti-seco
- overflow
- stale data ⇒ STOP

#### water.valve.\* — State

    { "required": ["open","mode","ts"], "properties": { "open": { "type": "boolean" }, "mode": { "type": "string", "enum": ["MANUAL","AUTO","LOCKED"] }, "reason": { "type": ["string","null"] }, "ts": { "type": "integer" } }}

Commands:

- OPEN
- CLOSE
- SET\_MODE

* * *

### 4.3 CAP: ENV\_SENSOR

**Resources:**

- env.climate.\*
- env.air.\*

Publicação:

- data

* * *

### 4.4 CAP: PRESENCE\_SENSOR

**Resources:**

- security.presence.*

Publicação:

- state

* * *

### 4.5 CAP: EVENT\_NODE

**Objetivo:** eventos pontuais.

**Resources:**

- security.doorbell.\*
- security.alarm.\*
- hmi.button.\*

Publicação:

- event (retain NÃO)

* * *

### 4.6 CAP: HMI\_NODE

**Objetivo:** interface local.

**Resources comuns:**

- hmi.buzzer.\*
- hmi.display.\*
- hmi.button.\*

Pode coexistir com EVENT\_NODE.

* * *

### 4.7 CAP: APP\_CLIENT

**Objetivo:** perfil do app.

Norma:

- Publica command/meta
- Nunca publica state/data

* * *

### 4.8 CAP: SYSTEM\_AUTOMATION

**Objetivo:** orquestrador (Node-RED).

Permissões ampliadas:

- command
- meta
- config (se autorizado)

====================================================================

## 5. ACL Templates (Norma Obrigatória)

### 5.1 Princípios

- Deny by default
- Sem wildcard global em device
- ACL sempre derivada de resource_id
- ACL valida tópico e ownership. Payload é opaco.

* * *

### 5.2 ACL — Device

PUB Allow:

- home/{tenant}/{home}/device/{device\_id}/#
- home/{tenant}/{home}/r/{resource\_id}/state
- home/{tenant}/{home}/r/{resource\_id}/data

SUB Allow:

- home/{tenant}/{home}/r/{resource\_id}/command
- home/{tenant}/{home}/r/{resource\_id}/config
- home/{tenant}/{home}/r/{dep\_resource\_id}/state
- home/{tenant}/{home}/r/{dep\_resource\_id}/data

* * *

### 5.3 ACL — App (WSS)

PUB:

- home/{tenant}/{home}/r/+/command
- home/{tenant}/{home}/meta/#

SUB:

- home/{tenant}/{home}/device/+/status
- home/{tenant}/{home}/device/+/errors
- home/{tenant}/{home}/r/+/state
- home/{tenant}/{home}/r/+/data
- home/{tenant}/{home}/r/+/result
- home/{tenant}/{home}/meta/#
- home/{tenant}/{home}/event/#

* * *

### 5.4 ACL — Provisionamento (setup)

User: setup

PUB:

- setup/{tenant}/{home}/registro

SUB:

- setup/{tenant}/{home}/resposta/+

====================================================================

## 6. Regras Finais (Normativas)

- resource\_id é imutável
- Renomear recurso = meta/resource/{resource\_id}.label
- Atuadores DEVEM responder command com result
- Automação local é soberana (fail-safe sempre)
- Devices não se comandam diretamente; dependem de estado

====================================================================
