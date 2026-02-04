#ifndef NETWORK_MANAGER_H
#define NETWORK_MANAGER_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Network FSM States
typedef enum {
  NETWORK_STATE_BOOT,         // Initial state, checking config
  NETWORK_STATE_GRACE_PERIOD, // Trying to connect (3 min timeout)
  NETWORK_STATE_CONNECTED,    // Connected to WiFi (Normal Operation)
  NETWORK_STATE_AP_MODE,      // AP Mode for configuration (10 min timeout)
  NETWORK_STATE_RECOVERY      // Trying to recover connection
} network_state_t;

// Public API
int network_manager_init(void);
void network_manager_update(void); // Call in main loop (non-blocking)
network_state_t network_manager_get_state(void);
const char *network_manager_get_state_string(void);
bool network_manager_is_ntp_synced(void);

#ifdef __cplusplus
}
#endif

#endif // NETWORK_MANAGER_H
