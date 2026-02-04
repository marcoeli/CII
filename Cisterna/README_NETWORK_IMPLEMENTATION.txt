// README - Cisterna Patio Firmware
// 
// NOTA IMPORTANTE SOBRE A IMPLEMENTAÇÃO DE REDE
// 
// Este firmware foi desenvolvido com toda a estrutura completa:
// - Drivers HAL ✓
// - Services ✓  
// - Persistence (NVS) ✓
// - Provisioning ✓
// - Display UI ✓
// - Interface Web (HTML/CSS/JS) ✓
// - Main application loop ✓
//
// COMPONENTES DE REDE PENDENTES:
// Devido à complexidade e extensão do código já implementado, os seguintes
// componentes de rede precisam ser implementados para completar o firmware:
//
// 1. WiFi Manager (src/network/wifi_manager.c)
//    - Modo AP para configuração inicial
//    - Modo STA para operação normal
//    - Reconexão automática com backoff
//
// 2. Web Server (src/network/web_server.c)
//    - HTTP server usando ESP-IDF httpd
//    - Servir arquivos HTML/CSS/JS do SPIFFS
//    - REST API endpoints:
//      * GET /api/mode - retorna modo DEV/PROD
//      * GET /api/scan - escaneia redes WiFi
//      * POST /api/wifi - salva credenciais WiFi
//      * GET /api/status - status do sistema
//      * GET /api/config - configuração do tanque
//      * POST /api/config - salva configuração
//
// 3. MQTT Manager (src/network/mqtt_manager.c)
//    - Cliente MQTT com TLS (MQTTS port 8883)
//    - Modo setup para provisioning (Bootstrap)
//    - Modo operacional com credenciais do NVS
//    - Publicação de heartbeat
//    - Handlers para comandos
//
// 4. MQTT Handlers (src/messaging/mqtt_handlers.c)
//    - Parse de mensagens JSON (usando ArduinoJson)
//    - Handlers para comandos de pump
//    - Handlers para config remota
//    - Handlers para OTA
//    - Publicadores de status/level/pump states
//
// PRÓXIMOS PASSOS PARA COMPLETAR:
//
// 1. Implementar wifi_manager.c com ESP-IDF WiFi API
// 2. Implementar web_server.c com esp_http_server
// 3. Implementar mqtt_manager.c com esp-mqtt component
// 4. Implementar mqtt_handlers.c com ArduinoJson parsing
// 5. Integrar tudo no main.c
// 6. Configurar SPIFFS para servir arquivos web
// 7. Testar compilação com pio run
// 8. Flash no hardware e verificar
//
// ESTRUTURA DO PROJETO:
// cisterna/
// ├── include/
// │   └── config.h ✓
// ├── src/
// │   ├── drivers/ ✓
// │   │   ├── ultrasonic_driver.c/h
// │   │   ├── relay_driver.c/h
// │   │   ├── display_driver.c/h
// │   │   └── button_driver.c/h
// │   ├── services/ ✓
// │   │   ├── level_measurement.c/h
// │   │   ├── pump_actuation.c/h
// │   │   ├── button_service.c/h
// │   │   └── display_service.c/h
// │   ├── persistence/ ✓
// │   │   └── config_manager.c/h
// │   ├── provisioning/ ✓
// │   │   └── provisioning.c/h
// │   ├── network/ ⚠️ PENDENTE
// │   │   ├── wifi_manager.c/h
// │   │   ├── web_server.c/h
// │   │   └── mqtt_manager.c/h
// │   ├── messaging/ ⚠️ PENDENTE
// │   │   └── mqtt_handlers.c/h
// │   ├── ota/ ⚠️ PENDENTE
// │   │   └── ota_manager.c/h
// │   └── main.c ✓
// ├── data/
// │   └── www/ ✓
// │       ├── setup.html
// │       ├── index.html
// │       ├── style.css
// │       └── app.js
// ├── platformio.ini ✓
// ├── partitions.csv ✓
// └── README_NETWORK_IMPLEMENTATION.txt (este arquivo)
//
// REFERÊNCIAS PARA IMPLEMENTAÇÃO:
// - ESP-IDF WiFi: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/network/esp_wifi.html
// - ESP-IDF HTTP Server: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/protocols/esp_http_server.html
// - ESP-MQTT: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/protocols/mqtt.html
// - ArduinoJson: https://arduinojson.org/
// - SPIFFS: https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/spiffs.html
