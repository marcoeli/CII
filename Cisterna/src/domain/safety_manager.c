// Safety Manager Implementation

#include "safety_manager.h"
#include "../include/config.h"
#include "esp_log.h"
#include "esp_timer.h"
#include <math.h>

static const char *TAG = "SAFETY";

// Maximum pump runtime before forced stop (30 minutes)
#define MAX_PUMP_RUNTIME_MS (30 * 60 * 1000)

// Maximum acceptable level change per minute (20%)
#define MAX_LEVEL_CHANGE_PER_MIN 20.0f

static safety_stats_t stats = {0};
static float last_level_percent = 0.0f;
static uint64_t last_level_check_ms = 0;
static uint32_t sensor_failure_count = 0;

int safety_manager_init(void) {
    stats.dry_run_prevents = 0;
    stats.overflow_prevents = 0;
    stats.emergency_stops = 0;
    stats.last_violation_ms = 0;
    stats.last_violation = SAFETY_OK;
    
    last_level_percent = 0.0f;
    last_level_check_ms = esp_timer_get_time() / 1000;
    sensor_failure_count = 0;
    
    ESP_LOGI(TAG, "Safety manager initialized");
    return 0;
}

bool safety_check_sensor_health(const level_measurement_t* level) {
    if (!level || !level->valid) {
        sensor_failure_count++;
        
        if (sensor_failure_count > 5) {
            ESP_LOGE(TAG, "Sensor health check failed - %lu consecutive failures",
                    sensor_failure_count);
            return false;
        }
        return false;
    }
    
    // Reset failure count on successful reading
    sensor_failure_count = 0;
    
    // Check for physically impossible values
    if (level->percent < 0.0f || level->percent > 105.0f) {
        ESP_LOGW(TAG, "Sensor returned impossible value: %.1f%%", level->percent);
        return false;
    }
    
    return true;
}

safety_violation_t safety_check_pump_operation(
    pump_id_t pump_id,
    const level_measurement_t* level
) {
    // Check sensor health first
    if (!safety_check_sensor_health(level)) {
        ESP_LOGW(TAG, "Pump %d: Sensor failure detected", pump_id);
        return SAFETY_SENSOR_FAILURE;
    }
    
    // Check for dry-run risk
    if (level->alert == LEVEL_ALERT_CRITICAL_LOW) {
        ESP_LOGW(TAG, "Pump %d: Dry-run risk at %.1f%%", pump_id, level->percent);
        stats.dry_run_prevents++;
        stats.last_violation = SAFETY_DRY_RUN_RISK;
        stats.last_violation_ms = esp_timer_get_time() / 1000;
        return SAFETY_DRY_RUN_RISK;
    }
    
    // Check for overflow risk
    if (level->alert == LEVEL_ALERT_OVERFLOW) {
        ESP_LOGW(TAG, "Pump %d: Overflow risk at %.1f%%", pump_id, level->percent);
        stats.overflow_prevents++;
        stats.last_violation = SAFETY_OVERFLOW_RISK;
        stats.last_violation_ms = esp_timer_get_time() / 1000;
        return SAFETY_OVERFLOW_RISK;
    }
    
    return SAFETY_OK;
}

void safety_monitor_update(
    const level_measurement_t* current_level,
    const pump_state_t* pump1,
    const pump_state_t* pump2
) {
    uint64_t now_ms = esp_timer_get_time() / 1000;
    
    // Check sensor health
    if (!safety_check_sensor_health(current_level)) {
        // If sensor is failing and pumps are running, this is critical
        if ((pump1 && pump1->running) || (pump2 && pump2->running)) {
            ESP_LOGE(TAG, "Critical: Pumps running with sensor failure!");
            stats.emergency_stops++;
        }
    }
    
    // Check for rapid level changes (possible leak or sensor malfunction)
    if (current_level && current_level->valid && last_level_check_ms > 0) {
        uint64_t elapsed_ms = now_ms - last_level_check_ms;
        if (elapsed_ms >= 60000) { // Check every minute
            float level_change = fabsf(current_level->percent - last_level_percent);
            float minutes = elapsed_ms / 60000.0f;
            float change_per_minute = level_change / minutes;
            
            if (change_per_minute > MAX_LEVEL_CHANGE_PER_MIN) {
                ESP_LOGW(TAG, "Rapid level change detected: %.1f%%/min", change_per_minute);
                stats.last_violation = SAFETY_RAPID_LEVEL_CHANGE;
                stats.last_violation_ms = now_ms;
            }
            
            last_level_percent = current_level->percent;
            last_level_check_ms = now_ms;
        }
    } else if (current_level && current_level->valid) {
        last_level_percent = current_level->percent;
        last_level_check_ms = now_ms;
    }
    
    // Check pump runtime limits
    if (pump1 && pump1->running && pump1->start_time_ms > 0) {
        uint64_t runtime_ms = now_ms - pump1->start_time_ms;
        if (runtime_ms > MAX_PUMP_RUNTIME_MS) {
            ESP_LOGE(TAG, "Pump 1 exceeded maximum runtime (%llu ms)", runtime_ms);
            stats.last_violation = SAFETY_PUMP_STUCK_ON;
            stats.last_violation_ms = now_ms;
            stats.emergency_stops++;
        }
    }
    
    if (pump2 && pump2->running && pump2->start_time_ms > 0) {
        uint64_t runtime_ms = now_ms - pump2->start_time_ms;
        if (runtime_ms > MAX_PUMP_RUNTIME_MS) {
            ESP_LOGE(TAG, "Pump 2 exceeded maximum runtime (%llu ms)", runtime_ms);
            stats.last_violation = SAFETY_PUMP_STUCK_ON;
            stats.last_violation_ms = now_ms;
            stats.emergency_stops++;
        }
    }
}

const safety_stats_t* safety_get_stats(void) {
    return &stats;
}

void safety_reset_stats(void) {
    stats.dry_run_prevents = 0;
    stats.overflow_prevents = 0;
    stats.emergency_stops = 0;
    stats.last_violation_ms = 0;
    stats.last_violation = SAFETY_OK;
}

const char* safety_violation_to_string(safety_violation_t violation) {
    switch(violation) {
        case SAFETY_OK: return "OK";
        case SAFETY_DRY_RUN_RISK: return "DRY_RUN_RISK";
        case SAFETY_OVERFLOW_RISK: return "OVERFLOW_RISK";
        case SAFETY_SENSOR_FAILURE: return "SENSOR_FAILURE";
        case SAFETY_PUMP_STUCK_ON: return "PUMP_STUCK_ON";
        case SAFETY_RAPID_LEVEL_CHANGE: return "RAPID_LEVEL_CHANGE";
        default: return "UNKNOWN";
    }
}
