// Web Server Implementation - ESP-IDF HTTP Server

#include "web_server.h"
#include "wifi_manager.h"
#include "../persistence/config_manager.h"
#include "../include/resource_names.h"
#include "../include/topic_builder.h"
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"
#include "../domain/cistern_controller.h"
#include "../include/config.h"
#include "esp_http_server.h"
#include "esp_log.h"
#include "esp_spiffs.h"
#include "cJSON.h"
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

static const char *TAG = "WEB_SRV";

static httpd_handle_t server = NULL;

// Helper function to get content type from file extension
static const char* get_content_type(const char* filename) {
    if (strstr(filename, ".html")) return "text/html";
    if (strstr(filename, ".css")) return "text/css";
    if (strstr(filename, ".js")) return "application/javascript";
    if (strstr(filename, ".json")) return "application/json";
    if (strstr(filename, ".png")) return "image/png";
    if (strstr(filename, ".jpg") || strstr(filename, ".jpeg")) return "image/jpeg";
    return "text/plain";
}

// Helper function to serve file from SPIFFS
static esp_err_t serve_spiffs_file(httpd_req_t *req, const char* filepath) {
    ESP_LOGI(TAG, "Attempting to serve file: %s", filepath);
    
    FILE *fd = fopen(filepath, "r");
    if (!fd) {
        ESP_LOGE(TAG, "Failed to open file: %s (errno=%d)", filepath, errno);
        return ESP_FAIL;  // Don't send 404 here, let handler decide
    }
    
    ESP_LOGI(TAG, "File opened successfully: %s", filepath);
    
    // Get file size
    struct stat file_stat;
    if (stat(filepath, &file_stat) != 0) {
        ESP_LOGE(TAG, "Failed to stat file: %s", filepath);
        fclose(fd);
        return ESP_FAIL;
    }
    
    ESP_LOGI(TAG, "File size: %ld bytes", file_stat.st_size);
    
    httpd_resp_set_type(req, get_content_type(filepath));
    
    char *chunk = malloc(1024);
    if (!chunk) {
        ESP_LOGE(TAG, "Failed to allocate chunk buffer");
        fclose(fd);
        return ESP_FAIL;
    }
    
    size_t chunksize;
    do {
        chunksize = fread(chunk, 1, 1024, fd);
        if (chunksize > 0) {
            if (httpd_resp_send_chunk(req, chunk, chunksize) != ESP_OK) {
                ESP_LOGE(TAG, "Failed to send chunk");
                free(chunk);
                fclose(fd);
                return ESP_FAIL;
            }
        }
    } while (chunksize != 0);
    
    ESP_LOGI(TAG, "File sent successfully: %s", filepath);
    free(chunk);
    fclose(fd);
    httpd_resp_send_chunk(req, NULL, 0);
    return ESP_OK;
}

// ============================================================================
// Handler: GET /
// ============================================================================
static esp_err_t root_handler(httpd_req_t *req) {
    // Try SPIFFS first, fallback to embedded HTML
    esp_err_t ret = serve_spiffs_file(req, "/spiffs/www/index.html");
    if (ret != ESP_OK) {
        // Fallback to embedded HTML
        const char* html = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Cisterna Patio</title></head>"
                          "<body><h1>Cisterna Patio</h1><p>Sistema funcionando!</p>"
                          "<p><a href='/setup'>Configuração WiFi</a></p></body></html>";
        httpd_resp_set_type(req, "text/html");
        httpd_resp_send(req, html, strlen(html));
    }
    return ESP_OK;
}

// ============================================================================
// Handler: GET /setup
// ============================================================================
static esp_err_t setup_handler(httpd_req_t *req) {
    // Try SPIFFS first, fallback to embedded HTML
    esp_err_t ret = serve_spiffs_file(req, "/spiffs/www/setup.html");
    if (ret != ESP_OK) {
        // Fallback to embedded setup page
        const char* html = 
            "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>WiFi Setup</title>"
            "<style>body{font-family:Arial;max-width:400px;margin:50px auto;padding:20px}"
            "input{width:100%;padding:10px;margin:10px 0;box-sizing:border-box}"
            "button{width:100%;padding:15px;background:#4CAF50;color:white;border:none;cursor:pointer}"
            "button:hover{background:#45a049}</style></head><body>"
            "<h2>Configuração WiFi</h2>"
            "<form action='/api/wifi' method='POST'>"
            "<label>SSID:</label><input type='text' name='ssid' required>"
            "<label>Senha:</label><input type='password' name='password' required>"
            "<button type='submit'>Salvar e Conectar</button>"
            "</form></body></html>";
        httpd_resp_set_type(req, "text/html");
        httpd_resp_send(req, html, strlen(html));
    }
    return ESP_OK;
}
// Handler for /resources page
static esp_err_t resources_handler(httpd_req_t *req) {
    return serve_spiffs_file(req, "/spiffs/www/resources.html");
}

// ============================================================================
// Handler: GET /style.css
// ============================================================================
static esp_err_t style_handler(httpd_req_t *req) {
    return serve_spiffs_file(req, "/spiffs/www/style.css");
}

// ============================================================================
// Handler: GET /app.js
// ============================================================================
static esp_err_t app_js_handler(httpd_req_t *req) {
    return serve_spiffs_file(req, "/spiffs/www/app.js");
}

// ============================================================================
// Handler: GET /api/mode
// ============================================================================
static esp_err_t api_mode_handler(httpd_req_t *req) {
    cJSON *root = cJSON_CreateObject();
    
    #if PROVISIONING_MODE == MODE_DEV
        cJSON_AddStringToObject(root, "mode", "dev");
    #else
        cJSON_AddStringToObject(root, "mode", "prod");
    #endif
    
    char *response = cJSON_PrintUnformatted(root);
    cJSON_Delete(root);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: GET /api/scan
// ============================================================================
static esp_err_t api_scan_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "Scanning WiFi networks...");
    
    int count = wifi_manager_scan_networks();
    
    // Create array directly (no wrapper object)
    cJSON *networks = cJSON_CreateArray();
    
    for (int i = 0; i < count && i < 20; i++) {
        cJSON *net = cJSON_CreateObject();
        cJSON_AddStringToObject(net, "ssid", wifi_manager_get_scanned_ssid(i));
        cJSON_AddNumberToObject(net, "rssi", wifi_manager_get_scanned_rssi(i));
        cJSON_AddItemToArray(networks, net);
    }
    
    char *response = cJSON_PrintUnformatted(networks);
    cJSON_Delete(networks);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: POST /api/wifi
// ============================================================================
static esp_err_t api_wifi_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "WiFi API handler called");
    
    char content[512];
    int ret = httpd_req_recv(req, content, sizeof(content) - 1);
    if (ret <= 0) {
        ESP_LOGE(TAG, "Failed to receive data: %d", ret);
        cJSON *err = cJSON_CreateObject();
        cJSON_AddBoolToObject(err, "ok", false);
        cJSON_AddStringToObject(err, "error", "no_data");
        char *response = cJSON_PrintUnformatted(err);
        cJSON_Delete(err);
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
        return ESP_OK;
    }
    content[ret] = '\0';
    
    ESP_LOGI(TAG, "Received data: %s", content);
    
    char ssid[64] = {0};
    char password[64] = {0};
    char claim_code[64] = {0};
    char tenant[64] = {0};
    char home[64] = {0};
    char dev_token[64] = {0};
    auth_mode_t auth_mode = AUTH_MODE_PROD;
    
    // Try JSON parsing first (setup.html sends JSON)
    cJSON *doc = cJSON_Parse(content);
    if (doc) {
        ESP_LOGI(TAG, "Parsing JSON data");
        cJSON *ssid_item = cJSON_GetObjectItem(doc, "ssid");
        cJSON *pass_item = cJSON_GetObjectItem(doc, "password");
        cJSON *claim_item = cJSON_GetObjectItem(doc, "claim_code");
        cJSON *tenant_item = cJSON_GetObjectItem(doc, "tenant");
        cJSON *home_item = cJSON_GetObjectItem(doc, "home");
        cJSON *dev_token_item = cJSON_GetObjectItem(doc, "dev_token");
        cJSON *auth_mode_item = cJSON_GetObjectItem(doc, "auth_mode");
        
        if (ssid_item && cJSON_IsString(ssid_item)) {
            strncpy(ssid, cJSON_GetStringValue(ssid_item), sizeof(ssid) - 1);
        }
        if (pass_item && cJSON_IsString(pass_item)) {
            strncpy(password, cJSON_GetStringValue(pass_item), sizeof(password) - 1);
        }
        if (claim_item && cJSON_IsString(claim_item)) {
            strncpy(claim_code, cJSON_GetStringValue(claim_item), sizeof(claim_code) - 1);
        }
        if (tenant_item && cJSON_IsString(tenant_item)) {
            strncpy(tenant, cJSON_GetStringValue(tenant_item), sizeof(tenant) - 1);
        }
        if (home_item && cJSON_IsString(home_item)) {
            strncpy(home, cJSON_GetStringValue(home_item), sizeof(home) - 1);
        }
        if (dev_token_item && cJSON_IsString(dev_token_item)) {
            strncpy(dev_token, cJSON_GetStringValue(dev_token_item), sizeof(dev_token) - 1);
        }
        if (auth_mode_item && cJSON_IsString(auth_mode_item)) {
            const char* mode_str = cJSON_GetStringValue(auth_mode_item);
            if (strcmp(mode_str, "dev") == 0) {
                auth_mode = AUTH_MODE_DEV;
            }
        }
        
        cJSON_Delete(doc);
        ESP_LOGI(TAG, "JSON parsed: SSID='%s', Tenant='%s'", ssid, tenant);
    }
    // Fallback to form-urlencoded (ssid=xxx&password=yyy)
    else if (strstr(content, "ssid=") != NULL) {
        ESP_LOGI(TAG, "Parsing form-urlencoded data");
        char *ssid_start = strstr(content, "ssid=");
        char *pass_start = strstr(content, "password=");
        
        if (ssid_start && pass_start) {
            ssid_start += 5;  // Skip "ssid="
            char *ssid_end = strchr(ssid_start, '&');
            if (ssid_end) {
                int len = ssid_end - ssid_start;
                if (len < sizeof(ssid)) {
                    strncpy(ssid, ssid_start, len);
                    ssid[len] = '\0';
                }
            } else {
                strncpy(ssid, ssid_start, sizeof(ssid) - 1);
            }
            
            pass_start += 9;  // Skip "password="
            char *pass_end = strchr(pass_start, '&');
            int pass_len = pass_end ? (pass_end - pass_start) : strlen(pass_start);
            if (pass_len < sizeof(password)) {
                strncpy(password, pass_start, pass_len);
                password[pass_len] = '\0';
            }
            
            ESP_LOGI(TAG, "Form parsed: SSID='%s'", ssid);
        }
    }
    
    // Validate
    if (strlen(ssid) == 0) {
        ESP_LOGE(TAG, "SSID is empty!");
        cJSON *err = cJSON_CreateObject();
        cJSON_AddBoolToObject(err, "ok", false);
        cJSON_AddStringToObject(err, "error", "missing_ssid");
        char *response = cJSON_PrintUnformatted(err);
        cJSON_Delete(err);
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
        return ESP_OK;
    }
    
    // Save credentials
    ESP_LOGI(TAG, "Saving WiFi credentials...");
    config_save_wifi_credentials(ssid, password);
    
    // Save Context V2.4
    if (strlen(tenant) == 0) strcpy(tenant, "default");
    if (strlen(home) == 0) strcpy(home, "main");
    
    ESP_LOGI(TAG, "Saving context: %s/%s", tenant, home);
    config_save_context(tenant, home);
    
    // Save Auth V2.4
    config_save_auth_mode(auth_mode);
    if (auth_mode == AUTH_MODE_DEV && strlen(dev_token) > 0) {
        ESP_LOGI(TAG, "Saving dev token");
        config_save_dev_token(dev_token);
    } else if (strlen(claim_code) > 0) {
        ESP_LOGI(TAG, "Saving claim code: %s", claim_code);
        config_save_claim_code(claim_code);
    }
    
    // Send success response
    cJSON *resp = cJSON_CreateObject();
    cJSON_AddBoolToObject(resp, "ok", true);
    cJSON_AddStringToObject(resp, "message", "Configuration saved. Rebooting...");
    
    char *response = cJSON_PrintUnformatted(resp);
    cJSON_Delete(resp);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    free(response);
    
    // Reboot after 2 seconds
    ESP_LOGI(TAG, "Configuration saved. Rebooting in 2s...");
    vTaskDelay(pdMS_TO_TICKS(2000));
    esp_restart();
    
    return ESP_OK;
}

// ============================================================================
// Handler: GET /api/status
// ============================================================================
static esp_err_t api_status_handler(httpd_req_t *req) {
    // ESP_LOGI("WEB_API", "API status requested"); // Uncomment for debugging
    const controller_context_t* ctx = cistern_controller_get_context();
    
    cJSON *root = cJSON_CreateObject();
    
    // Level data
    cJSON *level = cJSON_CreateObject();
    if (ctx->last_level.valid) {
        cJSON_AddNumberToObject(level, "percent", ctx->last_level.percent);
        cJSON_AddNumberToObject(level, "liters", ctx->last_level.liters);
        
        const char* alert_str = "NORMAL";
        switch(ctx->last_level.alert) {
            case LEVEL_ALERT_OVERFLOW: alert_str = "OVERFLOW"; break;
            case LEVEL_ALERT_HIGH: alert_str = "HIGH"; break;
            case LEVEL_ALERT_LOW: alert_str = "LOW"; break;
            case LEVEL_ALERT_CRITICAL_LOW: alert_str = "CRITICAL"; break;
            default: break;
        }
        cJSON_AddStringToObject(level, "alert", alert_str);
    }
    cJSON_AddItemToObject(root, "level", level);
    
    // Pump states
    cJSON *pump1 = cJSON_CreateObject();
    cJSON_AddBoolToObject(pump1, "running", ctx->pump1_state.running);
    cJSON_AddStringToObject(pump1, "mode", (ctx->pump1_state.mode == PUMP_MODE_AUTO) ? "auto" : "manual");
    cJSON_AddItemToObject(root, "pump1", pump1);
    
    cJSON *pump2 = cJSON_CreateObject();
    cJSON_AddBoolToObject(pump2, "running", ctx->pump2_state.running);
    cJSON_AddStringToObject(pump2, "mode", (ctx->pump2_state.mode == PUMP_MODE_AUTO) ? "auto" : "manual");
    cJSON_AddItemToObject(root, "pump2", pump2);
    
    // Connection status
    cJSON_AddBoolToObject(root, "wifi_connected", ctx->wifi_connected);
    cJSON_AddBoolToObject(root, "mqtt_connected", ctx->mqtt_connected);
    
    char *response = cJSON_PrintUnformatted(root);
    cJSON_Delete(root);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: GET /api/config
// ============================================================================
static esp_err_t api_config_get_handler(httpd_req_t *req) {
    tank_config_t tank_cfg;
    
    cJSON *root = cJSON_CreateObject();
    
    if (config_get_tank_config(&tank_cfg) == 0) {
        cJSON *tank = cJSON_CreateObject();
        cJSON_AddStringToObject(tank, "shape", (tank_cfg.shape == TANK_SHAPE_CYLINDRICAL) ? "cylindrical" : "rectangular");
        cJSON_AddNumberToObject(tank, "height", tank_cfg.height_cm);
        cJSON_AddNumberToObject(tank, "width", tank_cfg.width_cm);
        cJSON_AddNumberToObject(tank, "depth", tank_cfg.depth_cm);
        cJSON_AddNumberToObject(tank, "diameter_top", tank_cfg.diameter_top_cm);
        cJSON_AddNumberToObject(tank, "diameter_bottom", tank_cfg.diameter_bottom_cm);
        cJSON_AddNumberToObject(tank, "sensor_offset", tank_cfg.sensor_offset_cm);
        cJSON_AddItemToObject(root, "tank", tank);
    }
    
    // Add report interval
    cJSON_AddNumberToObject(root, "report_interval", config_get_report_interval());
    
    // Add temperature
    cJSON_AddNumberToObject(root, "temperature", config_get_temperature());
    
    char *response = cJSON_PrintUnformatted(root);
    cJSON_Delete(root);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: POST /api/config
// ============================================================================
static esp_err_t api_config_post_handler(httpd_req_t *req) {
    char content[512];
    int ret = httpd_req_recv(req, content, sizeof(content) - 1);
    
    if (ret <= 0) {
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to read request");
        return ESP_FAIL;
    }
    
    content[ret] = '\0';
    
    cJSON *doc = cJSON_Parse(content);
    
    if (!doc) {
        cJSON *resp = cJSON_CreateObject();
        cJSON_AddBoolToObject(resp, "ok", false);
        cJSON_AddStringToObject(resp, "error", "invalid_json");
        
        char *response = cJSON_PrintUnformatted(resp);
        cJSON_Delete(resp);
        
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
        return ESP_FAIL;
    }
    
    // Config updated flag
    bool updated = false;

    // Handle report_interval
    if (cJSON_HasObjectItem(doc, "report_interval")) {
        uint32_t interval = (uint32_t)cJSON_GetNumberValue(cJSON_GetObjectItem(doc, "report_interval"));
        if (config_save_report_interval(interval) == 0) {
            updated = true;
        }
    }

    // Handle temperature
    if (cJSON_HasObjectItem(doc, "temperature")) {
        float temp = (float)cJSON_GetNumberValue(cJSON_GetObjectItem(doc, "temperature"));
        if (config_save_temperature(temp) == 0) {
            level_measurement_set_temperature(temp); // Apply immediately
            updated = true;
        }
    }


    
    // Parse tank configuration
    cJSON *tank_obj = cJSON_GetObjectItem(doc, "tank");
    if (tank_obj) {
        tank_config_t tank_cfg;
        memset(&tank_cfg, 0, sizeof(tank_cfg));
        
        cJSON *shape_item = cJSON_GetObjectItem(tank_obj, "shape");
        const char* shape = cJSON_GetStringValue(shape_item);
        tank_cfg.shape = (shape && strcmp(shape, "cylindrical") == 0) ? 
                         TANK_SHAPE_CYLINDRICAL : TANK_SHAPE_RECTANGULAR;
        
        cJSON *item;
        if ((item = cJSON_GetObjectItem(tank_obj, "height"))) tank_cfg.height_cm = item->valuedouble;
        if ((item = cJSON_GetObjectItem(tank_obj, "width"))) tank_cfg.width_cm = item->valuedouble;
        if ((item = cJSON_GetObjectItem(tank_obj, "depth"))) tank_cfg.depth_cm = item->valuedouble;
        if ((item = cJSON_GetObjectItem(tank_obj, "diameter_top"))) tank_cfg.diameter_top_cm = item->valuedouble;
        if ((item = cJSON_GetObjectItem(tank_obj, "diameter_bottom"))) tank_cfg.diameter_bottom_cm = item->valuedouble;
        if ((item = cJSON_GetObjectItem(tank_obj, "sensor_offset"))) tank_cfg.sensor_offset_cm = item->valuedouble;
        
        config_save_tank_config(&tank_cfg);
        level_measurement_set_config(&tank_cfg);
    }
    
    cJSON *resp = cJSON_CreateObject();
    cJSON_AddBoolToObject(resp, "ok", true);
    cJSON_AddBoolToObject(resp, "updated", updated);
    
    char *response = cJSON_PrintUnformatted(resp);
    cJSON_Delete(resp);
    cJSON_Delete(doc);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: GET /api/resources
// ============================================================================
static esp_err_t api_resources_get_handler(httpd_req_t *req) {
    resource_names_t names;
    
    // Load current resource names
    if (resource_names_load(&names) != 0) {
        // No stored config, use defaults
        resource_names_set_defaults(&names);
    }
    
    cJSON *root = cJSON_CreateObject();
    
    // Add pump names
    cJSON *pumps = cJSON_CreateArray();
    for (int i = 0; i < names.pump_count; i++) {
        cJSON_AddItemToArray(pumps, cJSON_CreateString(names.pump_names[i]));
    }
    cJSON_AddItemToObject(root, "pumps", pumps);
    
    // Add level sensor names
    cJSON *levels = cJSON_CreateArray();
    for (int i = 0; i < names.level_count; i++) {
        cJSON_AddItemToArray(levels, cJSON_CreateString(names.level_names[i]));
    }
    cJSON_AddItemToObject(root, "levels", levels);
    
    char *response = cJSON_PrintUnformatted(root);
    cJSON_Delete(root);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    
    free(response);
    return ESP_OK;
}

// ============================================================================
// Handler: POST /api/resources
// ============================================================================
static esp_err_t api_resources_post_handler(httpd_req_t *req) {
    char content[512];
    int ret = httpd_req_recv(req, content, sizeof(content) - 1);
    
    if (ret <= 0) {
        cJSON *err = cJSON_CreateObject();
        cJSON_AddBoolToObject(err, "ok", false);
        cJSON_AddStringToObject(err, "error", "no_data");
        
        char *response = cJSON_PrintUnformatted(err);
        cJSON_Delete(err);
        
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
        return ESP_OK;
    }
    
    content[ret] = '\0';
    
    cJSON *doc = cJSON_Parse(content);
    if (!doc) {
        cJSON *err = cJSON_CreateObject();
        cJSON_AddBoolToObject(err, "ok", false);
        cJSON_AddStringToObject(err, "error", "invalid_json");
        
        char *response = cJSON_PrintUnformatted(err);
        cJSON_Delete(err);
        
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
        return ESP_OK;
    }
    
    resource_names_t names;
    memset(&names, 0, sizeof(names));
    
    // Parse pumps array
    cJSON *pumps = cJSON_GetObjectItem(doc, "pumps");
    if (pumps && cJSON_IsArray(pumps)) {
        int count = cJSON_GetArraySize(pumps);
        names.pump_count = (count > MAX_PUMPS) ? MAX_PUMPS : count;
        
        for (int i = 0; i < names.pump_count; i++) {
            cJSON *item = cJSON_GetArrayItem(pumps, i);
            if (cJSON_IsString(item)) {
                strncpy(names.pump_names[i], cJSON_GetStringValue(item), RESOURCE_NAME_LEN - 1);
            }
        }
    }
    
    // Parse levels array
    cJSON *levels = cJSON_GetObjectItem(doc, "levels");
    if (levels && cJSON_IsArray(levels)) {
        int count = cJSON_GetArraySize(levels);
        names.level_count = (count > MAX_LEVELS) ? MAX_LEVELS : count;
        
        for (int i = 0; i < names.level_count; i++) {
            cJSON *item = cJSON_GetArrayItem(levels, i);
            if (cJSON_IsString(item)) {
                strncpy(names.level_names[i], cJSON_GetStringValue(item), RESOURCE_NAME_LEN - 1);
            }
        }
    }
    
    // Save to NVS
    if (resource_names_save(&names) == 0) {
        // Reload topic builder cache
        topic_builder_reload();
        
        cJSON *resp = cJSON_CreateObject();
        cJSON_AddBoolToObject(resp, "ok", true);
        cJSON_AddStringToObject(resp, "message", "Resources saved successfully");
        
        char *response = cJSON_PrintUnformatted(resp);
        cJSON_Delete(resp);
        cJSON_Delete(doc);
        
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
    } else {
        cJSON *err = cJSON_CreateObject();
        cJSON_AddBoolToObject(err, "ok", false);
        cJSON_AddStringToObject(err, "error", "save_failed");
        
        char *response = cJSON_PrintUnformatted(err);
        cJSON_Delete(err);
        cJSON_Delete(doc);
        
        httpd_resp_set_type(req, "application/json");
        httpd_resp_send(req, response, strlen(response));
        free(response);
    }
    
    return ESP_OK;
}

// ============================================================================
// Handler: POST /api/command
// ============================================================================
static esp_err_t api_command_handler(httpd_req_t *req) {
    char content[512];
    int ret = httpd_req_recv(req, content, sizeof(content) - 1);
    
    if (ret <= 0) {
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to read request");
        return ESP_FAIL;
    }
    
    content[ret] = '\0';
    cJSON *doc = cJSON_Parse(content);
    
    if (!doc) {
        httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, "Invalid JSON");
        return ESP_FAIL;
    }
    
    // Parse command
    cJSON *cmd_item = cJSON_GetObjectItem(doc, "command");
    cJSON *pump_item = cJSON_GetObjectItem(doc, "pump");
    
    bool success = false;
    const char* error_msg = "Unknown command";
    
    if (cmd_item && cJSON_IsString(cmd_item) && pump_item && cJSON_IsNumber(pump_item)) {
        const char* cmd = cJSON_GetStringValue(cmd_item);
        int pump_idx = pump_item->valueint;
        pump_id_t pump_id = (pump_idx == 0) ? PUMP_1 : (pump_idx == 1) ? PUMP_2 : -1;
        
        if (pump_id != -1) {
            if (strcmp(cmd, "toggle") == 0) {
                // Get current state to toggle
                pump_state_t state = pump_get_state(pump_id);
                if (state.running) {
                    pump_stop(pump_id, "web_user");
                    success = true;
                } else {
                    pump_start(pump_id, "web_user", true); // Force manually
                    success = true;
                }
            } else if (strcmp(cmd, "on") == 0) {
                pump_start(pump_id, "web_user", true);
                success = true;
            } else if (strcmp(cmd, "off") == 0) {
                pump_stop(pump_id, "web_user");
                success = true;
            }
        } else {
            error_msg = "Invalid pump ID";
        }
    }
    
    cJSON *resp = cJSON_CreateObject();
    cJSON_AddBoolToObject(resp, "ok", success);
    if (!success) cJSON_AddStringToObject(resp, "error", error_msg);
    
    char *response = cJSON_PrintUnformatted(resp);
    cJSON_Delete(resp);
    cJSON_Delete(doc);
    
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, response, strlen(response));
    free(response);
    return ESP_OK;
}

// ============================================================================
// Server Configuration
// ============================================================================

static const httpd_uri_t uri_root = {
    .uri = "/",
    .method = HTTP_GET,
    .handler = root_handler
};

static const httpd_uri_t uri_setup = {
    .uri = "/setup",
    .method = HTTP_GET,
    .handler = setup_handler
};

static const httpd_uri_t uri_resources = {
    .uri = "/resources",
    .method = HTTP_GET,
    .handler = resources_handler
};

static const httpd_uri_t uri_api_mode = {
    .uri = "/api/mode",
    .method = HTTP_GET,
    .handler = api_mode_handler
};

static const httpd_uri_t uri_api_scan = {
    .uri = "/api/scan",
    .method = HTTP_GET,
    .handler = api_scan_handler
};

static const httpd_uri_t uri_api_wifi = {
    .uri = "/api/wifi",
    .method = HTTP_POST,
    .handler = api_wifi_handler
};

static const httpd_uri_t uri_api_status = {
    .uri = "/api/status",
    .method = HTTP_GET,
    .handler = api_status_handler
};

static const httpd_uri_t uri_api_config_get = {
    .uri = "/api/config",
    .method = HTTP_GET,
    .handler = api_config_get_handler
};

static const httpd_uri_t uri_api_config_post = {
    .uri = "/api/config",
    .method = HTTP_POST,
    .handler = api_config_post_handler
};

static const httpd_uri_t uri_style = {
    .uri = "/style.css",
    .method = HTTP_GET,
    .handler = style_handler
};

static const httpd_uri_t uri_app_js = {
    .uri = "/app.js",
    .method = HTTP_GET,
   .handler = app_js_handler
};

static const httpd_uri_t uri_api_resources_get = {
    .uri = "/api/resources",
    .method = HTTP_GET,
    .handler = api_resources_get_handler
};

static const httpd_uri_t uri_api_resources_post = {
    .uri = "/api/resources",
    .method = HTTP_POST,
    .handler = api_resources_post_handler
};

static const httpd_uri_t uri_api_command = {
    .uri = "/api/command",
    .method = HTTP_POST,
    .handler = api_command_handler
};

// ============================================================================
// Public Functions
// ============================================================================

int web_server_init(void) {
    // Initialize SPIFFS
    esp_vfs_spiffs_conf_t conf = {
        .base_path = "/spiffs",
        .partition_label = NULL,
        .max_files = 5,
        .format_if_mount_failed = false
    };
    
    esp_err_t ret = esp_vfs_spiffs_register(&conf);
    if (ret != ESP_OK) {
        if (ret == ESP_FAIL) {
            ESP_LOGE(TAG, "Failed to mount or format filesystem");
        } else if (ret == ESP_ERR_NOT_FOUND) {
            ESP_LOGE(TAG, "Failed to find SPIFFS partition");
        } else {
            ESP_LOGE(TAG, "Failed to initialize SPIFFS (%s)", esp_err_to_name(ret));
        }
        return -1;
    }
    
    size_t total = 0, used = 0;
    ret = esp_spiffs_info(NULL, &total, &used);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "SPIFFS: %d KB total, %d KB used", total / 1024, used / 1024);
    }
    
    ESP_LOGI(TAG, "Web server initialized");
    return 0;
}

int web_server_start(void) {
    if (server) {
        ESP_LOGW(TAG, "Server already running");
        return 0;
    }
    
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    config.server_port = WEB_SERVER_PORT;
    config.max_uri_handlers = 16;
    config.lru_purge_enable = true;
    
    ESP_LOGI(TAG, "Starting HTTP server on port %d", config.server_port);
    
    if (httpd_start(&server, &config) == ESP_OK) {
        // Register URI handlers
        httpd_register_uri_handler(server, &uri_root);
        httpd_register_uri_handler(server, &uri_setup);
        httpd_register_uri_handler(server, &uri_resources);
        httpd_register_uri_handler(server, &uri_style);
        httpd_register_uri_handler(server, &uri_app_js);
        httpd_register_uri_handler(server, &uri_api_mode);
        httpd_register_uri_handler(server, &uri_api_scan);
        httpd_register_uri_handler(server, &uri_api_wifi);
        httpd_register_uri_handler(server, &uri_api_status);
        httpd_register_uri_handler(server, &uri_api_config_get);
        httpd_register_uri_handler(server, &uri_api_config_post);
        httpd_register_uri_handler(server, &uri_api_resources_get);
        httpd_register_uri_handler(server, &uri_api_resources_post);
        httpd_register_uri_handler(server, &uri_api_command);
        
        ESP_LOGI(TAG, "HTTP server started successfully");
        return 0;
    }
    
    ESP_LOGE(TAG, "Failed to start HTTP server");
    return -1;
}

void web_server_stop(void) {
    if (server) {
        httpd_stop(server);
        server = NULL;
        ESP_LOGI(TAG, "HTTP server stopped");
    }
}

bool web_server_is_running(void) {
    return (server != NULL);
}
