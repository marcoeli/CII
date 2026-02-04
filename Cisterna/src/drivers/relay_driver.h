// Relay Driver for SSR-40 Solid State Relays
// Controls relay modules (active-low typical for SSR-40)

#ifndef RELAY_DRIVER_H
#define RELAY_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

// Relay IDs
typedef enum {
    RELAY_1 = 0,
    RELAY_2 = 1,
    RELAY_COUNT = 2
} relay_id_t;

// Relay states
typedef enum {
    RELAY_OFF = 0,
    RELAY_ON = 1
} relay_state_t;

// Initialize relay driver
// Sets up GPIO pins for both relays
// Returns 0 on success
int relay_init(uint8_t relay1_pin, uint8_t relay2_pin);

// Set relay state
// relay_id: RELAY_1 or RELAY_2
// state: RELAY_ON or RELAY_OFF
void relay_set_state(relay_id_t relay_id, relay_state_t state);

// Get relay state
// Returns current relay state
relay_state_t relay_get_state(relay_id_t relay_id);

// Turn relay on
void relay_on(relay_id_t relay_id);

// Turn relay off
void relay_off(relay_id_t relay_id);

#endif // RELAY_DRIVER_H
