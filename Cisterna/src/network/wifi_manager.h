// WiFi Manager - Network Connectivity
// Manages WiFi in AP and STA modes

#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// WiFi status
typedef enum {
    WIFI_STATUS_DISCONNECTED,
    WIFI_STATUS_CONNECTING,
    WIFI_STATUS_CONNECTED,
    WIFI_STATUS_AP_MODE,
    WIFI_STATUS_ERROR
} wifi_status_t;

// Note: wifi_mode_t is already defined by ESP-IDF (esp_wifi_types.h)
// We don't redefine it to avoid conflicts

// Callback types
typedef void (*wifi_connected_cb_t)(void);
typedef void (*wifi_disconnected_cb_t)(void);

// Initialize WiFi manager
int wifi_manager_init(void);

// Start in AP mode (for initial setup)
int wifi_manager_start_ap(const char* ssid, const char* password);

// Start in STA mode (connect to saved network)
int wifi_manager_start_sta(const char* ssid, const char* password);

// Stop WiFi
void wifi_manager_stop(void);

// Get current status
wifi_status_t wifi_manager_get_status(void);

// Get IP address (in STA mode)
const char* wifi_manager_get_ip(void);

// Get RSSI (signal strength)
int8_t wifi_manager_get_rssi(void);

// Set callbacks
void wifi_manager_set_callbacks(wifi_connected_cb_t connected_cb, 
                                 wifi_disconnected_cb_t disconnected_cb);

// Scan networks (blocking, returns count)
int wifi_manager_scan_networks(void);

// Get scanned network info
const char* wifi_manager_get_scanned_ssid(int index);
int8_t wifi_manager_get_scanned_rssi(int index);

#ifdef __cplusplus
}
#endif

#endif // WIFI_MANAGER_H
