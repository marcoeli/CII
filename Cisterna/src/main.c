// Cisterna Patio Firmware - Main Application
// Integrates all modules into a cohesive system

#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_task_wdt.h"

// Include all module headers
#include "include/config.h"
#include "persistence/config_manager.h"
#include "provisioning/provisioning.h"
#include "network/network_manager.h" // [NEW] Replaces direct wifi/mqtt management
#include "network/web_server.h"      // Still needed for some internal types if any
#include "network/wifi_manager.h" // Added for RSSI and IP access
#include "network/mqtt_manager.h"    // Needed for status checks in display
#include "messaging/mqtt_handlers.h"
#include "drivers/ultrasonic_driver.h"

#include "drivers/relay_driver.h"
#include "drivers/display_driver.h"
#include "drivers/button_driver.h"
#include "services/level_measurement.h"
#include "services/pump_actuation.h"
#include "services/button_service.h"
#include "services/display_service.h"
#include "domain/cistern_controller.h"
#include "ota/ota_manager.h"

static const char *TAG = "CISTERNA";

// Watchdog timeout (15 seconds)
#ifdef WATCHDOG_TIMEOUT_S
#undef WATCHDOG_TIMEOUT_S
#endif
#define WATCHDOG_TIMEOUT_S 15

// Static state variables
// static device_state_t current_device_state = DEVICE_STATE_BOOT; // Managed by controller and net mgr

// Timing tracking
static uint64_t last_display_update_ms = 0;

// Current measurements (deprecated in favor of controller context)
static network_status_t network_status = {0};

// Function prototypes
static void init_hardware(void);
static void init_services(void);
static void load_configuration(void);

// ============================================================================
// Initialization
// ============================================================================

static void init_hardware(void) {
    ESP_LOGI(TAG, "Initializing hardware drivers...");
    
    // Initialize ultrasonic sensor
    ultrasonic_init(PIN_ULTRASONIC_TRIG, PIN_ULTRASONIC_ECHO);
    
    // Initialize relays
    relay_init(PIN_RELAY_PUMP_1, PIN_RELAY_PUMP_2);
    
    // Initialize display
    display_init(PIN_I2C_SDA, PIN_I2C_SCL);
    
    // Initialize buttons
    button_init(PIN_BUTTON_UP, PIN_BUTTON_DOWN, 
                PIN_BUTTON_SELECT, PIN_BUTTON_BACK);
    
    ESP_LOGI(TAG, "Hardware initialized");
}

static void init_services(void) {
    ESP_LOGI(TAG, "Initializing services...");
    
    // Initialize pump actuation
    pump_actuation_init();
    
    // Initialize button service
    button_service_init();
    
    // Initialize display service
    display_service_init();
    
    ESP_LOGI(TAG, "Services initialized");
}

static void load_configuration(void) {
    ESP_LOGI(TAG, "Loading configuration from NVS...");
    
    // Load tank configuration
    tank_config_t tank_cfg;
    if (config_get_tank_config(&tank_cfg) == 0) {
        level_measurement_init(&tank_cfg);
        ESP_LOGI(TAG, "Tank configuration loaded");
    } else {
        // Use default configuration
        tank_cfg.shape = TANK_SHAPE_RECTANGULAR;
        tank_cfg.height_cm = DEFAULT_TANK_HEIGHT_CM;
        tank_cfg.width_cm = DEFAULT_TANK_WIDTH_CM;
        tank_cfg.depth_cm = DEFAULT_TANK_DEPTH_CM;
        tank_cfg.sensor_offset_cm = DEFAULT_SENSOR_OFFSET_CM;
        
        level_measurement_init(&tank_cfg);
        config_save_tank_config(&tank_cfg);
        
        ESP_LOGW(TAG, "Using default tank configuration");
    }
    
    // Load Temperature Config
    float temp_c = config_get_temperature();
    level_measurement_set_temperature(temp_c);
}

// ============================================================================
// Main Loop Tasks
// ============================================================================

static void update_display(void) {
    uint64_t now_ms = esp_timer_get_time() / 1000;
    
    if (now_ms - last_display_update_ms >= DISPLAY_UPDATE_INTERVAL_MS) {
        last_display_update_ms = now_ms;
        
        const controller_context_t* ctx = cistern_controller_get_context();
        
        // Update network status for display from Network Manager
        network_state_t net_state = network_manager_get_state();
        network_status.wifi_connected = (net_state == NETWORK_STATE_CONNECTED || net_state == NETWORK_STATE_AP_MODE); // Simplified for display
        network_status.wifi_rssi = wifi_manager_get_rssi();
        network_status.mqtt_connected = (mqtt_manager_get_status() == MQTT_STATUS_CONNECTED);
        network_status.device_state = cistern_controller_state_to_string(ctx->current_state);
        
        // Populate IP and Device ID
        const char* ip_addr = wifi_manager_get_ip();
        if (ip_addr) {
             strncpy(network_status.ip_address, ip_addr, sizeof(network_status.ip_address) - 1);
        } else {
             strcpy(network_status.ip_address, "0.0.0.0");
        }
        
        char username[64] = {0};
        char dummy_pass[4] = {0};
        char dummy_broker[4] = {0};
        uint16_t dummy_port = 0;
        
        if (config_get_mqtt_credentials(username, sizeof(username), 
                                        dummy_pass, sizeof(dummy_pass), 
                                        dummy_broker, sizeof(dummy_broker), 
                                        &dummy_port) == 0) {
             strncpy(network_status.device_id, username, sizeof(network_status.device_id) - 1);
        } else {
             strcpy(network_status.device_id, "Unknown");
        }
        
        // Auto-switch logic removed (Handled by Display Service Carousel)

        
        // Render current screen using data from controller context
        display_service_render(&ctx->last_level, &ctx->pump1_state, &ctx->pump2_state, &network_status);
    }
}

static void handle_button_input(void) {
    button_action_t action = button_service_get_action();
    
    if (action != BUTTON_ACTION_NONE) {
        switch(action) {
            case BUTTON_ACTION_NAVIGATE_UP:
                // Button 1: Toggle Pump 1
                {
                    const pump_state_t* p1 = &cistern_controller_get_context()->pump1_state;
                    if (p1->running) {
                        pump_stop(PUMP_1, "user_button");
                        display_service_show_message("PUMP 1", "STOPPING...", 1000);
                    } else {
                        pump_start(PUMP_1, "user_button", true);
                        display_service_show_message("PUMP 1", "STARTING...", 1000);
                    }
                }
                break;
                
            case BUTTON_ACTION_NAVIGATE_DOWN:
                // Button 2: Toggle Pump 2
                {
                    const pump_state_t* p2 = &cistern_controller_get_context()->pump2_state;
                    if (p2->running) {
                        pump_stop(PUMP_2, "user_button");
                        display_service_show_message("PUMP 2", "STOPPING...", 1000);
                    } else {
                        pump_start(PUMP_2, "user_button", true);
                        display_service_show_message("PUMP 2", "STARTING...", 1000);
                    }
                }
                break;
                
            case BUTTON_ACTION_SELECT:
            case BUTTON_ACTION_BACK:
                // Buttons reused for info (e.g. force showing network info temporarily)
                // For now, just show a message or wake display
                display_service_show_message("INFO", "CISTERNA v2.4", 1000);
                break;
                
            case BUTTON_ACTION_LONG_SELECT:
                ESP_LOGW(TAG, "Factory reset disabled");
                break;
                
            default:
                break;
        }
        
        button_service_clear_action();
    }
}

// ============================================================================
// Main Application Task
// ============================================================================

void app_main(void)
{
    ESP_LOGI(TAG, "==============================================");
    ESP_LOGI(TAG, "  Cisterna Patio Firmware v%s (Refactored)", FIRMWARE_VERSION);
    ESP_LOGI(TAG, "  Device Type: %s", DEVICE_TYPE);
    ESP_LOGI(TAG, "  Mode: %s", PROVISIONING_MODE == MODE_DEV ? "DEV" : "PROD");
    ESP_LOGI(TAG, "==============================================");
    
    // Initialize watchdog timer
    ESP_LOGI(TAG, "Initializing watchdog timer (%ds timeout)...", WATCHDOG_TIMEOUT_S);
    esp_task_wdt_config_t wdt_config = {
        .timeout_ms = WATCHDOG_TIMEOUT_S * 1000,
        .idle_core_mask = 0,
        .trigger_panic = true
    };
    esp_err_t wdt_err = esp_task_wdt_init(&wdt_config);
    if (wdt_err != ESP_OK && wdt_err != ESP_ERR_INVALID_STATE) {
        ESP_ERROR_CHECK(wdt_err);
    }
    esp_task_wdt_add(NULL); // Add current task to watchdog
    
    // Initialize NVS first
    ESP_LOGI(TAG, "Initializing config manager...");
    if (config_manager_init() != 0) {
        ESP_LOGE(TAG, "Failed to initialize config manager!");
        return;
    }
    
    // Initialize hardware
    init_hardware();
    
    // Initialize services
    init_services();
    
    // Load configuration
    load_configuration();
    
    // Initialize OTA manager
    ESP_LOGI(TAG, "Initializing OTA manager...");
    ota_manager_init();
    ota_manager_mark_valid();
    
    // Show boot message on display
    display_service_show_message("BOOT", "Starting...", 2000);
    // Removed blocking delay here to start network task sooner
    
    // Initialize domain controller
    cistern_controller_init();
    
    // Initialize provisioning (helpers)
    provisioning_init();
    
    // Initialize MQTT handlers
    mqtt_handlers_init();
    
    // Initialize Network Manager (Handles WiFi, FSM, AP Mode)
    network_manager_init();
    
    ESP_LOGI(TAG, "Entering main loop...");
    
    // ========================================================================
    // Main Loop (Non-Blocking)
    // ========================================================================
    
    while (1) {
        // Feed watchdog timer
        esp_task_wdt_reset();
        
        // Update Network Manager (FSM)
        network_manager_update();
        
        // Update domain controller (handles measurements and safety)
        cistern_controller_update();
        
        // Update button service (must be called every loop)
        button_service_update();
        
        // Handle button input
        handle_button_input();
        
        // Update display (periodic)
        update_display();
        
        // Update pump runtime tracking
        pump_update_runtime();
        
        // Small delay to prevent CPU hogging
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}
