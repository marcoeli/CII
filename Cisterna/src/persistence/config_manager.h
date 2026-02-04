// Config Manager - NVS Storage
// Manages all persistent configuration

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "../services/level_measurement.h"

#ifdef __cplusplus
extern "C" {
#endif

// Initialize config manager (NVS)
int config_manager_init(void);

// Factory reset (clear all settings)
int config_manager_factory_reset(void);

// ============================================================================
// Wi-Fi Credentials
// ============================================================================
int config_save_wifi_credentials(const char* ssid, const char* password);
int config_get_wifi_credentials(char* ssid, size_t ssid_len, char* password, size_t pass_len);
bool config_has_wifi_credentials(void);

// ============================================================================
// MQTT Credentials (from provisioning)
// ============================================================================
int config_save_mqtt_credentials(const char* username, const char* password, 
                                  const char* broker, uint16_t port);
int config_get_mqtt_credentials(char* username, size_t user_len, 
                                 char* password, size_t pass_len,
                                 char* broker, size_t broker_len,
                                 uint16_t* port);
bool config_has_mqtt_credentials(void);

// ============================================================================
// Context & Auth (V2.4)
// ============================================================================
int config_save_context(const char* tenant, const char* home);
int config_get_context(char* tenant, size_t tenant_len, char* home, size_t home_len);
bool config_has_context(void);

int config_save_dev_token(const char* dev_token);
int config_get_dev_token(char* dev_token, size_t len);
int config_clear_dev_token(void);

typedef enum {
    AUTH_MODE_PROD = 0,
    AUTH_MODE_DEV = 1
} auth_mode_t;

int config_save_auth_mode(auth_mode_t mode);
auth_mode_t config_get_auth_mode(void);

// ============================================================================
// Provisioning State
// ============================================================================
int config_set_provisioned(bool provisioned);
bool config_is_provisioned(void);

// Claim code (PROD mode only)
int config_save_claim_code(const char* claim_code);
int config_get_claim_code(char* claim_code, size_t len);
int config_clear_claim_code(void);

// ============================================================================
// Tank Configuration
// ============================================================================
int config_save_tank_config(const tank_config_t* config);
int config_get_tank_config(tank_config_t* config);
bool config_has_tank_config(void);

int config_save_temperature(float temp_c);
float config_get_temperature(void);

// ============================================================================
// Alert Thresholds
// ============================================================================
typedef struct {
    float low_percent;
    float critical_low_percent;
    float high_percent;
} alert_thresholds_t;

int config_save_alert_thresholds(const alert_thresholds_t* thresholds);
int config_get_alert_thresholds(alert_thresholds_t* thresholds);

// ============================================================================
// Device Settings
// ============================================================================
int config_save_location(const char* location);
int config_get_location(char* location, size_t len);

int config_save_report_interval(uint32_t interval_s);
uint32_t config_get_report_interval(void);

// ============================================================================
// ACL Topics (from provisioning response)
// ============================================================================
int config_save_acl_topics(const char* topics);
int config_get_acl_topics(char* topics, size_t len);
int config_clear_acl_topics(void);

#ifdef __cplusplus
}
#endif

#endif // CONFIG_MANAGER_H
