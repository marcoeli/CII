// Display Service
// Manages display screens and UI rendering

#ifndef DISPLAY_SERVICE_H
#define DISPLAY_SERVICE_H

#include <stdint.h>
#include <stdbool.h>
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"

// Display screens
typedef enum {
    SCREEN_HOME,           // Main screen: water level + status
    SCREEN_PUMP_1,         // Pump 1 details and control
    SCREEN_PUMP_2,         // Pump 2 details and control
    SCREEN_NETWORK_INFO,   // Wi-Fi + MQTT connection status
    SCREEN_COUNT
} screen_id_t;

// Network status
typedef struct {
    bool wifi_connected;
    int8_t wifi_rssi;
    bool mqtt_connected;
    char ip_address[16];       // IP Address
    char device_id[32];        // Device ID / Hostname
    const char* device_state;  // PROVISIONING, RUNNING, DEGRADED, etc.
} network_status_t;

// Initialize display service
int display_service_init(void);

// Set current screen
void display_service_set_screen(screen_id_t screen);

// Get current screen
screen_id_t display_service_get_screen(void);

// Set current screen (Internal use mostly now)
void display_service_set_screen(screen_id_t screen);

// Get current screen
screen_id_t display_service_get_screen(void);

// Render current screen
// level: Current water level measurement
// pump1, pump2: Pump states
// network: Network status
void display_service_render(
    const level_measurement_t* level,
    const pump_state_t* pump1,
    const pump_state_t* pump2,
    const network_status_t* network
);

// Show message overlay (for errors, alerts, etc.)
void display_service_show_message(const char* title, const char* message, uint32_t duration_ms);

#endif // DISPLAY_SERVICE_H
