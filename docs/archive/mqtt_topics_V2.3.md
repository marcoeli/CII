# Contrato MQTT V2.3 (Fechado)

**Projeto:** Automação Residencial  
**Broker:** EMQX (remoto)  
**Transporte:**
- **MQTTS (8883):** dispositivos/backends
- **WSS (8084 /mqtt):** app/web
- **Provisionamento:** isolado em `setup/` (fora de `home/`)

**Mudanças em V2.3:**
- ✨ Campo `capabilities` obrigatório no heartbeat para auto-discovery de recursos

---

## 1. Regras Globais

### 1.1 Namespace
- **Namespace principal:** `home/`
- **Namespace de provisionamento:** `setup/` (fora de `home/`)

### 1.2 QoS e Retain (regra única)
- **QoS:** 1 (sempre)
- **Retain:**
    - **SIM:** state, data contínuo, status, config
    - **NÃO:** event, command, ota

### 1.3 Payload
- **Formato:** JSON
- **Encoding:** UTF-8
- **Validação:** Dispositivos devem validar schema e ignorar payload inválido.

---

## 2. Padrão Oficial de IDs

### 2.1 username (identidade MQTT do device)
- Único por device.
- **Recomendado:** `{role}-{suffix}`
    - Ex.: `water-actuator-a1b2c3`, `env-sensor-93ff10`
- **Regra:** `username` é a identidade técnica (AuthN + ACL). Labels humanos não entram no tópico.

### 2.2 local (local humano)
- Identificador curto e estável: `kitchen`, `livingroom`, `bedroom`, `entrance`, `cistern_room`, etc.
- Deve ser lowercase, sem espaços. Use `_` se necessário.

### 2.3 reservatorio (reservatório / destino de nível)
- **Padrão:**
    - `cistern`
    - `caixa_<nome>` (ex.: `caixa_sobrado`, `caixa_edícula`)
    - `pool` (se existir)

### 2.4 pump_id (atuador bomba)
- **Padrão oficial:**
    - `cistern_pump_<n>` para bombas na cisterna (ex.: `cistern_pump_1`, `cistern_pump_2`)
    - `caixa_<nome>_pump_<n>` quando fizer sentido por caixa/destino (Ex.: `caixa_sobrado_pump_1`)
- **Motivo:** um device pode controlar várias bombas; `pump_id` é o recurso, não o device.

### 2.5 sensor_id (opcional)
- Se houver múltiplos sensores do mesmo tipo no mesmo local, adote: `{local}_{tipo}_{n}`
    - Ex.: `kitchen_temp_1`, `kitchen_gas_1`

---

## 3. Domínio de Gestão do Dispositivo — home/device/

### 3.1 Status (Heartbeat)
- **Tópico:** `home/device/{username}/status` (Retain: SIM)
- **Payload:**
```json
{
  "state": "ONLINE",
  "role": "CISTERN_NODE",
  "fw": "1.0.0",
  "uptime": 12345,
  "rssi": -60,
  "capabilities": [
    {
      "type": "WATER_LEVEL",
      "resources": ["cistern"]
    },
    {
      "type": "WATER_ACTUATOR",
      "resources": ["cistern_pump_1", "cistern_pump_2"]
    }
  ]
}
```

**Campos:**
- `state`: "ONLINE" | "OFFLINE"
- `role`: Tipo do dispositivo (ex: "CISTERN_NODE", "WATER_ACTUATOR", "ENV_SENSOR")
- `fw`: Versão do firmware
- `uptime`: Tempo ligado em segundos
- `rssi`: Sinal Wi-Fi em dBm
- `capabilities`: **[NOVO V2.3]** Array de recursos que este dispositivo gerencia
  - `type`: Tipo da capability ("WATER_LEVEL", "WATER_ACTUATOR", "CLIMATE", etc.)
  - `resources`: IDs dos recursos gerenciados (ex: ["cistern"], ["pump_1", "pump_2"])

**Exemplos:**

```json
// Nó Cisterna (multi-capability)
{
  "state": "ONLINE",
  "role": "CISTERN_NODE",
  "fw": "1.0.0",
  "rssi": -55,
  "capabilities": [
    {"type": "WATER_LEVEL", "resources": ["cistern"]},
    {"type": "WATER_ACTUATOR", "resources": ["cistern_pump_1", "cistern_pump_2"]}
  ]
}

// Sensor Ambiental
{
  "state": "ONLINE",
  "role": "ENV_SENSOR",
  "fw": "2.1.0",
  "rssi": -62,
  "capabilities": [
    {"type": "CLIMATE", "resources": ["kitchen"]}
  ]
}
```

### 3.2 Erros
- **Tópico:** `home/device/{username}/errors` (Retain: SIM)
- **Payload:**
```json
{
  "code": "SENSOR_TIMEOUT",
  "severity": "WARN",
  "detail": "ultrasonic no echo",
  "ts": 1710000000
}
```

### 3.3 Configuração Remota
- **Tópico:** `home/device/{username}/config` (Retain: SIM)
- **Payload:**
```json
{
  "report_interval_s": 60,
  "location": "cistern_room"
}
```

### 3.4 OTA
- **Tópico:** `home/device/{username}/ota` (Retain: NÃO)
- **Payload:**
```json
{
  "version": "1.2.0",
  "url": "https://servidor/fw.bin",
  "sha256": "..."
}
```

---

## 4. Domínio Hidráulico — home/water/

### 4.1 Nível de Reservatórios (data contínuo)
- **Tópico:** `home/water/level/{reservatorio}` (Retain: SIM)
- **Payload:**
```json
{
  "liters": 5000,
  "percent": 80.5,
  "distance_cm": 20,
  "alert": "NORMAL",
  "ts": 1710000000
}
```

### 4.2 Bombas (atuadores)

#### 4.2.1 Estado
- **Tópico:** `home/water/pump/{pump_id}/state` (Retain: SIM)
- **Payload:**
```json
{
  "running": true,
  "mode": "AUTO",
  "reason": "LEVEL_LOW",
  "ts": 1710000000
}
```

#### 4.2.2 Comando
- **Tópico:** `home/water/pump/{pump_id}/command` (Retain: NÃO)
- **Payload:**
```json
{
  "action": "START",
  "force": false,
  "origin": "app",
  "ts": 1710000000
}
```

**Regras de segurança (norma):** O atuador deve:
1. Rejeitar comandos inválidos.
2. Confirmar execução publicando `state` (não há ACK síncrono).
3. Aplicar travas locais (ex.: “não iniciar se condição crítica”).

---

## 5. Domínio Ambiental — home/env/

### 5.1 Clima
- **Tópico:** `home/env/{local}/climate` (Retain: SIM)
- **Payload:**
```json
{
  "temp": 24.5,
  "hum": 60.2,
  "heat_index": 26.0,
  "ts": 1710000000
}
```

### 5.2 Qualidade do Ar / Gás
- **Tópico:** `home/env/{local}/air` (Retain: SIM)
- **Payload:**
```json
{
  "gas_detected": false,
  "co2_ppm": 450,
  "alert": "NORMAL",
  "ts": 1710000000
}
```

---

## 6. Domínio de Eventos — home/event/

### 6.1 Campainha (evento pontual)
- **Tópico:** `home/event/doorbell/{local}` (Retain: NÃO)
- **Payload:**
```json
{
  "pressed": true,
  "ts": 1710000000
}
```

### 6.2 Presença (estado útil para app)
- **Tópico:** `home/event/presence/{local}` (Retain: SIM)
- **Payload:**
```json
{
  "detected": true,
  "last_seen_seconds_ago": 0,
  "ts": 1710000000
}
```

### 6.3 Buzzer / Notificações locais (ação remota no HMI)
Quando o HMI precisar "tocar buzzer" por evento externo:
- **Tópico:** `home/event/notify/{local}/command` (Retain: NÃO)
- **Payload:**
```json
{
  "type": "BEEP",
  "pattern": "SHORTx3",
  "origin": "doorbell",
  "ts": 1710000000
}
```
**Nota:** `local` aqui é o local do dispositivo que executa o buzzer (ex.: `kitchen`).

### 6.4 Alarme (evento pontual)
- **Tópico:** `home/event/alarm/{local}` (Retain: NÃO)
- **Payload:**
```json
{
  "pressed": true,
  "ts": 1710000000
}
```

---

## 7. Provisionamento — setup/ (Isolado)

Consulte `provisioning.md` para detalhes completos.

- **Publish:** `setup/registro` (QoS 1, Retain NÃO)
- **Payload de Registro:**
```json
{
  "mac": "AA:BB:CC:DD:EE",
  "type": "WATER_SENSOR",
  "location": "cistern_room",
  "fw": "0.1.0",
  "mode": "prod",
  "claim_code": "8H2K-9QZP",
  "correlation_id": "uuid"
}

7.2 Resposta
Subscribe: setup/resposta/{correlation_id} (QoS 1, Retain NÃO)


{
  "ok": true,
  "username": "water-sensor-a1b2c3",
  "password": "senha_forte",
  "mqtts": { "host": "mqtt.icodz.com.br", "port": 8883 },
  "wss": { "host": "mqtt.icodz.com.br", "port": 8084, "path": "/mqtt" }
}

7.3 Modo DEV (para testes)
No registro DEV:
mode = "dev"


inclui dev_token


{
  "mac": "AA:BB:CC:DD:EE",
  "type": "WATER_SENSOR",
  "location": "unassigned",
  "fw": "0.1.0",
  "mode": "dev",
  "dev_token": "DEV-PSK",
  "correlation_id": "uuid"
}
7.4 Capacidades do Dispositivo (cap)
Um dispositivo pode exercer mais de uma função (ex.: cisterna = sensor + atuador).
 Para isso, no provisionamento, o device pode informar uma lista de capacidades:
Exemplo:
"cap": ["WATER_SENSOR","WATER_ACTUATOR"]

Regra:
Se cap vier no registro, o orquestrador aplica a união das ACLs correspondentes.


Se cap não vier, o orquestrador usa o mapeamento padrão type → cap (definido em acl_profiles.md).



8. Observações Normativas
App Flutter


conecta via WSS (wss://mqtt.icodz.com.br/mqtt)


publica commands, nunca state


Dispositivos ESP32


conectam via MQTTS (mqtts://mqtt.icodz.com.br:8883)


publicam status e seus domínios


Automação local é soberana


bomba decide localmente (fail-safe) mesmo com MQTT fora



9. Checklist de Implementação (para o time)
Device publica home/device/{username}/status com retain


Device aplica retain corretamente (state/data sim; event/command não)


Atuador confirma comando via publicação de state


IDs seguem padrão oficial (pump_id, reservatorio, local)


Provisionamento usa correlation_id e setup/ isolado


