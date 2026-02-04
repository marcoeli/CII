# 📱 ARQUITETURA DO APLICATIVO FLUTTER V2.4

**Projeto:** Sistema de Automação Residencial  
**Status:** RCO-2401 Compliant - DB-First + UX Pessimista  
**Padrão:** Flutter Modular + Riverpod 3.x + Clean Architecture

* * *

## 🎯 1. OBJETIVO DO APLICATIVO

O aplicativo Flutter é o **cliente de interação humana** com o sistema.

### Responsabilidades Core

✅ Visualizar dados em tempo real (DB-First)  
✅ Enviar comandos manuais (UX Pessimista)  
✅ Exibir alertas e eventos  
✅ Configurar parâmetros dos dispositivos  
✅ Facilitar operação diária da casa

### O que o app NÃO é

❌ Não é servidor  
❌ Não é orquestrador crítico  
❌ Não executa lógica de segurança  
❌ Não toma decisões autônomas

> 
> 📌 **Regra de Ouro:** Se o app for fechado, o sistema continua funcionando.

* * *

## 🏗️ 2. STACK TECNOLÓGICA

| Item | Definição |
| --- | --- |
| Framework | Flutter |
| DI + Rotas | **Flutter Modular** |
| Estado | **Riverpod 3.x (Notifier API)** |
| Persistência | Drift |
| Comunicação | MQTT WSS |
| Arquitetura | Clean + Feature Modules |

* * *

## 📐 3. PRINCÍPIOS ARQUITETURAIS RCO-2401

### DB-First (Fonte da Verdade)
- UI **nunca** lê MQTT diretamente
- Toda mudança passa por: **MQTT → DB → ViewModel → UI**
- `MqttSyncService` é **write-only** para o banco

### UX Pessimista
- Comandos mostram **loading** imediatamente
- Confirmação **somente** após mudança no DB
- Timeout de 10s para evitar loading eterno
- Feedback de erro via `.../result` topic

### Separação de Responsabilidades
- **Modular:** Rotas + Injeção de Dependências pesadas (Singletons, Services)
- **Riverpod:** Estado de UI + ViewModels
- **View (Widget):** Burra - Apenas renderiza
- **ViewModel:** Toda lógica de apresentação e comandos

---

## 📂 4. ESTRUTURA DE DIRETÓRIOS PADRÃO V2.4

> ⚠️ **Regra de Ouro:** Nenhuma pasta deve ser criada fora deste padrão sem aprovação do arquiteto.

```
lib/
├── app/
│   ├── app_module.dart          # DI Global (Modular Binds)
│   └── app_widget.dart          # MaterialApp + Theme + AutoStart
│
├── core/                        # NÚCLEO (Compartilhado e Estável)
│   ├── constants/
│   │   ├── mqtt_topics.dart     # Contrato V2.4
│   │   └── enums.dart           # CapabilityType, ResourceKind, etc
│   │
│   ├── database/                # PERSISTÊNCIA (Fonte da Verdade)
│   │   ├── app_database.dart    # Drift Database
│   │   ├── daos/                # ResourcesDao, DevicesDao, EventsDao
│   │   └── tables/              # v24_tables.dart
│   │
│   ├── mqtt/                    # CAMADA DE REDE (Infraestrutura)
│   │   ├── mqtt_client.dart     # Cliente Singleton
│   │   ├── mqtt_sync_service.dart   # MQTT → DB (Write-Only)
│   │   └── mqtt_repository_impl.dart # Comandos (params wrapper)
│   │
│   ├── providers/
│   │   └── global_providers.dart     # databaseProvider, mqttRepositoryProvider
│   │
│   └── utils/
│       ├── resource_id_parser.dart
│       └── json_helpers.dart
│
├── modules/                     # FUNCIONALIDADES (Feature-Based)
│   │
│   ├── settings/                # 🔧 CONFIGURAÇÃO & CONTEXTO
│   │   ├── settings_module.dart
│   │   ├── domain/
│   │   │   └── entities/        # TenantEntity, HomeEntity
│   │   ├── data/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── viewmodels/      # ⭐ LÓGICA DE ESTADO
│   │       │   └── context_view_model.dart  # Troca Tenant/Home + Auto-start
│   │       ├── providers/       # contextViewModelProvider
│   │       ├── pages/
│   │       │   ├── settings_page.dart
│   │       │   └── home_selector_page.dart
│   │       └── widgets/
│   │
│   ├── home/                    # 🏠 DASHBOARD
│   │   ├── home_module.dart
│   │   ├── presentation/
│   │       ├── viewmodels/
│   │       │   └── system_status_view_model.dart  # Header Vivo (alertas + MQTT)
│   │       ├── providers/
│   │       ├── pages/
│   │       │   └── dashboard_page.dart
│   │       └── widgets/
│   │           ├── dynamic_header.dart        # Consome SystemStatusViewModel
│   │           └── resource_card.dart
│   │
│   ├── water/                   # 💧 CONTROLE HIDRÁULICO
│   │   ├── water_module.dart
│   │   ├── domain/
│   │   │   └── entities/        # Pump, Reservoir, Valve (Domain Models)
│   │   ├── data/
│   │   │   └── repositories/    # WaterRepository (lê do DB)
│   │   └── presentation/
│   │       ├── viewmodels/      # ⭐ AQUI VIVE A LÓGICA PESSIMISTA
│   │       │   ├── base/
│   │       │   │   ├── base_actuator_view_model.dart  # Abstrata (toggle, timeout)
│   │       │   │   └── base_sensor_view_model.dart    # Abstrata (stale, format)
│   │       │   ├── pump_view_model.dart         # Extends BaseActuator
│   │       │   ├── valve_view_model.dart        # Extends BaseActuator
│   │       │   └── water_level_view_model.dart  # Extends BaseSensor
│   │       ├── providers/       # pumpViewModelProvider, valveViewModelProvider
│   │       ├── pages/
│   │       │   ├── pumps_page.dart              # Lista de bombas
│   │       │   └── water_page.dart
│   │       └── widgets/
│   │           └── pump_switch_widget.dart      # Consome PumpViewModel
│   │
│   ├── environment/             # 🌡️ SENSORES AMBIENTAIS
│   │   ├── environment_module.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   ├── climate_view_model.dart      # Temp/Humidity + Stale
│   │       │   └── air_quality_view_model.dart  # CO2/VOC + Badge Color
│   │       ├── providers/
│   │       └── pages/
│   │           └── environment_page.dart
│   │
│   ├── events/                  # ⚠️ FEED DE ALERTAS
│   │   ├── events_module.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── events_feed_view_model.dart  # Filtros + MarkAsRead
│   │       ├── providers/
│   │       └── pages/
│   │           └── events_page.dart
│   │
│   ├── devices/                 # 🔧 GESTÃO TÉCNICA
│   │   ├── devices_module.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── device_admin_view_model.dart  # OTA, Reboot, Config
│   │       ├── providers/
│   │       └── pages/
│   │           └── device_details_page.dart
│   │
│   └── main_scaffold.dart       # Scaffold Principal (Bottom Nav)
│
└── shared/                      # COMPONENTES GLOBAIS
    ├── models/                  # DTOs compartilhados
    ├── theme/                   # Sistema de Cores / Typography
    └── widgets/                 # Cards, Loaders, Snackbars genéricos
```

---

* * *

# 🔄 5. FLUXO MODULAR + RIVERPOD (ATUALIZADO — RIVERPOD 3.x)

## Onde vive o Flutter Modular?

**Modular é responsável por:**

- Rotas
- Singletons pesados
- Serviços de infraestrutura
- Repositórios concretos
- Database
- MQTT client
- Sync services

### Regra

Modular injeta **infraestrutura**.  
Riverpod gerencia **estado e lifecycle de UI**.

* * *

## Onde vive o Riverpod?

**Riverpod 3.x é responsável por:**

- ViewModels
- Estado reativo
- Lifecycle de ViewModels
- Family por resourceId
- AutoDispose de estado de tela

* * *

## 🔧 Regra de Integração Modular + Riverpod

ViewModel (Notifier) pode buscar dependências do Modular:

    final repo = Modular.get<MqttRepository>();final db = Modular.get<AppDatabase>();

Isso é permitido porque:

- Modular = infra singleton
- Riverpod = estado de tela

* * *

## 🚫 Regra Proibida

Repository **NÃO** pode depender de Riverpod `ref`.

Repositories devem ser puros.

* * *

# 🧠 6. VIEWMODELS — PADRÃO RIVERPOD 3.x (NOVO)

## ❗ Riverpod 3 remove ChangeNotifierProvider por padrão

O padrão oficial agora é:

- Notifier
- AutoDisposeNotifier
- FamilyNotifier

* * *

## ✅ Padrão Obrigatório Novo

### Provider

    final pumpNotifierProvider = NotifierProvider.autoDispose .family<PumpNotifier, PumpState, String>(PumpNotifier.new);

* * *

## ViewModel

    class PumpNotifier extends AutoDisposeNotifier<PumpState> { @override PumpState build(String resourceId) { // setup return const PumpState(); } Future<void> toggle() async { ... }}

* * *

## Sensor ViewModel

    class ClimateNotifier extends AutoDisposeFamilyNotifier<ClimateState, String> { @override ClimateState build(String resourceId) { ... }}

* * *

## 🔁 Lifecycle

| Tipo | Uso |
| --- | --- |
| Notifier | singleton de estado |
| AutoDisposeNotifier | estado por tela |
| FamilyNotifier | estado por resourceId |

* * *

# 🧾 6.1 LEGACY — ChangeNotifier (SUPORTE TRANSITÓRIO)

## ⚠️ Permitido apenas para código antigo

Pode existir legado:

    ChangeNotifierProvider(...)

Mas:

- não usar em código novo
- não misturar com Notifier no mesmo módulo
- planejar migração

* * *

# 🎨 6.2 HIERARQUIA DE VIEWMODELS (ATUALIZADA)

    BaseNotifier│├── BaseActuatorNotifier│ ├── PumpNotifier│ ├── ValveNotifier│├── BaseSensorNotifier│ ├── WaterLevelNotifier│ ├── ClimateNotifier│└── SystemNotifier

* * *

# 📡 7. MQTT

### Conexão
- **Protocolo:** WSS
- **Endpoint:** `wss://mqtt.icodz.com.br/mqtt`
- **Reconexão:** Automática
- **Status:** Exposto para UI via `SystemStatusViewModel`

### Subscrições (V2.4)
| Domínio | Tópico |
|---------|--------|
| **Meta** | `home/{t}/{h}/meta/resource/#` | 
| **State** | `home/{t}/{h}/r/+/state` |
| **Data** | `home/{t}/{h}/r/+/data` |
| **Result** | `home/{t}/{h}/r/+/result` |
| **Device Status** | `home/{t}/{h}/device/+/status` |
> [!NOTE]
> meta está no contrato mas não usamos no app.

### Envio de Comandos
**Tópico:** `home/{t}/{h}/r/{resource_id}/command`

* * *

# 🛡️ 8. DEVICE SPECS

Baseado em `device_spec_sheets.md`, o app suporta:

### Dispositivos Atuais
| Device | Recursos | ViewModels Necessários |
|--------|----------|------------------------|
| **Cisterna Node** | Pump, WaterLevel | PumpViewModel, WaterLevelViewModel |
| **Clima Node** | Temperature, Humidity | ClimateViewModel |
| **Campainha** | Doorbell Event | EventsFeedViewModel |

### Recursos por Domínio
- **water:** pump, valve, level, flow
- **env:** climate (temp/humidity), air_quality
- **security:** doorbell, motion, camera
- **hmi:** relay, dimmer, display

---

* * *

# 🧪 9. TESTES

## Testando Notifier Riverpod 3

    final container = ProviderContainer(); final state = container.read( pumpNotifierProvider("water.pump.1"));

* * *

# 📋 10. CHECKLIST NOVA FEATURE (ATUALIZADO)

- <input disabled="" type="checkbox"> Criar Notifier (não ChangeNotifier)
- <input disabled="" type="checkbox"> Criar NotifierProvider.autoDispose.family
- <input disabled="" type="checkbox"> Dependências via Modular.get
- <input disabled="" type="checkbox"> Sem ref dentro de Repository
- <input disabled="" type="checkbox"> Teste unitário com ProviderContainer

* * *

# ⚠️ 11. ANTI-PATTERNS PROIBIDOS (ATUALIZADO)

❌ ChangeNotifier novo  
❌ Repository usando ref  
❌ Provider fazendo navegação  
❌ View acessando DB  
❌ Widget chamando Repository

* * *

# 🚀 12. EVOLUÇÃO FUTURA

### Próximos Passos
✅ Multi-residência (já suportado via `tenant/home`)  
✅ Notificações Push  
✅ Histórico longo (Drift + paginação)  
✅ Web/Desktop (Flutter já preparado)  
✅ Modo Offline (DB-First garante)

### Expansão de ViewModels
- `NotificationViewModel` (Push + Local)
- `HistoryViewModel` (Gráficos + Filtros)
- `AutomationViewModel` (Criar/Editar regras)

---

* * *

# ✅ 13. DEFINIÇÃO DE SUCESSO

### MVP Completo
✅ DB-First rigorosamente aplicado  
✅ UX Pessimista em todos os comandos  
✅ ViewModels para **todo** estado dinâmico  
✅ Zero lógica de negócio em Widgets  
✅ Estrutura Modular + Riverpod consistente  
✅ Testes unitários de ViewModels  
✅ Reconexão MQTT automática  
✅ Feedback visual (loading/stale/error)
✅ ViewModels usando Notifier API  
✅ Zero ChangeNotifier novo

* * *

# 📚 14. REFERÊNCIAS

Este documento está 100% compatível com:
- `mqtt_topics_V2.4.md` - Contrato de comunicação
- `acl_profiles.md` - Permissões do app
- `provisioning.md` - Fluxo de setup
- `device_spec_sheets.md` - Dispositivos suportados
- `RCO-2401.md` - Requisitos de compliance
- `app_ui_ux-espec.md` - Guidelines de UX
- Riverpod 3 migration guide

* * *

# 🎯 OBSERVAÇÃO FINAL (mantida)

 **O aplicativo é uma janela para o sistema, não o cérebro.**  
> Se ele virar o cérebro, o projeto falhou arquiteturalmente.

**Responsabilidades Claras:**
- **Firmware:** Lógica crítica + Safe-fail
- **Backend:** Orquestração + ACL + Meta
- **App:** Visualização + Comandos manuais

**Padrão Arquitetural:**
```
MQTT (Infraestrutura)
  ↓
DB (Verdade)
  ↓
ViewModel (Lógica)
  ↓
Widget (UI Burra)
```

---

**Versão:** 2.4 RCO-2401  
**Data:** 2026-01-27  
