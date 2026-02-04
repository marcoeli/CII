// Button Driver Implementation

#include "button_driver.h"
#include "../include/gpio_utils.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "esp_timer.h"
#include <string.h>

static const char* TAG = "BUTTON_DRV";

typedef struct {
    uint8_t pin;
    bool current_state;
    bool last_stable_state;
    uint64_t last_change_time;
    uint64_t press_start_time;
    button_event_t pending_event;
    bool long_press_triggered;
} button_state_t;

static button_state_t buttons[BUTTON_COUNT];

int button_init(uint8_t up_pin, uint8_t down_pin, uint8_t select_pin, uint8_t back_pin) {
    uint8_t pins[BUTTON_COUNT] = {up_pin, down_pin, select_pin, back_pin};
    
    // Initialize button states
    memset(buttons, 0, sizeof(buttons));
    
    // Configure GPIO pins with safe configuration
    for (int i = 0; i < BUTTON_COUNT; i++) {
        buttons[i].pin = pins[i];
        buttons[i].current_state = false;
        buttons[i].last_stable_state = false;
        buttons[i].pending_event = BUTTON_EVENT_NONE;
        
        ESP_LOGI(TAG, "Configuring button %d on GPIO %d", i, pins[i]);
        esp_err_t ret = gpio_config_input_safe(pins[i], true, false);
        if (ret != ESP_OK) {
            ESP_LOGE(TAG, "Failed to configure button GPIO %d: %s", 
                     pins[i], esp_err_to_name(ret));
            return -1;
        }
    }
    
    return 0;
}

void button_poll(uint32_t debounce_ms, uint32_t long_press_ms) {
    uint64_t now = esp_timer_get_time() / 1000;  // Convert to milliseconds
    
    for (int i = 0; i < BUTTON_COUNT; i++) {
        // Read current button state (active-low: 0 = pressed)
        bool raw_state = (gpio_get_level(buttons[i].pin) == 0);
        
        // Debouncing logic
        if (raw_state != buttons[i].current_state) {
            buttons[i].last_change_time = now;
            buttons[i].current_state = raw_state;
        }
        
        // Check if state has been stable for debounce period
        if (now - buttons[i].last_change_time >= debounce_ms) {
            bool new_stable_state = buttons[i].current_state;
            
            // Detect state changes
            if (new_stable_state && !buttons[i].last_stable_state) {
                // Button pressed
                buttons[i].press_start_time = now;
                buttons[i].pending_event = BUTTON_EVENT_PRESSED;
                buttons[i].long_press_triggered = false;
            }
            else if (!new_stable_state && buttons[i].last_stable_state) {
                // Button released
                if (!buttons[i].long_press_triggered) {
                    buttons[i].pending_event = BUTTON_EVENT_RELEASED;
                }
            }
            else if (new_stable_state && buttons[i].last_stable_state) {
                // Button still pressed - check for long press
                if (!buttons[i].long_press_triggered && 
                    (now - buttons[i].press_start_time >= long_press_ms)) {
                    buttons[i].pending_event = BUTTON_EVENT_LONG_PRESS;
                    buttons[i].long_press_triggered = true;
                }
            }
            
            buttons[i].last_stable_state = new_stable_state;
        }
    }
}

bool button_is_pressed(button_id_t button_id) {
    if (button_id >= BUTTON_COUNT) return false;
    return (gpio_get_level(buttons[button_id].pin) == 0);
}

button_event_t button_get_event(button_id_t button_id) {
    if (button_id >= BUTTON_COUNT) return BUTTON_EVENT_NONE;
    return buttons[button_id].pending_event;
}

void button_clear_event(button_id_t button_id) {
    if (button_id >= BUTTON_COUNT) return;
    buttons[button_id].pending_event = BUTTON_EVENT_NONE;
}
