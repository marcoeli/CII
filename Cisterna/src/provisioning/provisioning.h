// Provisioning Module
// Handles device provisioning via MQTT

#ifndef PROVISIONING_H
#define PROVISIONING_H

#include <stdbool.h>
#include <stdint.h>


#ifdef __cplusplus
extern "C" {
#endif

// Provisioning state
typedef enum {
  PROV_STATE_IDLE,
  PROV_STATE_CONNECTING,
  PROV_STATE_REGISTERING,
  PROV_STATE_WAITING_RESPONSE,
  PROV_STATE_SUCCESS,
  PROV_STATE_FAILED
} provisioning_state_t;

// Provisioning error codes
typedef enum {
  PROV_ERR_NONE = 0,
  PROV_ERR_MQTT_CONNECT,
  PROV_ERR_TIMEOUT,
  PROV_ERR_INVALID_RESPONSE,
  PROV_ERR_SERVER_REJECTED,
  PROV_ERR_ALREADY_PROVISIONED
} provisioning_error_t;

// Provisioning callbacks
typedef void (*provisioning_success_cb_t)(void);
typedef void (*provisioning_error_cb_t)(provisioning_error_t error,
                                        const char *detail);

// Initialize provisioning module
int provisioning_init(void);

// Start provisioning process
// Connects to MQTT using setup credentials and sends registration request
int provisioning_start(provisioning_success_cb_t success_cb,
                       provisioning_error_cb_t error_cb);

// Get current provisioning state
provisioning_state_t provisioning_get_state(void);

// Get correlation ID (used for debugging)
const char *provisioning_get_correlation_id(void);

// Cancel provisioning
void provisioning_cancel(void);

// Build provisioning registration payload (JSON)
// Returns static buffer - do not free
char *provisioning_build_registration_payload(void);

// Parse provisioning response
// Returns 0 on success, -1 on error
int provisioning_parse_response(const char *json_response);

// Update provisioning state (called by MQTT manager)
void provisioning_set_state(provisioning_state_t state);

#ifdef __cplusplus
}
#endif

#endif // PROVISIONING_H
