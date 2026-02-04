// Level Measurement Service Implementation

#include "level_measurement.h"
#include "../drivers/ultrasonic_driver.h"
#include "../config/app_config.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <math.h>
#include <string.h>
#include <stdlib.h> // For compar function if needed, or implement simple sort

static const char *TAG = "LEVEL_MEAS";

static tank_config_t current_config;
static float current_temperature = DEFAULT_TEMPERATURE_C;
static bool initialized = false;

// Helpers
static int compare_float(const void* a, const void* b) {
    float fa = *(const float*)a;
    float fb = *(const float*)b;
    return (fa > fb) - (fa < fb);
}

int level_measurement_init(const tank_config_t* config) {
    if (!config) {
        ESP_LOGE(TAG, "Config is NULL");
        return -1;
    }
    
    // Validation
    if (config->height_cm <= 0) {
        ESP_LOGE(TAG, "Invalid height: %.2f", config->height_cm);
        return -2;
    }
    
    if (config->shape == TANK_SHAPE_RECTANGULAR) {
        if (config->width_cm <= 0 || config->depth_cm <= 0) {
            ESP_LOGE(TAG, "Invalid dimensions: w=%.2f d=%.2f", 
                     config->width_cm, config->depth_cm);
            return -3;
        }
    } else if (config->shape == TANK_SHAPE_CYLINDRICAL) {
        if (config->diameter_top_cm <= 0 || config->diameter_bottom_cm <= 0) {
            ESP_LOGE(TAG, "Invalid diameters: top=%.2f bottom=%.2f", 
                     config->diameter_top_cm, config->diameter_bottom_cm);
            return -4;
        }
    }
    
    if (config->sensor_offset_cm < 0) {
        ESP_LOGE(TAG, "Invalid sensor offset: %.2f", config->sensor_offset_cm);
        return -5;
    }
    
    memcpy(&current_config, config, sizeof(tank_config_t));
    initialized = true;
    
    ESP_LOGI(TAG, "Initialized: shape=%d, height=%.2f cm, temp=%.1fC", 
             config->shape, config->height_cm, current_temperature);
    return 0;
}

void level_measurement_set_config(const tank_config_t* config) {
    if (!config) {
        ESP_LOGW(TAG, "Cannot set NULL config");
        return;
    }
    if (!initialized) {
        ESP_LOGW(TAG, "Not initialized, call init() first");
        return;
    }
    memcpy(&current_config, config, sizeof(tank_config_t));
    ESP_LOGI(TAG, "Config updated");
}

void level_measurement_set_temperature(float temp_c) {
    current_temperature = temp_c;
    ESP_LOGI(TAG, "Temperature set to %.1f C", current_temperature);
}

void level_measurement_get_config(tank_config_t* config) {
    if (!config) return;
    memcpy(config, &current_config, sizeof(tank_config_t));
}

float level_measurement_calculate_volume(float water_height_cm) {
    if (!initialized || water_height_cm < 0) return 0.0f;
    
    float volume_cm3 = 0.0f;
    
    if (current_config.shape == TANK_SHAPE_RECTANGULAR) {
        // Volume = width x depth x height
        volume_cm3 = current_config.width_cm * current_config.depth_cm * water_height_cm;
    }
    else if (current_config.shape == TANK_SHAPE_CYLINDRICAL) {
        // Average diameter
        float avg_diameter = (current_config.diameter_top_cm + current_config.diameter_bottom_cm) / 2.0f;
        float radius_cm = avg_diameter / 2.0f;
        
        // Volume = pi * r^2 * height
        volume_cm3 = M_PI * radius_cm * radius_cm * water_height_cm;
    }
    
    // Convert cm3 to liters (1 liter = 1000 cm3)
    return volume_cm3 / 1000.0f;
}

level_alert_t level_measurement_get_alert(float percent) {
    if (percent >= LEVEL_OVERFLOW_PERCENT) {
        return LEVEL_ALERT_OVERFLOW;
    } else if (percent >= LEVEL_HIGH_PERCENT) {
        return LEVEL_ALERT_HIGH;
    } else if (percent >= LEVEL_LOW_PERCENT) {
        return LEVEL_ALERT_NORMAL;
    } else if (percent >= LEVEL_CRITICAL_LOW_PERCENT) {
        return LEVEL_ALERT_LOW;
    } else {
        return LEVEL_ALERT_CRITICAL_LOW;
    }
}

level_measurement_t level_measurement_read(uint8_t samples) {
    level_measurement_t result = {0};
    
    if (!initialized) {
        ESP_LOGE(TAG, "Not initialized");
        result.valid = false;
        return result;
    }
    
    if (samples == 0) samples = 5;
    if (samples > 20) samples = 20; // Cap max samples
    
    float distances[20]; // Buffer for sorting/filtering
    uint8_t valid_samples = 0;
    
    // 1. Collect Valid Samples
    for (uint8_t i = 0; i < samples; i++) {
        int32_t duration_us = ultrasonic_measure_raw_us(ULTRASONIC_TIMEOUT_US);
        
        if (duration_us > 0) {
            // Calculate distance with Temperature Compensation
            // Speed (m/s) = 331.3 + (0.606 * T)
            // Speed (cm/us) = Speed(m/s) / 10000
            float speed_m_s = 331.3f + (0.606f * current_temperature);
            float speed_cm_us = speed_m_s / 10000.0f;
            
            float dist = ((float)duration_us * speed_cm_us) / 2.0f;
            
            if (dist >= 2.0f && dist <= 400.0f) {
                distances[valid_samples++] = dist;
            }
        }
        
        vTaskDelay(pdMS_TO_TICKS(SAMPLE_DELAY_MS));
    }
    
    uint8_t min_required = (samples * MIN_VALID_SAMPLES_PERCENT) / 100;
    if (valid_samples < min_required) {
        ESP_LOGW(TAG, "Insufficient valid samples: %d/%d (min: %d)", 
                 valid_samples, samples, min_required);
        result.valid = false;
        return result;
    }
    
    // 2. Filter Outliers (using Median for robustness)
    // Sort the valid samples
    qsort(distances, valid_samples, sizeof(float), compare_float);
    
    // Pick the median (better than mean for outlier rejection)
    float median_dist = distances[valid_samples / 2];
    
    // Reuse filtered samples logic from request (Mean Deviation) around Median
    // Or just use the median? Median is usually enough for ultrasonic noise.
    // Let's implement the requested deviation filter but around median.
    
    float total = 0.0f;
    uint8_t filtered_count = 0;
    
    for (uint8_t i = 0; i < valid_samples; i++) {
        if (fabs(distances[i] - median_dist) <= MAX_SAMPLE_DEVIATION_CM) {
            total += distances[i];
            filtered_count++;
        }
    }
    
    if (filtered_count == 0) {
        // Should happen rarely if built around median
        result.distance_cm = median_dist; 
    } else {
        result.distance_cm = total / filtered_count;
    }
    
    // 3. Process Result
    // Water Height = Tank Height - (Measured Distance - Sensor Offset)
    // Offset is gap between sensor face and "Full (Height)" line? 
    // Usually Config Offset = Distance from sensor to TANK TOP 
    // And Config Height = Tank Max Water Depth.
    // So Empty Distance = SensorOffset + TankHeight.
    // Water Height = (SensorOffset + TankHeight) - MeasuredDistance.
    
    // Let's assume standard config:
    // Sensor Offset = Distance from Sensor to MAX Water Level.
    // Tank Height = MAX Water Level to Bottom.
    // So Water Height = TankHeight - (MeasuredDistance - SensorOffset)
    
    result.distance_cm = result.distance_cm; // Logical placeholder
    
    // Safety clamp on math inputs
    float effective_dist = result.distance_cm - current_config.sensor_offset_cm;
    if (effective_dist < 0) effective_dist = 0; // Water above max level?
    
    result.water_height_cm = current_config.height_cm - effective_dist;
    
    // Clamp result
    if (result.water_height_cm < 0.0f) {
        result.water_height_cm = 0.0f;
    } else if (result.water_height_cm > current_config.height_cm) {
        result.water_height_cm = current_config.height_cm;
    }
    
    // Volume & Percent
    result.liters = level_measurement_calculate_volume(result.water_height_cm);
    
    float max_vol = level_measurement_calculate_volume(current_config.height_cm);
    if (max_vol > 0.001f) {
        result.percent = (result.liters / max_vol) * 100.0f;
    } else {
        result.percent = 0.0f;
    }
    
    result.alert = level_measurement_get_alert(result.percent);
    result.valid = true;
    
    ESP_LOGD(TAG, "Dist: %.1fcm (Valid: %d/%d) -> Level: %.1f%% (%.1f L)", 
             result.distance_cm, valid_samples, samples, result.percent, result.liters);
             
    return result;
}
