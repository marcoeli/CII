// Cisterna Patio Firmware Configuration
// Version 1.0.0

#ifndef CONFIG_H
#define CONFIG_H

// Import secrets if available
#if __has_include("secrets.h")
    #include "secrets.h"
#endif

// ============================================================================
// FIRMWARE VERSION
// ============================================================================
#define FIRMWARE_VERSION "1.0.0"
#define DEVICE_TYPE "CISTERN_NODE"

// ============================================================================
// PROVISIONING MODE (Change for production)
// ============================================================================
#define MODE_DEV  0
#define MODE_PROD 1

#ifndef PROVISIONING_MODE
#define PROVISIONING_MODE MODE_DEV  // DEV or PROD
#endif

// DEV Mode Token (placeholder - definition should be in secrets.h)
#ifndef SECRET_DEV_TOKEN
    #define SECRET_DEV_TOKEN "PLACEHOLDER_DEV_TOKEN"
#endif
#define DEV_TOKEN SECRET_DEV_TOKEN

// MQTT Configuration (Setup Mode - for provisioning device)
#define SETUP_MQTT_BROKER       "mqtt.icodz.com.br"
#define SETUP_MQTT_PORT         1883  // Non-secure port for DEV mode
#define SETUP_MQTT_USERNAME     "setup"                                  

#ifndef SECRET_SETUP_MQTT_PASSWORD
    #define SECRET_SETUP_MQTT_PASSWORD "PLACEHOLDER_SETUP_PASS"
#endif
#define SETUP_MQTT_PASSWORD     SECRET_SETUP_MQTT_PASSWORD 

// ============================================================================
// GPIO PIN ASSIGNMENTS (ESP32 DevKit V1 30-pin)
// ============================================================================

// Ultrasonic Sensor (HC-SR04)
#define PIN_ULTRASONIC_TRIG 23
#define PIN_ULTRASONIC_ECHO 19  // FIXED: Moved from 22 to 19 to avoid conflict with I2C SCL

// SSR-40 Relays (Solid State Relays)
#define PIN_RELAY_PUMP_1    25  // GPIO25 (DAC1/ADC2_8)
#define PIN_RELAY_PUMP_2    26  // GPIO26 (DAC2/ADC2_9)

// I2C for SSD1306 Display
#define PIN_I2C_SDA         21
#define PIN_I2C_SCL         22  // Dedicated for I2C SCL

// Buttons (Note: GPIO34 and GPIO35 are input-only)
#define PIN_BUTTON_UP       32
#define PIN_BUTTON_DOWN     33
#define PIN_BUTTON_SELECT   34  // Input only
#define PIN_BUTTON_BACK     35  // Input only

// ============================================================================
// TIMING INTERVALS (milliseconds)
// ============================================================================// Timing Configuration
#define WATCHDOG_TIMEOUT_S              120    // Increased for network operations
#define MQTT_HEARTBEAT_INTERVAL_MS      30000  // 30 seconds
#define LEVEL_MEASUREMENT_INTERVAL_MS   5000   // 5 seconds
#define DISPLAY_UPDATE_INTERVAL_MS      1000    // 1 second
#define BUTTON_DEBOUNCE_MS              50      // 50 ms debounce
#define BUTTON_LONG_PRESS_MS            2000    // 2 seconds for long press

// MQTT Reconnection
#define MQTT_RECONNECT_DELAY_MS         10000   // 10 seconds
#define MQTT_RECONNECT_MAX_DELAY_MS     60000   // 60 seconds max backoff

// WiFi Reconnection
#define WIFI_RECONNECT_DELAY_MS     5000    // 5 seconds
#define WIFI_AP_TIMEOUT_MS          300000  // 5 minutes in AP mode before retry

// ============================================================================
// SAFETY THRESHOLDS (percentages)
// ============================================================================
#define LEVEL_CRITICAL_LOW_PERCENT  10.0    // Below this = dry-run risk
#define LEVEL_LOW_PERCENT           20.0    // Low water warning
#define LEVEL_HIGH_PERCENT          90.0    // High water warning
#define LEVEL_OVERFLOW_PERCENT      95.0    // Overflow risk

// ============================================================================
// DEFAULT TANK CONFIGURATION
// ============================================================================
// These are defaults - user can configure via web interface
#define DEFAULT_TANK_SHAPE          "rectangular"  // or "cylindrical"
#define DEFAULT_TANK_HEIGHT_CM      200.0
#define DEFAULT_TANK_WIDTH_CM       100.0
#define DEFAULT_TANK_DEPTH_CM       100.0
#define DEFAULT_SENSOR_OFFSET_CM    5.0    // Distance from sensor to top of tank

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================
#define WIFI_AP_SSID_PREFIX         "Cisterna-Setup-"

#ifndef SECRET_WIFI_AP_PASSWORD
    #define SECRET_WIFI_AP_PASSWORD "PLACEHOLDER_AP_PASS"
#endif
#define WIFI_AP_PASSWORD            SECRET_WIFI_AP_PASSWORD
#define WIFI_AP_CHANNEL             6
#define WIFI_AP_MAX_CONNECTIONS     4

#define WEB_SERVER_PORT             80

// ============================================================================
// NVS (Non-Volatile Storage) KEYS
// ============================================================================
#define NVS_NAMESPACE               "cisterna"

// Wi-Fi credentials
#define NVS_KEY_WIFI_SSID           "wifi_ssid"
#define NVS_KEY_WIFI_PASSWORD       "wifi_pass"

// MQTT credentials (from provisioning)
#define NVS_KEY_MQTT_USERNAME       "mqtt_user"
#define NVS_KEY_MQTT_PASSWORD       "mqtt_pass"
#define NVS_KEY_MQTT_BROKER         "mqtt_broker"
#define NVS_KEY_MQTT_PORT           "mqtt_port"

// Provisioning state
#define NVS_KEY_PROVISIONED         "provisioned"
#define NVS_KEY_CLAIM_CODE          "claim_code"

// Tank configuration
#define NVS_KEY_TANK_SHAPE          "tank_shape"
#define NVS_KEY_TANK_HEIGHT         "tank_height"
#define NVS_KEY_TANK_WIDTH          "tank_width"
#define NVS_KEY_TANK_DEPTH          "tank_depth"
#define NVS_KEY_TANK_DIAMETER_TOP   "tank_dia_top"
#define NVS_KEY_TANK_DIAMETER_BTM   "tank_dia_btm"
#define NVS_KEY_SENSOR_OFFSET       "sensor_offset"

// Alert thresholds
#define NVS_KEY_THRESHOLD_LOW       "thresh_low"
#define NVS_KEY_THRESHOLD_CRIT_LOW  "thresh_crit"
#define NVS_KEY_THRESHOLD_HIGH      "thresh_high"

// Device configuration
#define NVS_KEY_LOCATION            "location"
#define NVS_KEY_REPORT_INTERVAL     "report_int"

// ============================================================================
// DEVICE CAPABILITIES
// ============================================================================
#define DEVICE_CAPABILITY_WATER_LEVEL    "WATER_LEVEL"
#define DEVICE_CAPABILITY_WATER_ACTUATOR "WATER_ACTUATOR"

// Resources
#define RESOURCE_CISTERN                 "cistern"
#define RESOURCE_PUMP_1                  "cistern_pump_1"
#define RESOURCE_PUMP_2                  "cistern_pump_2"

// ============================================================================
// OPERATIONAL MQTT TOPICS
// ============================================================================
// NOTE: These topics are NOT hardcoded in the firmware logic
// They are defined here for reference/documentation only
// The actual pub/sub is determined by server ACLs after provisioning

// Provisioning (Hardcoded - used before provisioning)
#define TOPIC_SETUP_REGISTRO         "setup/registro"
#define TOPIC_SETUP_RESPOSTA_PREFIX  "setup/resposta/"

// Device Management (Post-provisioning - username comes from server)
// Format: home/device/{username}/status
// Format: home/device/{username}/errors
// Format: home/device/{username}/config
// Format: home/device/{username}/ota

// Water Domain (Post-provisioning)
// Format: home/water/level/{reservatorio}
// Format: home/water/pump/{pump_id}/state
// Format: home/water/pump/{pump_id}/command

#endif // CONFIG_H
