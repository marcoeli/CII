// Button Driver with Debouncing

#ifndef BUTTON_DRIVER_H
#define BUTTON_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

// Button IDs
typedef enum {
    BUTTON_UP = 0,
    BUTTON_DOWN = 1,
    BUTTON_SELECT = 2,
    BUTTON_BACK = 3,
    BUTTON_COUNT = 4
} button_id_t;

// Button events
typedef enum {
    BUTTON_EVENT_NONE = 0,
    BUTTON_EVENT_PRESSED,
    BUTTON_EVENT_RELEASED,
    BUTTON_EVENT_LONG_PRESS
} button_event_t;

// Initialize button driver
// Returns 0 on success
int button_init(uint8_t up_pin, uint8_t down_pin, uint8_t select_pin, uint8_t back_pin);

// Poll buttons (call this in main loop)
// debounce_ms: Minimum time button must be stable (default 50ms)
// long_press_ms: Time threshold for long press detection (default 2000ms)
void button_poll(uint32_t debounce_ms, uint32_t long_press_ms);

// Check if button is currently pressed (immediate, no debounce)
bool button_is_pressed(button_id_t button_id);

// Get button event (after debouncing)
// Returns BUTTON_EVENT_NONE if no event
button_event_t button_get_event(button_id_t button_id);

// Clear button event
void button_clear_event(button_id_t button_id);

#endif // BUTTON_DRIVER_H
