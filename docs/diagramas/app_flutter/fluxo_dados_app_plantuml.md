# Fluxo de Dados e Ciclo de Vida - App Flutter (Diagnóstico)

## Diagrama de Fluxo de Dados (Data Flow Diagram)

Este diagrama detalha o caminho do dado desde a recepção via MQTT/Banco de Dados até a renderização na UI, expondo pontos críticos de sincronização.

```plantuml
@startuml
!theme plain
title Ciclo de Vida do Dado e Descoberta de Dispositivos (V2.4 + DB-First)

|#LightGray|Infraestrutura|
start
:App Inicializa;

|#LightBlue|Database Service (Local)|
:Init SQLite;
:Carregar Dispositivos em Cache;

|#Pink|UI Layer|
:Renderizar Lista (Dados Offline);
note right: DB-First: UI sempre lê do banco

|#LightGreen|MQTT Service|
:Conectar ao Broker;

if (Conectado?) then (sim)
    |#LightYellow|MqttRepository|
    :Auto-trigger **refreshDevices()**;
    note right: RCO-2401: Auto-start no listener\ndo selectedHomeProvider
    :Subscribe **home/{t}/{h}/meta/resource/#**\n(Descoberta);
    :Subscribe **home/{t}/{h}/r/+/state**\n(Estado Atual);
    :Subscribe **home/{t}/{h}/r/+/data**\n(Telemetria);
    :Subscribe **home/{t}/{h}/r/+/result**\n(Feedback de Comando);
else (não)
    :Exibir Erro Conexão;
    stop
endif

|#LightGray|Infraestrutura|
fork
    :Recebe MENSAGEM **.../meta/resource/{id}**;
    |#Aqua|MqttSyncService|
    :Parse Meta Payload;
    :Ler **owner_device_id** (V2.4);
    note right: RCO-2401: Mudança de device_id\npara owner_device_id
    :Verificar se Device/Resource Existe no DB;
    if (Device Existe?) then (não)
        :Criar Device Stub;
        note right: Stubbing: garante integridade\nreferencial mesmo sem status
    endif
    :Upsert Resource no SQLite;
    |#LightBlue|Database Service (Local)|
    :Persistir + Emitir Stream;
    |#Pink|UI Layer (via ViewModel)|
    :Atualizar Lista de Recursos;

fork again
    |#LightGray|Infraestrutura|
    :Recebe MENSAGEM **.../r/{id}/state**;
    |#Aqua|MqttSyncService|
    :Parse State (running, mode, etc);
    if (Resource Existe?) then (não)
        :Criar Resource Stub;
        note right: RCO-2401: Resiliência\nNunca descarta dados
    endif
    |#LightBlue|Database Service (Local)|
    :UPDATE State + Emitir Stream;
    |#Pink|UI Layer (via ViewModel)|
    :PumpViewModel recebe novo estado;
    :Set isLoading = false;
    :Re-renderizar Switch;

fork again
    |#LightGray|Infraestrutura|
    :Recebe MENSAGEM **.../r/{id}/data**;
    |#Aqua|MqttSyncService|
    :Parse Data (liters, percent, etc);
    if (Resource Existe?) then (não)
        :Criar Resource Stub;
    endif
    |#LightBlue|Database Service (Local)|
    :Upsert Data + Histórico + Emitir Stream;
    |#Pink|UI Layer (via ViewModel)|
    :SensorViewModel recebe novos dados;
    :Atualizar Gráfico/Texto;

fork again
    |#LightGray|Infraestrutura|
    :Recebe MENSAGEM **.../r/{id}/result**;
    |#Aqua|MqttSyncService|
    :Parse Result (status, error_code, detail);
    |#LightBlue|Database Service (Local)|
    :INSERT command_result;
    :Emitir Error Event Stream;
    |#Pink|UI Layer (via ViewModel)|
    :PumpViewModel recebe erro;
    :Set isLoading = false;
    :Show Snackbar com detail;
end fork

stop
@enduml
```

## Fluxo de Comando (UX Pessimista + Timeout + Error Handling)

Este fluxo mostra a aderência total à regra de "Verdade Assíncrona", "UI Pessimista" e tratamento de erros via `.../result`.

```plantuml
@startuml
!theme plain
title Fluxo de Comando de Atuação (V2.4 Strict: PendingCommands + Result)

|#Pink|UI Layer (Widget)|
start
:Usuário Toca "Ligar";
note right: UI não muda estado localmente

|#Lavender|PumpViewModel|
:Recebe toggle(force: false);
:Set isLoading = true;
:notifyListeners();

|#Pink|UI Layer (Widget)|
:Widget recebe update;
:Renderizar Spinner (LOADING);

|#LightYellow|MqttRepository|
:Montar Payload V2.4;
|#Orange|CommandManager|
:createCommand(...);
|#LightBlue|Database|
:INSERT INTO PendingCommands\n(correlation_id, status='pending');

|#LightYellow|MqttRepository|
:Loop Retry (3x);
|#LightGreen|MqttService|
:Publish **home/.../r/{id}/command**\n{correlation_id: "xyz"};

|#LightYellow|MqttRepository|
:await **waitForCompletion("xyz")**;
note right: Bloqueia aguardando DB update\n(Observer na tabela PendingCommands)

|#LightGray|Hardware (Device)|
:Recebe Comando;
:Executa Ação;
:Publish **.../r/{id}/result**\n{correlation_id: "xyz", status: "OK"};

|#Aqua|MqttSyncService|
:Recebe **.../result**;
|#LightBlue|Database|
:UPDATE PendingCommands\nSET status='success' WHERE correlation_id="xyz";

|#Orange|CommandManager|
:Stream detecta status='success';
:Completer.complete(true);

|#LightYellow|MqttRepository|
:Retorna true;

|#Lavender|PumpViewModel|
:Recebe sucesso;
:Set isLoading = false;
:notifyListeners();

|#Pink|UI Layer (Widget)|
:Hide Spinner;
:Show Estado Atual (via Stream de Dados);
stop

@enduml
```
