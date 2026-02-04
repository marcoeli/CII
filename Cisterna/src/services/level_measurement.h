// Level Measurement Service
// Processes ultrasonic sensor readings and calculates water volume

#ifndef LEVEL_MEASUREMENT_H
#define LEVEL_MEASUREMENT_H

#include <stdint.h>
#include <stdbool.h>

// Tank shapes
typedef enum {
    TANK_SHAPE_RECTANGULAR,
    TANK_SHAPE_CYLINDRICAL
} tank_shape_t;

// Tank configuration
typedef struct {
    tank_shape_t shape;
    float height_cm;          // Tank height
    
    // Rectangular tank dimensions
    float width_cm;
    float depth_cm;
    
    // Cylindrical tank dimensions
    float diameter_top_cm;    // Top diameter (for tapered tanks)
    float diameter_bottom_cm; // Bottom diameter
    
    float sensor_offset_cm;   // Distance from sensor to tank top
} tank_config_t;

// Alert levels
typedef enum {
    LEVEL_ALERT_OVERFLOW,    // > 95%
    LEVEL_ALERT_HIGH,        // > 90%
    LEVEL_ALERT_NORMAL,      // 20% - 90%
    LEVEL_ALERT_LOW,         // 10% - 20%
    LEVEL_ALERT_CRITICAL_LOW // < 10%
} level_alert_t;

// Level measurement result
typedef struct {
    float distance_cm;       // Distance from sensor to water surface
    float water_height_cm;   // Actual water height in tank
    float liters;            // Volume in liters
    float percent;           // Fill percentage
    level_alert_t alert;     // Alert level
    bool valid;              // Measurement valid flag
} level_measurement_t;

// Initialize level measurement service
int level_measurement_init(const tank_config_t* config);

// Update tank configuration
void level_measurement_set_config(const tank_config_t* config);

// Set ambient temperature for compensation (default 30.0C)
void level_measurement_set_temperature(float temp_c);

// Get current tank configuration
void level_measurement_get_config(tank_config_t* config);

// Perform measurement
// samples: Number of samples to average (default 5)
level_measurement_t level_measurement_read(uint8_t samples);

// Calculate volume from water height (utility function)
float level_measurement_calculate_volume(float water_height_cm);

// Get alert level relative to percentage (utility function)
level_alert_t level_measurement_get_alert(float percent);

#endif // LEVEL_MEASUREMENT_H
