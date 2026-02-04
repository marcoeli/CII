// Button Service
// Higher-level button handling with event processing

#ifndef BUTTON_SERVICE_H
#define BUTTON_SERVICE_H

#include <stdint.h>
#include <stdbool.h>
#include "../drivers/button_driver.h"

// Button actions (semantic meaning)
typedef enum {
    BUTTON_ACTION_NONE,
    BUTTON_ACTION_NAVIGATE_UP,
    BUTTON_ACTION_NAVIGATE_DOWN,
    BUTTON_ACTION_SELECT,
    BUTTON_ACTION_BACK,
    BUTTON_ACTION_LONG_SELECT,  // Long press on SELECT for special function
    BUTTON_ACTION_LONG_BACK     // Long press on BACK for special function
} button_action_t;

// Initialize button service
int button_service_init(void);

// Update button service (call in main loop)
void button_service_update(void);

// Get pending action
button_action_t button_service_get_action(void);

// Clear pending action
void button_service_clear_action(void);

// Check if any button is currently pressed
bool button_service_any_pressed(void);

#endif // BUTTON_SERVICE_H
