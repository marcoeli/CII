# Estratégia de OTA, Versionamento e Rollout V1.0

**Projeto:** Automação Residencial  
**Objetivo:** Garantir atualização segura, controlada e reversível dos dispositivos ESP32, sem comprometer automações críticas.

---

## 1. Princípios Obrigatórios

- **Fail-safe:** Atualização nunca pode quebrar funções críticas (ex.: controle de bomba).
- **Rollback automático:** Firmware inválido deve reverter sem intervenção humana.
- **Controle de rollout:** Nem todos os dispositivos atualizam ao mesmo tempo.
- **Compatibilidade contratual:** Firmware só pode ser atualizado se compatível com o contrato MQTT vigente.
- **Zero confiança em sucesso:** OTA só é considerado concluído após confirmação explícita do device.

---

## 2. Modelo de Versionamento

### 2.1 Versão de Firmware (SemVer)
**Formato:** `MAJOR.MINOR.PATCH`

| Campo | Regra |
| :--- | :--- |
| **MAJOR** | Quebra contrato MQTT ou lógica de automação |
| **MINOR** | Nova funcionalidade compatível |
| **PATCH** | Correção de bug |

**Exemplo:** `2.1.4`

### 2.2 Versão de Contrato MQTT
O contrato MQTT tem versionamento próprio.
**Formato:** `MQTT_CONTRACT = vX`

**Exemplo:**
- Firmware 1.x → MQTT v2
- Firmware 2.x → MQTT v3

**Regra obrigatória:**
Device só aceita OTA se `firmware_suporta(contract_version)`.
Essa informação deve constar:
- no payload de OTA
- e internamente no firmware

---

## 3. Tipos de Atualização

### 3.1 Atualização Individual
Aplicada a um único device (debug, correção pontual).

### 3.2 Atualização por Grupo
Aplicada a:
- todos os devices de um `type`
- ou de um `location`
- ou de um perfil ACL

### 3.3 Atualização Global
Aplicada a todos os dispositivos compatíveis.
**Regra:** nunca usar rollout global sem fase de canário.

---

## 4. Fluxo de OTA

### 4.1 Publicação do Comando OTA
- **Tópico:** `home/device/{username}/ota`
- **Payload:**
```json
{
  "version": "1.3.0",
  "contract": "v2",
  "url": "https://fw.icodz.com.br/water_sensor_1.3.0.bin",
  "sha256": "....",
  "rollout_id": "2026-01-water-sensor",
  "mandatory": false
}
```

### 4.2 Estados de OTA (Publicados pelo Device)
- **Tópico:** `home/device/{username}/status`
- **Campo adicional:**
```json
{
  "ota": {
    "state": "DOWNLOADING | VERIFYING | INSTALLING | REBOOTING | OK | FAILED | ROLLBACK",
    "version_target": "1.3.0",
    "rollout_id": "2026-01-water-sensor",
    "error": null
  }
}
```

---

## 5. Regras de Segurança no Device

### 5.1 Pré-condições Obrigatórias
Device não pode iniciar OTA se:
- estiver executando função crítica (ex.: bomba ligada)
- estiver em estado de erro crítico
- estiver com bateria baixa (se aplicável)

Se não puder atualizar:
- publica `status` com `state=DEFERRED`

### 5.2 Validações Obrigatórias
Antes de instalar:
- validar HTTPS
- validar SHA256
- validar compatibilidade de contrato

Se falhar:
- abortar OTA
- publicar erro

### 5.3 Self-Test Pós-Boot
Após reboot:
- firmware executa testes mínimos:
    - sensores acessíveis
    - loop principal funcionando
    - só então confirma OTA como OK

Se falhar:
- aciona rollback automático

---

## 6. Estratégia de Rollout (Implantação Gradual)

### 6.1 Fases
1. **Canário:** 1 ou poucos devices.
2. **Grupo Controlado:** mesmo `type` ou `location`.
3. **Produção:** todos os compatíveis.

### 6.2 Regras de Avanço
Orquestrador (Node-RED / backend) só avança se:
- % mínimo de sucesso na fase atual.
- nenhum erro crítico detectado.

**Exemplo:**
- ≥ 95% sucesso → avançar
- rollback detectado → parar rollout

---

## 7. Políticas de Atualização

### 7.1 Atualização Automática
Permitida para:
- `PATCH`
- `MINOR` (se não afetar automação crítica)

### 7.2 Atualização Manual / Aprovada
Obrigatória para:
- `MAJOR`
- mudanças em lógica de atuadores

Deve exigir ação explícita do administrador (painel/app).

### 7.3 Mandatory Update
Campo `mandatory=true` no payload.
Usado quando:
- há falha de segurança
- bug crítico que compromete operação

Device deve:
- tentar atualizar assim que possível
- mas ainda respeitar pré-condições de segurança

---

## 8. Gestão de Artefatos de Firmware

### 8.1 Repositório
Firmware deve ser hospedado em:
- HTTPS
- com versionamento imutável

**Exemplo:**
- `/firmware/water_sensor/1.3.0.bin`
- `/firmware/water_sensor/1.3.0.sha256`

### 8.2 Retenção
**Política mínima:** Manter últimas 3 versões por tipo de device.

---

## 9. Auditoria e Rastreabilidade

Cada OTA deve ser rastreável por:
- `rollout_id`
- versão
- timestamp
- resultado por device

Esses dados devem ser armazenados no backend (não só no broker).

---

## 10. Critérios de Aceite (para times de firmware)

- Device ignora OTA incompatível com contrato.
- Device não atualiza durante operação crítica.
- OTA inválido gera rollback automático.
- Status de OTA é publicado em todas as fases.
- Após OTA, status final é `OK` ou `ROLLBACK`.

---

## 11. Responsabilidades por Componente

### Dispositivo ESP32
- validar segurança
- executar OTA
- reportar estado real

### Node-RED / Backend
- decidir quem recebe OTA
- controlar fases de rollout
- interromper se houver falhas

### App / Painel
- apenas inicia campanhas (não executa OTA diretamente)

---

## 12. Regra de Ouro

> **OTA é um processo de produto, não um recurso técnico.**
> Nunca deve ser tratado como simples "download de binário".
