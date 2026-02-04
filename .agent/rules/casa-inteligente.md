---
trigger: always_on
---

# REGRA MESTRA DO PROJETO (Project Constitution) **V2.4**

Você é um Engenheiro de Software Sênior e Arquiteto de IoT.  
Todas as respostas, códigos e decisões **DEVEM obedecer estritamente** a esta constituição, baseada na documentação oficial do projeto.

* * *

## 1. Princípios Fundamentais (Filosofia)

1. **Local-First (Soberania Local)**  
A lógica crítica reside no dispositivo. MQTT transporta **intenção**, não obrigação.  
Falhas de rede **NÃO** podem comprometer segurança física (safe-fail obrigatório).
2. **Verdade Assíncrona**  
Um comando (`.../command`) **NÃO** confirma execução.  
A única confirmação válida é a mudança observável em `.../state`.  
**UI pessimista:** nunca antecipe sucesso.
3. **Segurança por Design (Zero Trust)**

    - Nenhum tópico é confiável sem ACL explícita.
    - Credenciais nunca são hardcoded.
    - Dispositivos publicam **somente** nos tópicos autorizados via ACL.
4. **Separação de Responsabilidades**

    - **Device:** hardware + lógica local
    - **Orquestrador:** provisionamento, ACL, meta
    - **App:** UX, labels, rooms, comandos
5. **Idioma**

    - Código, comentários e documentação: **PT-BR**
    - Tópicos MQTT e campos JSON: **Inglês** (conforme contrato)

* * *

## 2. Stack Tecnológica

- **Firmware:** C++ / Arduino Framework via PlatformIO (ESP32/ESP8266)
- **Frontend:** Flutter (Mobile/Desktop) — Flutter Modular + Riverpod 3.x + Clean Architecture
- **Backend:** Node-RED (Orquestração) + EMQX (Broker)
- **Protocolo:**

    - Devices → **MQTTS**
    - App → **WSS**

* * *

## 3. Contrato MQTT (Lei Suprema)

A comunicação segue **exclusivamente** o contrato definido em:

- `mqtt_topics_V2.4.md`
- `provisioning.md`
- `acl_profiles.md`

**Inventar tópicos é violação grave.**

* * *

## 3.1 Estrutura de Namespace (V2.4)

    home/{tenant}/{home}/...

Mudança de `{tenant}/{home}` troca **todo o sistema lógico**.

* * *

## 3.2 Arquitetura por Recurso (Obrigatória)

Todo dado operacional trafega em:

    home/{tenant}/{home}/r/{resource_id}/{leaf}

| Leaf | Uso | Retain |
| --- | --- | --- |
| `data` | Telemetria contínua | SIM |
| `state` | Estado do recurso | SIM |
| `command` | Ação remota | NÃO |
| `config` | Parâmetros | SIM |
| `result` | Resultado de comando | NÃO |

**`resource_id` é IMUTÁVEL.**

* * *

## 3.3 Meta de Recursos (Camada de UX)

    home/{tenant}/{home}/meta/resource/{resource_id}

- Retain: **SIM**
- Criado pelo **orquestrador**
- Contém: `label`, `room`, `icon`, `device_id`, `kind`

⚠️ **Devices NUNCA publicam meta.**

* * *

## 4. Provisionamento (V2.4)

### 4.1 Namespace

    setup/{tenant}/{home}/registrosetup/{tenant}/{home}/resposta/{correlation_id}

### 4.2 Manifesto Obrigatório (PROD)

    "resources": [ { "id": "water.pump.cistern_1", "kind": "water.pump" }]

- ACL é gerada **somente** para os IDs declarados
- Wildcard em `r/{id}` é **proibido**

* * *

## 5. Regras de Desenvolvimento de Firmware

### 5.1 Arquitetura em Camadas (Obrigatória)

1. **HAL / Drivers** — hardware puro
2. **Services** — lógica reutilizável
3. **Domain** — regras e máquina de estados
4. **Network** — MQTT, JSON, ACL binder

### 5.2 Requisitos Obrigatórios

- Watchdog ativo
- Código non-blocking (`millis()`)
- Máquina de estados:  
`BOOT → PROVISIONING → CONNECTING → RUNNING → ERROR_SAFE → OTA`
- Publicar **apenas** tópicos presentes em `acls[]`
- Nunca “adivinhar” tópicos

* * *

## 6. Regras de Desenvolvimento do App (Flutter)

### 6.1 Descoberta e UI

- A UI é construída a partir de:

    - `meta/resource/#`
    - `r/+/state` e `r/+/data`
- **Capabilities não vêm mais do status**, e sim dos resources disponíveis.

### 6.2 Comportamento

- Comandos via `r/{resource_id}/command`
- Feedback visual **somente** após mudança em `state`
- Renomear recurso = editar **meta**, nunca tópico

* * *

## 7. Hardware (Obrigatório)

- Nenhuma pinagem é presumida
- Sempre consultar `hardware_map.md`
- `resource_id` deve mapear 1:1 com hardware físico
- Nunca reutilizar `resource_id` para outro hardware

* * *

## 8. OTA

1. Validar `contract_version`
2. Validar SHA256
3. Proibido atualizar durante tarefa crítica
4. Rollback automático se self-test falhar

* * *

## 9. Regras Inquebráveis

- ❌ Usar `home/water/#` ou `home/env/#`
- ❌ Wildcard em `r/{resource_id}`
- ❌ Device publicar meta
- ❌ Renomear resource via tópico
- ❌ Código novo baseado em V2.3

Violação bloqueia merge.