---
name: CII Project Documentation
description: Orientação estruturada para consulta da documentação técnica e arquitetural do projeto CII (Casa Inteligente IoT).
---

# Skill: Consultar Documentação CII

Esta skill orienta o agente a navegar de forma eficiente pela documentação do projeto CII, garantindo que as decisões técnicas estejam alinhadas com a Constituição do Projeto (V2.4).

## 📂 Ponto de Entrada
Sempre comece consultando o arquivo de índice principal:
- [README.md](file:///d:/Projects/CII/docs/README.md)

## 🗺️ Estrutura de Pastas

| Pasta | Conteúdo Principal | Documentos Chave |
| :--- | :--- | :--- |
| `01-principios/` | Filosofia e Regras de Negócio | `principios_sistema.md`, `system_roles_and_responsibilities.md` |
| `02-arquitetura/` | Infraestrutura e Redes | `INFRAESTRUTURA_BACKEND_BROKER.md`, `ota_strategy.md` |
| `03-protocolo/` | Contrato MQTT e Provisionamento | `mqtt_topics_V2.4.md`, `provisioning.md`, `acl_profiles.md` |
| `04-firmware/` | Hardware e ESP32 | `hardware_map.md`, `firmware_architecture_esp32.md` |
| `05-app/` | Flutter e UI/UX | `architecture_flutterapp.md`, `app_ui_ux-espec.md` |

## 🛠️ Procedimento de Consulta

1. **Entenda o Contexto**: Identifique se a tarefa é de Firmware, App, Protocolo ou Arquitetura.
2. **Localize o Documento**: Utilize o [README.md](file:///d:/Projects/CII/docs/README.md) para encontrar o caminho absoluto do arquivo necessário.
3. **Valide com a Constituição**: Antes de qualquer implementação, verifique se a proposta não viola as "Regras Inquebráveis" definidas na **Regra Mestra do Projeto (V2.4)**.
4. **Links Relativos**: Ao citar documentos em outros arquivos de documentação, prefira usar caminhos relativos ou links absolutos formatados com a estrutura de pastas atualizada.

## ⚠️ Regras Cruciais
- **NÃO invente tópicos MQTT**. Consulte sempre o `mqtt_topics_V2.4.md` na pasta `03-protocolo`.
- **NÃO ignore o Hardware Map**. Consulte `hardware_map.md` em `04-firmware` antes de sugerir mudanças de pinagem.
- **Siga o Clean Architecture** no App Flutter, conforme detalhado em `05-app/architecture_flutterapp.md`.
