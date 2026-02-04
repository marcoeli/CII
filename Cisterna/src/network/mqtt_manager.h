// MQTT Manager - MQTT Client with TLS
// Handles both setup and operational MQTT connections

#ifndef MQTT_MANAGER_H
#define MQTT_MANAGER_H

#include <stdbool.h>
#include <stdint.h>


#ifdef __cplusplus
extern "C" {
#endif

// MQTT connection mode
typedef enum {
  MQTT_MODE_IDLE = 0,
  MQTT_MODE_SETUP = 1,      // Setup mode for provisioning
  MQTT_MODE_OPERATIONAL = 2 // Operational mode with user credentials
} mqtt_mode_t;

// MQTT status
typedef enum {
  MQTT_STATUS_DISCONNECTED,
  MQTT_STATUS_CONNECTING,
  MQTT_STATUS_CONNECTED,
  MQTT_STATUS_ERROR
} mqtt_status_t;

// Message callback
typedef void (*mqtt_message_cb_t)(const char *topic, const char *payload,
                                  int len);

// Connection callbacks
typedef void (*mqtt_connected_cb_t)(void);
typedef void (*mqtt_disconnected_cb_t)(void);

// Initialize MQTT manager
int mqtt_manager_init(void);

// Connect in setup mode (for provisioning)
int mqtt_manager_connect_setup(void);

// Connect in operational mode (with saved credentials)
int mqtt_manager_connect_operational(const char *username, const char *password,
                                     const char *broker, uint16_t port);

// Disconnect
void mqtt_manager_disconnect(void);

// Publish message
int mqtt_manager_publish(const char *topic, const char *payload, int qos,
                         bool retain);

// Subscribe to topic
int mqtt_manager_subscribe(const char *topic, int qos);

// Unsubscribe from topic
int mqtt_manager_unsubscribe(const char *topic);

// Get status
mqtt_status_t mqtt_manager_get_status(void);
bool mqtt_manager_is_started(void);
int mqtt_manager_get_mode(void); // 0=None, 1=Setup, 2=Operational
// Set callbacks
void mqtt_manager_set_message_callback(mqtt_message_cb_t cb);
void mqtt_manager_set_connection_callbacks(
    mqtt_connected_cb_t connected_cb, mqtt_disconnected_cb_t disconnected_cb);

#ifdef __cplusplus
}
#endif

#endif // MQTT_MANAGER_H
