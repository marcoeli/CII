#include "resource_names.h"
#include "../include/config.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_log.h"
#include <string.h>

static const char* TAG = "resource_names";
static const char* RESOURCE_NVS_NAMESPACE = "resource";
static const char* RESOURCE_NVS_KEY = "names";

void resource_names_set_defaults(resource_names_t* names) {
    if (!names) return;
    
    memset(names, 0, sizeof(resource_names_t));
    
    // Default pump names (based on cistern hardware)
    names->pump_count = 2;
    strncpy(names->pump_names[0], "cistern_pump_1", RESOURCE_NAME_LEN - 1);
    strncpy(names->pump_names[1], "cistern_pump_2", RESOURCE_NAME_LEN - 1);
    
    // Default level sensor name
    names->level_count = 1;
    strncpy(names->level_names[0], "cistern", RESOURCE_NAME_LEN - 1);
    
    ESP_LOGI(TAG, "Set default resource names");
}

int resource_names_save(const resource_names_t* names) {
    if (!names) return -1;
    
    nvs_handle_t handle;
    esp_err_t err;
    
    err = nvs_open(RESOURCE_NVS_NAMESPACE, NVS_READWRITE, &handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to open NVS namespace: %s", esp_err_to_name(err));
        return -1;
    }
    
    err = nvs_set_blob(handle, RESOURCE_NVS_KEY, names, sizeof(resource_names_t));
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save resource names: %s", esp_err_to_name(err));
        nvs_close(handle);
        return -1;
    }
    
    err = nvs_commit(handle);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to commit NVS: %s", esp_err_to_name(err));
        nvs_close(handle);
        return -1;
    }
    
    nvs_close(handle);
    
    ESP_LOGI(TAG, "Saved resource names (%d pumps, %d levels)", 
             names->pump_count, names->level_count);
    
    return 0;
}

int resource_names_load(resource_names_t* names) {
    if (!names) return -1;
    
    // Try to load from NVS
    nvs_handle_t handle;
    esp_err_t err = nvs_open(RESOURCE_NVS_NAMESPACE, NVS_READONLY, &handle);
    
    if (err == ESP_OK) {
        size_t required_size = sizeof(resource_names_t);
        err = nvs_get_blob(handle, RESOURCE_NVS_KEY, names, &required_size);
        nvs_close(handle);
        
        if (err == ESP_OK) {
            ESP_LOGI(TAG, "Loaded resource names from NVS (%d pumps, %d levels)",
                     names->pump_count, names->level_count);
            return 0;
        }
    }
    
    // Not found in NVS or failed to read - use defaults
    ESP_LOGW(TAG, "Resource names not found in NVS or failed to load - using defaults");
    resource_names_set_defaults(names);
    return 0;  // Return success with defaults
}

bool resource_names_is_configured(void) {
    resource_names_t temp;
    return (resource_names_load(&temp) == 0);
}

void resource_names_clear(void) {
    nvs_handle_t handle;
    esp_err_t err;
    
    err = nvs_open(RESOURCE_NVS_NAMESPACE, NVS_READWRITE, &handle);
    if (err != ESP_OK) {
        return;
    }
    
    nvs_erase_key(handle, RESOURCE_NVS_KEY);
    nvs_commit(handle);
    nvs_close(handle);
    
    ESP_LOGI(TAG, "Cleared resource names");
}
