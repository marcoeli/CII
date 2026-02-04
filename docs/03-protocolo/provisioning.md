# Provisionamento de Dispositivos (DEV / PROD) — **V2.4**

**Projeto:** Automação Residencial  
**Broker:** EMQX (Built-in Database)  
**Orquestrador:** Node-RED (serviço confiável, `SYSTEM_AUTOMATION`)  
**Objetivo:** provisionar dispositivos “virgens” com **credenciais únicas**, **ACL mínima explícita por `resource_id`**, suportando **multi-casa / multi-usuário**, **Zero Trust** e escala segura.

* * *

## 1. Conceitos e Papéis

### 1.1 Dispositivo Virgem (Unprovisioned)

Dispositivo recém-gravado ou resetado que:

- não possui `username/password` definitivos
- conecta apenas como usuário **`setup`**
- **não acessa `home/#`**
- declara explicitamente **os recursos reais que controla** (manifesto)

* * *

### 1.2 Orquestrador (Node-RED)

Serviço confiável responsável por:

- validar pedido de registro
- validar manifesto (`type / cap / resources`)
- criar credenciais no EMQX (AuthN)
- gerar **ACL explícita por `resource_id`** (AuthZ)
- publicar **metadados oficiais** de recursos (`meta/`)
- responder credenciais e ACLs ao device

* * *

### 1.3 Modos de Provisionamento

**PROD (padrão)**

- exige `claim_code`
- manifesto `resources[]` **obrigatório**

**DEV / FÁBRICA**

- exige `dev_token`
- recursos permitidos podem ser limitados
- uso temporário (kill switch obrigatório)

* * *

## 2. Bootstrap de Contexto (SoftAP + HTTP Local)

> 
> Necessário porque o contrato V2.4 exige `tenant/home` **antes** do MQTT.

### 2.1 Quando o SoftAP é ativado

- não existe Wi-Fi salvo **ou**
- não existe `tenant/home` persistido **ou**
- factory reset (botão físico)

**Regras obrigatórias**

- SoftAP ativo por janela curta (ex.: 10 min)
- encerra após configuração válida
- aceita **uma única configuração por boot**

* * *

### 2.2 SoftAP

**SSID**

    ICODZ_SETUP_{MAC_SUFFIX}

**Senha**

- DEV: pode ser aberta ou simples (janela curta)
- PROD: **não pode ser fixa**

    - derivada do hardware ou etiqueta física

* * *

### 2.3 Endpoint HTTP Local (Device)

- **IP:** `192.168.4.1`
- **Método:** `POST`
- **Path:** `/config`
- **Content-Type:** `application/json`

#### Payload oficial

    { "wifi": { "ssid": "MinhaCasa_2G", "pass": "senha123456" }, "context": { "tenant": "marcoeli", "home": "casa" }, "auth": { "mode": "prod", "claim_code": "8H2K-9QZP" }}

#### DEV

    { "wifi": { "ssid": "LabWiFi", "pass": "12345678" }, "context": { "tenant": "dev", "home": "lab" }, "auth": { "mode": "dev", "dev_token": "ICODZ-DEV-SECRET-2026" }}

* * *

### 2.4 Validações obrigatórias no Device

**tenant / home**

- regex: `^[a-z0-9_-]{3,32}$`
- lowercase obrigatório
- sem espaços

**Wi-Fi**

- `ssid`: 1..32
- `pass`: 0..63

**Auth**

- `mode`: `prod | dev`
- PROD → `claim_code` obrigatório
- DEV → `dev_token` obrigatório

* * *

### 2.5 Persistência (NVS)

Salvar:

- `wifi_ssid`, `wifi_pass`
- `tenant`, `home`
- `mode`
- `claim_code` **ou** `dev_token`

Responder:

    { "ok": true, "action": "reboot" }

Reiniciar imediatamente.

* * *

## 3. Namespace e Tópicos (Multi-Tenant)

Provisionamento fica **fora de `home/`**, porém com escopo explícito:

### Device → Orquestrador

    setup/{tenant}/{home}/registro

### Orquestrador → Device

    setup/{tenant}/{home}/resposta/{correlation_id}

> 
> Isolamento garantido por **namespace + ACL**.

* * *

## 4. ACL do Usuário `setup`

Usuário MQTT temporário do device virgem.

**Username:** `setup`  
**Password:** definido pela infraestrutura

| Permission | Action | Topic |
| --- | --- | --- |
| Allow | Publish | `setup/+/+/registro` |
| Allow | Subscribe | `setup/+/+/resposta/+` |

**Regra:** `setup` **não** acessa `home/#`.

* * *

## 5. Contrato de Mensagens

### 5.1 Registro (`setup/{tenant}/{home}/registro`)

#### Campos obrigatórios

- `mac`
- `type`
- `fw`
- `mode`
- `correlation_id`
- `resources[]` (**obrigatório em PROD**)

#### Opcionais

- `cap`
- `hw`
- `location`

* * *

### 5.1.1 Manifesto de Recursos (V2.4)

    "resources": [ { "id": "water.level.cistern", "kind": "water.level" }, { "id": "water.pump.cistern_pump_1", "kind": "water.pump" }]

**Regras**

- `id`

    - imutável
    - único dentro do `home`
    - usado diretamente na ACL
- `kind`

    - usado **somente para validação**
    - mapeado em `acl_profiles.md`
- **proibido wildcard em `resource_id`**

* * *

### 5.1.2 Exemplo PROD

    { "mac": "AA:BB:CC:DD:EE", "type": "CISTERN_NODE", "fw": "2.4.0", "mode": "prod", "claim_code": "8H2K-9QZP", "correlation_id": "uuid", "resources": [ { "id": "water.level.cistern", "kind": "water.level" }, { "id": "water.pump.cistern_pump_1", "kind": "water.pump" } ]}

* * *

### 5.2 Resposta (`setup/{tenant}/{home}/resposta/{correlation_id}`)

#### Sucesso

    { "ok": true, "username": "cistern-node-bb00bb", "password": "senha_forte", "home": { "tenant": "marcoeli", "id": "casa", "prefix": "home/marcoeli/casa" }, "mqtts": { "host": "mqtt.icodz.com.br", "port": 8883 }, "acls": [ { "permission": "allow", "action": "publish", "topic": "home/marcoeli/casa/r/water.level.cistern/data" }, { "permission": "allow", "action": "publish", "topic": "home/marcoeli/casa/r/water.pump.cistern_pump_1/state" }, { "permission": "allow", "action": "subscribe", "topic": "home/marcoeli/casa/r/water.pump.cistern_pump_1/command" } ]}

> 
> `acls[]` é a **única fonte da verdade** para publish/subscribe do firmware.

* * *

## 6. Regras do Orquestrador

### 6.1 Username

    {type-lower}-{mac_suffix}

### 6.2 Validação de Recursos

Para cada resource:

1. validar `id` (regex / unicidade)
2. validar `kind` existe
3. validar `type/cap` permite `kind`
4. gerar ACL **somente para aquele ID**

### 6.3 ACL

- proibido wildcard em `resource_id`
- permitido apenas em:

    - `device/{username}/#`
    - `event/#` (quando aplicável)

* * *

## 7. Meta de Recursos (Catálogo Oficial)

Publicado **somente pelo Orquestrador**:

    home/{tenant}/{home}/meta/resource/{resource_id}

Payload típico:

    { "id": "water.pump.cistern_pump_1", "kind": "water.pump", "label": "Bomba 1", "device_id": "cistern-node-bb00bb", "controls": ["START","STOP"], "telemetry": ["state","result"]}

> 
> Devices **nunca** publicam `meta`.

* * *

## 8. Segurança

- Claim Code: uso único + expiração
- Rate limit: IP + MAC
- Replay protection: `correlation_id`

* * *

## 9. Critérios de Aceite (Firmware)

- conecta como `setup`
- publica em `setup/{tenant}/{home}/registro`
- persiste credenciais
- reconecta em MQTTS
- **usa exclusivamente os tópicos listados em `acls[]`**

* * *

## 10. Erros Padronizados (V2.4)

| Código | Quando |
| --- | --- |
| RESOURCE\_MISSING | PROD sem resources |
| RESOURCE\_INVALID | id/kind inválido |
| RESOURCE\_NOT\_ALLOWED | kind não permitido |
| RESOURCE\_CONFLICT | id já existe |
| CONTEXT\_INVALID | tenant/home inválido |