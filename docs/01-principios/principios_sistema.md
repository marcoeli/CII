📘 Documento de Arquitetura do Sistema --- V1.1
=============================================

* * * * *

1. Princípios Fundamentais do Sistema
======================================

O sistema é baseado em diretrizes técnicas obrigatórias:

-   Local-First e Autônomo: Nenhuma lógica crítica do sistema deve depender do aplicativo, de serviços em nuvem ou de comandos de voz. A lógica da bomba, por exemplo, deve residir no nó da cisterna, não no aplicativo.

-   Broker Remoto, Lógica Local: O broker MQTT é remoto (cloud), porém a perda de internet ou MQTT não pode interromper a automação local.

-   Comunicação: O protocolo central é o MQTT, funcionando como o "contrato de comunicação". O formato de dados é JSON, com QoS 1 e uso de Retain apenas para estados e dados contínuos.

> [!IMPORTANT]
> **Regra de Ouro V2.4**
> 1. Contexto vem antes de comunicação.
> 2. Comunicação vem antes de automação.
> 3. Automação vem antes de conforto.
> *Inverter essa ordem gera sistemas frágeis.*
>
> **Imutabilidade de resource_id:** O `resource_id` é a identidade técnica, imutável, usada em ACL, automação e roteamento. Qualquer renomeação (label) ocorre exclusivamente na camada de metadados (`meta/resource`).
> 
> **Regra Conceitual - Domínios:**  
> Ambiente (`env`) mede condições físicas (temp, air, humidity).  
> Presença (`security`) indica ocupação/estado lógico.  
> Nunca misturar os dois.

-   Transporte Seguro:

-   MQTTS (TCP + TLS) porta 8883 é o canal principal para ESP32 e backend.

-   WSS (WebSocket Secure) porta 8084 é reservado para App Flutter e interfaces web.

-   Provisionamento: Dispositivos recebem credenciais dinamicamente via Node-RED, com dois modos:

-   PROD: exige Claim Code (uso único, expira).

-   DEV/FÁBRICA: usa token de desenvolvimento + janela de tempo limitada.

-   Plataformas: O firmware será desenvolvido em C++ usando PlatformIO e o Espressif Framework (com possível adoção futura do ESP-IDF). O aplicativo de interação humana será feito em Flutter.

* * * * *

2. Arquitetura de Dispositivos (Nós)
=====================================

A identidade MQTT de cada dispositivo é o username, gerado no provisionamento e único por device.\
Nomes como cistern-node são apenas labels humanos, não identidades técnicas.

|

Dispositivo (Label)

 |

Role (Type)

 |

Funções Principais

 |

Hardware Chave

 |
|

Nó Cisterna

 |

WATER_ACTUATOR

 |

Medir nível, controlar duas bombas (lógica AUTO/MANUAL).

 |

ESP32, Sensor ultrassônico, 2x Relés

 |
|

Nó Cozinha

 |

HMI_NODE

 |

Interface local (LCD), Monitorar ambiente (Temp, Umidade, Gás), Alertas.

 |

ESP32, Display LCD, Botões, DHT11, MQ-2, Buzzer

 |
|

Sensor Nível Caixa

 |

WATER_SENSOR

 |

Medição precisa de nível/volume.

 |

ESP32, Sensor ultrassônico

 |
|

Campainha

 |

EVENT_NODE

 |

Detectar acionamento e publicar evento imediato.

 |

ESP32, Botão

 |

* * * * *

3. Contrato MQTT (Comunicação)
===============================

O contrato MQTT é a base não negociável do sistema, onde qualquer mudança na versão MAJOR do firmware indica uma quebra de compatibilidade no contrato MQTT.

3.1 Padrões Gerais
------------------

### Prefixo Global

home/

### Estrutura Lógica do Tópico

home/{dominio}/{tipo}/{id_ou_local}/{dado}

### Convenções de Payload

-   Formato: JSON

-   Encoding: UTF-8

-   QoS: 1

* * * * *

3.2 Domínio de Gestão de Dispositivo --- home/device/
---------------------------------------------------

### ACL Universal (All Users)

Allow Publish/Subscribe: home/device/${username}/#

### Status (Heartbeat)

Tópico:

home/device/{username}/status

Retain: SIM

Payload:

{

  "state": "ONLINE",

  "fw": "1.0.0",

  "uptime": 12345,

  "rssi": -60,

  "role": "WATER_SENSOR"

}

* * * * *

### Configuração Remota

Tópico:

home/device/{username}/config

Retain: SIM

* * * * *

### Atualização OTA

Tópico:

home/device/{username}/ota

Retain: NÃO

Payload:

{

  "version": "1.2.0",

  "url": "https://servidor/fw.bin",

  "sha256": "hash"

}

* * * * *

3.3 Domínio Hidráulico --- home/water/
------------------------------------

### Sensores (WATER_SENSOR)

Tópico:

home/water/level/{reservatorio}

Retain: SIM

* * * * *

### Atuadores (WATER_ACTUATOR)

Estado:

home/water/pump/{pump_id}/state

Retain: SIM

Comando:

home/water/pump/{pump_id}/command

Retain: NÃO

* * * * *

3.4 Domínio Ambiental --- home/env/
---------------------------------

### Clima

home/env/{local}/climate

Retain: SIM

### Qualidade do Ar

home/env/{local}/air

Retain: SIM

* * * * *

3.5 Domínio de Eventos --- home/event/
------------------------------------

### Campainha

home/event/doorbell/{local}

Retain: NÃO

### Presença

home/event/security/presence/{resource_id}

Retain: SIM

* * * * *

3.6 Retain e QoS
----------------

|

Tipo

 |

Retain

 |

QoS

 |
|

State

 |

SIM

 |

1

 |
|

Data

 |

SIM

 |

1

 |
|

Event

 |

NÃO

 |

1

 |
|

Command

 |

NÃO

 |

1

 |

* * * * *

4. Provisionamento de Dispositivos
===================================

Tópicos
-------

-   Publish: setup/registro

-   Subscribe: setup/resposta/{correlation_id}

* * * * *

Registro --- Modo PROD
--------------------

{

  "mac": "AA:BB:CC:DD:EE",

  "type": "WATER_SENSOR",

  "fw": "0.1.0",

  "mode": "prod",

  "claim_code": "8H2K-9QZP",

  "correlation_id": "uuid"

}

* * * * *

Registro --- Modo DEV
-------------------

{

  "mac": "AA:BB:CC:DD:EE",

  "type": "WATER_SENSOR",

  "fw": "0.1.0",

  "mode": "dev",

  "dev_token": "DEV-PSK",

  "correlation_id": "uuid"

}

* * * * *

Resposta
--------

{

  "ok": true,

  "username": "water-sensor-a1b2c3",

  "password": "senha_forte",

  "mqtts": { "host": "mqtt.icodz.com.br", "port": 8883 },

  "wss": { "host": "mqtt.icodz.com.br", "port": 8084, "path": "/mqtt" }

}

* * * * *

5. Arquitetura de Firmware e OTA
=================================

Camadas Lógicas
---------------

-   Drivers: Comunicação com hardware. Não acessa MQTT.

-   Network: Wi-Fi + MQTT + TLS.

-   Logic: Decisões locais e automação.

-   Main: Inicialização e loop principal.

OTA (Over-The-Air)
------------------

-   HTTPS obrigatório

-   Hash obrigatório

-   Rollback automático

-   OTA proibido durante operação crítica

* * * * *

6. Arquitetura de Interfaces (Painel e App)
============================================

Painel da Cozinha (HMI_NODE)
----------------------------

-   Funciona offline

-   Prioridade para alarmes

-   Indicação de status Wi-Fi/MQTT

Aplicativo Flutter
------------------

-   Conexão via WSS

-   Sem lógica crítica

-   Reage a estados MQTT

* * * * *

7. Segurança e Testes
======================

Segurança
---------

-   Credencial única por dispositivo

-   ACL mínima por perfil

-   Provisionamento DEV pode ser desativado globalmente

-   Firmware valida payloads

Testes de Falha
---------------

-   Perda de MQTT

-   Perda de Wi-Fi

-   OTA inválido

-   Ataque de provisionamento

-   Sensor tentando comandar atuador

-   Falha elétrica

* * * * *

8. Estratégia e Ordem de Desenvolvimento
=========================================

1.  Fechar contrato MQTT + provisionamento

2.  Broker remoto + TLS + ACL

3.  Template firmware base (Wi-Fi, MQTT, OTA)

4.  WATER_SENSOR (nível cisterna)

5.  WATER_ACTUATOR (bombas)

6.  HMI_NODE

7.  App Flutter