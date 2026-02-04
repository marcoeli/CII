// Ultrasonic Sensor Driver (HC-SR04)
// Measures distance using ultrasonic pulses

#ifndef ULTRASONIC_DRIVER_H
#define ULTRASONIC_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

// Error codes
#define ULTRASONIC_OK           0
#define ULTRASONIC_ERR_TIMEOUT  -1
#define ULTRASONIC_ERR_INVALID  -2

// Initialize the ultrasonic sensor
// Returns ULTRASONIC_OK on success
int ultrasonic_init(uint8_t trig_pin, uint8_t echo_pin);

// Measure distance in centimeters
// Returns distance in cm, or negative error code
// timeout_us: Maximum time to wait for echo (default 30000 = 30ms)
int32_t ultrasonic_measure_cm(uint32_t timeout_us);

// Measure raw echo time in microseconds
// Returns time in us, or negative error code
int32_t ultrasonic_measure_raw_us(uint32_t timeout_us);

#endif // ULTRASONIC_DRIVER_H
