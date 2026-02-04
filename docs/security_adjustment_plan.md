# Plano Unificado de Ajuste de Segurança e Autenticação
## Projeto CII — Contrato V2.4

### 1. Objetivo do Documento
Este documento define as mudanças obrigatórias de segurança e autenticação no Projeto CII com três objetivos claros:
- Elevar o nível de segurança para um padrão profissional.
- Permitir publicação do projeto no GitHub sem exposição de dados sensíveis.
- Alinhar App e Simulador ao modelo de provisionamento já utilizado pelos dispositivos ESP32, sem introduzir backend adicional.

Este documento descreve o comportamento real atual do sistema e como o App deve ser implementado para funcionar hoje e estar preparado para evoluções futuras.

### 2. Estado Atual do Provisionamento (FATO TÉCNICO)
⚠️ **Importante — Este é o comportamento real do sistema hoje**

- O **claim code** é gerado pelo orquestrador (painel administrativo).
- O claim code **NÃO** é validado pelo fluxo de provisionamento.
- O reprovisionamento **NÃO** exige novo claim code, inclusive em modo PROD.
- **O orquestrador:**
  - cria/atualiza usuários no broker;
  - cadastra ACLs no broker;
  - devolve credenciais finais ao cliente.

A segurança efetiva atual vem de:
- ACL mínima do usuário `setup`;
- escopo das ACLs criadas pelo orquestrador;
- enforcement feito exclusivamente pelo broker.

O claim code hoje é controle operacional/manual, não um gate de segurança.

### 3. Vulnerabilidades Identificadas

#### 3.1 Firmware (ESP32 – Cisterna)
- **Arquivo:** `Cisterna/include/config.h`
- **Vulnerabilidades:** `DEV_TOKEN` hardcoded, `SETUP_MQTT_PASSWORD` visível, `WIFI_AP_PASSWORD` hardcoded.
- **Risco:** Extração direta de credenciais a partir do código-fonte ou binário.

#### 3.2 Simulador
- **Arquivo:** `simulator/lib/core/services/mqtt_simulator_service.dart`
- **Vulnerabilidades:** Host, porta e credenciais `setup` hardcoded.
- **Risco:** Exposição direta de credenciais no repositório público.

#### 3.3 App (Ponto Crítico)
- **Vulnerabilidade:** App conecta ao broker com usuário superadministrador. Não existe escopo por tenant ou home.
- **Risco:** O app contorna completamente o modelo de segurança do sistema.

#### 3.4 Arquivos Sensíveis
- Certificados (`.pem`) e possíveis chaves privadas. Devem ser sempre excluídos do repositório público.

### 4. Modelo de Segurança Alvo
| Componente | Modelo de Autenticação |
| --- | --- |
| **ESP32** | Setup → Orquestrador → Credencial final por HOME |
| **Simulador** | Igual ao ESP32 (device-like) |
| **App** | Setup → Orquestrador → Credencial final por TENANT |
| **Broker** | Fonte da verdade (enforcement de ACL) |
| **Claim Code** | Operacional hoje / Enforcement futuro |

### 5. Novo Modelo de Autenticação do App (OBRIGATÓRIO)

#### 5.1 Proibição imediata
❌ **O App não pode mais usar usuário superadministrador do broker.**

#### 5.2 Fluxo correto do App
1.  **Bootstrap (Setup):** O App conecta ao broker usando `setup_user` / `setup_pass`. Este usuário possui ACL mínima, limitada aos tópicos de provisionamento (`setup/...`). Em ambiente PROD, o claim code é informado ao App pelo usuário.
2.  **Provisionamento:** O App envia o pedido de registro ao orquestrador. O payload inclui o claim code. O orquestrador cria/atualiza o usuário, cadastra ACLs e responde com credenciais finais.
3.  **Escopo da Credencial do App:** A credencial final do App é **TENANT-WIDE** (`home/{tenant}/+/...`). O App pode acessar múltiplas homes na mesma tenant, mas não cross-tenant.
4.  **Persistência Local:** O App armazena credenciais finais **exclusivamente** via `flutter_secure_storage`. Nunca em código, `.env` ou `SharedPreferences`.
5.  **Reprovisionamento:** Em erro de autenticação, apagar credenciais locais da tenant e reiniciar bootstrap.

### 6. Regras Obrigatórias para Devs (App)
- ❌ Proibido hardcode de qualquer senha real.
- ❌ Proibido logar: claim code, username/password, payload de provisionamento.
- **Escopo:** 1 credencial = 1 tenant. Troca de tenant ⇒ novo provisionamento.
- **Transporte:** TLS sempre que disponível.

### 7. Simulador
- O simulador continua funcionando como device, recebendo credenciais via NVS simulado.
- ❌ O simulador **NÃO** pode usar perfil de App ou credencial tenant-wide.

### 8. Remoção de Segredos do Código
- **Firmware:** Criar `secrets.h` (ignorado pelo git). `config.h` usa apenas placeholders. Versionar apenas `secrets.h.example`.
- **Flutter (App e Simulador):** Usar `flutter_dotenv` para variáveis de ambiente (não substitui `flutter_secure_storage`). `.env` nunca versionado.

### 9. Publicação no GitHub
- Nenhum segredo em código, JSON, assets ou fixtures.
- Se qualquer segredo já foi commitado: Rotacionar credenciais e criar repositório limpo (resetar histórico).

---

### 📋 Checklist de PR / Definition of Done

#### 1. Requisitos Gerais
- [ ] Nenhum segredo hardcoded.
- [ ] Nenhum segredo em logs ou mensagens de erro.
- [ ] `.gitignore` cobre `.env`, `.pem`, `.key`, `secrets.h`.
- [ ] Existe `.env.example` ou `secrets.h.example`.

#### 2. App Flutter
- [ ] ❌ App NÃO usa superusuário.
- [ ] Implementa bootstrap via `setup_user`.
- [ ] Envia claim code no provisionamento (em PROD).
- [ ] Credenciais finais são TENANT-WIDE.
- [ ] Uso exclusivo de `flutter_secure_storage` para segredos.
- [ ] Erro de auth força limpeza e reprovisionamento.

#### 3. Simulador
- [ ] Continua device-like.
- [ ] Credenciais via NVS simulado.
- [ ] Setup via `.env` (não hardcoded).

#### 4. Firmware ESP32
- [ ] ❌ Sem credenciais em `config.h`.
- [ ] `secrets.h` utilizado e ignorado pelo git.
- [ ] Credenciais finais vêm do NVS, nunca do binário.

#### 5. GitHub & DoD
- [ ] Segredos antigos rotacionados.
- [ ] Histórico Git limpo se necessário.
- [ ] Build/clone limpo não exige segredos para compilar.
