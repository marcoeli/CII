// Configuration Manager Implementation

#include "config_manager.h"
#include "../config/app_config.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_log.h"
#include <string.h>

static nvs_handle_t s_nvs_handle = 0;
static bool initialized = false;
static const char* TAG = "CONFIG";

int config_manager_init(void) {
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        // NVS partition was truncated, erase and re-initialize
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
    
    // Open NVS namespace
    ret = nvs_open(NVS_NAMESPACE, NVS_READWRITE, &s_nvs_handle);
    if (ret != ESP_OK) {
        return -1;
    }
    
    initialized = true;
    return 0;
}

int config_manager_factory_reset(void) {
    if (!initialized) return -1;
    
    // Erase all keys in namespace
    esp_err_t ret = nvs_erase_all(s_nvs_handle);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_commit(s_nvs_handle);
    return (ret == ESP_OK) ? 0 : -1;
}

// ============================================================================
// Wi-Fi Credentials
// ============================================================================

int config_save_wifi_credentials(const char* ssid, const char* password) {
    if (!initialized || !ssid || !password) {
        ESP_LOGE(TAG, "Save WiFi failed: not initialized or null params");
        return -1;
    }
    
    // Check existing values first (Read-Verify-Update)
    char current_ssid[64] = {0};
    char current_pass[64] = {0};
    size_t len = sizeof(current_ssid);
    
    // Check SSID
    esp_err_t err_ssid = nvs_get_str(s_nvs_handle, NVS_KEY_WIFI_SSID, current_ssid, &len);
    len = sizeof(current_pass);
    esp_err_t err_pass = nvs_get_str(s_nvs_handle, NVS_KEY_WIFI_PASSWORD, current_pass, &len);
    
    if (err_ssid == ESP_OK && err_pass == ESP_OK) {
        if (strcmp(current_ssid, ssid) == 0 && strcmp(current_pass, password) == 0) {
            ESP_LOGI(TAG, "WiFi credentials unchanged, skipping NVS write");
            return 0;
        }
    }
    
    ESP_LOGI(TAG, "Saving WiFi credentials: SSID=%s", ssid);
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_WIFI_SSID, ssid);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save SSID: %s", esp_err_to_name(ret));
        return -1;
    }
    
    ret = nvs_set_str(s_nvs_handle, NVS_KEY_WIFI_PASSWORD, password);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save password: %s", esp_err_to_name(ret));
        return -1;
    }
    
    ret = nvs_commit(s_nvs_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to commit NVS: %s", esp_err_to_name(ret));
        return -1;
    }
    
    ESP_LOGI(TAG, "WiFi credentials saved successfully");
    return 0;
}

int config_get_wifi_credentials(char* ssid, size_t ssid_len, char* password, size_t pass_len) {
    if (!initialized || !ssid || !password) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_WIFI_SSID, ssid, &ssid_len);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_get_str(s_nvs_handle, NVS_KEY_WIFI_PASSWORD, password, &pass_len);
    return (ret == ESP_OK) ? 0 : -1;
}

bool config_has_wifi_credentials(void) {
    if (!initialized) {
        ESP_LOGW(TAG, "config_has_wifi_credentials: not initialized");
        return false;
    }
    
    size_t len = 0;
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_WIFI_SSID, NULL, &len);
    ESP_LOGI(TAG, "Checking WiFi credentials: ret=%s, len=%d", esp_err_to_name(ret), len);
    return (ret == ESP_OK && len > 0);
}

// ============================================================================
// MQTT Credentials
// ============================================================================

int config_save_mqtt_credentials(const char* username, const char* password,
                                  const char* broker, uint16_t port) {
    if (!initialized || !username || !password || !broker) return -1;
    
    // Check existing values (Read-Verify-Update)
    char cur_user[64] = {0}, cur_pass[64] = {0}, cur_broker[64] = {0};
    uint16_t cur_port = 0;
    size_t len_u = sizeof(cur_user), len_p = sizeof(cur_pass), len_b = sizeof(cur_broker);
    
    bool match = true;
    if (nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_USERNAME, cur_user, &len_u) != ESP_OK || strcmp(cur_user, username) != 0) match = false;
    if (match && (nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_PASSWORD, cur_pass, &len_p) != ESP_OK || strcmp(cur_pass, password) != 0)) match = false;
    if (match && (nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_BROKER, cur_broker, &len_b) != ESP_OK || strcmp(cur_broker, broker) != 0)) match = false;
    if (match && (nvs_get_u16(s_nvs_handle, NVS_KEY_MQTT_PORT, &cur_port) != ESP_OK || cur_port != port)) match = false;
    
    if (match) {
        ESP_LOGI(TAG, "MQTT credentials unchanged, skipping NVS write");
        return 0;
    }
    
    ESP_LOGI(TAG, "Saving new MQTT credentials...");
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_MQTT_USERNAME, username);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_set_str(s_nvs_handle, NVS_KEY_MQTT_PASSWORD, password);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_set_str(s_nvs_handle, NVS_KEY_MQTT_BROKER, broker);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_set_u16(s_nvs_handle, NVS_KEY_MQTT_PORT, port);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_mqtt_credentials(char* username, size_t user_len,
                                 char* password, size_t pass_len,
                                 char* broker, size_t broker_len,
                                 uint16_t* port) {
    if (!initialized || !username || !password || !broker || !port) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_USERNAME, username, &user_len);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_PASSWORD, password, &pass_len);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_BROKER, broker, &broker_len);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_get_u16(s_nvs_handle, NVS_KEY_MQTT_PORT, port);
    return (ret == ESP_OK) ? 0 : -1;
}

bool config_has_mqtt_credentials(void) {
    if (!initialized) return false;
    
    size_t len = 0;
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_MQTT_USERNAME, NULL, &len);
    return (ret == ESP_OK && len > 0);
}

// ============================================================================
// Context & Auth (V2.4)
// ============================================================================

int config_save_context(const char* tenant, const char* home) {
    if (!initialized || !tenant || !home) return -1;
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_TENANT, tenant);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_set_str(s_nvs_handle, NVS_KEY_HOME, home);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_context(char* tenant, size_t tenant_len, char* home, size_t home_len) {
    if (!initialized || !tenant || !home) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_TENANT, tenant, &tenant_len);
    if (ret != ESP_OK) return -1;
    
    ret = nvs_get_str(s_nvs_handle, NVS_KEY_HOME, home, &home_len);
    return (ret == ESP_OK) ? 0 : -1;
}

bool config_has_context(void) {
    if (!initialized) return false;
    
    size_t len_t = 0, len_h = 0;
    esp_err_t ret_t = nvs_get_str(s_nvs_handle, NVS_KEY_TENANT, NULL, &len_t);
    esp_err_t ret_h = nvs_get_str(s_nvs_handle, NVS_KEY_HOME, NULL, &len_h);
    
    return (ret_t == ESP_OK && len_t > 0 && ret_h == ESP_OK && len_h > 0);
}

int config_save_dev_token(const char* dev_token) {
    if (!initialized || !dev_token) return -1;
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_DEV_TOKEN, dev_token);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_dev_token(char* dev_token, size_t len) {
    if (!initialized || !dev_token) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_DEV_TOKEN, dev_token, &len);
    return (ret == ESP_OK) ? 0 : -1;
}

int config_clear_dev_token(void) {
    if (!initialized) return -1;
    
    esp_err_t ret = nvs_erase_key(s_nvs_handle, NVS_KEY_DEV_TOKEN);
    if (ret != ESP_OK && ret != ESP_ERR_NVS_NOT_FOUND) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_save_auth_mode(auth_mode_t mode) {
    if (!initialized) return -1;
    
    esp_err_t ret = nvs_set_u8(s_nvs_handle, NVS_KEY_AUTH_MODE, (uint8_t)mode);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

auth_mode_t config_get_auth_mode(void) {
    if (!initialized) return AUTH_MODE_PROD;
    
    uint8_t mode = 0;
    esp_err_t ret = nvs_get_u8(s_nvs_handle, NVS_KEY_AUTH_MODE, &mode);
    if (ret != ESP_OK) return AUTH_MODE_PROD;
    
    return (auth_mode_t)mode;
}

// ============================================================================
// Provisioning State
// ============================================================================

int config_set_provisioned(bool provisioned) {
    if (!initialized) return -1;
    
    uint8_t value = provisioned ? 1 : 0;
    esp_err_t ret = nvs_set_u8(s_nvs_handle, NVS_KEY_PROVISIONED, value);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

bool config_is_provisioned(void) {
    if (!initialized) return false;
    
    uint8_t value = 0;
    esp_err_t ret = nvs_get_u8(s_nvs_handle, NVS_KEY_PROVISIONED, &value);
    return (ret == ESP_OK && value == 1);
}

int config_save_claim_code(const char* claim_code) {
    if (!initialized || !claim_code) return -1;
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_CLAIM_CODE, claim_code);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_claim_code(char* claim_code, size_t len) {
    if (!initialized || !claim_code) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_CLAIM_CODE, claim_code, &len);
    return (ret == ESP_OK) ? 0 : -1;
}

int config_clear_claim_code(void) {
    if (!initialized) return -1;
    
    esp_err_t ret = nvs_erase_key(s_nvs_handle, NVS_KEY_CLAIM_CODE);
    if (ret != ESP_OK && ret != ESP_ERR_NVS_NOT_FOUND) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

// ============================================================================
// Tank Configuration
// ============================================================================

int config_save_tank_config(const tank_config_t* config) {
    if (!initialized || !config) return -1;
    
    // Save as blob
    esp_err_t ret = nvs_set_blob(s_nvs_handle, "tank_cfg", config, sizeof(tank_config_t));
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_tank_config(tank_config_t* config) {
    if (!initialized || !config) return -1;
    
    size_t len = sizeof(tank_config_t);
    esp_err_t ret = nvs_get_blob(s_nvs_handle, "tank_cfg", config, &len);
    return (ret == ESP_OK) ? 0 : -1;
}

bool config_has_tank_config(void) {
    if (!initialized) return false;
    
    size_t len = 0;
    esp_err_t ret = nvs_get_blob(s_nvs_handle, "tank_cfg", NULL, &len);
    return (ret == ESP_OK && len == sizeof(tank_config_t));
}

int config_save_temperature(float temp_c) {
    if (!initialized) return -1;
    
    // Save as blob since NVS doesn't support float directly
    esp_err_t ret = nvs_set_blob(s_nvs_handle, NVS_KEY_TEMPERATURE, &temp_c, sizeof(float));
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save temp: %s", esp_err_to_name(ret));
        return -1;
    }
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

float config_get_temperature(void) {
    if (!initialized) return DEFAULT_TEMPERATURE_C;
    
    float temp = DEFAULT_TEMPERATURE_C;
    size_t len = sizeof(float);
    
    esp_err_t ret = nvs_get_blob(s_nvs_handle, NVS_KEY_TEMPERATURE, &temp, &len);
    if (ret != ESP_OK && ret != ESP_ERR_NVS_NOT_FOUND) {
        ESP_LOGE(TAG, "Failed to load temp: %s", esp_err_to_name(ret));
    }
    
    return temp;
}

// ============================================================================
// Alert Thresholds
// ============================================================================

int config_save_alert_thresholds(const alert_thresholds_t* thresholds) {
    if (!initialized || !thresholds) return -1;
    
    esp_err_t ret = nvs_set_blob(s_nvs_handle, "alert_thresh", thresholds, sizeof(alert_thresholds_t));
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_alert_thresholds(alert_thresholds_t* thresholds) {
    if (!initialized || !thresholds) return -1;
    
    size_t len = sizeof(alert_thresholds_t);
    esp_err_t ret = nvs_get_blob(s_nvs_handle, "alert_thresh", thresholds, &len);
    
    // If not found, use defaults
    if (ret == ESP_ERR_NVS_NOT_FOUND) {
        thresholds->low_percent = LEVEL_LOW_PERCENT;
        thresholds->critical_low_percent = LEVEL_CRITICAL_LOW_PERCENT;
        thresholds->high_percent = LEVEL_HIGH_PERCENT;
        return 0;
    }
    
    return (ret == ESP_OK) ? 0 : -1;
}

// ============================================================================
// Device Settings
// ============================================================================

int config_save_location(const char* location) {
    if (!initialized || !location) return -1;
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, NVS_KEY_LOCATION, location);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_location(char* location, size_t len) {
    if (!initialized || !location) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, NVS_KEY_LOCATION, location, &len);
    
    // If not found, use default
    if (ret == ESP_ERR_NVS_NOT_FOUND) {
        strncpy(location, "cistern_room", len);
        return 0;
    }
    
    return (ret == ESP_OK) ? 0 : -1;
}

int config_save_report_interval(uint32_t interval_s) {
    if (!initialized) return -1;
    
    esp_err_t ret = nvs_set_u32(s_nvs_handle, NVS_KEY_REPORT_INTERVAL, interval_s);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

uint32_t config_get_report_interval(void) {
    if (!initialized) return 30;  // Default 30 seconds
    
    uint32_t value = 30;
    nvs_get_u32(s_nvs_handle, NVS_KEY_REPORT_INTERVAL, &value);
    return value;
}

// ============================================================================
// ACL Topics (from provisioning response)
// ============================================================================

int config_save_acl_topics(const char* topics) {
    if (!initialized || !topics) return -1;
    
    esp_err_t ret = nvs_set_str(s_nvs_handle, "acl_topics", topics);
    if (ret != ESP_OK) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}

int config_get_acl_topics(char* topics, size_t len) {
    if (!initialized || !topics) return -1;
    
    esp_err_t ret = nvs_get_str(s_nvs_handle, "acl_topics", topics, &len);
    return (ret == ESP_OK) ? 0 : -1;
}

int config_clear_acl_topics(void) {
    if (!initialized) return -1;
    
    esp_err_t ret = nvs_erase_key(s_nvs_handle, "acl_topics");
    if (ret != ESP_OK && ret != ESP_ERR_NVS_NOT_FOUND) return -1;
    
    return (nvs_commit(s_nvs_handle) == ESP_OK) ? 0 : -1;
}
