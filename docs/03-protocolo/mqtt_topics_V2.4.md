* * *

# Contrato MQTT V2.4 (Baseado no V2.3)

**Projeto:** Automação Residencial (multi-casa / escalável)  
**Broker:** EMQX (nuvem)  
**Transporte:**

- **MQTTS (8883):** dispositivos / orquestrador
- **WSS (8084 /mqtt):** app / web
- **Provisionamento:** `setup/` (isolado)

* * *

## 1. Regras Globais

### 1.1 Namespace (NOVO – multicasa)

Todos os tópicos produtivos DEVEM estar sob:

    home/{tenant}/{home}/

Exemplo:

    home/marco/casa_principal/home/cliente_x/apt_302/

**Regra:**  
Credenciais + ACL garantem que um device/app **só enxerga seu próprio tenant/home**.

* * *

### 1.2 QoS e Retain (inalterado)

- **QoS:** 1 (sempre)
- **Retain:**

  - **SIM:** `status`, `state`, `data`, `config`, `meta`
  - **NÃO:** `event`, `command`, `result`, `ota`, `setup`

* * *

### 1.3 Payload

- JSON UTF-8
- Devices validam schema e ignoram payload inválido
- Campos desconhecidos DEVEM ser ignorados (forward-compatible)
- Schemas detalhados de payload são orientativos e documentados em [sensor_payload_guidelines.md](file:///d:/Projects/CII/docs/sensor_payload_guidelines.md).

* * *

## 2. Identidades Oficiais

### 2.1 device\_id (antes username)

- Identidade técnica + ACL
- Único por dispositivo
- Ex.: `cistern-node-4c7848`, `pump-node-91af20`

>
> `device_id` continua sendo o **username MQTT**.

* * *

### 2.2 resource\_id (NOVO – imutável)

Identificador técnico do recurso (NUNCA muda).

**Padrão:**

    {domain}.{kind}.{name}

Exemplos:

- `water.level.cistern`
- `water.pump.cistern_pump_1`
- `light.lamp.livingroom_main`
- `power.outlet.garage_1`
- `security.camera.entrance_1`
- `security.presence.hall_1`
- `water.valve.inlet_main`

* * *

### 2.3 label (humano)

- Mutável
- Pode duplicar
- **Nunca entra em tópico**

* * *

## 3. Domínio de Gestão do Dispositivo — `home/device/`

### 3.1 Status (Heartbeat)

**Tópico:**

    home/{tenant}/{home}/device/{device_id}/status

(Retain: SIM)

    {
  "contract": "2.4",
  "state": "ONLINE",
  "role": "CISTERN_NODE",
  "fw": "1.0.0",
  "uptime": 12345,
  "rssi": -55,
  "hw": {
    "vendor": "icodz",
    "model": "CISTERN_NODE_V1",
    "rev": "1.1",
    "serial": "CNV1-A1B2C3"
  },
  "capabilities": [
    {
      "type": "WATER_LEVEL",
      "resources": [
        {
          "id": "water.level.cistern",
          "label": "Cisterna",
          "domain": "water",
          "kind": "level"
        }
      ]
    },
    {
      "type": "WATER_ACTUATOR",
      "resources": [
        {
          "id": "water.pump.cistern_pump_1",
          "label": "Bomba 1",
          "domain": "water",
          "kind": "pump"
        }
      ],
      "controls": [
        "START",
        "STOP",
        "SET_MODE"
      ],
      "params": {
        "force": {
          "type": "bool",
          "default": false
        }
      }
    }
  ]
}

* * *

### 3.2 Errors

    home/{tenant}/{home}/device/{device_id}/errors

(Retain: SIM)

    { "code": "SENSOR_TIMEOUT", "severity": "WARN", "detail": "ultrasonic no echo", "ts": 1710000000}

* * *

### 3.3 Configuração do Device (opcional)

    home/{tenant}/{home}/device/{device_id}/config

(Retain: SIM)

Usar **somente** para parâmetros globais:

- `report_interval`
- logs
- rede
- debug

* * *

## 4. Domínio de Recursos — `home/r/` (NÚCLEO)

Base:

    home/{tenant}/{home}/r/{resource_id}/

* * *

### 4.1 State (estado discreto)

    .../state

(Retain: SIM)

**Exemplo – bomba**

    { "running": true, "mode": "AUTO", "reason": "LEVEL_LOW", "ts": 1710000000}

* * *

### 4.2 Data (telemetria contínua)

    .../data

(Retain: SIM)

**Exemplo – nível**

    { "liters": 5000, "percent": 80.5, "distance_cm": 20, "alert": "NORMAL", "ts": 1710000000}

* * *

### 4.3 Command

    .../command

(Retain: NÃO)

    { "action": "START", "params": { "force": false }, "origin": "app", "correlation_id": "uuid", "ts": 1710000000}

* * *

### 4.4 Result (NOVO)

    .../result

(Retain: NÃO)

    { "correlation_id": "uuid", "status": "OK", "error_code": null, "detail": null, "ts": 1710000000}

* * *

### 4.5 Configuração por Recurso (NOVO)

    .../config

(Retain: SIM)

#### Exemplo – bomba dependente de níveis

    { "mode": "AUTO", 
    "bindings": { "source_level": "water.level.cistern", 
    "target_level": "water.level.caixa_sobrado" }, 
    "rules": { "min_source_percent": 15, "start_below_percent": 30, "stop_above_percent": 85 }, 
    "safety": { "stop_on_stale_seconds": 30 }}

* * *

## 5. Domínio de Eventos — `home/event/`

    home/{tenant}/{home}/event/{domain}/{kind}/{resource_id}

(Retain: NÃO)

### Exemplo – campainha

    { "event": "PRESSED", "ts": 1710000000}

* * *

## 6. Registry / Meta (UI, labels, ownership)

    home/{tenant}/{home}/meta/resource/{resource_id}

(Retain: SIM)

    { "resource_id": "water.pump.cistern_pump_1", 
    "label": "Bomba da Cisterna", 
    "location": "cistern_room",
    "owner_device_id": "cistern-node-4c7848",
    "domain": "water", 
    "kind": "pump", 
    "ts": 1710000000, 
    "updated_by": "app"}

* * *

## 7. Exemplos de Novos Cenários

### 7.1 Lâmpada

**State**

    { "on": true, "brightness": 80, "ts": 1710000000 }

**Command**

    { "action": "SET", "params": { "on": true, "brightness": 50 }, "ts": 1710000000 }

* * *

### 7.2 Tomada

**State**

    { "on": false, "locked": false, "ts": 1710000000 }

**Data**

    { "watts": 120.5, "volts": 127.0, "amps": 0.95, "ts": 1710000000 }

* * *

### 7.3 Válvula

**State**

    { "open": true, "mode": "AUTO", "ts": 1710000000 }

* * *

### 7.4 Câmera (sem vídeo)

**State**

    { "online": true, "motion": false, "ts": 1710000000 }

**Event**

    { "event": "MOTION", "score": 0.81, "ts": 1710000000 }

* * *

## 8. ACL (Norma)

### Device

- PUB:

  - `home/{tenant}/{home}/device/{device_id}/#`
  - `home/{tenant}/{home}/r/<resource_id>/{state|data}`
- SUB:

  - `home/{tenant}/{home}/r/<resource_id>/command`
  - `home/{tenant}/{home}/r/<dep_resource_id>/{state|data}` (se necessário)

### App

- PUB: `home/{tenant}/{home}/r/+/command`
- SUB:

  - `home/{tenant}/{home}/device/+/status`
  - `home/{tenant}/{home}/r/+/state`
  - `home/{tenant}/{home}/r/+/data`
  - `home/{tenant}/{home}/event/#`
  - `home/{tenant}/{home}/meta/#`

* * *

## 9. Regras Finais

- IDs técnicos são imutáveis
- Labels são humanos e ficam em `meta`
- Devices são “burros” e soberanos localmente (fail-safe)
- Automação nasce do **estado**, não de comandos diretos entre devices
