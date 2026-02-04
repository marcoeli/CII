#ifndef GPIO_UTILS_H
#define GPIO_UTILS_H

#include "driver/gpio.h"
#include "esp_log.h"

/**
 * @brief Check if GPIO supports internal pull-up/pull-down
 * @param gpio_num GPIO number to check
 * @return true if supports, false otherwise
 */
static inline bool gpio_supports_internal_pull(gpio_num_t gpio_num) {
    // ESP32: GPIO34-39 are input-only without internal pull resistors
    return !(gpio_num >= GPIO_NUM_34 && gpio_num <= GPIO_NUM_39);
}

/**
 * @brief Safely configure GPIO as input with optional pull resistors
 * @param gpio_num GPIO number
 * @param pullup Enable pull-up (ignored for input-only pins)
 * @param pulldown Enable pull-down (ignored for input-only pins)
 * @return ESP_OK on success, error code otherwise
 */
static inline esp_err_t gpio_config_input_safe(gpio_num_t gpio_num, bool pullup, bool pulldown) {
    if (!GPIO_IS_VALID_GPIO(gpio_num)) {
        ESP_LOGE("GPIO_UTILS", "Invalid GPIO: %d", (int)gpio_num);
        return ESP_ERR_INVALID_ARG;
    }

    gpio_config_t io = {
        .pin_bit_mask = 1ULL << gpio_num,
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };

    // Check if pull resistors are requested on input-only pins
    if ((pullup || pulldown) && !gpio_supports_internal_pull(gpio_num)) {
        ESP_LOGW("GPIO_UTILS", 
                 "GPIO %d is input-only (no internal pull). Use external resistor. Ignoring pull config.",
                 (int)gpio_num);
        pullup = false;
        pulldown = false;
    }

    io.pull_up_en = pullup ? GPIO_PULLUP_ENABLE : GPIO_PULLUP_DISABLE;
    io.pull_down_en = pulldown ? GPIO_PULLDOWN_ENABLE : GPIO_PULLDOWN_DISABLE;

    return gpio_config(&io);
}

#endif // GPIO_UTILS_H
