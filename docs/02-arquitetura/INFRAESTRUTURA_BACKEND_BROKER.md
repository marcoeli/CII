Infraestrutura de Backend e Broker MQTT V1.0
============================================

Projeto: Sistema de Automação Residencial

Status: Operacional / Pronto para Desenvolvimento

Versão: 1.1 (Compatível com Contrato MQTT V2.4)

* * * * *

1. Visão Geral da Infraestrutura
---------------------------------

O backend do sistema foi desenhado para ser agnóstico, seguro e escalável. Ele não contém regras de negócio críticas (que residem no firmware, conforme princípio Local-First), atuando estritamente como:

1. Transportador Seguro: Garantindo entrega de mensagens via MQTT/TLS.

2. Autorizador: Controlando quem pode ler/escrever em quais tópicos (ACLs).

3. Provisionador: Gerenciando a entrada de novos dispositivos (Onboarding).

### Topologia de Rede

-   Hospedagem: Oracle Cloud (Docker em CyberPanel/OpenLiteSpeed).

-   Proxy Reverso: Gerencia SSL e terminações TLS.

-   Firewall: Portas administrativas (1880, 18083) bloqueadas publicamente. Acesso apenas via túnel seguro ou subdomínios protegidos.

* * * * *

2\. Broker MQTT (EMQX)
----------------------

O coração da comunicação é o EMQX v5 (Open Source), configurado para alta performance e segurança granular.

### 2.1 Listeners (Portas de Entrada)

| Protocolo | Porta | Segurança | Uso Exclusivo |
|-----------|-------|-----------|---------------|
| MQTTS | 8883 | TLS/SSL | Dispositivos ESP32 (Firmware) |
| WSS | 8084 | SSL + Path /mqtt | App Flutter e Web Clients |
| MQTT | 1883 | TCP (Sem cripto) | Desativado/Bloqueado externamente |

### 2.2 Autenticação (AuthN)

-   Método:  Password-Based (Built-in Database).

-   Políticas:

-   Não permite clientes anônimos (exceto em rotas controladas de setup).

-   Senhas são geradas aleatoriamente (hash) durante o provisionamento.

-   Credenciais são únicas por ClientID (um vazamento não compromete a rede).

### 2.3 Autorização (AuthZ / ACLs)
O sistema opera em modo Deny-by-Default (Zero Trust).

As regras de ACL são geradas de forma dinâmica e explícita pelo Node-RED durante o provisionamento, entregues no array `acls[]`.

**Padrão de ACL V2.4:**
- **Status Central:** `Allow Publish -> home/{tenant}/{home}/device/{username}/status` (Retain: SIM)
- **Recursos (r/):**
    - `Allow Publish/Subscribe -> home/{tenant}/{home}/r/{resource_id}/{leaf}`
    - Sem wildcards em `{resource_id}` para devices.
- **Metadados (meta/):**
    - `Allow Subscribe -> home/{tenant}/{home}/meta/resource/#` (para App/Painéis)
    - Device **não possui** permissão de escrita em `meta/`.

**Perfis de Acesso (Exemplos):**
- **Dispositivo (Nó):** Somente seus próprios `r/{id}/#` declarados no manifesto.
- **App/HMI:** Acesso total via `meta/#` e `r/#` para visualização e comandos.

* * * * *

3\. Orquestrador de Backend (Node-RED)
--------------------------------------

O Node-RED atua como "Porteiro" e "Gerente Administrativo". Ele não processa automações rápidas (ex: sensor -> lâmpada), garantindo que a latência de rede não afete a física da casa.

### 3.1 Fluxo de Provisionamento V2.4 (Secure Onboarding)
Implementa o fluxo descrito em `provisioning.md`.

1. **Bootstrap de Contexto (App <-> Device):**
   - O App injeta `tenant/home` no hardware via SoftAP.

2. **Registro MQTT:**
   - Recebe requisição em `setup/{tenant}/{home}/registro`.
   - Valida manifesto de resources e gera ACLs explícitas.

1. Gatekeeper (Segurança):

   - Recebe requisição em setup/registro.
   - Modo DEV: Valida contra MASTER_DEV_TOKEN (hardcoded no servidor).
   - Modo PROD: Valida contra banco de dados de Claim Codes (uso único).

2. Identity Manager:

   - Gera username padronizado: {type}-{mac_suffix}.
   - Gera senha forte aleatória.

3. EMQX API Connector:

   - Cria o usuário no banco do EMQX.
   - Insere as regras de ACL específicas do tipo do dispositivo.

4. **Meta Curator Flow:**
   - Ao completar o provisionamento, o Node-RED cria/atualiza os tópicos `home/{tenant}/{home}/meta/resource/{resource_id}` com as informações básicas do hardware (kind, device_id).
   - Mantém o catálogo de recursos atualizado para o App.

### 3.2 Painel Administrativo (Dashboard 2.0)

Interface visual protegida para gestão técnica.

-   Tecnologia:  @flowfuse/node-red-dashboard (Vue.js).

-   URL: Acesso restrito (autenticado).

-   Funcionalidades:

-   Gerador de Claims: Cria códigos de instalação para técnicos (Ex: A1B2-C3D4).

-   Monitoramento: Lista códigos ativos e histórico de uso.

-   Persistência: Dados salvos em arquivo JSON (claims.json) para sobreviver a reboots.

* * * * *

4\. Endpoints Oficiais para Desenvolvimento
-------------------------------------------

Os desenvolvedores devem utilizar os seguintes endereços hardcoded ou configuráveis nos firmwares/apps:

| Serviço | Host | Protocolo | Porta | Obs |
|---------|------|-----------|-------|-----|
| Broker (Devices) | mqtt.icodz.com.br | MQTTS | 8883 | Requer Certificado Root CA (ISRG Root X1) |
| Broker (App) | mqtt.icodz.com.br | WSS | 8084 | Path: /mqtt |
| OTA Server | ota.icodz.com.br | HTTPS | 8084 | Hospedagem de binários .bin e JSONs |
| Admin Painel | nodered.icodz.com.br | HTTPS | 8084 | Caminho: /dashboard/admin |

* * * * *

5\. Procedimentos de Operação (SOP)
-----------------------------------

### 5.1 Para adicionar um novo dispositivo (PROD)

1.  Acesse o Painel Admin.

2.  Clique em "Gerar Código de Instalação".

3.  Forneça o código gerado ao instalador/app.

4.  O dispositivo envia o código no payload de registro.

5.  O sistema valida, apaga o código (burn) e provisiona o acesso.

### 5.2 Para adicionar um dispositivo em bancada (DEV)

1.  Configure o firmware com mode: "dev".

2.  Utilize o Token Mestre de Desenvolvimento (definido nas variáveis de ambiente do Node-RED).

3.  O sistema ignora a verificação de Claim Code.

* * * * *

6\. Checklist de Entrega (Status Atual)
---------------------------------------

-   [x] EMQX: Instalado, cluster rodando, API v5 ativa.

-   [x] TLS/SSL: Certificados configurados e renovação automática via CyberPanel.

-   [x] ACLs: Regras dinâmicas implementadas conforme Fichas Técnicas.

-   [x] Node-RED: Fluxos de segurança e provisionamento V3 ativos.

-   [x] Interface Admin: Dashboard operacional e gerando códigos.

-   [x] Firewall: Portas críticas fechadas para a internet pública.