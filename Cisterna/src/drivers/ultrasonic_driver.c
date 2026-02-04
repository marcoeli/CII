// Ultrasonic Sensor Driver (HC-SR04) Implementation

#include "ultrasonic_driver.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static uint8_t trig_pin_num = 0;
static uint8_t echo_pin_num = 0;

int ultrasonic_init(uint8_t trig_pin, uint8_t echo_pin) {
    trig_pin_num = trig_pin;
    echo_pin_num = echo_pin;
    
    // Configure trigger pin as output
    gpio_config_t trig_conf = {
        .pin_bit_mask = (1ULL << trig_pin),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&trig_conf);
    gpio_set_level(trig_pin, 0);
    
    // Configure echo pin as input
    gpio_config_t echo_conf = {
        .pin_bit_mask = (1ULL << echo_pin),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_ENABLE, // Fix floating pin
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&echo_conf);
    
    return ULTRASONIC_OK;
}

int32_t ultrasonic_measure_raw_us(uint32_t timeout_us) {
    // Ensure trigger is low
    gpio_set_level(trig_pin_num, 0);
    esp_rom_delay_us(2);
    
    // Send 10us trigger pulse
    gpio_set_level(trig_pin_num, 1);
    esp_rom_delay_us(10);
    gpio_set_level(trig_pin_num, 0);
    
    // Wait for echo pin to go HIGH
    uint64_t start_time = esp_timer_get_time();
    while (gpio_get_level(echo_pin_num) == 0) {
        if ((esp_timer_get_time() - start_time) > timeout_us) {
            return ULTRASONIC_ERR_TIMEOUT;
        }
    }
    
    // Measure pulse duration (echo pin HIGH time)
    uint64_t pulse_start = esp_timer_get_time();
    while (gpio_get_level(echo_pin_num) == 1) {
        if ((esp_timer_get_time() - pulse_start) > timeout_us) {
            return ULTRASONIC_ERR_TIMEOUT;
        }
    }
    uint64_t pulse_end = esp_timer_get_time();
    
    return (int32_t)(pulse_end - pulse_start);
}

int32_t ultrasonic_measure_cm(uint32_t timeout_us) {
    int32_t duration_us = ultrasonic_measure_raw_us(timeout_us);
    
    if (duration_us < 0) {
        return duration_us; // Propagate error
    }
    
    // Calculate distance
    // Speed of sound = 343 m/s = 0.0343 cm/us (Fixed fallback)
    // Distance = (pulse_duration * 0.0343) / 2  (divide by 2 for round trip)
    int32_t distance_cm = (int32_t)((duration_us * 343) / (2 * 10000));
    
    // Sanity check (HC-SR04 range: 2cm to 400cm)
    if (distance_cm < 2 || distance_cm > 400) {
        return ULTRASONIC_ERR_INVALID;
    }
    
    return distance_cm;
}
