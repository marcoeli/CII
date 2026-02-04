# Especificação Técnica: Dispositivo Cisterna (Cistern Node)

> [!NOTE]
> **Natureza do Documento**: Este arquivo **NÃO** faz parte dos contratos normativos que determinam as regras do projeto (como `mqtt_topics.md`). Ele é um **descritivo técnico** de como o dispositivo físico está configurado e implementado na versão atual.

Este documento define as especificações técnicas, mapa de hardware, funcionalidades e interface de comunicação (API MQTT) do dispositivo Controlador de Cisterna.

---

## 1. Visão Geral

O **Cistern Node** é um dispositivo IoT baseado em ESP32 projetado para monitorar níveis de água e controlar bombas de forma autônoma e remota. Ele opera com a filosofia **Local-First**, garantindo proteção e operação básica mesmo sem conexão de rede.

### Principais Features
*   **Monitoramento de Nível:** Leitura ultrassônica com filtro de ruído (EMA) e cálculo volumétrico (litros/percentual).
*   **Controle de Atuadores:** Controle de 2 bombas (Relés) com modos Manual, Automático e Bloqueado.
*   **Proteção (Safe-Fail):** Desligamento automático em caso de nível crítico (proteção contra funcionamento a seco).
*   **Interface Local:** Display OLED navegaável e botões físicos para controle manual independente do Wi-Fi.
*   **Conectividade:**
    *   Wi-Fi Station (Cliente) e Access Point (Fallback de configuração).
    *   MQTT sobre TLS (MQTTS) para comunicação segura.
    *   Sincronização de tempo (NTP).
*   **Configuração:** Interface Web Local e Comandos remotos MQTT.
*   **OTA:** Atualização de firmware via rede.

---

## 2. Mapa de Hardware (Pinout)

**Placa Alvo:** ESP32 DevKit V1

| Componente | Função | Pino (GPIO) | Detalhes |
| :--- | :--- | :--- | :--- |
| **Sensor Nível** | Trigger | **GPIO 23** | HC-SR04 Trigger |
| | Echo | **GPIO 19** | HC-SR04 Echo (Input) |
| **Atuadores** | Bomba 1 | **GPIO 25** | Relé SSR (Ativo Alto) |
| | Bomba 2 | **GPIO 26** | Relé SSR (Ativo Alto) |
| **Display** | I2C SDA | **GPIO 21** | OLED SSD1306 |
| | I2C SCL | **GPIO 22** | OLED SSD1306 |
| **Interface** | Botão UP | **GPIO 32** | Pull-up Interno |
| | Botão DOWN | **GPIO 33** | Pull-up Interno |
| | Botão SELECT | **GPIO 34** | Input Only (Pull-up externo necessário*) |
| | Botão BACK | **GPIO 35** | Input Only (Pull-up externo necessário*) |

*\*Nota: GPIO 34 e 35 são apenas entrada e não possuem pull-up interno. Requer resistor pull-up físico no circuito.*

---

## 3. Interface de Comunicação (Contrato MQTT)

### 3.1 Tópicos de Publicação (Device -> Broker)

O dispositivo publica informações para monitoramento.

#### Status (Heartbeat)
Reporta saúde central do hardware.
*   **Tópico:** `home/{tenant}/{home}/device/{username}/status`
*   **Retain:** `true`
*   **Payload:**
    ```json
    {
      "state": "ONLINE",
      "fw": "1.0.0",
      "uptime": 1205,
      "rssi": -65
    }
    ```

#### Nível de Água (Recurso)
*   **Tópico:** `home/{tenant}/{home}/r/water.level.cistern/data`
*   **Retain:** `true`
*   **Payload:**
    ```json
    {
      "liters": 1500.5,
      "percent": 75.2,
      "ts": 1709123456
    }
    ```

#### Estado da Bomba (Recurso)
*   **Tópico:** `home/{tenant}/{home}/r/water.pump.cistern_pump_1/state`
*   **Retain:** `true`
*   **Payload:**
    ```json
    {
      "running": true,
      "mode": "AUTO",
      "reason": "mqtt_command",
      "ts": 1709123456
    }
    ```

---

### 3.2 Tópicos de Comando (Broker -> Device)

O dispositivo aceita comandos para atuar no hardware ou alterar configurações.

#### Controle de Bomba
Liga, desliga ou altera o modo de operação de uma bomba.
*   **Tópico:** `home/{tenant}/{home}/r/water.pump.cistern_pump_1/command`
*   **Payload:**
    ```json
    {
      "action": "START", // ou "STOP", "SET_MODE"
      "mode": "AUTO",    // opcional para SET_MODE
      "force": false
    }
    ```

#### Configuração Remota
Altera parâmetros do dispositivo em tempo de execução.
*   **Tópico:** `home/device/{username}/config`
*   **Payload (Parcial ou Completo):**
    ```json
    {
      "report_interval": 60, // Intervalo de reporte em segundos
      
---

## 4. Manifesto de Recursos (PROD)
No provisionamento, o dispositivo declara:
```json
{
  "resources": [
    { "id": "water.level.cistern", "kind": "water.level" },
    { "id": "water.pump.cistern_pump_1", "kind": "water.pump" },
    { "id": "water.pump.cistern_pump_2", "kind": "water.pump" }
  ]
}
```

## 5. Configuração Inicial e Provisionamento V2.4

1.  **Modo AP:** Se não houver contexto, cria rede `ICODZ_SETUP_{MAC}`.
2.  **Bootstrap:** App envia JSON via POST para `http://192.168.4.1/config` contendo `tenant`, `home` e Wi-Fi.
3.  **Registro MQTT:** O dispositivo se registra em `setup/{tenant}/{home}/registro`.
4.  **Operação:** Baixa ACLs e inicia em `home/{tenant}/{home}/r/...`.
