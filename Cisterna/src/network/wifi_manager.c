// WiFi Manager Implementation (Simplified ESP-IDF wrapper)

#include "wifi_manager.h"
#include "../include/config.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include <string.h>

static const char *TAG = "WIFI_MGR";

static wifi_status_t current_status = WIFI_STATUS_DISCONNECTED;
static wifi_connected_cb_t connected_callback = NULL;
static wifi_disconnected_cb_t disconnected_callback = NULL;
static char ip_address[16] = "0.0.0.0";
// Flag to control auto-reconnection (prevent loops during provisioning)
static bool should_reconnect = false;

// Event handler
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data) {
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        if (should_reconnect) {
            esp_wifi_connect();
        }
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        wifi_event_sta_disconnected_t* event = (wifi_event_sta_disconnected_t*) event_data;
        
        // Log unconditionally at Error level to debug connection loop
        ESP_LOGE(TAG, "Disconnected from AP! Reason: %d", event->reason);
        
        current_status = WIFI_STATUS_DISCONNECTED;
        if (disconnected_callback) {
            disconnected_callback();
        }
        // Retry connection only if enabled
        if (should_reconnect) {
            esp_wifi_connect();
        }
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        snprintf(ip_address, sizeof(ip_address), IPSTR, IP2STR(&event->ip_info.ip));
        ESP_LOGI(TAG, "Got IP: %s", ip_address);
        current_status = WIFI_STATUS_CONNECTED;
        if (connected_callback) {
            connected_callback();
        }
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_AP_STACONNECTED) {
        ESP_LOGI(TAG, "Station connected to AP");
    }
}

int wifi_manager_init(void) {
    // Initialize network interface
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    
    // Create default WiFi station and AP
    esp_netif_create_default_wifi_sta();
    esp_netif_create_default_wifi_ap();
    
    // Initialize WiFi with default config
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
    
    // Register event handlers
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, 
                                               &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, 
                                               &wifi_event_handler, NULL));
                                               
    // Start WiFi driver
    ESP_ERROR_CHECK(esp_wifi_start());
    
    ESP_LOGI(TAG, "WiFi manager initialized");
    return 0;
}

int wifi_manager_start_ap(const char* ssid, const char* password) {
    ESP_LOGI(TAG, "Starting AP mode (APSTA): %s", ssid);
    
    should_reconnect = false; // Disable auto-reconnect logic in provisioning
    
    wifi_config_t ap_config = {0};
    ap_config.ap.max_connection = WIFI_AP_MAX_CONNECTIONS;
    ap_config.ap.channel = WIFI_AP_CHANNEL;
    ap_config.ap.authmode = WIFI_AUTH_WPA2_PSK;
    
    strncpy((char*)ap_config.ap.ssid, ssid, sizeof(ap_config.ap.ssid) - 1);
    strncpy((char*)ap_config.ap.password, password, sizeof(ap_config.ap.password) - 1);
    ap_config.ap.ssid_len = strlen(ssid);
    
    // Switch to APSTA to allow scanning while AP is running
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_APSTA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &ap_config));
    ESP_ERROR_CHECK(esp_wifi_start());
    
    current_status = WIFI_STATUS_AP_MODE;
    strcpy(ip_address, "192.168.4.1"); // Default AP IP
    
    ESP_LOGI(TAG, "AP started successfully");
    return 0;
}

int wifi_manager_start_sta(const char* ssid, const char* password) {
    ESP_LOGI(TAG, "Starting STA mode, connecting to: %s", ssid);
    
    should_reconnect = true; // Enable auto-reconnect
    
    wifi_config_t wifi_config = {0};
    strncpy((char*)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid) - 1);
    strncpy((char*)wifi_config.sta.password, password, sizeof(wifi_config.sta.password) - 1);
    
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());
    
    // Explicitly connect (event handler will retry if needed)
    esp_wifi_connect();
    
    current_status = WIFI_STATUS_CONNECTING;
    
    return 0;
}

void wifi_manager_stop(void) {
    esp_wifi_stop();
    current_status = WIFI_STATUS_DISCONNECTED;
}

wifi_status_t wifi_manager_get_status(void) {
    return current_status;
}

const char* wifi_manager_get_ip(void) {
    return ip_address;
}

int8_t wifi_manager_get_rssi(void) {
    wifi_ap_record_t ap_info;
    if (esp_wifi_sta_get_ap_info(&ap_info) == ESP_OK) {
        return ap_info.rssi;
    }
    return -100;
}

void wifi_manager_set_callbacks(wifi_connected_cb_t connected_cb, 
                                 wifi_disconnected_cb_t disconnected_cb) {
    connected_callback = connected_cb;
    disconnected_callback = disconnected_cb;
}

static wifi_ap_record_t cached_records[20];
static uint16_t cached_count = 0;

int wifi_manager_scan_networks(void) {
    // Clear cache
    cached_count = 0;
    memset(cached_records, 0, sizeof(cached_records));
    
    // Ensure we are in a mode that supports scanning (APSTA or STA)
    wifi_mode_t mode;
    esp_wifi_get_mode(&mode);
    if (mode == WIFI_MODE_AP) {
        ESP_LOGI(TAG, "Switching to APSTA for scan");
        esp_wifi_set_mode(WIFI_MODE_APSTA);
    }
    
    // Configure scan
    wifi_scan_config_t scan_config = {0};
    scan_config.show_hidden = true; 
    scan_config.scan_type = WIFI_SCAN_TYPE_ACTIVE;
    
    // Start blocking scan
    ESP_LOGI(TAG, "Starting active scan...");
    esp_err_t ret = esp_wifi_scan_start(&scan_config, true);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "WiFi scan failed: %s", esp_err_to_name(ret));
        return 0;
    }
    
    // Get count first
    uint16_t ap_count = 0;
    esp_wifi_scan_get_ap_num(&ap_count);
    
    if (ap_count > 0) {
        uint16_t number = 20; // Max to retrieve
        if (ap_count < number) number = ap_count;
        
        ret = esp_wifi_scan_get_ap_records(&number, cached_records);
        if (ret == ESP_OK) {
            cached_count = number;
            ESP_LOGI(TAG, "Scan done. Found %d networks (limit 20).", cached_count);
        } else {
            ESP_LOGE(TAG, "Failed to get AP records: %s", esp_err_to_name(ret));
        }
    } else {
        ESP_LOGI(TAG, "Scan done. No networks found.");
    }
    
    return cached_count;
}

const char* wifi_manager_get_scanned_ssid(int index) {
    if (index >= 0 && index < cached_count) {
        return (const char*)cached_records[index].ssid;
    }
    return "";
}

int8_t wifi_manager_get_scanned_rssi(int index) {
    if (index >= 0 && index < cached_count) {
        return cached_records[index].rssi;
    }
    return -100;
}
