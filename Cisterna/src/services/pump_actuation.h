// Pump Actuation Service
// Manages pump control with safety interlocks

#ifndef PUMP_ACTUATION_H
#define PUMP_ACTUATION_H

#include <stdint.h>
#include <stdbool.h>
#include "../services/level_measurement.h"

// Pump IDs (matches relay IDs)
typedef enum {
    PUMP_1 = 0,
    PUMP_2 = 1,
    PUMP_COUNT = 2
} pump_id_t;

// Pump modes
typedef enum {
    PUMP_MODE_MANUAL,
    PUMP_MODE_AUTO,
    PUMP_MODE_LOCKED
} pump_mode_t;

// Pump state
typedef struct {
    bool running;
    pump_mode_t mode;
    const char* reason;      // Reason for current state
    bool forced;             // If true, safety checks are bypassed
    uint64_t start_time_ms;  // When pump started (for runtime tracking)
    uint32_t runtime_s;      // Total runtime in seconds
} pump_state_t;

// Initialize pump actuation service
int pump_actuation_init(void);

// Start pump
// Returns true if started successfully, false if safety interlock prevented start
bool pump_start(pump_id_t pump_id, const char* reason, bool force);

// Stop pump
void pump_stop(pump_id_t pump_id, const char* reason);

// Set pump mode
void pump_set_mode(pump_id_t pump_id, pump_mode_t mode);

// Get pump state
pump_state_t pump_get_state(pump_id_t pump_id);

// Check safety interlocks
// level: Current water level measurement
// Returns true if safe to run pumps
bool pump_check_safety(const level_measurement_t* level);

// Update pump runtime tracking (call periodically)
void pump_update_runtime(void);

#endif // PUMP_ACTUATION_H
