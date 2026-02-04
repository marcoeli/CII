# Copilot Instructions for CII Monorepo

## Visão Geral
Este repositório contém múltiplos projetos para uma solução de automação residencial, incluindo firmware ESP32 (ESP-IDF/PlatformIO) e um aplicativo Flutter. Cada subdiretório representa um contexto de build e domínio diferente.

## Estrutura dos Projetos
  - `cisterna/`: Firmware ESP32, organizados em:
  - `main/`: Lógica principal (WiFi, MQTT, Config, State, OTA)
  - `components/`: Drivers (actuators, sensors, display, utils)
  - `docs/`: Documentação técnica
  - Build via PlatformIO (VSCode recomendado)
  - `flutter/`: Aplicativo Flutter para interface do usuário
  - `lib/`: Código Dart principal
  - `test/`: Testes unitários
  - `android/`, `ios/`, `web/`, etc.: Plataformas suportadas

## Fluxos de Desenvolvimento
### Firmware ESP32
- Use o PlatformIO no VSCode para build/upload.
- Configurações customizadas em `platformio.ini` e arquivos `sdkconfig.*`.
- Lógica de dispositivos, conectividade e atualização OTA estão em `main/`.
- Drivers customizados ficam em `components/`.
- Documentação relevante em `docs/`.

### Flutter App
- Build/test padrão Flutter (`flutter run`, `flutter test`).
- Organização modular em `lib/app/modules/` e `lib/app/shared/`.
- Siga padrões de navegação e gerenciamento de estado já presentes.

## Convenções Específicas
- Código C do firmware segue separação clara entre lógica de aplicação (`main/`) e drivers/utilitários (`components/`).
- Configurações de build e partições são customizadas por hardware (veja arquivos `sdkconfig.*` e `partitions.csv`).
- Documentação de tópicos MQTT e guidelines de firmware em `docs/`.

## Integrações e Comunicação
- Comunicação entre firmware e app via MQTT (tópicos documentados em `docs/mqtt_topics.md`).
- Atualização OTA implementada no firmware (`app_ota.c`).
- O app Flutter consome dados do backend MQTT e exibe na interface.

## Exemplos de Arquivos-Chave
- Firmware: `main/app_mqtt.c`, `main/app_ota.c`, `components/sensors/`, `platformio.ini`
- Flutter: `lib/main.dart`, `lib/app/modules/`, `pubspec.yaml`
- Documentação: `docs/acl_profiles.md`, `docs/mqtt_topics.md`, `docs/app_ui_blueprint.md`, `docs/app_ui_ux-espec.md`, `docs/architecture_flutterapp.md`, `docs/device_spec_sheets.md`, `docs/firmware_architecture_esp32.md`, `docs/ota_strategy.md`, `docs/provisioning.md`,`doc/system_roles_and_responsibilities.md`, etc.

## Dicas para Agentes AI
- Sempre consulte os arquivos de documentação antes de propor mudanças em fluxos de comunicação ou arquitetura.
- Respeite a separação de responsabilidades entre camadas e componentes.
- Prefira reutilizar padrões já presentes no código.
- Para builds, use sempre as ferramentas e comandos recomendados (PlatformIO para firmware, CLI do Flutter para app).
