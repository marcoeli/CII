Arquitetura de Firmware (ESP32) V1.1
====================================

Projeto: Automação Residencial\
Objetivo: definir uma arquitetura padrão para todos os firmwares ESP32, garantindo modularidade, testabilidade, consistência entre dispositivos e aderência ao contrato MQTT.

* * * * *

1. Princípios Obrigatórios
---------------------------

-   Modularidade rígida: cada camada tem responsabilidades claras e não "invade" a outra.

-   Local-first: regras críticas residem no dispositivo responsável (ex.: bomba no WATER_ACTUATOR).

-   MQTT é transporte, não lógica: MQTT não contém decisões críticas; apenas distribui comandos/estado.

-   Event-loop não bloqueante: nenhuma lógica deve travar o loop principal.

-   Observabilidade: todo device deve publicar status e errors em home/device/{username}/....

-   Configuração remota: parâmetros são recebidos via home/device/{username}/config e persistidos.

-   OTA obrigatório: todos os devices suportam OTA com validação e rollback conforme ota_strategy.md.

* * * * *

2. Camadas do Firmware (padrão do projeto)
-------------------------------------------

### 2.1 Drivers (HAL)

Responsabilidade:

-   ler/escrever hardware (GPIO, I2C, SPI, ADC, UART)

-   fornecer leituras brutas ou normalizadas

Regras:

-   não conhece MQTT

-   não conhece JSON

-   não conhece regras de negócio

-   idealmente sem alocação dinâmica e sem delays longos

Exemplos:

-   UltrasonicSensorDriver

-   RelayDriver

-   BuzzerDriver

-   DisplayDriver

-   DHTDriver

-   MQ2Driver

* * * * *

### 2.2 Services (Serviços locais)

Responsabilidade:

-   empacotar drivers em serviços de nível médio

-   oferecer API estável para a lógica

Regras:

-   ainda não conhece MQTT diretamente (ou conhece por meio de interfaces)

-   concentra filtragem, debounce, smoothing, calibração

Exemplos:

-   LevelMeasurementService (filtra distância, calcula litros/% via fórmulas geométricas para tanques retangulares e cilíndricos; tabelas de lookup podem ser usadas para formas irregulares)

-   GasAlarmService (limiar + histerese)

-   ButtonService (debounce + press types)

-   PumpActuationService (abstrai relés e feedback)

* * * * *

### 2.3 Domain / Logic (Regras de negócio)

Responsabilidade:

-   lógica local e decisões

-   máquina de estados

-   validação de comandos

Regras:

-   não sabe conectar Wi-Fi

-   não conhece detalhes de MQTT (recebe comandos e publica estados via interfaces)

-   deve ser determinística e orientada a eventos

Exemplos:

-   CisternControllerLogic

-   PumpStateMachine

-   KitchenHmiLogic

-   PresenceLogic

* * * * *

### 2.4 Network (Conectividade V2.4)
Responsabilidade:
- Wi-Fi (connect/reconnect/SoftAP)
- **ProvisioningClient:** gerencia o bootstrap via SoftAP + HTTP Local.
- **MqttClient:** gerencia a conexão MQTTS.
- **AclBinder:** interpreta o array `acls[]` recebido e configura permissões de publish/subscribe.
- TLS (MQTTS)
- Keepalive e backoff exponencial.

Regras:
- O módulo de rede só inicia o MQTT após possuir o contexto (`tenant`, `home`) e credenciais válidas.
- Bloqueia publicações fora da ACL autorizada.

* * * * *

### 2.5 Messaging (Contrato MQTT)

Responsabilidade:

-   mapear tópicos e payloads do mqtt_topics.md

-   serialização/deserialização JSON

-   validação de schema mínimo (campos obrigatórios)

Regras:

-   não decide nada, só traduz e valida formato

* * * * *

### 2.6 Persistence (Config & Credenciais)

Responsabilidade:

-   armazenar username/password, location, parâmetros de calibração

-   versionar configurações

Regras:

-   configurações devem ter schema e versão

-   suportar reset para modo "virgem" (provisionamento)

* * * * *

### 2.7 OTA Manager

Responsabilidade:

-   receber comando OTA

-   validar pré-condições

-   baixar binário

-   validar hash

-   acionar update

-   reportar estados (DOWNLOADING, VERIFYING, etc.)

-   garantir rollback em falha pós-boot

* * * * *

### 2.8 Main / App (Boot + Loop)

Responsabilidade:

-   inicializar módulos

-   orquestrar loop não bloqueante

-   watchdog

-   telemetria mínima

Regras:

-   main não deve conter lógica de negócio

-   cada módulo deve ter setup() e loopTick(nowMs) (ou equivalente)

* * * * *

3. Máquina de Estados (obrigatória)
------------------------------------

Todo device deve ter uma máquina de estados mínima:

1.  **BOOT**
2.  **SOFTAP_SETUP** (Awaiting context via HTTP local)
3.  **PROVISIONING** (Connecting with setup credentials, publishing manifest)
4.  **AWAITING_ACL** (Waiting for registration response)
5.  **CONNECTING** (Applying production credentials)
6.  **RUNNING** (Normal operation within ACL boundaries)
7.  **DEGRADED** (Lost MQTT, local logic active)
8.  **OTA_IN_PROGRESS**
9.  **ERROR_SAFE** (Critical failure)

Regras:

-   perda de MQTT → transição para DEGRADED (sem travar o device)

-   OTA só entra em OTA_IN_PROGRESS se pré-condições ok

* * * * *

4. Padrões de Publicação e Assinatura
--------------------------------------

### 4.1 Publicações obrigatórias (todos)

-   home/device/{username}/status (retain)

-   home/device/{username}/errors (retain)

### 4.2 Assinaturas obrigatórias (todos)

-   home/device/{username}/config (retain)

-   home/device/{username}/ota (não retain)

### 4.3 Publicações/assinaturas por tipo

-   WATER_SENSOR: publica home/water/level/{reservatorio}

-   WATER_ACTUATOR: assina home/water/pump/+/command, publica home/water/pump/+/state

-   ENV_SENSOR: publica home/env/{local}/climate e home/env/{local}/air

-   EVENT_NODE: publica home/event/doorbell/{local}

-   PRESENCE_SENSOR: publica home/{tenant}/{home}/r/security.presence.{id}/state

-   HMI_NODE: assina home/water/#, home/env/#, home/event/#, publica comandos autorizados

* * * * *

5. Padrões de Timing
---------------------

-   Loop principal: sem delays longos

-   Publicação de status: intervalo configurável (default recomendado: 30--60s)

-   Publicações de data contínuo:

-   nível: 10--60s (configurável)

-   clima/ar: 10--60s (configurável)

-   Retentativas:

-   Wi-Fi e MQTT com backoff exponencial (limites definidos)

* * * * *

6. Padrão de Configuração (Config Schema)
------------------------------------------

A configuração recebida em home/device/{username}/config deve seguir:

{

  "schema": 1,

  "location": "kitchen",

  "report_interval_s": 30,

  "calibration": {

    "level_offset_cm": 0

  }

}

Regras:

-   schema obrigatório

-   campos desconhecidos devem ser ignorados (forward compatible)

-   persistência local obrigatória

* * * * *

7. Segurança no Firmware
-------------------------

-   não confiar em command

-   validar action, tipos e limites

-   rejeitar e reportar errors em caso de abuso

-   em caso crítico, entrar em ERROR_SAFE

-   nunca embutir credenciais definitivas no binário (somente setup para provisionar)

* * * * *

8. Observabilidade e Diagnóstico
---------------------------------

Todo device deve incluir no status:

-   state, role, fw, uptime, rssi

-   ota.state quando aplicável

-   net.mqtt: conectado/desconectado (opcional)

Erros:

-   code, severity, detail, ts

* * * * *

9. Critérios de Aceite (para o time de firmware)
-------------------------------------------------

-   aderente ao contrato MQTT V2.3

-   sem lógica crítica fora do device responsável

-   loop não bloqueante

-   robusto a queda de Wi-Fi/MQTT

-   OTA com validações e rollback

-   status/errors sempre publicados