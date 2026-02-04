# CII - Casa Inteligente Icodz (Smart Home)
![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)


CII (Casa Inteligente Icodz) is a comprehensive IoT ecosystem designed for local-first automation, robust MQTT communication, and smart resource management. Originally developed for water storage monitoring and control (Cisterna), it has evolved into a modular smart home framework.

## 🚀 Core Principles (The System Constitution)

Our system is built on four non-negotiable pillars:

1.  **Local-First Sovereignty**: Critical logic resides in the device. MQTT carries **intent**, not obligation. Network failures **MUST NOT** compromise physical safety (safe-fail mandatory).
2.  **Asynchronous Truth**: A command (`.../command`) does **NOT** confirm execution. The only valid confirmation is an observable change in `.../state`. **Pessimistic UI**: Never anticipate success.
3.  **Security by Design (Zero Trust)**: No topic is trusted without explicit ACLs. Credentials are never hardcoded. Devices only publish to authorized topics via ACLs.
4.  **Separation of Concerns**:
    *   **Device**: Hardware + Local Logic.
    *   **Orchestrator**: Provisioning, ACLs, Metadata.
    *   *App**: UX, Labels, Rooms, Commands.

## 🛠 Technology Stack

*   **Firmware**: C++ / Arduino Framework via PlatformIO (ESP32/ESP8266).
*   **Frontend**: Flutter (Mobile/Desktop) — Clean Architecture + Riverpod 3.x.
*   **Backend**: Node-RED (Orchestration) + EMQX (Broker).
*   **Protocol**:
    *   Devices → **MQTTS** (TLS 8883)
    *   App → **WSS** (Secure WebSockets 8084)

## 📖 Documentation

The project documentation is organized to facilitate both technical implementation and high-level understanding.

### English Documentation
*   [English Documentation Index](docs/en/README.md) - Summary of architecture and principles.

### Documentação em Português (Original)
*   [Índice de Documentação (PT-BR)](docs/README.md)
*   [Princípios do Sistema](docs/01-principios/principios_sistema.md)
*   [Contrato MQTT V2.4](docs/03-protocolo/mqtt_topics_V2.4.md)
*   [Arquitetura Flutter](docs/05-app/architecture_flutterapp.md)

## 📡 MQTT Namespace (V2.4)

The communication follows a strict namespace structure:
`home/{tenant}/{home}/...`

Operational data flows through:
`home/{tenant}/{home}/r/{resource_id}/{leaf}`

| Leaf | Purpose | Retain |
| --- | --- | --- |
| `data` | Continuous Telemetry | YES |
| `state` | Resource Status | YES |
| `command` | Remote Action | NO |
| `config` | Operation Parameters | YES |
| `result` | Command Result | NO |

---

Developed with ❤️ by Icodz.
