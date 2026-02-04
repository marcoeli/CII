# Fichas de Especificação por Dispositivo — **V2.4**

**Projeto:** Automação Residencial  
**Base normativa:**  
`mqtt_topics_V2.4.md`, `provisioning.md`, `acl_profiles.md`, `firmware_architecture_esp32.md`

**Objetivo:**  
Definir, por **tipo de device**, suas responsabilidades físicas e lógicas, **tipos de recursos**, comportamento MQTT **orientado a resource**, validações locais e critérios de aceite.

* * *

## PRINCÍPIOS OBRIGATÓRIOS (V2.4)

- Todos os dados operacionais trafegam em  
`home/{tenant}/{home}/r/{resource_id}/...`
- `resource_id` é **imutável**
- Discovery e UI são baseados em **`meta/resource/*`**
- `status` **não contém** capabilities, location ou labels
- Device **nunca publica meta**
- ACL de device é **explícita por resource\_id** (sem wildcard)

* * *

## 1) WATER\_ACTUATOR — Controlador Hidráulico

- **type:** `WATER_ACTUATOR`
- **cap:** `["WATER_ACTUATOR"]`
- Pode coexistir com `WATER_SENSOR` (device híbrido)

### 1.1 Responsabilidade

- Controlar um ou mais atuadores físicos (bombas, válvulas).
- Executar lógica local AUTO / MANUAL / LOCKED.
- Garantir intertravamentos e fail-safe **independente de MQTT**.

### 1.2 Recursos típicos

- `water.pump.cistern_pump_1`
- `water.valve.inlet_1`

### 1.3 Tópicos MQTT (por resource)

- **State:**  
`home/{tenant}/{home}/r/{resource_id}/state` (retain)
- **Command:**  
`home/{tenant}/{home}/r/{resource_id}/command` (não retain)
- **Config:**  
`home/{tenant}/{home}/r/{resource_id}/config` (retain)
- **Result:**  
`home/{tenant}/{home}/r/{resource_id}/result` (opcional)

### 1.4 Payloads mínimos

**command**

    { "action": "START", "force": false, "origin": "app", "ts": 1710000000 }

**state**

    { "running": true, "mode": "AUTO", "reason": "LEVEL_LOW", "ts": 1710000000 }

### 1.5 Máquina de estados local

- **AUTO:** decide com base em sensores/config.
- **MANUAL:** aceita comandos com validação.
- **LOCKED:** condição crítica (dry-run, erro sensor).

### 1.6 Regras críticas

- Nunca iniciar OTA com atuador ativo.
- MQTT fora **não altera** a lógica local.
- Comando ≠ confirmação. Confirmação é `state`.

### 1.7 Critérios de aceite

- Executa comandos válidos.
- Rejeita comandos inválidos.
- Nunca viola travas de segurança.
- Suporta N recursos (N ≥ 2).

* * *

## 2) WATER\_SENSOR — Sensor Hidráulico

- **type:** `WATER_SENSOR` ou `LEVEL_SENSOR`
- **cap:** `["WATER_SENSOR"]`

### 2.1 Responsabilidade

- Medir nível/volume/fluxo.
- Publicar dados contínuos (retain).
- **Não controla atuadores.**

### 2.2 Recursos típicos

- `water.level.cistern`
- `water.flow.inlet_1`

### 2.3 Tópicos MQTT

- **Data:**  
`home/{tenant}/{home}/r/{resource_id}/data` (retain)
- **Config:**  
`home/{tenant}/{home}/r/{resource_id}/config` (retain)

### 2.4 Payload nível (mínimo)

    { "liters": 5000, "percent": 80.5, "alert": "NORMAL", "ts": 1710000000 }

### 2.5 Regras críticas

- Nunca publica `command`.
- Offline continua medindo localmente.
- Retoma publicação ao reconectar.

### 2.6 Critérios de aceite

- Retain consistente.
- Erro ≤ 5%.
- Config inválida é ignorada + erro registrado.

* * *

## 3) ENV\_SENSOR — Sensor Ambiental

- **type:** `ENV_SENSOR`
- **cap:** `["ENV_SENSOR"]`

### 3.1 Responsabilidade

- Medir clima e qualidade do ar.

### 3.2 Recursos típicos

- `env.climate.kitchen`
- `env.air.kitchen`

### 3.3 Tópicos MQTT

- **Data:**  
`home/{tenant}/{home}/r/{resource_id}/data` (retain)

### 3.4 Regras críticas

- Thresholds aplicados localmente.
- Alertas consistentes (`NORMAL|WARN|CRITICAL`).

### 3.5 Critérios de aceite

- Publicação contínua com retain.
- Offline continua exibindo leituras locais (se houver HMI).

* * *

## 4) PRESENCE\_SENSOR — Sensor de Presença

- **type:** `PRESENCE_SENSOR`
- **cap:** `["PRESENCE_SENSOR"]`

### 4.1 Responsabilidade

- Detectar presença/movimento.
- Manter último estado conhecido.

### 4.2 Recurso típico

- `security.presence.hall`

### 4.3 Tópicos MQTT

- **State:**  
`home/{tenant}/{home}/r/{resource_id}/state` (retain)

### 4.4 Payload (Estado)

```json
{
  "detected": true,
  "confidence": 0.81,
  "ts": 1710000000
}
```

### 4.5 Critérios de aceite

- Retain reflete última presença válida.
- Timestamp coerente.

* * *

## 5) EVENT\_NODE — Evento Pontual (Campainha)

- **type:** `EVENT_NODE` ou `DOORBELL`
- **cap:** `["EVENT_NODE"]`

### 5.1 Responsabilidade

- Detectar evento pontual.
- Publicar evento sem retain.

### 5.2 Recurso típico

- `event.doorbell.front`

### 5.3 Tópicos MQTT

- **State/Event:**  
`home/{tenant}/{home}/r/{resource_id}/state` (não retain)

### 5.4 Critérios de aceite

- QoS 1.
- Debounce obrigatório.

* * *

## 6) HMI\_NODE — Interface Humana Local

- **type:** `HMI_NODE`
- **cap:** `["HMI_NODE"]`

### 6.1 Responsabilidade

- Exibir estados.
- Emitir comandos autorizados.
- Operar offline.

### 6.2 Regras

- Comanda apenas resources permitidos pela ACL.
- UI local nunca assume sucesso sem `state`.

* * *

## 7) APP\_CLIENT — Aplicativo Flutter

- **type:** `APP_CLIENT`
- **cap:** `["APP_CLIENT"]`

### 7.1 Responsabilidade

- Leitura do sistema.
- Emissão de comandos.
- UX e notificações.

### 7.2 MQTT

**SUB**

- `home/{tenant}/{home}/device/+/status`
- `home/{tenant}/{home}/r/+/state`
- `home/{tenant}/{home}/r/+/data`
- `home/{tenant}/{home}/r/+/result`
- `home/{tenant}/{home}/meta/#`
- `home/{tenant}/{home}/event/#`

**PUB**

- `home/{tenant}/{home}/r/{resource_id}/command`

### 7.3 Critérios de aceite

- UI reidrata via retained.
- Nunca publica `state`, `data` ou `status`.

* * *

## 8) Observações finais

- Este documento **não define ACL** (ver `acl_profiles.md`)
- Este documento **não define provisionamento** (ver `provisioning.md`)
- Payloads seguem guidelines orientativas em [sensor_payload_guidelines.md](file:///d:/Projects/CII/docs/sensor_payload_guidelines.md).
- Qualquer exceção **exige mudança formal de contrato**