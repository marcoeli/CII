// Provisioning Module Implementation
// NOTE: This is a simplified implementation outline
// Full MQTT client integration will be done in the main application

#include "provisioning.h"
#include "../persistence/config_manager.h"
#include "../network/mqtt_manager.h"
#include "../include/config.h"
#include "esp_log.h"
#include "esp_random.h"
#include "esp_mac.h" // Retained as esp_read_mac is used
#include "cJSON.h"
#include <stdio.h>
#include <string.h>

static provisioning_state_t current_state = PROV_STATE_IDLE;
static provisioning_success_cb_t success_callback = NULL;
static provisioning_error_cb_t error_callback = NULL;
static char correlation_id[40] = {0};
static char device_mac[18] = {0};

// Generate UUID-like correlation ID
static void generate_correlation_id(void) {
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    uint32_t random = esp_random();
    
    snprintf(correlation_id, sizeof(correlation_id),
             "%02x%02x%02x%02x-%04x-%04x",
             mac[0], mac[1], mac[2], mac[3],
             (uint16_t)(random >> 16),
             (uint16_t)(random & 0xFFFF));
}

// Get device MAC address as string
static void get_device_mac(void) {
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    snprintf(device_mac, sizeof(device_mac),
             "%02X:%02X:%02X:%02X:%02X:%02X",
             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}

int provisioning_init(void) {
    current_state = PROV_STATE_IDLE;
    get_device_mac();
    generate_correlation_id();  // Generate correlation ID at init
    ESP_LOGI("PROV", "Provisioning init - MAC: %s, Correlation ID: %s", device_mac, correlation_id);
    return 0;
}

int provisioning_start(provisioning_success_cb_t success_cb,
                       provisioning_error_cb_t error_cb) {
    // Check if already provisioned
    if (config_is_provisioned()) {
        current_state = PROV_STATE_FAILED;
        if (error_cb) {
            error_cb(PROV_ERR_ALREADY_PROVISIONED, "Device already provisioned");
        }
        return -1;
    }
    
    success_callback = success_cb;
    error_callback = error_cb;
    
    // Generate new correlation ID for this attempt
    generate_correlation_id();
    
    current_state = PROV_STATE_CONNECTING;
    
    // NOTE: Actual MQTT connection and provisioning logic
    // will be handled by the main application and MQTT manager
    // This module provides the data structures and state management
    
    return 0;
}

// Build provisioning registration payload (JSON)
// Returns payload string (must be freed by caller)
char* provisioning_build_registration_payload(void) {
    static char payload[1024];
    char tenant[64] = {0}, home[64] = {0};
    config_get_context(tenant, sizeof(tenant), home, sizeof(home));
    
    auth_mode_t auth_mode = config_get_auth_mode();
    char auth_token[64] = {0};
    
    if (auth_mode == AUTH_MODE_DEV) {
        config_get_dev_token(auth_token, sizeof(auth_token));
    } else {
        config_get_claim_code(auth_token, sizeof(auth_token));
    }

    snprintf(payload, sizeof(payload),
             "{"
             "\"id\":\"%s\","
             "\"mac\":\"%s\","
             "\"type\":\"%s\","
             "\"fw\":\"%s\","
             "\"auth\":{"
             "\"mode\":\"%s\","
             "\"token\":\"%s\""
             "},"
             "\"resources\":["
             "{\"id\":\"water.level.cistern\",\"kind\":\"water.level\"},"
             "{\"id\":\"water.pump.cistern_pump_1\",\"kind\":\"water.pump\"},"
             "{\"id\":\"water.pump.cistern_pump_2\",\"kind\":\"water.pump\"}"
             "],"
             "\"correlation_id\":\"%s\""
             "}",
             DEVICE_TYPE, // Using DEVICE_TYPE as base ID for simplicity or just MAC
             device_mac,
             DEVICE_TYPE,
             FIRMWARE_VERSION,
             (auth_mode == AUTH_MODE_DEV) ? "dev" : "prod",
             auth_token,
             correlation_id);
    
    return payload;
}

// Parse provisioning response
// Returns 0 on success, -1 on error
int provisioning_parse_response(const char* json_response) {
    if (!json_response) return -1;
    
    cJSON *root = cJSON_Parse(json_response);
    if (!root) {
        ESP_LOGE("PROV", "Failed to parse JSON response");
        return -1;
    }
    
    cJSON *ok_item = cJSON_GetObjectItem(root, "ok");
    if (ok_item && cJSON_IsTrue(ok_item)) {
        // Success - extract credentials (V2.4 Structure)
        // Response format: {"ok":true,"username":"...","password":"...","mqtts":{"host":"...","port":8883},"acls":[...]}
        
        cJSON *username_item = cJSON_GetObjectItem(root, "username");
        cJSON *password_item = cJSON_GetObjectItem(root, "password");
        cJSON *mqtts = cJSON_GetObjectItem(root, "mqtts");
        
        const char *user = cJSON_GetStringValue(username_item);
        const char *pass = cJSON_GetStringValue(password_item);
        const char *broker = NULL;
        int port = 0;
        
        if (mqtts) {
            broker = cJSON_GetStringValue(cJSON_GetObjectItem(mqtts, "host"));
            port = cJSON_GetNumberValue(cJSON_GetObjectItem(mqtts, "port"));
        }
        
        if (user && pass && broker) {
            config_save_mqtt_credentials(user, pass, broker, (uint16_t)port);
            ESP_LOGI("PROV", "MQTT credentials saved: %s @ %s:%d", user, broker, port);
        } else {
             ESP_LOGE("PROV", "Failed to extract credentials from response");
        }
        
        // Extract ACLs V2.4 (Array of Objects)
        // [{"permission":"allow","action":"...","topic":"..."}]
        cJSON *acls = cJSON_GetObjectItem(root, "acls");
        if (acls && cJSON_IsArray(acls)) {
            char acl_buffer[2048] = {0}; // Increased buffer for full ACL list
            int offset = 0;
            int size = cJSON_GetArraySize(acls);
            
            for (int i = 0; i < size; i++) {
                cJSON *item = cJSON_GetArrayItem(acls, i);
                cJSON *topic_item = cJSON_GetObjectItem(item, "topic");
                
                if (topic_item && cJSON_IsString(topic_item)) {
                    const char* topic = topic_item->valuestring;
                    // Append topic to comma-separated list/buffer for internal check
                    int written = snprintf(acl_buffer + offset, sizeof(acl_buffer) - offset, 
                                       "%s%s", topic, (i == size - 1) ? "" : ";");
                    if (written > 0) offset += written;
                }
            }
            config_save_acl_topics(acl_buffer);
            ESP_LOGI("PROV", "ACLs saved (%d bytes)", offset);
        }
        
        current_state = PROV_STATE_SUCCESS;
        config_set_provisioned(true);
        config_clear_claim_code();
        // DEV token isn't cleared in V2.4 based on logs showing 'dev' mode used, but safe to keep logic consistent
        config_clear_dev_token(); // Also clear dev token for safety
        
        if (success_callback) {
            success_callback();
        }
        
        cJSON_Delete(root);
        return 0;
    } else {
        // Error
        current_state = PROV_STATE_FAILED;
        const char* detail = cJSON_GetStringValue(cJSON_GetObjectItem(root, "detail"));
        
        if (error_callback) {
            error_callback(PROV_ERR_SERVER_REJECTED, detail ? detail : "Server rejected registration");
        }
        
        cJSON_Delete(root);
        return -1;
    }
}

provisioning_state_t provisioning_get_state(void) {
    return current_state;
}

const char* provisioning_get_correlation_id(void) {
    return correlation_id;
}

void provisioning_cancel(void) {
    current_state = PROV_STATE_IDLE;
    success_callback = NULL;
    error_callback = NULL;
}

// Update provisioning state (called by MQTT manager)
void provisioning_set_state(provisioning_state_t state) {
    current_state = state;
}
