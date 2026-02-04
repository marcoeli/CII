## Documento de Atualização — Migração para MQTT **V2.4** (Plano + Ajustes de Documentação)

**Status atual (premissas):**

- Broker (EMQX): pronto/seguro
- Orquestrador (Node-RED): V2.4 implementado (Provisionamento + ACL explícita + Meta Curator)
- Core docs V2.4: `mqtt_topics_V2.4.md`, `provisioning.md`, `acl_profiles.md` atualizados
- `mqtt_topics_V2.3.md`: manter como referência (não usar em produção V2.4)

* * *

# 1) Objetivo da migração

Padronizar todo o ecossistema para:

- **Multi-tenant / multi-casa** via namespace: `home/{tenant}/{home}/...`
- **Arquitetura por recurso**: `home/{tenant}/{home}/r/{resource_id}/{leaf}`
- **ACL por resource\_id explícito** (Zero Trust; sem wildcard em `r/{id}`)
- **Catálogo oficial de recursos** via meta retain:

    - `home/{tenant}/{home}/meta/resource/{resource_id}` (retain)

* * *

# 2) Mudanças contratuais que impactam código (resumo executivo)

### 2.1 Provisionamento

- Antes: `setup/registro` → Depois: `setup/{tenant}/{home}/registro`
- Manifesto obrigatório em PROD:

    - `resources: [{ id, kind }, ...]`

### 2.2 Telemetria / comando (novo padrão)

- Sai: `home/water/...`, `home/env/...`
- Entra:

    - `home/{tenant}/{home}/r/{resource_id}/data`
    - `home/{tenant}/{home}/r/{resource_id}/state`
    - `home/{tenant}/{home}/r/{resource_id}/command`
    - `home/{tenant}/{home}/r/{resource_id}/config`
    - `home/{tenant}/{home}/r/{resource_id}/result`

### 2.3 Meta (novo pilar para o app)

- `home/{tenant}/{home}/meta/resource/{resource_id}` (retain)
- Device **não publica** `meta/` (meta é do orquestrador/app)

* * *

# 3) Ajustes necessários na documentação “não-core”

Abaixo, o que cada documento deve refletir para não ficar divergente do core.

## 3.1 UI / App (Flutter)

### `docs/app_ui_blueprint.md`

**Atualizar para:**

- O app monta a UI a partir de:

    1. `meta/resource/#` (catálogo, labels, rooms, ícones)
    2. `r/+/state` e `r/+/data` (valores)
- O app **não depende mais** de domínios fixos `water/level`, `pump/...`
- Nova tela “Gerenciar recursos”:

    - lista recursos por `room`, por `kind`
    - editar `label/room/icon`
    - mostrar `device_id` e status (via `device/{username}/status`)
- “Descoberta”:

    - recursos entram via meta retain (não por adivinhar tópicos)
    - quando meta não existir, app pode exibir fallback (ex.: “Recurso sem cadastro”)

**Checklist de atualização:**

- <input disabled="" type="checkbox"> Remover referências diretas a `home/water/...` e `home/env/...`
- <input disabled="" type="checkbox"> Incluir fluxo: “carregar meta → agrupar → assinar state/data”
- <input disabled="" type="checkbox"> Definir regras de fallback de UI (sem label, room, ícone)

### `docs/app_ui_ux-espec.md`

**Atualizar para:**

- Termos e nomenclaturas:

    - “Dispositivo” ≠ “Recurso”
    - Recurso é o item de controle/telemetria que o usuário vê
- UX de renomeação:

    - renomeia `label` (meta), **não renomeia `resource_id`**
- Multi-casa:

    - seleção de `{tenant}/{home}` (trocar contexto muda prefixo MQTT)

**Checklist:**

- <input disabled="" type="checkbox"> UX de “selecionar casa” e persistência do contexto
- <input disabled="" type="checkbox"> Fluxo de “Recurso offline”: mostrar baseado em last-seen/estado do device

### `docs/architecture_flutterapp.md`

**Atualizar para:**

- Camadas:

    - `MqttService` com suporte a:

        - contexto `homePrefix = home/{tenant}/{home}`
        - subscriptions:

            - `.../meta/resource/#`
            - `.../device/+/status` (opcional)
            - `.../r/+/state` e `.../r/+/data`
- Modelo de dados:

    - `ResourceMeta { id, kind, label, room, deviceId }`
    - `ResourceState/Data` (por leaf)
- Estratégia de cache:

    - `meta` é retain → cache local (SQLite/Isar/Hive) e reidratação rápida

**Checklist:**

- <input disabled="" type="checkbox"> Novo “ResourceRepository” (meta + state/data)
- <input disabled="" type="checkbox"> Desacoplar UI de tópicos hardcoded

* * *

## 3.2 Firmware / ESP32

### `docs/cheklist_firmware.md`

**Atualizar para refletir V2.4:**

- Provisionamento:

    - publicar em `setup/{tenant}/{home}/registro`
    - enviar manifesto `resources[]` (id + kind)
    - receber `acls[]` e configurar subscriptions/publications somente dentro delas
- Publicação:

    - publicar apenas em tópicos que constam em `acls`
    - `retain` conforme regra do contrato (state/data SIM; command/event NÃO)
- Segurança:

    - rejeitar publish fora da ACL prevista (defesa no firmware: “não publico tópico não autorizado”)
- Persistência:

    - salvar credenciais e `homePrefix`

**Checklist (colocar no doc):**

- <input disabled="" type="checkbox"> Parser de `acls[]` e binding de publish/subscribe
- <input disabled="" type="checkbox"> Manifesto de resources compilado por hardware (const) + enviado no setup
- <input disabled="" type="checkbox"> Backoff exponencial em falha de provisionamento
- <input disabled="" type="checkbox"> LWT/heartbeat em `device/{id}/status` com retain

### `docs/firmware_architecture_esp32.md`

**Atualizar para:**

- módulos:

    - `ProvisioningClient` (setup V2.4)
    - `AclBinder` (interpreta `acls[]`)
    - `ResourceDrivers` (implementam pump/level/etc)
- mapear “driver → resource\_id” (imutável)

**Checklist:**

- <input disabled="" type="checkbox"> Remover lógica de “renomear tópico pelo app”
- <input disabled="" type="checkbox"> Fixar resource\_id como imutável; label fica no app/meta

### `docs/device_cisterna_specs.md` e `docs/device_spec_sheets.md`

**Atualizar para:**

- manifesto oficial do dispositivo:

    - lista de resources e seus kinds
    - exemplos de telemetria e state/command
- cenários:

    - cisterna com duas bombas e válvula:

        - `water.level.cistern`
        - `water.pump.cistern_pump_1`
        - `water.pump.cistern_pump_2`
        - `water.valve.cistern_inlet`
        - `water.flow.cistern_inlet` (opcional)
- quais leaves cada kind usa (data/state/command/config/result)

* * *

## 3.3 Infra / Node-RED

### `docs/INFRAESTRUTURA_BACKEND_BROKER.md`

**Atualizar para:**

- EMQX:

    - ACL explícita por resource
    - setup user com `setup/+/+/...`
- Node-RED:

    - provisionamento V2.4
    - meta curator flow (retain)
- Política:

    - device não publica meta



* * *

## 3.4 Sistema e Princípios

### `docs/principios_sistema.md`

**Atualizar para:**

- “resource\_id é imutável”
- “meta é a camada de UX; device é burro”
- “least privilege: ACL por resource”

### `docs/system_roles_and_responsibilities.md`

**Atualizar para:**

- responsabilidades:

    - device: hardware + drivers + state/data
    - orquestrador: provisionamento, ACL, meta curator
    - app: UX, labels, rooms, comandos (via command)

### `docs/hardware_map.md`

**Atualizar para:**

- mapear pinos/slots → resource\_id (imutável)
- exemplo: relay1 = `water.pump.cistern_pump_1`

### `docs/ota_strategy.md`

**Atualizar para:**

- OTA target deve continuar fora de `r/` (conforme seu core)
- mas incluir o `homePrefix` no contexto quando aplicável (se o OTA topic for namespaced)

* * *

# 4) Plano de implementação (para devs) — migração V2.4

## Fase 0 — Congelar contrato e “Definition of Done”

- Fonte única:

    - `mqtt_topics_V2.4.md`
    - `provisioning.md`
    - `acl_profiles.md`
- “Proibido” no código novo:

    - qualquer publish/subscribe em `home/water/#` e `home/env/#`
    - wildcard em `r/{id}` no lado do device

**DoD da fase:**

- build passa com V2.4 compilado no firmware e app

* * *

## Fase 1 — Firmware (primeiro, porque sem ele não valida)

1. Implementar setup V2.4:

    - publicar em `setup/{tenant}/{home}/registro`
    - enviar manifesto `resources[{id,kind}]`
2. Implementar binder de ACL:

    - device só assina/publica o que está em `acls[]`
3. Publicar:

    - `device/{id}/status` (retain)
    - `r/{resource_id}/data|state` conforme kind
4. Testes:

    - provar que device A não publica no resource do device B (negação de ACL)

**DoD:**

- device provisiona e opera 100% usando `r/`
- tentativa de publish fora da ACL falha no broker

* * *

## Fase 2 — App Flutter (UI baseada em meta)

1. Implementar `ResourceMetaRepository`:

    - subscribe `meta/resource/#` (retain)
    - persistir local
2. Implementar `ResourceTelemetryRepository`:

    - subscribe `r/+/state`, `r/+/data`
3. Atualizar telas:

    - dashboard por `room` e `kind`
    - edição de `label/room/icon` (definir mecanismo: direto em meta ou via request)
4. Remover dependências V2.3

**DoD:**

- app mostra recursos mesmo sem “configurar nomes no device”
- labels/rooms persistem via meta retain

* * *

## Fase 3 — Automations Node-RED (migrar water/env)

1. Reescrever automations para ler `r/`:

    - exemplo: controle de bomba:

        - input: `r/water.level.* /data`
        - output: `r/water.pump.* /command`
2. Usar `meta/resource` para localizar recursos por kind/room (opcional, mas recomendado)

**DoD:**

- automações funcionam sem tópicos V2.3

* * *

## Fase 4 — Limpeza / Remoção de V2.3 do runtime

- manter `mqtt_topics_V2.3.md` só como referência
- bloquear subscriptions/publicações V2.3 no app e firmware
- revisar ACL profiles para remover restos

**DoD:**

- nenhum cliente usa `home/water/#` em produção V2.4

* * *

# 5) Instruções curtas para o time (mensagem “mandatória”)

**Regra de ouro V2.4:**

1. `resource_id` é imutável. Nome humano = `meta.label`.
2. Device só publica/assina o que vier em `acls[]`.
3. App constrói UI a partir de `meta/resource/#` + `r/+/state|data`.
4. Não existe wildcard em `r/{id}` para devices.

* * *

# 6) Entregáveis esperados por arquivo (lista de tarefas)

- `app_ui_blueprint.md`: trocar para “UI baseada em meta/resources”
- `app_ui_ux-espec.md`: separar dispositivo vs recurso; renomear via meta
- `architecture_flutterapp.md`: repositórios meta + telemetry + cache; multi-home context
- `cheklist_firmware.md`: setup V2.4 + manifesto + ACL binder + retain correto
- `device_cisterna_specs.md`: manifesto oficial cisterna + exemplos `r/`
- `device_spec_sheets.md`: manifesto por device + kinds/leaves
- `firmware_architecture_esp32.md`: módulos Provisioning + AclBinder + Drivers
- `hardware_map.md`: pino/slot → resource\_id
- `INFRAESTRUTURA_BACKEND_BROKER.md`: setup ACL + meta curator + política meta
- `ota_strategy.md`: alinhar com V2.4 (namespacing e regras)
- `principios_sistema.md`: imutabilidade resource\_id + least privilege
- `system_roles_and_responsibilities.md`: responsabilidades por componente

**🚨 MIGRAÇÃO OBRIGATÓRIA — MQTT V2.4 (LEIA ANTES DE CODAR)**

1. **V2.4 é o padrão ativo.** V2.3 é somente consulta.
2. **Namespace único:** `home/{tenant}/{home}/...`
3. **Arquitetura por recurso:** tudo opera em `home/{tenant}/{home}/r/{resource_id}/...`
4. **`resource_id` é IMUTÁVEL.** Nome humano vai em `meta.label`.
5. **Provisionamento:** publicar em `setup/{tenant}/{home}/registro`.
6. **PROD exige manifesto:** `resources[{ id, kind }]`.
7. **ACL é explícita por resource.** Sem wildcard em `r/{id}` para devices.
8. **Firmware:** só publica/assina tópicos presentes em `acls[]`.
9. **Retain:** `state` e `data` = SIM | `command` e `event` = NÃO.
10. **Heartbeat:** `device/{id}/status` (retain).
11. **Meta:** `meta/resource/{resource_id}` é criado pelo orquestrador (retain).
12. **Device NÃO publica meta.**
13. **App:** constrói UI a partir de `meta/resource/#`.
14. **App:** assina `r/+/state` e `r/+/data`.
15. **Renomear recurso = editar meta, nunca tópico.**
16. **Automations:** migrar de `home/water/#` para `home/.../r/#`.
17. **Multi-casa:** trocar `{tenant}/{home}` troca o sistema inteiro.
18. **Segurança:** publicar fora da ACL = ERRO.
19. **Firmware:** não “adivinha” tópicos. Usa ACL recebida.
20. **Node-RED:** responsável por provisionamento, ACL e meta curator.
21. **App:** responsável por UX, labels, rooms, ícones.
22. **Device:** responsável só por hardware e lógica local.
23. **Não criar exceções locais.** Contrato é lei.
24. **Novo device = novo manifesto.**
25. **Novo recurso = novo `resource_id`.**
26. **Nunca reutilizar `resource_id` para outro hardware.**
27. **Logs e debug sempre em contexto `{tenant}/{home}`.**
28. **Código novo NÃO usa V2.3.**
29. **Dúvida? Consulte:** `mqtt_topics_V2.4.md`.
30. **Descumprimento bloqueia merge.**

✔️ **Sem exceções. Sem atalhos.**