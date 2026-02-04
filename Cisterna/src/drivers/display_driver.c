// Display Driver Implementation (SSD1306 OLED via U8g2 Software I2C)

#include "display_driver.h"
#include <u8g2.h>
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>

static u8g2_t u8g2;
static bool display_initialized = false;

// GPIO pins for software I2C
static uint8_t sda_gpio = 0;
static uint8_t scl_gpio = 0;

// Software I2C bit-bang implementation
static void sw_i2c_delay(void) {
    esp_rom_delay_us(5);  // ~100kHz
}

static void sw_i2c_sda_high(void) {
    gpio_set_direction(sda_gpio, GPIO_MODE_INPUT);
}

static void sw_i2c_sda_low(void) {
    gpio_set_direction(sda_gpio, GPIO_MODE_OUTPUT);
    gpio_set_level(sda_gpio, 0);
}

static void sw_i2c_scl_high(void) {
    gpio_set_level(scl_gpio, 1);
}

static void sw_i2c_scl_low(void) {
    gpio_set_level(scl_gpio, 0);
}

static uint8_t u8g2_esp32_i2c_byte_cb(u8x8_t *u8x8, uint8_t msg, uint8_t arg_int, void *arg_ptr) {
    switch(msg) {
        case U8X8_MSG_BYTE_SEND: {
            uint8_t *data = (uint8_t *)arg_ptr;
            while(arg_int > 0) {
                uint8_t byte = *data;
                for(int i = 0; i < 8; i++) {
                    sw_i2c_scl_low();
                    if(byte & 0x80) sw_i2c_sda_high();
                    else sw_i2c_sda_low();
                    sw_i2c_delay();
                    sw_i2c_scl_high();
                    sw_i2c_delay();
                    byte <<= 1;
                }
                // ACK bit
                sw_i2c_scl_low();
                sw_i2c_sda_high();
                sw_i2c_delay();
                sw_i2c_scl_high();
                sw_i2c_delay();
                data++;
                arg_int--;
            }
            break;
        }
        case U8X8_MSG_BYTE_INIT: {
            break;
        }
        case U8X8_MSG_BYTE_SET_DC: {
            break;
        }
        case U8X8_MSG_BYTE_START_TRANSFER: {
            // I2C START condition
            sw_i2c_sda_high();
            sw_i2c_scl_high();
            sw_i2c_delay();
            sw_i2c_sda_low();
            sw_i2c_delay();
            sw_i2c_scl_low();
            
            // Send I2C address
            uint8_t addr = u8x8_GetI2CAddress(u8x8);
            for(int i = 0; i < 8; i++) {
                if(addr & 0x80) sw_i2c_sda_high();
                else sw_i2c_sda_low();
                sw_i2c_delay();
                sw_i2c_scl_high();
                sw_i2c_delay();
                sw_i2c_scl_low();
                addr <<= 1;
            }
            // ACK
            sw_i2c_sda_high();
            sw_i2c_delay();
            sw_i2c_scl_high();
            sw_i2c_delay();
            sw_i2c_scl_low();
            break;
        }
        case U8X8_MSG_BYTE_END_TRANSFER: {
            // I2C STOP condition
            sw_i2c_scl_low();
            sw_i2c_sda_low();
            sw_i2c_delay();
            sw_i2c_scl_high();
            sw_i2c_delay();
            sw_i2c_sda_high();
            sw_i2c_delay();
            break;
        }
        default:
            return 0;
    }
    return 1;
}

static uint8_t u8g2_esp32_gpio_and_delay_cb(u8x8_t *u8x8, uint8_t msg, uint8_t arg_int, void *arg_ptr) {
    switch(msg) {
        case U8X8_MSG_GPIO_AND_DELAY_INIT:
            break;
        case U8X8_MSG_DELAY_MILLI:
            vTaskDelay(pdMS_TO_TICKS(arg_int));
            break;
        case U8X8_MSG_DELAY_10MICRO:
            esp_rom_delay_us(arg_int * 10);
            break;
        case U8X8_MSG_DELAY_100NANO:
            esp_rom_delay_us(1);
            break;
        default:
            return 0;
    }
    return 1;
}

int display_init(uint8_t sda_pin, uint8_t scl_pin) {
    // Salvar pinos para software I2C
    sda_gpio = sda_pin;
    scl_gpio = scl_pin;
    
    // Configurar GPIOs
    gpio_reset_pin(sda_gpio);
    gpio_reset_pin(scl_gpio);
    gpio_set_direction(scl_gpio, GPIO_MODE_OUTPUT);
    gpio_set_level(scl_gpio, 1);
    gpio_set_direction(sda_gpio, GPIO_MODE_INPUT);  // Open-drain via INPUT mode
    gpio_set_pull_mode(sda_gpio, GPIO_PULLUP_ONLY);
    gpio_set_pull_mode(scl_gpio, GPIO_PULLUP_ONLY);
    
    ESP_LOGI("DISP", "Initializing SSD1306 with Software I2C (SDA=%d, SCL=%d)", sda_pin, scl_pin);
    
    // SSD1306 NONAME com Software I2C conforme especificação do fornecedor
    u8g2_Setup_ssd1306_i2c_128x64_noname_f(&u8g2, U8G2_R0, 
                                           u8g2_esp32_i2c_byte_cb, 
                                           u8g2_esp32_gpio_and_delay_cb);
    
    u8g2_SetI2CAddress(&u8g2, 0x78); // 0x3C << 1
    u8g2_InitDisplay(&u8g2);
    u8g2_SetPowerSave(&u8g2, 0);
    u8g2_ClearDisplay(&u8g2);

    // DRAW TEST PATTERN
    ESP_LOGW("DISP", "Drawing test pattern...");
    u8g2_SetFont(&u8g2, u8g2_font_ncenB08_tr);
    u8g2_DrawStr(&u8g2, 0, 10, "Display Test OK!");
    u8g2_DrawBox(&u8g2, 0, 20, 128, 10);
    u8g2_SendBuffer(&u8g2);
    
    display_initialized = true;
    return 0;
}

void display_clear(void) {
    if (!display_initialized) return;
    u8g2_ClearBuffer(&u8g2);
}

void display_update(void) {
    if (!display_initialized) return;
    u8g2_SendBuffer(&u8g2);
}

void display_draw_string(uint8_t x, uint8_t y, const char* str) {
    if (!display_initialized) return;
    u8g2_DrawStr(&u8g2, x, y, str);
}

void display_draw_string_centered(uint8_t y, const char* str) {
    if (!display_initialized) return;
    uint8_t width = u8g2_GetStrWidth(&u8g2, str);
    uint8_t x = (DISPLAY_WIDTH - width) / 2;
    u8g2_DrawStr(&u8g2, x, y, str);
}

void display_set_font_small(void) {
    if (!display_initialized) return;
    u8g2_SetFont(&u8g2, u8g2_font_6x10_tf);
}

void display_set_font_medium(void) {
    if (!display_initialized) return;
    u8g2_SetFont(&u8g2, u8g2_font_9x15_tf);
}

void display_set_font_large(void) {
    if (!display_initialized) return;
    u8g2_SetFont(&u8g2, u8g2_font_inb16_mf);
}

void display_set_font_huge(void) {
    if (!display_initialized) return;
    u8g2_SetFont(&u8g2, u8g2_font_inb24_mf);
}

uint8_t display_get_str_width(const char* str) {
    if (!display_initialized) return 0;
    return u8g2_GetStrWidth(&u8g2, str);
}

void display_draw_frame(uint8_t x, uint8_t y, uint8_t w, uint8_t h) {
    if (!display_initialized) return;
    u8g2_DrawFrame(&u8g2, x, y, w, h);
}

void display_draw_box(uint8_t x, uint8_t y, uint8_t w, uint8_t h) {
    if (!display_initialized) return;
    u8g2_DrawBox(&u8g2, x, y, w, h);
}

void display_draw_hline(uint8_t x, uint8_t y, uint8_t w) {
    if (!display_initialized) return;
    u8g2_DrawHLine(&u8g2, x, y, w);
}

void display_draw_vline(uint8_t x, uint8_t y, uint8_t h) {
    if (!display_initialized) return;
    u8g2_DrawVLine(&u8g2, x, y, h);
}

void display_set_contrast(uint8_t value) {
    if (!display_initialized) return;
    u8g2_SetContrast(&u8g2, value);
}

void display_power(bool on) {
    if (!display_initialized) return;
    u8g2_SetPowerSave(&u8g2, on ? 0 : 1);
}