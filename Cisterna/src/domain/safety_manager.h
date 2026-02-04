// Safety Manager - Critical Safety Rules
// Enforces safety interlocks and monitors critical conditions

#ifndef SAFETY_MANAGER_H
#define SAFETY_MANAGER_H

#include <stdint.h>
#include <stdbool.h>
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"

// Safety violation types
typedef enum {
    SAFETY_OK = 0,
    SAFETY_DRY_RUN_RISK,        // Water too low
    SAFETY_OVERFLOW_RISK,        // Water too high
    SAFETY_SENSOR_FAILURE,       // No valid measurement
    SAFETY_PUMP_STUCK_ON,        // Pump running too long
    SAFETY_RAPID_LEVEL_CHANGE    // Unusual level change (leak?)
} safety_violation_t;

// Safety statistics
typedef struct {
    uint32_t dry_run_prevents;
    uint32_t overflow_prevents;
    uint32_t emergency_stops;
    uint64_t last_violation_ms;
    safety_violation_t last_violation;
} safety_stats_t;

// Initialize safety manager
int safety_manager_init(void);

// Check if safe to operate pump
// Returns SAFETY_OK if safe, otherwise returns violation type
safety_violation_t safety_check_pump_operation(
    pump_id_t pump_id,
    const level_measurement_t* level
);

// Monitor running pumps for safety
// Should be called periodically in main loop
void safety_monitor_update(
    const level_measurement_t* current_level,
    const pump_state_t* pump1,
    const pump_state_t* pump2
);

// Get safety statistics
const safety_stats_t* safety_get_stats(void);

// Reset safety statistics
void safety_reset_stats(void);

// Get violation as string
const char* safety_violation_to_string(safety_violation_t violation);

// Check for sensor health
bool safety_check_sensor_health(const level_measurement_t* level);

#endif // SAFETY_MANAGER_H
