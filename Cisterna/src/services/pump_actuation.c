// Pump Actuation Service Implementation

#include "pump_actuation.h"
#include "../drivers/relay_driver.h"
#include "esp_timer.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include <string.h>

static pump_state_t pump_states[PUMP_COUNT];
static SemaphoreHandle_t pump_mutex = NULL;

#define TIMEOUT_SAFETY_S (60 * 60) // 60 minutes max runtime

int pump_actuation_init(void) {
    if (pump_mutex == NULL) {
        pump_mutex = xSemaphoreCreateMutex();
    }

    // Initialize pump states
    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        for (int i = 0; i < PUMP_COUNT; i++) {
            pump_states[i].running = false;
            pump_states[i].mode = PUMP_MODE_MANUAL;
            pump_states[i].reason = "initialized";
            pump_states[i].start_time_ms = 0;
            pump_states[i].runtime_s = 0;
        }
        xSemaphoreGive(pump_mutex);
    }
    
    return 0;
}

bool pump_check_safety(const level_measurement_t* level) {
    if (!level) return false;
    
    static uint64_t last_log_ms = 0;
    uint64_t now_ms = esp_timer_get_time() / 1000;

    if (!level->valid) {
        if (now_ms - last_log_ms > 5000) {
            ESP_LOGW("PUMP_SAFETY", "Safety check failed: Level measurement invalid");
            last_log_ms = now_ms;
        }
        return false;
    }
    
    // Don't run pumps if level is critical low (dry-run protection)
    if (level->alert == LEVEL_ALERT_CRITICAL_LOW) {
        if (now_ms - last_log_ms > 5000) {
            ESP_LOGW("PUMP_SAFETY", "Safety check failed: Critical Low Level (Dry Run Protection)");
            last_log_ms = now_ms;
        }
        return false;
    }
    
    // Removed OVERFLOW check: Cistern pumps should run on overflow (emptying)
    
    return true;
}

bool pump_start(pump_id_t pump_id, const char* reason, bool force) {
    if (pump_id >= PUMP_COUNT) return false;
    
    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        // Check if pump is already running
        if (pump_states[pump_id].running) {
             xSemaphoreGive(pump_mutex);
            return true;  // Already running
        }
        
        if (pump_states[pump_id].mode == PUMP_MODE_LOCKED && !force) {
             xSemaphoreGive(pump_mutex);
            return false;
        }

        // Don't release mutex yet, we want to update state atomically with action roughly
    } else {
        return false;
    }
    
    // Note: Safety checks should be done by caller
    // Force flag allows manual override in testing/maintenance
    
    // Start the pump (activate relay)
    relay_on((relay_id_t)pump_id);
    
    // Update state
    pump_states[pump_id].running = true;
    pump_states[pump_id].reason = reason ? reason : "started";
    pump_states[pump_id].forced = force;  // Store forced state
    pump_states[pump_id].start_time_ms = esp_timer_get_time() / 1000;
    
    xSemaphoreGive(pump_mutex);
    
    return true;
}

void pump_stop(pump_id_t pump_id, const char* reason) {
    if (pump_id >= PUMP_COUNT) return;
    
    // Stop the pump (deactivate relay)
    relay_off((relay_id_t)pump_id);
    
    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        // Update runtime if pump was running
        if (pump_states[pump_id].running && pump_states[pump_id].start_time_ms > 0) {
            uint64_t now_ms = esp_timer_get_time() / 1000;
            uint32_t session_runtime_s = (uint32_t)((now_ms - pump_states[pump_id].start_time_ms) / 1000);
            pump_states[pump_id].runtime_s += session_runtime_s;
        }
        
        // Update state
        pump_states[pump_id].running = false;
        pump_states[pump_id].reason = reason ? reason : "stopped";
        pump_states[pump_id].start_time_ms = 0;
        
        xSemaphoreGive(pump_mutex);
    }
}

void pump_set_mode(pump_id_t pump_id, pump_mode_t mode) {
    if (pump_id >= PUMP_COUNT) return;
    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        pump_states[pump_id].mode = mode;
        xSemaphoreGive(pump_mutex);
    }
}

pump_state_t pump_get_state(pump_id_t pump_id) {
    pump_state_t state = {0};
    if (pump_id >= PUMP_COUNT) {
        state.reason = "invalid_pump_id";
        return state;
    }
    
    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        state = pump_states[pump_id];
        xSemaphoreGive(pump_mutex);
    }
    return state;
}

void pump_update_runtime(void) {
    static uint64_t last_check_ms = 0;
    uint64_t now_ms = esp_timer_get_time() / 1000;
    
    // Run concise check every 1s
    if (now_ms - last_check_ms < 1000) return;
    last_check_ms = now_ms;

    if (xSemaphoreTake(pump_mutex, portMAX_DELAY)) {
        for (int i = 0; i < PUMP_COUNT; i++) {
            if (pump_states[i].running && pump_states[i].start_time_ms > 0) {
                // Check Safety Timeout
                uint32_t current_run_s = (uint32_t)((now_ms - pump_states[i].start_time_ms) / 1000);
                
                if (current_run_s > TIMEOUT_SAFETY_S) {
                    ESP_LOGE("PUMP_SAFETY", "Pump %d exceeded max runtime (%ds). Specifying SAFETY STOP.", i, TIMEOUT_SAFETY_S);
                    // Unlock mutex before calling stop to avoid deadlock (stop takes mutex)
                    xSemaphoreGive(pump_mutex);
                    pump_stop((pump_id_t)i, "SAFETY_MAX_RUNTIME");
                    // Re-take mutex to continue loop? No, better restart loop or just exit
                    // since we modified state. Let's just return to be safe.
                    return; 
                }
            }
        }
        xSemaphoreGive(pump_mutex);
    }
}
