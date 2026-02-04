# Diretrizes de Operação MQTT - Projeto CII (V2.4)

> [!NOTE]
> Este documento define o "Contrato Operacional" sugerido para dispositivos e orquestrador. O objetivo é garantir escalabilidade, economia de banda e facilidade de depuração.

## 1. Classes de Mensagens e Cadência

| Tópico (`leaf`) | Retain | QoS | Gatilho de Envio | Objetivo |
| :--- | :--- | :--- | :--- | :--- |
| `status` | **SIM** | 1 | Boot, troca de config, heartbeat lento (60-300s) | Descoberta e inventário |
| `state` | **SIM** | 1 | **Edge-trigger** (mudança imediata) + Refresh (60-300s) | UI e lógica de automação |
| `data` | Depende | 0/1 | **Delta Threshold** + Intervalo Máximo | Telemetria e Analytics |
| `command` | NÃO | 1 | Ação do usuário ou orquestrador | Controle remoto |
| `result` | NÃO | 1 | Imediatamente após execução do comando | Auditoria e Feedback UI |

## 2. Regras de Otimização (Padrão Ouro)

### 2.1 "Mudou então Publica" (Edge-Trigger)
Dispositivos não devem fazer spam de mensagens idênticas. Mantenha o último hash enviado em RAM e publique apenas se houver mudança significativa.

### 2.2 Delta + Intervalo (Para `/data`)
Para sensores (nível, temperatura, etc.), a telemetria deve seguir a regra:
- **Publica se:** `abs(valor_atual - valor_anterior) >= threshold`
- **OU se:** `tempo_desde_ultimo_envio >= max_interval` (ex: 30s)

### 2.3 Normalização Numérica
Evite precisão infinita de ponto flutuante que gera ruído de rede.
- **Percentuais:** Máximo 2 casas decimais (ex: `31.72`).
- **Dimensões/Níveis:** Máximo 1 casa decimal (ex: `136.6`).

### 2.4 Timestamps Canônicos
- Use o campo `ts` (Unix Epoch em segundos) dentro do payload JSON como fonte única de verdade para ordenação.
- O timestamp ISO no envelope MQTT deve ser usado apenas para logs de transporte.

### 2.5 Correlação de Comandos
Todo comando (`/command`) deve conter um `correlation_id` (UUID curto). O dispositivo **DEVE** replicar esse ID no tópico `/result` correspondente para que a UI possa confirmar a ação de forma inequívoca.

## 3. Atuadores (Bombas e Válvulas)
- **Data é opcional:** Evite tópicos `/data` que contenham apenas `ts`.
- **Métricas úteis:** Se usar `/data` para atuadores, inclua dados como `runtime_s`, `start_count` ou `current_a`. Caso contrário, use apenas `/state`.

---
*Documento de Referência Técnica - V2.4*
