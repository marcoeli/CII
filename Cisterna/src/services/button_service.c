// Button Service Implementation

#include "button_service.h"
#include "../include/config.h"

static button_action_t pending_action = BUTTON_ACTION_NONE;

int button_service_init(void) {
    // Initialize button driver
    int result = button_init(
        PIN_BUTTON_UP,
        PIN_BUTTON_DOWN,
        PIN_BUTTON_SELECT,
        PIN_BUTTON_BACK
    );
    
    pending_action = BUTTON_ACTION_NONE;
    return result;
}

void button_service_update(void) {
    // Poll buttons with configured timing
    button_poll(BUTTON_DEBOUNCE_MS, BUTTON_LONG_PRESS_MS);
    
    // Check for events and translate to actions
    // Priority: process one event per update cycle
    
    // Check UP button
    button_event_t event = button_get_event(BUTTON_UP);
    if (event == BUTTON_EVENT_PRESSED || event == BUTTON_EVENT_RELEASED) {
        pending_action = BUTTON_ACTION_NAVIGATE_UP;
        button_clear_event(BUTTON_UP);
        return;
    }
    
    // Check DOWN button
    event = button_get_event(BUTTON_DOWN);
    if (event == BUTTON_EVENT_PRESSED || event == BUTTON_EVENT_RELEASED) {
        pending_action = BUTTON_ACTION_NAVIGATE_DOWN;
        button_clear_event(BUTTON_DOWN);
        return;
    }
    
    // Check SELECT button
    event = button_get_event(BUTTON_SELECT);
    if (event == BUTTON_EVENT_LONG_PRESS) {
        pending_action = BUTTON_ACTION_LONG_SELECT;
        button_clear_event(BUTTON_SELECT);
        return;
    } else if (event == BUTTON_EVENT_RELEASED) {
        pending_action = BUTTON_ACTION_SELECT;
        button_clear_event(BUTTON_SELECT);
        return;
    }
    
    // Check BACK button
    event = button_get_event(BUTTON_BACK);
    if (event == BUTTON_EVENT_LONG_PRESS) {
        pending_action = BUTTON_ACTION_LONG_BACK;
        button_clear_event(BUTTON_BACK);
        return;
    } else if (event == BUTTON_EVENT_RELEASED) {
        pending_action = BUTTON_ACTION_BACK;
        button_clear_event(BUTTON_BACK);
        return;
    }
}

button_action_t button_service_get_action(void) {
    return pending_action;
}

void button_service_clear_action(void) {
    pending_action = BUTTON_ACTION_NONE;
}

bool button_service_any_pressed(void) {
    return button_is_pressed(BUTTON_UP) ||
           button_is_pressed(BUTTON_DOWN) ||
           button_is_pressed(BUTTON_SELECT) ||
           button_is_pressed(BUTTON_BACK);
}
