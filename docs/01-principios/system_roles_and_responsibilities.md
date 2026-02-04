Papéis e Responsabilidades do Sistema V1.1
Projeto: Automação Residencial
 Objetivo: definir, de forma inequívoca, quem decide o quê, quem publica o quê e onde a lógica reside, para evitar acoplamentos perigosos (especialmente no app e em serviços remotos).

1. Princípios de Governança
Local-First: decisões críticas acontecem no dispositivo responsável (ex.: bomba decide ligar/desligar).


MQTT é o Contrato: MQTT transporta estado e comandos; não é “fila de execução” garantida.


Sem lógica crítica no App: o app é interface, não controlador de segurança.


Fail-safe sempre: em caso de dúvida, o sistema deve se manter seguro (ex.: bomba desliga).


Menor Privilégio: permissões por perfil (ACL) estritas e auditáveis.



2. Componentes do Sistema
2.1 Dispositivos (ESP32)
Subdivididos em classes:
Sensores: publicam dados/estado.


Atuadores: executam ações físicas e publicam estado.


Interfaces locais (HMI): exibem, alertam e podem emitir comandos autorizados.


2.2 Broker MQTT (EMQX remoto)
Roteia mensagens.


Aplica autenticação (AuthN) e autorização (AuthZ).


Não contém lógica de negócio.


2.3 Orquestrador (Node-RED / serviços)
- Provisionamento V2.4 (entrega credenciais e `acls[]`).
- Meta Curator Flow: responsável por manter os tópicos `meta/resource/{id}` (retained).
- ACL explícita: garante que cada device só acesse seus recursos.
- Automação de conveniência (não crítica).
- Integrações externas (Alexa, etc.).
- Gestão de rollout OTA (campanhas).


2.4 App Flutter
- Context Holder: detentor do `tenant` e `home` antes do device.
- Provisionamento SoftAP: injeta contexto no hardware via HTTP local.
- UI/UX e controle remoto não crítico.
- Descobre recursos via `meta/resource/#` (retained) e monta catálogo local.
- Observa estados em `r/+/state` e dados em `r/+/data`.
- Emite comandos autorizados em `r/{id}/command`.
- Nunca “assume que deu certo”; reage ao estado publicado pelo atuador.


2.5 Integrações externas (Alexa / outros)
Sempre via orquestrador/backend.


Nunca acessam dispositivos diretamente.


Nunca contêm lógica crítica.



3. Matriz de Responsabilidades (Quem Decide)
3.1 Decisões CRÍTICAS (obrigatoriamente locais)
Tema
Quem decide
Justificativa
Ligar/desligar bomba em AUTO
WATER_ACTUATOR
segurança e autonomia
Proteções: dry-run, timeout, intertravamentos
WATER_ACTUATOR
evita danos físicos
Alarmes críticos locais (gás detectado, etc.)
Device local (ENV/HMI)
segurança humana
Falha de sensor / fallback
Device responsável
resiliência
Aplicar comando recebido (validar payload)
Atuador
zero confiança em rede

Regra: o app e o Node-RED podem pedir, mas o atuador decide.

3.2 Decisões NÃO CRÍTICAS (podem ser remotas)
Tema
Quem decide
Observação
Rotinas e automações de conforto
Node-RED
ex.: horários
Notificações (push, alertas)
Node-RED/App
sem risco físico
Relatórios e dashboards
App/HMI
leitura
Integração com Alexa
Node-RED
sempre mediada
Campanhas OTA (quem atualiza quando)
Node-RED
device valida e pode adiar


4. Papéis por Tipo de Device (Firmware)
4.1 WATER_SENSOR
Responsável por:
medir nível/fluxo


publicar dados hidráulicos


Nunca faz:
publicar comandos de bomba


assumir controle de segurança


4.2 WATER_ACTUATOR
Responsável por:
executar comandos de bomba


controlar lógica AUTO/MANUAL


publicar estado da bomba e, se aplicável, nível


Deve sempre:
validar comando


publicar state como confirmação assíncrona


4.3 ENV_SENSOR
Responsável por:
medir clima e ar


publicar dados de ambiente


4.4 PRESENCE_SENSOR (Security)
Responsável por:
detectar presença


publicar estado/evento de presença


4.5 EVENT_NODE (Campainha ou alarme)
Responsável por:
publicar evento de acionamento


4.6 HMI_NODE (Cozinha)
Responsável por:
exibir dados do sistema (water/env/event)


alertas locais (buzzer/display)


permitir comandos autorizados (ex.: start/stop bomba)


Nunca faz:
substituir a lógica do atuador


manter lógica crítica no display/app



5. Responsabilidades por Domínio MQTT
5.1 home/device/{username}/#
Device publica: status (OBRIGATÓRIO: com `capabilities` e `location`), errors


Device assina: config, ota


App/Node-RED assinam: `home/device/+/status` para:


descobrir dispositivos disponíveis (auto-discovery)


construir catálogo de recursos a partir de `capabilities`


mapear localização física via `location`


monitorar saúde (ONLINE/OFFLINE, rssi, fw, uptime)


Esse domínio é obrigatório e universal. O campo `capabilities` no status é essencial para device discovery.
5.2 home/water/#
Sensores publicam: level/{reservatorio}


Atuadores publicam: pump/{pump_id}/state


App/HMI publicam: pump/{pump_id}/command


Node-RED pode publicar: command e rotinas de conveniência


5.3 home/env/#
Sensores publicam: climate, air


App/HMI/Node-RED assinam: leitura e alertas


5.4 home/event/#
Event nodes publicam: doorbell/{local}, presence/{local}
ou  alarm/{local}, presence/{local}


HMI assina: para acionar buzzer e alertas


Node-RED assina: para notificações externas (push)


5.5 setup/#
Device virgem publica: setup/registro


Orquestrador publica: setup/resposta/{correlation_id}


App não usa setup (exceto gerar claim code, fora do MQTT)



6. Padrões de Confirmação (Comando vs Estado)
Comandos não têm ACK.


A confirmação é sempre via state (retained) publicado pelo atuador.


App/HMI/Node-RED devem:


publicar command


aguardar mudança no state para refletir sucesso/falha



7. Regras Operacionais para o App Flutter
O app é “supervisor”, não “controlador”:
Deve descobrir dispositivos via `home/device/+/status` (retained):


ao conectar, recebe todos os status retidos


constrói catálogo local a partir do campo `capabilities`


identifica quais recursos (bombas, sensores) estão disponíveis


mapeia `location` para organizar UI por cômodo


Deve funcionar somente lendo state e publicando command.


Deve tratar o sistema como eventual-consistente:


comando pode não ser aplicado


estado pode demorar


Deve mostrar “pendente” até state confirmar.



8. Regras Operacionais para Node-RED (Orquestrador)
Pode automatizar conveniências.


Não deve conter lógica que impeça operação segura local.


Deve ser capaz de:


provisionar devices


controlar rollout OTA


integrar serviços externos



9. Regras de Falha e Resiliência
9.1 Se MQTT cair
Devices continuam operando localmente.


HMI continua operando localmente (dados locais e alertas).


App perde controle remoto, mas não quebra sistema.


9.2 Se Node-RED cair
Provisionamento e integrações param.


Automação crítica continua intacta (local).



10. Critérios de Aceite (para homologação)
Bomba opera corretamente sem MQTT e sem app


Sensor não consegue comandar atuador via ACL


App não depende de resposta síncrona


Node-RED pode cair sem afetar lógica crítica


OTA não ocorre durante operação crítica


Estado sempre reflete realidade (não “otimismo de UI”)



11. Regra Final (para evitar desastre)
Quem mexe na física decide localmente.
 MQTT carrega intenção; o atuador publica a verdade.
obs: “um device pode acumular papéis via capabilities; decisões críticas continuam no atuador quando houver.”
