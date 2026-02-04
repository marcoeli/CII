// Application Configuration Constants
// Centralized definitions for NVS keys and default values

#pragma once

// NVS Namespace
#define NVS_NAMESPACE "cfg"

// NVS Keys - Wi-Fi
#define NVS_KEY_WIFI_SSID      "wifi_ssid"
#define NVS_KEY_WIFI_PASSWORD  "wifi_pass"

// NVS Keys - MQTT
#define NVS_KEY_MQTT_USERNAME  "mqtt_user"
#define NVS_KEY_MQTT_PASSWORD  "mqtt_pass"
#define NVS_KEY_MQTT_BROKER    "mqtt_host"
#define NVS_KEY_MQTT_PORT      "mqtt_port"

// NVS Keys - Provisioning / Claim
#define NVS_KEY_PROVISIONED    "prov"
#define NVS_KEY_CLAIM_CODE     "claim"
#define NVS_KEY_DEV_TOKEN      "dev_token"
#define NVS_KEY_AUTH_MODE      "auth_mode"

// NVS Keys - Context (V2.4)
#define NVS_KEY_TENANT         "tenant"
#define NVS_KEY_HOME           "home"

// NVS Keys - Other
#define NVS_KEY_LOCATION       "loc"
#define NVS_KEY_REPORT_INTERVAL "rpt_int"

// Default Level Thresholds (percentages)
#define LEVEL_LOW_PERCENT               25
#define LEVEL_CRITICAL_LOW_PERCENT      10
#define LEVEL_HIGH_PERCENT              90
#define LEVEL_OVERFLOW_PERCENT          95

// Measurement Configuration
#define ULTRASONIC_TIMEOUT_US       30000
#define SAMPLE_DELAY_MS             50
#define MIN_VALID_SAMPLES_PERCENT   50
#define MAX_SAMPLE_DEVIATION_CM     10.0f
#define DEFAULT_TEMPERATURE_C       30.0f

// NVS Keys - Config
#define NVS_KEY_TEMPERATURE         "temp_c"
