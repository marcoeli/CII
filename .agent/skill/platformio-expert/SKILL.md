---
name: platformio-expert
description: Especialista em configuração do PlatformIO (platformio.ini), gerenciamento de bibliotecas e boards. Consulta a documentação local (código fonte do GitHub baixado) para resolver dúvidas de configuração.
---

# PlatformIO Documentation Expert

Esta skill instrui o agente a buscar respostas nos arquivos fonte da documentação do PlatformIO armazenados localmente.

## Configuração do Caminho
**IMPORTANTE:** Os arquivos de documentação estão localizados em:
`D:\Projects\CII\.agent\skill\platformio-expert\platformio-docs-develop`

## Quando usar
- O usuário precisa configurar o `platformio.ini` (baud rate, monitor filters, build flags).
- Dúvidas sobre como adicionar bibliotecas ou boards específicas.
- Erros de compilação relacionados ao ambiente PlatformIO.

## Como usar (Instruções Técnicas)

### 1. Formato dos Arquivos (.rst)
A documentação do PlatformIO é escrita em **reStructuredText (.rst)**, não apenas Markdown.
- Ao procurar informações, você deve ler o conteúdo dos arquivos `.rst`.
- A sintaxe é levemente diferente do Markdown (ex: links e blocos de código), mas o conteúdo textual é legível.

### 2. Mapeamento de Tópicos
Não tente ler todos os arquivos. Vá direto às pastas relevantes baseadas na dúvida:
- **Configuração:** Procure na pasta `configuration/` ou arquivos com `platformio.ini` no nome.
- **Placas/Boards:** Procure na pasta `boards/`.
- **Frameworks:** Procure na pasta `frameworks/` (ex: `arduino.rst`, `espidf.rst`).

### 3. Estratégia de Busca
Se o usuário perguntar "Como mudar a velocidade do monitor serial?", execute uma busca por palavras-chave (ex: "monitor_speed") dentro do diretório da documentação especificado acima.

## Exemplo de Resposta
"Baseado no arquivo local `configuration/section_env_monitor.rst`, a flag correta para o `platformio.ini` é:
`monitor_speed = 115200`"