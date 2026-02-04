// Relay Driver Implementation

#include "relay_driver.h"
#include "driver/gpio.h"

// SSR-40 is typically active-low, but can be configured
// Set to 1 for active-high, 0 for active-low
// FIXED: Changed to 1 (Active High) because user reported GPIOs always HIGH with 0 (Active Low)
#define RELAY_ACTIVE_HIGH 1

static uint8_t relay_pins[RELAY_COUNT] = {0};
static relay_state_t relay_states[RELAY_COUNT] = {RELAY_OFF, RELAY_OFF};

int relay_init(uint8_t relay1_pin, uint8_t relay2_pin) {
    relay_pins[RELAY_1] = relay1_pin;
    relay_pins[RELAY_2] = relay2_pin;
    
    // Configure both relay pins as outputs
    for (int i = 0; i < RELAY_COUNT; i++) {
        // CRITICAL: Set pin level BEFORE configuring as output to prevent momentary activation
        // For active-LOW relays (SSR-40): HIGH = OFF
        #if RELAY_ACTIVE_HIGH
            gpio_set_level(relay_pins[i], 0);  // Set LOW for active-high (OFF state)
        #else
            gpio_set_level(relay_pins[i], 1);  // Set HIGH for active-low (OFF state)
        #endif
        
        gpio_config_t io_conf = {
            .pin_bit_mask = (1ULL << relay_pins[i]),
            .mode = GPIO_MODE_OUTPUT,
            .pull_up_en = GPIO_PULLUP_DISABLE,
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .intr_type = GPIO_INTR_DISABLE
        };
        gpio_config(&io_conf);
        
        // Ensure OFF state (redundant but safe)
        relay_set_state(i, RELAY_OFF);
    }
    
    return 0;
}

void relay_set_state(relay_id_t relay_id, relay_state_t state) {
    if (relay_id >= RELAY_COUNT) return;
    
    relay_states[relay_id] = state;
    
    // SSR-40 logic: active-low means LOW = ON, HIGH = OFF
    #if RELAY_ACTIVE_HIGH
        gpio_set_level(relay_pins[relay_id], state == RELAY_ON ? 1 : 0);
    #else
        gpio_set_level(relay_pins[relay_id], state == RELAY_ON ? 0 : 1);
    #endif
}

relay_state_t relay_get_state(relay_id_t relay_id) {
    if (relay_id >= RELAY_COUNT) return RELAY_OFF;
    return relay_states[relay_id];
}

void relay_on(relay_id_t relay_id) {
    relay_set_state(relay_id, RELAY_ON);
}

void relay_off(relay_id_t relay_id) {
    relay_set_state(relay_id, RELAY_OFF);
}
