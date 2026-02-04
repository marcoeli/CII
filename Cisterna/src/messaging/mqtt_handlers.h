// MQTT Message Handlers
// Processes incoming MQTT messages and publishes device state

#ifndef MQTT_HANDLERS_H
#define MQTT_HANDLERS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include "../services/level_measurement.h"
#include "../services/pump_actuation.h"

// Initialize MQTT handlers
int mqtt_handlers_init(void);

// Main message dispatcher
void mqtt_handlers_on_message(const char* topic, const char* payload, int len);

// Provisioning response handler
void mqtt_handlers_on_provisioning_response(const char* payload);

// Pump command handler
void mqtt_handlers_on_pump_command(pump_id_t pump_id, const char* payload);

// Config command handler
void mqtt_handlers_on_config_command(const char* payload);

// Publishers
void mqtt_handlers_publish_heartbeat(void);
void mqtt_handlers_publish_level(const level_measurement_t* level);
void mqtt_handlers_publish_pump_state(pump_id_t pump_id, const pump_state_t* state);
void mqtt_handlers_publish_error(const char* error_code, const char* detail);

// Subscribe to operational topics
void mqtt_handlers_subscribe_operational(const char* username);

#ifdef __cplusplus
}
#endif

#endif // MQTT_HANDLERS_H
