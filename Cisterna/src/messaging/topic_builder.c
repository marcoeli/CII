#include "topic_builder.h"
#include "../persistence/config_manager.h"
#include "esp_log.h"
#include <stdio.h>
#include <string.h>

static const char* TAG = "topic_builder";

// Resource IDs (Imutáveis conforme V2.4)
static const char* RESOURCE_ID_LEVEL = "water.level.cistern";
static const char* RESOURCE_ID_PUMPS[] = {
    "water.pump.cistern_pump_1",
    "water.pump.cistern_pump_2"
};

const char* topic_get_pump_command(uint8_t pump_index) {
    static char topic[256];
    char tenant[64], home[64];
    
    if (pump_index >= 2) return NULL;
    if (config_get_context(tenant, sizeof(tenant), home, sizeof(home)) != 0) return NULL;
    
    snprintf(topic, sizeof(topic), "home/%s/%s/r/%s/command", 
             tenant, home, RESOURCE_ID_PUMPS[pump_index]);
    
    return topic;
}

const char* topic_get_pump_state(uint8_t pump_index) {
    static char topic[256];
    char tenant[64], home[64];
    
    if (pump_index >= 2) return NULL;
    if (config_get_context(tenant, sizeof(tenant), home, sizeof(home)) != 0) return NULL;
    
    snprintf(topic, sizeof(topic), "home/%s/%s/r/%s/state", 
             tenant, home, RESOURCE_ID_PUMPS[pump_index]);
    
    return topic;
}

const char* topic_get_level(uint8_t level_index) {
    static char topic[256];
    char tenant[64], home[64];
    
    if (level_index != 0) return NULL;
    if (config_get_context(tenant, sizeof(tenant), home, sizeof(home)) != 0) return NULL;
    
    snprintf(topic, sizeof(topic), "home/%s/%s/r/%s/data", 
             tenant, home, RESOURCE_ID_LEVEL);
    
    return topic;
}

const char* topic_get_status(void) {
    static char topic[256];
    char tenant[64], home[64];
    
    if (config_get_context(tenant, sizeof(tenant), home, sizeof(home)) != 0) return NULL;
    
    // home/{tenant}/{home}/device/{username}/status
    char username[64], password[64], broker[64];
    uint16_t port;
    
    // Fetch credentials to get the username
    if (config_get_mqtt_credentials(username, sizeof(username), password, sizeof(password),
                                   broker, sizeof(broker), &port) != 0) {
        return NULL;
    }
    
    snprintf(topic, sizeof(topic), "home/%s/%s/device/%s/status", 
             tenant, home, username);
    
    return topic;
}

void topic_builder_reload(void) {
    // No longer needed for resource names, but kept for compatibility
    ESP_LOGI(TAG, "Topic builder (V2.4) reload called");
}
