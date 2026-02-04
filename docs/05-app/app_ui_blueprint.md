# Blueprint de UI (Flutter) V1.0

> [!IMPORTANT]
> **Nota Arquitetural V2.4 — Importante para UX**
>
> 1. **O App é o detentor do contexto.** O App conhece `tenant`, `home` e usuário antes do device.
> 2. **Provisionamento é um ato consciente.** O App injeta contexto no hardware (SoftAP) — o device não “se auto-registra”.
> 3. **UI nunca depende de nomes técnicos.** `resource_id` é técnico e imutável. Labels, ícones e agrupamentos vêm somente de `meta/resource`.
> 4. **Descoberta = leitura, não inferência.** O App monta a UI a partir de `meta/resource/#` e `device/+/status`.
>
> *Se a UI precisar “adivinhar”, o contrato foi violado.*

**Projeto:** Automação Residencial  
**Objetivo:** Especificar a UI/UX do app (simples, bonita e animada para uso cotidiano; poderosa para operação e diagnóstico), sem dependência de “cadastro manual de devices”.  
**Escopo:** Mobile (Android) / Desktop(Windows).

---

## 1. Princípios de UX

- **Simples para uso cotidiano:** as ações comuns precisam estar a 1–2 toques.
- **Bonito e animado:** microanimações discretas (transições, estados, badges), sem poluição.
- **Sem “otimismo”:** comando nunca é “confirmado” até refletir no state.
- **Modo Offline útil:** manter visão com dados retidos + indicação de desatualização.
- **Progressive disclosure:** o básico aparece primeiro; o técnico fica em telas de “Gestão/Dev”.

---

## 2. Navegação (estrutura base)

### 2.1 Bottom Navigation (4 abas)

- **Casa**
- **Água**
- **Ambiente**
- **Eventos**

### 2.2 Ações globais (Top bar)

- 🔍 Buscar
- ⭐ Favoritos
- ⚙️ Configurações
- 🛠️ Dev (aparece somente após desbloqueio)

---

## 3. Cabeçalho “Vivo” (1/3 superior da tela)

### 3.1 Objetivo

Um cabeçalho persistente que resume saúde do sistema e reage a alarmes/notificações.

### 3.2 Conteúdo (sempre visível)

- Estado do sistema: **OK / Atenção / Crítico**
- Broker/Servidor: **Conectado / Reconectando / Offline**
- Dispositivos: **Online X / Total Y**
- Indicador de alarmes ativos: **contagem + ícone**

### 3.3 Comportamento reativo

- **OK (normal):** cabeçalho compacto (~15% da tela)
- **Atenção:** destaca em cor e mostra “ver detalhes”
- **Crítico:** expande (até ~1/3), exibe CTA principal “Ver alerta”
- **Offline:** muda para “Modo Offline” + “dados podem estar desatualizados”

---

### 3.4 Notificações (hoje e futuro)

- **Hoje (app aberto):** feedback visual + opcional vibração/áudio (configurável).
- **Futuro (app fechado / Windows/Android):** arquitetura deve permitir push/local notifications:
  - eventos críticos geram notificação do sistema
  - clique abre a tela de “Alertas”
  - *(Implementação futura, mas o design já prevê o fluxo.)*

---

## 4. Aba “Casa” (Home) — visão diária + acesso rápido

*Ajuste solicitado: “Dashboard do usuário” vira Casa = visão cotidiana; e a parte técnica vai para Gestão/Relatórios (seção 4.3).*

### 4.1 Seção A — Atalhos principais (cards grandes)

Cards com ícones grandes, animação leve no hover/press:

- Água (níveis + alertas)
- Ambiente (cozinha: temp/gás + alertas)
- Eventos (últimos eventos e alarmes)

Cada card mostra:

- valor principal
- estado (badge)
- “última atualização”

---

### 4.2 Seção B — Ações rápidas (contextuais) deprecated

Aparecem conforme o sistema:

- “Ver alertas”
- “Ir para bomba que está ON”
- “Ver dispositivos offline”
- “Silenciar alertas locais” (se existir no contrato)
- “Ações favoritas” (curadoria do usuário)

---

### 4.3 Seção C — Relatórios e gráficos (não crítico, mas poderoso) virou card de gráficos

Uma área “Insights” para você:

- Gráfico de nível (últimas horas/dia)
- Histórico de acionamento de bombas
- Tendência de consumo (derivada de nível vs tempo)
- “Anomalias” (ex.: bomba acionou muitas vezes)

*Nota: esta seção pode iniciar simples (mini-gráficos) e evoluir.*

---

## 5. Aba “Água” — operação hidráulica

### 5.1 Layout

Topo com chips de visualização:

- Por Local
- Por Tipo
- Por Dispositivo

### 5.2 Por Local (padrão)

Cards: Cisterna, Caixa Sobrado, Caixa Edícula, etc.  
Cada card:

- percent/litros
- alerta
- botão “Detalhes”

### 5.3 Por Tipo

- Reservatórios (lista)
- Bombas (lista)

### 5.4 Por Dispositivo (gestão rápida)

Lista com:

- nome amigável
- online/offline
- “bomba(s)” associadas (se aplicável)
- “última atualização”

### 5.5 Tela: Detalhe do Reservatório

- Percentual e litros (destaque)
- Gráfico (mini) + expandir
- Indicador de staleness
- Botão: “Bombas relacionadas”

### 5.6 Tela: Detalhe da Bomba (controle)

- Estado: ON/OFF
- Modo: AUTO/MANUAL/LOCKED
- Reason
- Botões START/STOP + toggle “force”
- Estado “PENDENTE” após comando (até refletir no state)
- Timeout visual 

---

## 6. Aba “Ambiente” — clima e segurança

### 6.1 Layout

Chips:

- Por Local
- Por Tipo
- Por Dispositivo

### 6.2 Cards por local

- Temperatura/umidade
- Qualidade do ar/gás (badge)
- “última atualização”

### 6.3 Tela: Detalhe do Local

- Indicadores grandes
- Gráfico simples (opcional)
- Histórico de alertas (últimos N)

---

## 7. Aba “Eventos” — feed e alarmes

### 7.1 Layout

Subtabs:

- Alertas
- Eventos
- Presença

### 7.2 Alertas (prioridade)

Lista de alertas ativos/recorrentes com:

- severidade
- origem (local/device)
- timestamp
- CTA: “abrir origem”

### 7.3 Eventos

Feed cronológico:

- campainha
- notificações do sistema
- eventos pontuais

### 7.4 Presença

Lista por local com estado atual (retained) e “última detecção”.

---

## 8. Tela “Dispositivos” (Gestão técnica)

*Esta tela é a “dashboard de dispositivos” mencionada.*

### 8.1 Objetivos

- Ver parque de dispositivos com saúde e capacidades
- Diagnóstico rápido (online/offline, atraso, firmware)
- Acesso às configurações do device

### 8.2 Visualizações

Tabs:

- Resumo
- Lista
- Mapa por Local (grid)

### 8.3 Item de dispositivo (card)

- Ícone do tipo + nome amigável
- status (online/offline)
- local
- firmware
- capabilities (chips)
- staleness (“atualizado há X min”)

Ações no card:

- “Detalhes”
- Favoritar
- Atalho de comandos (se permitido)

---

## 9. Tela “Detalhe do Dispositivo” (comandos + diagnóstico)

### 9.1 Seções

- Resumo
  - status, fw, uptime, rssi, last seen
- Capacidades
  - chips + quick links (ex.: se tem bomba, ir para controle)
- Configurações
- Diagnóstico
- Atualizações (OTA)
- Logs (light)

### 9.2 Comandos e configurações suportadas

Além do que já estava:

- Alterar Wi-Fi (se existir no contrato/config do firmware)
- Reboot remoto (se existir no contrato)
- Solicitar status imediato (se existir)
- Verificar atualização disponível (mostra se firmware alvo > atual)
- Aplicar config (validações e preview)

> Importante: esses comandos só entram se constarem em contrato. A UI deve ser “feature-gated” pelas capabilities.

### 9.3 OTA (UI)

- Mostra versão atual e alvo
- Mostra estado do OTA (downloading/verifying/etc.)
- Permite iniciar campanha quando aplicável (não executa binário)

---

## 10. Tela “Dev” (restrita)

### 10.1 Acesso

- Menu Configurações → “Desbloquear Dev”
- Senha local (armazenamento seguro)
- Pode ter “timeout” (ex.: expira após X horas)

### 10.2 Conteúdo Dev

- MQTT Inspector (somente leitura)
- Console de mensagens (filtro por tópico)
- Staleness map
- Ferramentas de simulação

### 10.3 Dispositivos fictícios (ajuste conforme solicitado) deprecated foi criado um app a parte para isso

- Não há botão “Criar dispositivos”.

O app terá uma única entrada: “Modo Simulação (solução atual do time)”

- quando ativado, a UI passa a receber dados do simulador existente
- o blueprint não redefine como o simulador funciona; apenas prevê o toggle

---

## 11. UX: níveis de simplicidade (para “vó” e para você)

### 11.1 Modo Simples (default)

- Casa / Água / Ambiente / Eventos por Local
- Botões grandes
- Sem IDs técnicos, sem username, sem pump_id
- Ações limitadas e seguras

### 11.2 Modo Avançado

Habilita:

- Dispositivos (Gestão técnica)
- Relatórios avançados
- Diagnóstico

### 11.3 Modo Dev

- Somente após senha local
- Ferramentas internas e simulação

---

## 12. Regras de UI que o time não deve quebrar

- Comando não confirma: confirmação é sempre o state.
- Staleness sempre visível quando dados antigos.
- Offline não “zera” UI: mantém dados retidos e sinaliza.
- Nada de editar tópico manualmente na UI.
- Feature gating: se o device não tem capability, a UI não mostra botões.

---

## 13. Itens para backlog do time Flutter

- Implementar cabeçalho “vivo” com 3 níveis (OK/Atenção/Crítico + Offline).
- Implementar tabs e visualizações “Por Local / Tipo / Dispositivo”.
- Implementar “Casa” com cards grandes + quick actions.
- Implementar “Dispositivos” + “Detalhe do dispositivo” com seções.
- Implementar “Modo Simples / Avançado / Dev” (com senha local para Dev).
- Integrar “Modo Simulação” usando a solução atual do time.
- Implementar padrões de pending/timeout para comandos.

---

// Arquivo formatado para padrão markdown
