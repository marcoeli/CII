// Cistern Controller - Domain Logic
// Manages overall device state machine and coordination

#ifndef CISTERN_CONTROLLER_H
#define CISTERN_CONTROLLER_H

#include <stdint.h>
#include <stdbool.h>
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"

// Device states
typedef enum {
    DEVICE_STATE_BOOT,
    DEVICE_STATE_UNPROVISIONED,
    DEVICE_STATE_PROVISIONING,
    DEVICE_STATE_CONNECTING,
    DEVICE_STATE_RUNNING,
    DEVICE_STATE_DEGRADED,
    DEVICE_STATE_OTA_IN_PROGRESS,
    DEVICE_STATE_ERROR_SAFE
} device_state_t;

// Controller context
typedef struct {
    device_state_t current_state;
    level_measurement_t last_level;
    pump_state_t pump1_state;
    pump_state_t pump2_state;
    bool wifi_connected;
    bool mqtt_connected;
    uint32_t error_count;
    uint64_t state_changed_at_ms;
    
    // State tracking for publishing updates
    uint64_t last_heartbeat_ms;
    level_measurement_t last_published_level;
    uint64_t last_published_level_ts;
    pump_state_t last_published_pump1;
    pump_state_t last_published_pump2;
} controller_context_t;

// Initialize controller
int cistern_controller_init(void);

// Get current state
device_state_t cistern_controller_get_state(void);

// Set device state
void cistern_controller_set_state(device_state_t new_state);

// Get state as string
const char* cistern_controller_state_to_string(device_state_t state);

// Update controller (call in main loop)
void cistern_controller_update(void);

// Network status callbacks
void cistern_controller_wifi_connected(void);
void cistern_controller_wifi_disconnected(void);
void cistern_controller_mqtt_connected(void);
void cistern_controller_mqtt_disconnected(void);

// Get controller context
const controller_context_t* cistern_controller_get_context(void);

// Safety check before pump operation
bool cistern_controller_is_safe_to_run_pump(pump_id_t pump_id);

// Emergency stop all pumps
void cistern_controller_emergency_stop(const char* reason);

#endif // CISTERN_CONTROLLER_H
