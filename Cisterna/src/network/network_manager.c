#include "network_manager.h"
#include "wifi_manager.h"
#include "web_server.h"
#include "mqtt_manager.h"
#include "../persistence/config_manager.h"
#include "../messaging/mqtt_handlers.h" // [NEW] Added to access callback
#include "../domain/cistern_controller.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_sntp.h"
#include "esp_mac.h"
#include <string.h>
#include <time.h>

static const char *TAG = "NET_MGR";

// Configurable constants
#define GRACE_PERIOD_MS (3 * 60 * 1000)      // 3 minutes
#define AP_MODE_TIMEOUT_MS (10 * 60 * 1000)  // 10 minutes

static network_state_t current_state = NETWORK_STATE_BOOT;
static uint64_t state_entry_time_ms = 0;
static bool web_server_active = false;
static bool ntp_synced = false;

// Helpers
static uint64_t get_time_ms(void) {
    return esp_timer_get_time() / 1000;
}

static void set_state(network_state_t new_state) {
    if (current_state != new_state) {
        ESP_LOGI(TAG, "State transition: %s -> %s", 
                network_manager_get_state_string(), 
                (new_state == NETWORK_STATE_BOOT) ? "BOOT" :
                (new_state == NETWORK_STATE_GRACE_PERIOD) ? "GRACE_PERIOD" :
                (new_state == NETWORK_STATE_CONNECTED) ? "CONNECTED" :
                (new_state == NETWORK_STATE_AP_MODE) ? "AP_MODE" :
                (new_state == NETWORK_STATE_RECOVERY) ? "RECOVERY" : "UNKNOWN");
        
        current_state = new_state;
        state_entry_time_ms = get_time_ms();
    }
}

// NTP/Time Sync
static void initialize_sntp(void)
{
    ESP_LOGI(TAG, "Initializing SNTP");
    esp_sntp_setoperatingmode(SNTP_OPMODE_POLL);
    esp_sntp_setservername(0, "pool.ntp.org");
    esp_sntp_setservername(1, "time.google.com");
    esp_sntp_init();
}

// Callbacks
static int wifi_retry_count = 0;
#define MAX_WIFI_RETRIES 5

static void on_wifi_connected(void) {
    ESP_LOGI(TAG, "WiFi Connected event received");
    
    wifi_retry_count = 0; // Reset retries on success
    
    // Start NTP sync attempt immediately upon connection
    initialize_sntp();
    
    if (current_state == NETWORK_STATE_GRACE_PERIOD || current_state == NETWORK_STATE_RECOVERY || current_state == NETWORK_STATE_BOOT) {
        set_state(NETWORK_STATE_CONNECTED);
        
        // Propagate to controller
        cistern_controller_wifi_connected();
        
        // Start Web Server for local access if not running
        if (!web_server_active) {
            web_server_init();
            web_server_start();
            web_server_active = true;
        }
    }
}

static void on_wifi_disconnected(void) {
    ESP_LOGW(TAG, "WiFi Disconnected event received");
    
    // Propagate to controller
    cistern_controller_wifi_disconnected();
    ntp_synced = false; // Require re-check on reconnection
    
    wifi_retry_count++;
    
    if (current_state == NETWORK_STATE_CONNECTED || current_state == NETWORK_STATE_GRACE_PERIOD || current_state == NETWORK_STATE_BOOT) {
        if (wifi_retry_count >= MAX_WIFI_RETRIES) {
            ESP_LOGW(TAG, "Max WiFi retries reached (%d). Switching to AP Mode for reconfiguration.", MAX_WIFI_RETRIES);
            
            // Force State Transition to handle AP start in main loop
            // We reuse AP_MODE state but need to ensure 'update' handles the transition logic
            // Currently AP_MODE block monitors timeout. We need a way to TRIGGER AP start.
            // Simplified: We call start_ap logic in the update loop by checking a flag or specific state entry.
            // But since 'set_state' updates entry time, we can handle it.
            // Problem: AP start logic is in BOOT and GRACE_PERIOD timeout.
            // Let's force it by resetting to BOOT but failing credentials check? No.
            
            // Best approach: Add a new internal flag or just call start_ap here?
            // Calling wifi_manager_start_ap here is callback context (ISR safe? usually yes for ESP-IDF if task based).
            // But let's be safe: Set state to RECOVERY and let update loop handle AP start.
            set_state(NETWORK_STATE_RECOVERY);
        } else {
             set_state(NETWORK_STATE_GRACE_PERIOD);
        }
    }
}

// Main API
int network_manager_init(void) {
    ESP_LOGI(TAG, "Initializing Network Manager");
    
    current_state = NETWORK_STATE_BOOT;
    state_entry_time_ms = get_time_ms();
    
    // Initialize WiFi Manager (driver)
    wifi_manager_init();
    wifi_manager_set_callbacks(on_wifi_connected, on_wifi_disconnected);
    
    return 0;
}

void network_manager_update(void) {
    uint64_t now = get_time_ms();
    
    // Check time sync status if connected
    if (current_state == NETWORK_STATE_CONNECTED && !ntp_synced) {
        static uint64_t last_time_check = 0;
        if (now - last_time_check > 2000) {
            time_t t_now;
            struct tm timeinfo;
            time(&t_now);
            localtime_r(&t_now, &timeinfo);
            last_time_check = now;
            
            if (timeinfo.tm_year > (2020 - 1900)) {
                ESP_LOGI(TAG, "NTP Synchronized: %s", asctime(&timeinfo));
                ntp_synced = true;
            }
        }
    }
    
    switch (current_state) {
        case NETWORK_STATE_BOOT:
            // Check for Wi-Fi credentials AND context (tenant/home)
            if (config_has_wifi_credentials() && config_has_context()) {
                ESP_LOGI(TAG, "Credentials and context found. Entering Grace Period.");
                
                // Start Connection Attempt
                char ssid[64], password[64];
                config_get_wifi_credentials(ssid, sizeof(ssid), password, sizeof(password));
                wifi_manager_start_sta(ssid, password);
                
                set_state(NETWORK_STATE_GRACE_PERIOD);
            } else {
                ESP_LOGW(TAG, "Missing credentials or context. Entering AP Mode.");
                set_state(NETWORK_STATE_AP_MODE);
                
                // Generate SSID with MAC suffix
                uint8_t mac[6];
                char ap_ssid[32];
                esp_read_mac(mac, ESP_MAC_WIFI_STA);
                snprintf(ap_ssid, sizeof(ap_ssid), "ICODZ_SETUP_%02X%02X%02X", 
                         mac[3], mac[4], mac[5]);
                
                // Start AP
                wifi_manager_start_ap(ap_ssid, "icodz123");
                
                // Start Web Server
                if (!web_server_active) {
                    web_server_init();
                    web_server_start();
                    web_server_active = true;
                }
            }
            break;
            
        case NETWORK_STATE_GRACE_PERIOD:
            // Waiting for connection...
            // Check timeout
            if (now - state_entry_time_ms > GRACE_PERIOD_MS) {
                ESP_LOGW(TAG, "Grace Period timeout. Switching to AP Mode.");
                
                // Generate SSID with MAC suffix
                uint8_t mac[6];
                char ap_ssid[32];
                esp_read_mac(mac, ESP_MAC_WIFI_STA);
                snprintf(ap_ssid, sizeof(ap_ssid), "ICODZ_SETUP_%02X%02X%02X", 
                         mac[3], mac[4], mac[5]);
                
                // Switch mode
                wifi_manager_start_ap(ap_ssid, "icodz123");
                
                if (!web_server_active) {
                    web_server_init();
                    web_server_start();
                    web_server_active = true;
                }
                
                set_state(NETWORK_STATE_AP_MODE);
            }
            break;
            
        case NETWORK_STATE_CONNECTED:
            // Check if we are stuck in Setup MQTT mode while provisioned (Zombie connection)
            if (config_is_provisioned() && mqtt_manager_is_started() && mqtt_manager_get_mode() == MQTT_MODE_SETUP) {
                ESP_LOGW(TAG, "Provisioned but running Setup MQTT. Disconnecting to switch to Operational...");
                mqtt_manager_disconnect();
                // Return to loop to allow state machine to pick up !is_started in next iteration
                break;
            }

            // Only connect if not started. ESP-MQTT handles auto-reconnect.
            if (!mqtt_manager_is_started()) {
                // Determine if we should connect (Setup vs Operational)
                static uint64_t last_mqtt_try = 0;
                
                // Wait for NTP sync before connecting if using TLS (Operational)
                // Setup mode might not strictly need it if we skip verify, but good practice
                if (!ntp_synced && config_is_provisioned()) {
                    // Waiting for NTP...
                    // Log periodically
                    if (now - last_mqtt_try > 5000) {
                        ESP_LOGI(TAG, "Waiting for NTP sync before connecting MQTTS...");
                        last_mqtt_try = now;
                    }
                    break; 
                }
                
                if (now - last_mqtt_try > 5000) {
                     last_mqtt_try = now;
                     
                     if (config_is_provisioned()) {
                        char user[64], pass[64], broker[64];
                        uint16_t port;
                        config_get_mqtt_credentials(user, sizeof(user), pass, sizeof(pass), broker, sizeof(broker), &port);
                        
                        mqtt_manager_set_connection_callbacks(
                             cistern_controller_mqtt_connected,
                             cistern_controller_mqtt_disconnected
                        );
                        // Register message handler for operational commands
                        mqtt_manager_set_message_callback(mqtt_handlers_on_message);
                        
                        // Use stored port or default 8883
                        if (port == 0) port = 8883;
                        
                        mqtt_manager_connect_operational(user, pass, broker, port);
                     } else {
                         mqtt_manager_connect_setup();
                     }
                }
            }
            break;
            
        case NETWORK_STATE_AP_MODE:
            // Check timeout to retry STA
            if (now - state_entry_time_ms > AP_MODE_TIMEOUT_MS) {
                if (config_has_wifi_credentials()) {
                    ESP_LOGI(TAG, "AP Mode timeout. Retrying Station Mode.");
                    
                    char ssid[64], password[64];
                    config_get_wifi_credentials(ssid, sizeof(ssid), password, sizeof(password));
                    wifi_manager_start_sta(ssid, password);
                    
                    set_state(NETWORK_STATE_GRACE_PERIOD);
                }
            }
            break;
            
        case NETWORK_STATE_RECOVERY:
             ESP_LOGW(TAG, "Recovery Mode: Starting AP for user intervention.");
             
             // Generate SSID with MAC suffix
             uint8_t mac_r[6];
             char ap_ssid_r[32];
             esp_read_mac(mac_r, ESP_MAC_WIFI_STA);
             snprintf(ap_ssid_r, sizeof(ap_ssid_r), "ICODZ_SETUP_%02X%02X%02X", 
                      mac_r[3], mac_r[4], mac_r[5]);
             
             // Start AP (this stops STA retry loop)
             wifi_manager_start_ap(ap_ssid_r, "icodz123");
             
             if (!web_server_active) {
                 web_server_init();
                 web_server_start();
                 web_server_active = true;
             }
             
             // Move to AP_MODE state to monitor timeout (and eventually retry STA if configured)
             set_state(NETWORK_STATE_AP_MODE);
            break;
    }
}

network_state_t network_manager_get_state(void) {
    return current_state;
}

const char* network_manager_get_state_string(void) {
    switch(current_state) {
        case NETWORK_STATE_BOOT: return "BOOT";
        case NETWORK_STATE_GRACE_PERIOD: return "GRACE_PERIOD";
        case NETWORK_STATE_CONNECTED: return "CONNECTED";
        case NETWORK_STATE_AP_MODE: return "AP_MODE";
        case NETWORK_STATE_RECOVERY: return "RECOVERY";
        default: return "UNKNOWN";
    }
}

bool network_manager_is_ntp_synced(void) {
    return ntp_synced;
}
