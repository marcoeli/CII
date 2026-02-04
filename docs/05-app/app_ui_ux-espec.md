(Theme-aware) Foco: Estrutura, Comportamento e Sistemas de Design.

O aplicativo deve suportar troca dinâmica de temas. Recomenda-se o uso de Provider, Bloc ou Riverpod para gerenciar o estado do tema globalmente.

Os desenvolvedores devem criar três constantes de ThemeData:

Baseada em gradientes vibrantes para um look futurista.

Baseada em tons de azul para passar confiança e estabilidade.

Para economia de bateria e uso noturno.

Localização: Adicionar na tela Configurações.

# Especificação de UI/UX V1.2

> [!IMPORTANT]
> **Nota Arquitetural V2.4 — Importante para UX**
>
> 1. **Dispositivo ≠ Recurso:** O "Dispositivo" é o hardware (Esp32). O "Recurso" é o item de controle ou telemetria (Bomba, Nível). Um dispositivo pode ter vários recursos.
> 2. **Contexto Multi-casa:** A UI deve permitir a seleção de `tenant` e `home`. Trocar o contexto muda o prefixo de todos os tópicos MQTT.
> 3. **Renomeação via Meta:** Renomear um recurso altera o `label` nos metadados (`meta/resource/{id}`), nunca o `resource_id`.

## 1. Sistema de Design e Temas

O aplicativo deve suportar troca dinâmica de temas. Recomenda-se o uso de Provider, Bloc ou Riverpod para gerenciar o estado do tema globalmente.

### 1.1 Paletas de Cores Sugeridas

Os desenvolvedores devem criar três constantes de `ThemeData`:

#### Opção A: Nebula (Padrão - Moderno)

Baseada em gradientes vibrantes para um look futurista.

- **Primary (Gradient):** LinearGradient de Roxo (#8E2DE2) para Rosa (#FF0080)
- **Secondary/Accent:** Ciano Brilhante (#00E5FF)
- **Background:** Cinza muito claro (#F5F7FB)
- **Surface (Cards):** Branco (#FFFFFF) com elevação suave
- **Status Colors:** Verde Menta (OK), Laranja Solar (Atenção), Vermelho Neon (Erro)

#### Opção B: Deep Ocean (Corporativo/Sóbrio)

Baseada em tons de azul para passar confiança e estabilidade.

- **Primary:** Azul Royal (#1565C0)
- **Secondary:** Azul Petróleo (#00695C)
- **Background:** Branco Gelo (#ECEFF1)
- **Surface (Cards):** Branco (#FFFFFF)
- **Status Colors:** Verde Floresta (OK), Amarelo Ouro (Atenção), Vermelho Tijolo (Erro)

#### Opção C: Midnight (OLED/Dark Mode)

Para economia de bateria e uso noturno.

- **Primary:** Roxo Profundo (#311B92)
- **Secondary:** Teal (#00BFA5)
- **Background:** Preto Real (#121212)
- **Surface (Cards):** Cinza Carvão (#1E1E1E)
- **Text:** Branco (High Emphasis) e Cinza (Medium Emphasis)

### 1.2 Implementação da Troca de Tema

- **Localização:** Adicionar na tela Configurações
- **Componente:** Um SegmentedControl ou Dropdown com as opções: "Nebula", "Ocean", "Midnight"
- **Persistência:** Salvar a preferência do usuário localmente (`shared_preferences` ou `hive`)

## 2. Estrutura Global (Scaffold)

### 2.0 Seletor de Contexto (Multi-casa)
Antes de acessar o Dashboard, o usuário deve selecionar o contexto:
- **Tenant:** Identificador do cliente (ex: `marcoeli`).
- **Home:** Identificador da residência (ex: `casa_praia`).
*O App persiste o último contexto selecionado.*

### 2.1 Cabeçalho "Vivo" (Reactive Header)

**Não usar AppBar padrão.** Criar um Container animado no topo da tela.

- **Dimensões:** Altura variável. 15% da tela (estado Normal) a 30% (estado Crítico/Expandido)

**Fundo:** Usa a Cor Primária do tema selecionado.

**Conteúdo:**

- Esquerda: Texto de boas-vindas ou Título da Seção
- Direita: Ícone de Status (Check, Alerta ou Nuvem cortada)

**Estados (Lógica de Cor/Tamanho):**

- Online/OK: Fundo Primário. Texto "Sistema Online"
- Atenção: Fundo muda para Laranja/Amarelo. Exibe badge de contagem
- Offline: Fundo Cinza Escuro (#37474F). Texto "Modo Offline - Dados em cache"

### 2.2 Navegação Inferior (`BottomNavigationBar`)

- **Tipo:** Fixed
- **Itens:** 4 ícones (Casa, Água, Ambiente, Eventos)
- **Estilo:**
 	- Unselected: Cinza (`Colors.grey`)
 	- Selected: Cor Primária ou Accent do tema ativo
- **Animação:** Leve aumento de escala (1.1x) no ícone selecionado

## 3. Especificação das Telas

### 3.1 Tela "Casa" (Dashboard)

- **Layout:** `CustomScrollView` com Slivers

**Componentes:**

- **Grid de Destaques (`SliverGrid`):**
 	- Cards quadrados com `BorderRadius` de 20px
 	- Conteúdo: Ícone grande centralizado + Valor numérico + Label pequeno
 	- Exemplo: Ícone Gota | 80% | Cisterna
- **Ações Rápidas (`SliverToBoxAdapter`):**
 	- ListView horizontal
 	- Itens: Chip ou ActionChip. Borda colorida, fundo transparente
- **Gráfico de Resumo:**
 	- Card retangular largo no rodapé. Usar biblioteca de gráficos (ex: `fl_chart`) para desenhar uma linha de tendência simples (Sparkline)

### 3.2 Tela "Água" (Hidráulica)

- **Filtros Superiores:** Linha de `ChoiceChips` (Local | Tipo | Dispositivo)
- **Indicadores de Nível:**
 	- Usar componente de progresso circular (`CircularPercentIndicator`)

Borda: BorderRadius.circular(16).

**Centro:** Valor em %
**Rodapé do card:** Valor em Litros

**Lista de Bombas (Lógica Crítica):**

- Usar `ListTile` dentro de Cards
- **Trailing Widget (Switch):**
 	- Este switch deve ter 3 estados visuais:
  		- On: Cor ativa
  		- Off: Cinza
  		- Loading: Substituir a "bolinha" do switch por um `CircularProgressIndicator` pequeno enquanto aguarda confirmação do MQTT. Não mudar a cor visualmente até o backend confirmar

### 3.3 Tela "Ambiente"

- **Cards de Sensor:**
 	- Layout: Título do local à esquerda, Temperatura grande à direita
 	- Badge de Qualidade: Pequeno círculo colorido no canto superior direito do card (Verde/Amarelo/Vermelho) indicando a qualidade do ar/gás
- **Sliders (Atuadores):**
 	- Se houver controle (ex: ventoinha), usar `Slider.adaptive`
 	- Implementar "Debounce" (só enviar comando ao soltar o dedo) para não inundar o broker MQTT

### 3.4 Tela "Eventos"

- **Navegação Interna:** `TabBar` no topo (abaixo do Header) com 3 abas: Alertas, Eventos, Presença
- **Lista de Alertas:**
 	- Cards com borda esquerda colorida indicando severidade (`Container` com `Border(left: BorderSide(color: ...))`)
 	- Botão de ação: "Ver Detalhes" (`OutlineButton`)
- **Timeline:**
 	- Lista vertical simples com linha pontilhada conectando os ícones à esquerda

### 3.5 Telas de Gestão/Dev (Técnicas)

- **Lista de Dispositivos:**
 	- Layout denso (Cards menores)
 	- Indicador de Staleness (Dados antigos): Se o timestamp da última mensagem for > X minutos, aplicar `Opacity(0.5)` no card inteiro e mostrar ícone de "Relógio/Atraso"
- **Console Dev:**
 	- Fundo preto/terminal (independente do tema claro). Fonte monoespaçada (ex: Roboto Mono)

## 4. Diretrizes de Componentes (Widget Catalog)

### 4.1 Cards (Padrão)

Container: Branco (ou Surface Color do tema)

 - **Borda:** `BorderRadius.circular(16)`
 - **Sombra:** `BoxShadow` suave, cor preta com opacidade 0.05, blur 10, offset (0, 4)
 - **Padding Interno:** 16px

### 4.2 Tipografia

- **Fonte:** Usar uma Sans-Serif moderna (ex: Poppins, Inter ou Roboto)
- **Hierarquia:**
 	- Headline: Bold, tamanho 24+
 	- Subhead: Medium, tamanho 16, cor cinza médio
 	- Body: Regular, tamanho 14
 	- Caption: Light, tamanho 12, cinza claro (usar para "Última atualização: 10:00")

### 4.3 Feedback de Ação (Microinterações)

- **Snackbars:** Usar para feedback de sistema
 	- Sucesso: Fundo Verde escuro
 	- Erro: Fundo Vermelho
 	- Loading: Nunca bloquear a tela inteira. Usar indicadores locais (dentro do botão ou do card que está atualizando)

## 5. Notas Técnicas para o Time Flutter

- **State Management:** Priorizar separação clara entre UI e Lógica. O "Switch" da bomba não muda seu valor bool localmente ao ser clicado; ele despacha um evento e aguarda o novo estado via Stream/Observer
- **Responsividade:** O layout deve funcionar em Mobile (Portrait) e adaptar para Desktop Windows (Landscape)
 	- No Desktop, o `GridView` da Home deve aumentar de 2 colunas para 4 colunas
 	- Usar `LayoutBuilder` ou pacotes como `responsive_framework`
- **Assets:** Usar SVGs para ícones customizados (pacote `flutter_svg`) para garantir nitidez em qualquer resolução, permitindo trocar a cor do ícone via código (`color: Theme.of(context).primaryColor`)
