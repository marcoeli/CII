# UML App Flutter - PlantUML

## Diagrama de Casos de Uso (Use Case Diagram)

```plantuml
@startuml
!theme plain
left to right direction
actor "Usuário" as User
actor "Broker MQTT" as MQTT

rectangle "App Flutter" {
    usecase "Visualizar Dashboard" as UC1
    usecase "Monitorar Nível Cisterna" as UC2
    usecase "Controlar Bombas" as UC3
    usecase "Configurar Conexão" as UC4
    usecase "Gerenciar Dispositivos" as UC5
    usecase "Visualizar Histórico" as UC6
}

User --> UC1
User --> UC2
User --> UC3
User --> UC4
User --> UC5
User --> UC6

UC2 <.. MQTT : Assina Tópicos
UC3 ..> MQTT : Publica Comandos
UC6 <.. MQTT : Carrega Logs
@enduml
```

## Diagrama de Classes (Class Diagram)

```plantuml
@startuml
!theme plain

package "Core" {
    class ServiceLocator {
        + registerSingletons()
        + get<T>()
    }
    
    class MqttService {
        + connect()
        + disconnect()
        + publish(topic, payload)
        + subscribe(topic)
        + stream<String> messageStream
    }
    
    class DatabaseService {
        + init()
        + select(table)
        + insert(table, data)
        + update(table, data)
        + watchTable(table)
    }
    
    class MqttSyncService {
        + startSync(homeId, tenant, home)
        + stopSync()
        - handleMessage(topic, payload)
        - handleResourceMeta()
        - handleResourceOperational()
        - handleResult()
    }
}

package "Data" {
    class DeviceRepository {
        + getAllDevices()
        + sendCommand(id, cmd)
        + updateStatus(id, status)
    }
    
    class MqttRepository {
        + sendPumpCommand(pumpId, turnOn, force)
        + setPumpMode(pumpId, mode)
        + refreshDevices()
        + updateResourceMeta()
    }
    
    class DeviceModel {
        + String id
        + String friendlyName
        + String type
        + dynamic status
    }
    
    class ResourceModel {
        + String resourceId
        + String label
        + String kind
        + String domain
        + dynamic state
        + dynamic data
    }
    
    DeviceRepository --> DeviceModel : Uses
    DeviceRepository --> MqttService : Uses
    DeviceRepository --> DatabaseService : Uses
    MqttRepository --> ResourceModel : Uses
    MqttSyncService --> DatabaseService : Writes To
}

package "Presentation (NEW - RCO-2401)" {
    class PumpViewModel {
        + bool isLoading
        + PumpState? currentState
        + bool isStale
        + Future<void> toggle(force)
        - initStateListener()
        - startTimeout()
    }
    
    class SensorViewModel {
        + SensorData? currentData
        + bool isStale
        - initDataListener()
    }
    
    PumpViewModel --> MqttRepository : Sends Commands
    PumpViewModel --> DatabaseService : Watches State
    SensorViewModel --> DatabaseService : Watches Data
}

package "Modules" {
    class HomeModule {
        + DashboardPage
    }
    
    class WaterModule {
        + WaterPage
        + CisternWidget
        + PumpControlWidget
    }
    
    class SettingsModule {
        + ConfigPage
    }
}

class MainScaffold {
    + build()
    + initAutoRefresh()
}

MainScaffold --> HomeModule
MainScaffold --> WaterModule
MainScaffold --> SettingsModule

' DB-First Flow (CRITICAL)
HomeModule ..> SensorViewModel : Observes
WaterModule ..> PumpViewModel : Observes
WaterModule ..> SensorViewModel : Observes

note right of PumpViewModel
  **DB-First Pattern**
  - UI never updates locally
  - Waits for DB Stream
  - Timeout after 10s
  - Listens to .../result
end note

@enduml
```

## Diagrama de Sequência (Sequence Diagram) - Comando de Bomba (V2.4 + DB-First)

```plantuml
@startuml
!theme plain
title Comando de Bomba com ViewModel e DB-First (RCO-2401)

actor User
participant "PumpWidget\n(UI)" as UI
participant "PumpViewModel" as VM
participant "MqttRepository" as Repo
participant "MqttService" as MQTT
participant "MQTT Broker" as Broker
participant "MqttSyncService" as Sync
participant "Database\n(SQLite)" as DB
database "DB Stream" as Stream

User -> UI : Clicar "Ligar"
activate UI
UI -> VM : toggle(force: false)
activate VM
VM -> VM : Set isLoading = true
VM -> UI : notifyListeners()
UI -> UI : Show Spinner (LOADING)

VM -> Repo : sendPumpCommand(pumpId, true, force: false)
activate Repo

Repo -> MQTT : publish("home/.../r/{id}/command",\n{"action":"START","params":{"force":false}})
activate MQTT
MQTT -> Broker : PUBLISH
MQTT --> Repo : ack
deactivate MQTT

Repo --> VM : success
deactivate Repo

VM -> VM : startTimeout(10s)
note right of VM
  Timeout previne loading eterno
  se nem state nem result chegarem
end note

... Aguardando Confirmação ...

alt#Gold Cenário 1: Sucesso (State Update)
    Broker -> MQTT : MESSAGE "home/.../r/{id}/state" = {"running":true}
    activate MQTT
    MQTT -> Sync : onMessage()
    activate Sync
    Sync -> DB : UPDATE resource_state
    activate DB
    DB -> Stream : Emit Change
    Stream -> VM : new State (running: true)
    deactivate DB
    deactivate Sync
    deactivate MQTT
    
    VM -> VM : isLoading = false
    VM -> VM : currentState.running = true
    VM -> UI : notifyListeners()
    UI -> UI : Hide Spinner, Show ON
    UI -> User : Visual Feedback "Ligado"
    
else Cenário 2: Rejeição (Result Error)
    Broker -> MQTT : MESSAGE "home/.../r/{id}/result"\n{"status":"ERROR","detail":"Bomba Travada"}
    activate MQTT
    MQTT -> Sync : onMessage()
    activate Sync
    Sync -> DB : INSERT command_result (error)
    DB -> Stream : Emit Error Event
    Stream -> VM : error result
    deactivate Sync
    deactivate MQTT
    
    VM -> VM : isLoading = false
    VM -> UI : notifyListeners() + showError()
    UI -> UI : Hide Spinner, Revert State
    UI -> User : Snackbar "Comando rejeitado: Bomba Travada"
    
else Cenário 3: Timeout (Nenhuma Resposta)
    VM -> VM : 10s elapsed
    VM -> VM : isLoading = false
    VM -> UI : notifyListeners() + showTimeout()
    UI -> UI : Hide Spinner, Revert State
    UI -> User : Snackbar "Timeout: Dispositivo não respondeu"
end

deactivate VM
deactivate UI
@enduml
```
