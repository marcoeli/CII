// Display Driver for SSD1306 OLED (using U8g2 library)

#ifndef DISPLAY_DRIVER_H
#define DISPLAY_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

// Display dimensions
#define DISPLAY_WIDTH  128
#define DISPLAY_HEIGHT 64

// Initialize display
// Returns 0 on success
int display_init(uint8_t sda_pin, uint8_t scl_pin);

// Clear display buffer
void display_clear(void);

// Update display (send buffer to screen)
void display_update(void);

// Drawing primitives
void display_draw_string(uint8_t x, uint8_t y, const char* str);
void display_draw_string_centered(uint8_t y, const char* str);
void display_set_font_small(void);
void display_set_font_medium(void);
void display_set_font_large(void);
void display_set_font_huge(void);

// Helper functions
uint8_t display_get_str_width(const char* str);

// Advanced drawing
void display_draw_frame(uint8_t x, uint8_t y, uint8_t w, uint8_t h);
void display_draw_box(uint8_t x, uint8_t y, uint8_t w, uint8_t h);
void display_draw_hline(uint8_t x, uint8_t y, uint8_t w);
void display_draw_vline(uint8_t x, uint8_t y, uint8_t h);

// Display control
void display_set_contrast(uint8_t value);  // 0-255
void display_power(bool on);

#endif // DISPLAY_DRIVER_H
