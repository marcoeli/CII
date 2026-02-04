---
name: flutter-arch-modular-riverpod
description: >
  MASTER PROJECT ARCHITECTURE.
  Defines the mandatory integration patterns between Flutter Modular and Riverpod 3.x.
  HIGHEST PRIORITY: Overrides generic documentation skills when deciding structure.
  Use for: DB-First logic, Repository placement, ViewModel lifecycle and Pessimistic UX rules.
---

# Flutter Architecture Skill: Modular + Riverpod 3.x (DB-First + UX Pessimista)

## Goal
Ensure all Flutter changes follow the project architecture:
- **DB-First**: UI never consumes MQTT directly; UI reacts only to DB (Drift) changes.
- **UX Pessimista**: commands show loading immediately, confirm only after DB updates, and must timeout safely.
- **Clear separation**: **Modular = Infrastructure + Routes**, **Riverpod = UI State + ViewModels + Lifecycle**.
- **Riverpod 3.x migration compliant** (Option B) while documenting **Legacy** patterns.

## When to use this skill
Use this skill when:
- Adding/changing **Notifiers / Providers** (Riverpod 3.x).
- Implementing **features** under `lib/modules/*`.
- Implementing **MQTT sync** (MQTT → DB) or **command flow** (UI → Repo → MQTT → DB → UI).
- Refactoring legacy `ChangeNotifier` / `StateNotifier` / old providers.
- Reviewing PRs touching: Modular modules, DB schema/DAOs, MQTT topics, session context, resource parsing.

## Non-goals
This skill does **not**:
- Modify MQTT contract, ACLs, provisioning rules, firmware behavior.
- Decide business/security logic that belongs to firmware or orchestrator.
- Define UI/UX layout details beyond DB-first + pessimistic UX rules.

---

# Core Principles (Mandatory)

## 1) DB-First (Source of Truth)
**Required flow**: `MQTT → Drift DB → Riverpod Notifier → Widgets`

Rules:
- Widgets must **not** parse MQTT payloads or subscribe to MQTT streams.
- The MQTT layer must write data/state/meta into DB via a sync service.
- ViewModels/Notifiers read **DB watch streams** and expose derived UI state.

## 2) UX Pessimista (Commands)
Rules:
- On user action: set loading **immediately**.
- Only confirm success when DB state reflects the change.
- Apply **timeout (10s default)** to avoid infinite loading.
- Failures must surface via state or a global error notifier (snackbar/toast).

## 3) Separation of Responsibilities
- **Flutter Modular**
  - Routes
  - Dependency Injection of infra singletons/services
  - Repositories (concrete implementations)
- **Riverpod**
  - UI state
  - ViewModels (Notifiers)
  - Lifecycle (autoDispose)
- **Widgets**
  - “Dumb”: render + delegate actions to ViewModels

---

# Modular vs Riverpod Rules (Definitive)

## Rule A — Infra lives in Modular
Bind in Modular:
- AppDatabase (Drift)
- MQTT client/service
- MqttRemoteDataSource / Sync service (MQTT → DB)
- Command manager
- Repositories (concrete) **without Ref/WidgetRef dependency**
- Logging, serializers, adapters

## Rule B — UI State lives in Riverpod
- Prefer **Riverpod 3.x Notifiers** for ViewModels.
- Use `.autoDispose.family` when state depends on a `resourceId`, `deviceId`, or similar.

## Rule C — Repository must NOT depend on `Ref`/`WidgetRef`
- Repositories must be constructible by Modular without Riverpod.
- If repository needs tenant/home context:
  - Use a **SessionContextProvider** (adapter owned by Riverpod, consumed by repo), OR
  - Require context as explicit method args (`sendCommand(tenantId, homeId, ...)`)

## Rule D — One “bridge” only
If context is needed across layers, use a single adapter:
- `SessionContextProvider` (current tenant/home) exposed by Riverpod, injected into repositories via Modular.

---

# Riverpod 3.x Standard (Option B)

## Provider Types (Standard)
- **Stateful ViewModels**: `Notifier` + `NotifierProvider.autoDispose.family`
- **Pure derived values**: `Provider`
- **Streams**: `StreamProvider` only when truly streaming (DB watch is usually handled inside Notifier)

### Canonical pattern (family Notifier)
File: `lib/modules/<feature>/presentation/providers/<x>_providers.dart`

```dart
final pumpNotifierProvider =
  NotifierProvider.autoDispose
    .family<PumpNotifier, PumpState, String>(PumpNotifier.new);
File: `lib/modules/<feature>/presentation/viewmodels/pump_notifier.dart`

- `build(resourceId)` wires DB watchers and sets initial state.

## Notifier Responsibilities

In `build(arg)`:

- Read DB + current home from providers
- Start DB watcher (Drift `.watch*`)
- Register `ref.onDispose` cleanup
- Return initial state (loading/stale by default)

Actions:

- Call repository methods
- Manage command timeout
- Never update UI based on publish success alone—wait for DB change.

* * *

# Legacy Patterns (Document but avoid new usage)

## Legacy A — ChangeNotifier / ChangeNotifierProvider

Allowed only for existing legacy code, during migration.

Rules:

- No new features should start in ChangeNotifier.
- If a legacy ChangeNotifier must remain, ensure:

    - It still follows DB-first and pessimistic UX
    - It cancels subscriptions/timers on dispose
    - There is a migration note for future conversion to Notifier

## Legacy B — Provider.autoDispose used as workaround (Not reactive)

Using plain `Provider.autoDispose` for ViewModels is forbidden for live data screens  
because UI will not rebuild when state changes.

* * *

# Decision Tree (Pick the right approach)

1. Is this UI showing live sensor/actuator data?

- Yes → Use `NotifierProvider.autoDispose.family` + DB watcher inside Notifier.
- No → Use `Provider` or simple computed provider.

1. Does the feature send commands?

- Yes → Add pessimistic UX logic + timeout + wait for DB update.

1. Does repository need tenant/home?

- Yes → Use SessionContextProvider adapter OR pass args explicitly.
- No → Keep repository pure.

1. Is it new code?

- Yes → Riverpod 3.x Notifier pattern only.
- No (legacy) → keep stable but add migration note.

* * *

# Code Review Checklist (PR Acceptance Criteria)

## Architecture

- <input disabled="" type="checkbox"> Modular contains infra binds (db/mqtt/services/repo) and routes.
- <input disabled="" type="checkbox"> Riverpod contains UI state + Notifiers.
- <input disabled="" type="checkbox"> No repository depends on `Ref`/`WidgetRef`.

## DB-First

- <input disabled="" type="checkbox"> No widget reads MQTT directly.
- <input disabled="" type="checkbox"> UI reacts only via DB watchers (Drift) exposed by Notifier state.

## UX Pessimista

- <input disabled="" type="checkbox"> Commands set loading immediately.
- <input disabled="" type="checkbox"> Success is confirmed only when DB updates.
- <input disabled="" type="checkbox"> Timeout prevents infinite loading.
- <input disabled="" type="checkbox"> Failures propagate to UI (state or global error notifier).

## Lifecycle

- <input disabled="" type="checkbox"> All stream subscriptions and timers are cancelled via `ref.onDispose`.

## Consistency

- <input disabled="" type="checkbox"> No duplicated subscription refresh calls.
- <input disabled="" type="checkbox"> No duplicate device/resource inserts (verify DAO conflict targets).
- <input disabled="" type="checkbox"> Resource IDs treated as immutable (contract).

* * *

# Anti-patterns (Block the PR)

- Widget parsing MQTT payload or subscribing MQTT directly.
- Widget calling repository to send command (must go through ViewModel/Notifier).
- Repository depending on `ref` or reading session providers directly.
- “Optimistic UI”: toggling state in UI without DB confirmation.
- Provider used instead of Notifier for live-changing ViewModel state.
- Notifier/VM missing dispose cleanup.

* * *

# Integration Notes (Project-specific)

## DB-first + MQTT sync

- `MqttRemoteDataSource`: raw MQTT IO + parsing → emits structured streams.
- `MqttSyncService`: consumes those streams and persists into Drift (write-only).
- Notifiers: read Drift watchers and compute UI state.

## Session context

- Tenant/Home selection must trigger:

    - Subscription refresh (topics for that tenant/home)
    - Sync service start with current home id

* * *

# Output format (When asked to implement)

When implementing/refactoring under this skill:

- Specify **file name**
- Specify **where to place it**
- Specify **purpose**
- Provide complete code that compiles
- Call out any contract constraints explicitly (resourceId immutável, meta topics, etc.)