// Cistern Controller - Main Device State Machine
// Coordinates all modules and manages device lifecycle

#include "cistern_controller.h"
#include "../include/config.h"
#include "../persistence/config_manager.h"
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"
#include "../services/display_service.h"
#include "../network/mqtt_manager.h"
#include "../messaging/mqtt_handlers.h"
#include "esp_log.h"
#include "esp_timer.h"
#include <string.h>
#include <math.h>

static const char *TAG = "CISTERN_CTRL";

static controller_context_t context = {
    .current_state = DEVICE_STATE_BOOT,
    .wifi_connected = false,
    .mqtt_connected = false,
    .error_count = 0,
    .state_changed_at_ms = 0
};

int cistern_controller_init(void) {
    context.current_state = DEVICE_STATE_BOOT;
    context.wifi_connected = false;
    context.mqtt_connected = false;
    context.error_count = 0;
    context.state_changed_at_ms = esp_timer_get_time() / 1000;
    
    // Init state tracking
    context.last_heartbeat_ms = 0;
    context.last_published_level_ts = 0;
    memset(&context.last_published_level, 0, sizeof(level_measurement_t));
    memset(&context.last_published_pump1, 0, sizeof(pump_state_t));
    memset(&context.last_published_pump2, 0, sizeof(pump_state_t));
    
    return 0;
}

device_state_t cistern_controller_get_state(void) {
    return context.current_state;
}

void cistern_controller_set_state(device_state_t new_state) {
    if (context.current_state != new_state) {
        ESP_LOGI(TAG, "State change: %s -> %s",
                cistern_controller_state_to_string(context.current_state),
                cistern_controller_state_to_string(new_state));
        
        context.current_state = new_state;
        context.state_changed_at_ms = esp_timer_get_time() / 1000;
    }
}

const char* cistern_controller_state_to_string(device_state_t state) {
    switch(state) {
        case DEVICE_STATE_BOOT: return "BOOT";
        case DEVICE_STATE_UNPROVISIONED: return "UNPROVISIONED";
        case DEVICE_STATE_PROVISIONING: return "PROVISIONING";
        case DEVICE_STATE_CONNECTING: return "CONNECTING";
        case DEVICE_STATE_RUNNING: return "RUNNING";
        case DEVICE_STATE_DEGRADED: return "DEGRADED";
        case DEVICE_STATE_OTA_IN_PROGRESS: return "OTA_IN_PROGRESS";
        case DEVICE_STATE_ERROR_SAFE: return "ERROR_SAFE";
        default: return "UNKNOWN";
    }
}

void cistern_controller_wifi_connected(void) {
    context.wifi_connected = true;
    ESP_LOGI(TAG, "WiFi connected");
    
    // If we were unprovisioned and now have WiFi, move to provisioning
    if (context.current_state == DEVICE_STATE_UNPROVISIONED) {
        cistern_controller_set_state(DEVICE_STATE_PROVISIONING);
    }
}

void cistern_controller_wifi_disconnected(void) {
    context.wifi_connected = false;
    ESP_LOGW(TAG, "WiFi disconnected");
    
    // If we were running, move to degraded mode
    if (context.current_state == DEVICE_STATE_RUNNING) {
        cistern_controller_set_state(DEVICE_STATE_DEGRADED);
    }
}

void cistern_controller_mqtt_connected(void) {
    context.mqtt_connected = true;
    ESP_LOGI(TAG, "MQTT connected");
    
    // Subscribe to command topics from ACLs (if provisioned)
    // Subscribe to command topics from ACLs (if provisioned)
    if (config_is_provisioned()) {
        char acl_topics[2048] = {0};
        if (config_get_acl_topics(acl_topics, sizeof(acl_topics)) == 0 && strlen(acl_topics) > 0) {
            ESP_LOGI(TAG, "Subscribing to ACL topics: %s", acl_topics);
            
            ESP_LOGI(TAG, "Subscribing to ACL topics: %s", acl_topics);
            
            // Parse semicolon-separated topics and subscribe to each
            char* topic = strtok(acl_topics, ";");
            int count = 0;
            while (topic != NULL) {
                ESP_LOGI(TAG, "Subscribing to item %d: %s", count++, topic);
                mqtt_manager_subscribe(topic, 1);
                topic = strtok(NULL, ";");
            }
            ESP_LOGI(TAG, "Finished subscribing to %d topics", count);
        }
        
        // Publish initial heartbeat - DEFERRED to main loop (cistern_controller_update)
        // to avoid running heavy JSON serialization in the MQTT task stack context.
        // mqtt_handlers_publish_heartbeat(); 
        ESP_LOGI(TAG, "Initial heartbeat deferred to main loop");
    }
    
    // If we were connecting or degraded, move to running
    if (context.current_state == DEVICE_STATE_CONNECTING ||
        context.current_state == DEVICE_STATE_DEGRADED) {
        cistern_controller_set_state(DEVICE_STATE_RUNNING);
    }
}

void cistern_controller_mqtt_disconnected(void) {
    context.mqtt_connected = false;
    ESP_LOGW(TAG, "MQTT disconnected");
    
    // If we were running, move to degraded
    if (context.current_state == DEVICE_STATE_RUNNING) {
        cistern_controller_set_state(DEVICE_STATE_DEGRADED);
    }
}

const controller_context_t* cistern_controller_get_context(void) {
    return &context;
}

bool cistern_controller_is_safe_to_run_pump(pump_id_t pump_id) {
    // Check if we have valid level measurement
    if (!context.last_level.valid) {
        ESP_LOGW(TAG, "Cannot run pump %d: no valid level measurement", pump_id);
        return false;
    }
    
    // ONLY check for critical low level (dry-run protection)
    // Pumps REMOVE water from cistern, so overflow is not relevant
    // Pumps feed OTHER tanks - those tanks handle their own overflow protection
    if (context.last_level.alert == LEVEL_ALERT_CRITICAL_LOW) {
        ESP_LOGW(TAG, "Cannot run pump %d: critical low water level (%.0f%%) - dry-run protection",
                pump_id, context.last_level.percent);
        return false;
    }
    
    // Check device state - only allow in RUNNING or DEGRADED
    if (context.current_state != DEVICE_STATE_RUNNING &&
        context.current_state != DEVICE_STATE_DEGRADED) {
        ESP_LOGW(TAG, "Cannot run pump %d: device state is %s",
                pump_id, cistern_controller_state_to_string(context.current_state));
        return false;
    }
    
    return true;
}

void cistern_controller_emergency_stop(const char* reason) {
    ESP_LOGE(TAG, "EMERGENCY STOP: %s", reason);
    
    // Stop all pumps immediately
    pump_stop(PUMP_1, reason);
    pump_stop(PUMP_2, reason);
    
    // Update state to error safe
    cistern_controller_set_state(DEVICE_STATE_ERROR_SAFE);
    
    context.error_count++;
}

void cistern_controller_update(void) {
    // Statics removed - using context state
    
    uint64_t now_ms = esp_timer_get_time() / 1000;
    

    
    // Update level measurement in context
    static uint64_t last_read_ms = 0;
    if (now_ms - last_read_ms > 1000) { // Read every 1s
         level_measurement_t reading = level_measurement_read(5);
         if (reading.valid) {
             last_read_ms = now_ms;
             
             // Update context directly (No smoothing)
             context.last_level = reading;
         } else {
             // Log warning but keep old value in context (Display will show stale but valid data)
             // only log occasionally to avoid flooding
             static uint64_t last_invalid_log = 0;
             if (now_ms - last_invalid_log >= 10000) {
                 ESP_LOGV(TAG, "Invalid level reading, keeping last known value");
                 last_invalid_log = now_ms;
             }
         }
    }
    
    // Update pump states in context
    context.pump1_state = pump_get_state(PUMP_1);
    context.pump2_state = pump_get_state(PUMP_2);
    
    // Publish heartbeat every 30 seconds if MQTT connected
    if (context.mqtt_connected && config_is_provisioned()) {
        if (now_ms - context.last_heartbeat_ms >= 30000) {
            ESP_LOGI(TAG, "Triggering Heartbeat Publication...");
            mqtt_handlers_publish_heartbeat();
            ESP_LOGI(TAG, "Heartbeat Published Successfully");
            context.last_heartbeat_ms = now_ms;
        }
        
        // Get configured report interval (default 30s)
        uint32_t report_interval_ms = config_get_report_interval() * 1000;
        if (report_interval_ms < 1000) report_interval_ms = 1000; // Min 1s
        
        // Publish level based on time or critical state change
        if (context.last_level.valid) {
            bool time_to_report = (now_ms - context.last_published_level_ts >= report_interval_ms);
            bool alert_changed = (context.last_level.alert != context.last_published_level.alert);
            
            // Still publish immediately if alert state changes (safety), but limit frequency
            // to avoid flooding if sensor is noisy (oscillating between alerts)
            bool rapid_change_allowed = (now_ms - context.last_published_level_ts >= 5000); // Max 1 update per 5s for alerts
            
            if (time_to_report || (alert_changed && rapid_change_allowed) || !context.last_published_level.valid) {
                 ESP_LOGI(TAG, "Publishing level: %.1f%% (Alert: %d)", 
                          context.last_level.percent, context.last_level.alert);
                mqtt_handlers_publish_level(&context.last_level);
                context.last_published_level = context.last_level;
                context.last_published_level_ts = now_ms;
            }
        } else {
            // Log why level is not published
            static uint64_t last_invalid_log = 0;
            if (now_ms - last_invalid_log >= 10000) {
                ESP_LOGW(TAG, "Level measurement invalid - not publishing");
                last_invalid_log = now_ms;
            }
        }
        
        // Publish pump state if changed
        if (context.pump1_state.running != context.last_published_pump1.running ||
            context.pump1_state.mode != context.last_published_pump1.mode) {
            ESP_LOGI(TAG, "Publishing pump1 state: running=%d mode=%d", 
                     context.pump1_state.running, context.pump1_state.mode);
            mqtt_handlers_publish_pump_state(PUMP_1, &context.pump1_state);
            context.last_published_pump1 = context.pump1_state;
        }
        
        if (context.pump2_state.running != context.last_published_pump2.running ||
            context.pump2_state.mode != context.last_published_pump2.mode) {
            ESP_LOGI(TAG, "Publishing pump2 state: running=%d mode=%d",
                     context.pump2_state.running, context.pump2_state.mode);
            mqtt_handlers_publish_pump_state(PUMP_2, &context.pump2_state);
            context.last_published_pump2 = context.pump2_state;
        }
    }
    
    // Safety monitoring - check running pumps
    if (context.pump1_state.running || context.pump2_state.running) {
        // Verify safety conditions for running pumps
        bool safety_ok = pump_check_safety(&context.last_level);
        
        if (!safety_ok) {
            if (context.pump1_state.running && !context.pump1_state.forced) {
                ESP_LOGW(TAG, "Safety violation - stopping pump 1");
                pump_stop(PUMP_1, "safety_violation");
            }
            if (context.pump2_state.running && !context.pump2_state.forced) {
                ESP_LOGW(TAG, "Safety violation - stopping pump 2");
                pump_stop(PUMP_2, "safety_violation");
            }
        }
    }
    
    // State machine logic
    switch(context.current_state) {
        case DEVICE_STATE_BOOT:
            // Boot state is managed externally
            break;
            
        case DEVICE_STATE_UNPROVISIONED:
            // Waiting for WiFi configuration
            break;
            
        case DEVICE_STATE_PROVISIONING:
            // Provisioning in progress
            break;
            
        case DEVICE_STATE_CONNECTING:
            // Attempting to connect to MQTT
            if (context.mqtt_connected) {
                cistern_controller_set_state(DEVICE_STATE_RUNNING);
            }
            break;
            
        case DEVICE_STATE_RUNNING:
            // Normal operation
            if (!context.mqtt_connected) {
                cistern_controller_set_state(DEVICE_STATE_DEGRADED);
            }
            break;
            
        case DEVICE_STATE_DEGRADED:
            // Local operation only - try to recover
            if (context.mqtt_connected) {
                cistern_controller_set_state(DEVICE_STATE_RUNNING);
            }
            break;
            
        case DEVICE_STATE_OTA_IN_PROGRESS:
            // OTA update in progress - maintain state
            break;
            
        case DEVICE_STATE_ERROR_SAFE:
            // Error state - require manual intervention
            // Could implement auto-recovery after timeout
            break;
    }
    // Update Display
    // Limit display refresh rate to ~10Hz to save CPU
    static uint64_t last_display_update = 0;
    if (now_ms - last_display_update > 100) {
        
        network_status_t net_status = {
            .wifi_connected = context.wifi_connected,
            .wifi_rssi = 0, // TODO: Get actual RSSI
            .mqtt_connected = context.mqtt_connected,
            .device_state = cistern_controller_state_to_string(context.current_state)
        };

        display_service_render(&context.last_level, 
                               &context.pump1_state, 
                               &context.pump2_state, 
                               &net_status);
        last_display_update = now_ms;
    }
}
