// Display Service Implementation

#include "display_service.h"
#include "../drivers/display_driver.h"
#include "esp_timer.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static screen_id_t current_screen = SCREEN_HOME;
static char message_title[32] = {0};
static char message_text[64] = {0};
static uint64_t message_expiry_ms = 0;

// Carousel State
static uint64_t last_carousel_switch_ms = 0;
static bool carousel_show_network = false;

// Cache for last valid measurement
static level_measurement_t last_valid_level = {0};
static bool has_valid_level = false;
static uint64_t last_valid_ts = 0;

int display_service_init(void) {
    current_screen = SCREEN_NETWORK_INFO; // Start at boot screen
    message_title[0] = '\0';
    message_text[0] = '\0';
    message_expiry_ms = 0;
    
    return 0;
}

void display_service_set_screen(screen_id_t screen) {
    if (screen < SCREEN_COUNT) {
        current_screen = screen;
    }
}

screen_id_t display_service_get_screen(void) {
    return current_screen;
}

// ============================================================================
// Render Helpers
// ============================================================================

static void render_pump_alert(void) {
    display_clear();
    display_draw_frame(0, 0, 128, 64);
    display_draw_box(0, 0, 128, 64); // Draw background first
    display_set_font_large();
    // Invert text logic via driver would be better, but assuming White on Black
    // If box is filled, text should be Black, or we just rely on the flash to catch attention
    // For now, let's keep simple text
    display_draw_string_centered(30, "BOMBA");
    display_draw_string_centered(55, "LIGADA");
    display_update();
}

static void render_home_screen(const level_measurement_t* level, const network_status_t* network) {
    display_clear();
    uint64_t now_ms = esp_timer_get_time() / 1000;
    
    // Update cache if we have a new valid reading
    if (level && level->valid) {
        last_valid_level = *level;
        has_valid_level = true;
        last_valid_ts = now_ms;
    }
    
    // Check if cache is stale (older than 15 seconds)
    // We allow some grace period for sensor glitches
    bool cache_is_stale = (now_ms - last_valid_ts > 15000); 

    // Decide what to show: Current valid, or Cached valid (if not stale)
    const level_measurement_t* show_level = (level && level->valid) ? level : 
                                            ((has_valid_level && !cache_is_stale) ? &last_valid_level : NULL);
    
    if (show_level) {
        // --- Level Bar (Left Side) ---
        display_draw_frame(0, 0, 24, 64);
        
        // Fill: Calculate height
        uint8_t max_h = 60; 
        uint8_t fill_h = (uint8_t)((show_level->percent * max_h) / 100.0f);
        if(fill_h > max_h) fill_h = max_h;
        display_draw_box(2, 62 - fill_h, 20, fill_h);
        
        // --- Text Info ---
        char buf[32];
        
        // Huge font for Percentage
        display_set_font_huge(); 
        snprintf(buf, sizeof(buf), "%.0f%%", show_level->percent);
        
        uint8_t str_w = display_get_str_width(buf);
        uint8_t x_pos = 24 + (104 - str_w) / 2;
        display_draw_string(x_pos, 35, buf); 
        
        // Liters & Height below
        display_set_font_small();
        
        // Liters
        snprintf(buf, sizeof(buf), "Vol: %.0f L", show_level->liters);
        str_w = display_get_str_width(buf);
        x_pos = 24 + (104 - str_w) / 2;
        display_draw_string(x_pos, 50, buf);

        // Raw Distance (for calibration/debug)
        snprintf(buf, sizeof(buf), "Dist: %.1f cm", show_level->distance_cm);
        str_w = display_get_str_width(buf);
        x_pos = 24 + (104 - str_w) / 2;
        display_draw_string(x_pos, 60, buf);
        
    } else {
        display_set_font_large();
        display_draw_string_centered(35, "ERRO SENSOR");
    }
    
    display_update();
}

static void render_network_screen(const network_status_t* network) {
    display_clear();
    display_set_font_medium();
    
    // check if connected
    bool fully_connected = network && network->wifi_connected && network->mqtt_connected;

    if (fully_connected) {
        // OPERATIONAL INFO (Carousel Frame B)
        display_draw_string_centered(12, "INFO REDE");
        display_draw_hline(0, 14, 128);

        display_set_font_small();

        char buf[48]; // Increased to avoid truncation (ID can be 32 chars + prefix)
        // IP Address
        snprintf(buf, sizeof(buf), "IP: %s", network->ip_address);
        display_draw_string(0, 28, buf);

        // ID / Hostname
        snprintf(buf, sizeof(buf), "ID: %s", network->device_id);
        display_draw_string(0, 38, buf);
        
        // RSSI
        snprintf(buf, sizeof(buf), "Signal: %d dBm", network->wifi_rssi);
        display_draw_string(0, 48, buf);
        
        // State
        snprintf(buf, sizeof(buf), "State: %s", network->device_state ? network->device_state : "UNK");
        display_draw_string(0, 58, buf);

    } else {
        // BOOT / INIT INFO
        display_draw_string_centered(15, "CONECTANDO...");
        display_draw_hline(0, 17, 128);
        
        if (network) {
            display_set_font_small();
            
            char buf[32];
            snprintf(buf, sizeof(buf), "WiFi: %s", network->wifi_connected ? "OK" : "...");
            display_draw_string(10, 35, buf);
            
            snprintf(buf, sizeof(buf), "MQTT: %s", network->mqtt_connected ? "OK" : "...");
            display_draw_string(10, 50, buf);
        }
    }
    
    display_update();
}

// render_pump_screen removed as unused

// ============================================================================
// Main Render Function
// ============================================================================

void display_service_render(
    const level_measurement_t* level,
    const pump_state_t* pump1,
    const pump_state_t* pump2,
    const network_status_t* network
) {
    uint64_t now_ms = esp_timer_get_time() / 1000;

    // 1. Message Overlay (Highest Priority - Errors, Feedback)
    if (message_expiry_ms > 0 && now_ms < message_expiry_ms) {
        display_clear();
        display_set_font_medium();
        display_draw_box(10, 10, 108, 44);
        display_draw_frame(10, 10, 108, 44);
        // Draw centered and update
        // Draw centered and update
         display_draw_string_centered(24, message_title);
        display_set_font_small();
        display_draw_string_centered(40, message_text);
        display_update();
        return;
    } else if (message_expiry_ms > 0) {
        message_expiry_ms = 0;  // Expired
    }

    // 2. Pump Alert (Operational Priority)
    bool any_pump_running = (pump1 && pump1->running) || (pump2 && pump2->running);
    if (any_pump_running) {
        static bool blink_state = false;
        static uint64_t last_blink = 0;
        
        if (now_ms - last_blink > 800) { // Blink every 800ms
            blink_state = !blink_state;
            last_blink = now_ms;
        }
        
        if (blink_state) {
            render_pump_alert();
            return;
        }
        // If blink_state is false, fall through to show context (Level) for better UX
    }

    // 3. Configuration Priority (Boot/AP Mode)
    // If not connected to WiFi or MQTT, stick to Network Screen
    bool connected = network && network->wifi_connected && network->mqtt_connected;
    if (!connected) {
        render_network_screen(network);
        return;
    }

    // 4. Idle Carousel (Carousel Priority)
    // Cycle between Level (Home) and Network Info
    if (now_ms - last_carousel_switch_ms > 5000) { // 5 Seconds
        carousel_show_network = !carousel_show_network;
        last_carousel_switch_ms = now_ms;
    }

    if (carousel_show_network) {
        render_network_screen(network);
    } else {
        render_home_screen(level, network);
    }
}

void display_service_show_message(const char* title, const char* message, uint32_t duration_ms) {
    if (title) {
        strncpy(message_title, title, sizeof(message_title) - 1);
        message_title[sizeof(message_title) - 1] = '\0';
    }
    if (message) {
        strncpy(message_text, message, sizeof(message_text) - 1);
        message_text[sizeof(message_text) - 1] = '\0';
    }
    
    uint64_t now_ms = esp_timer_get_time() / 1000;
    uint64_t dur_ms = (uint64_t)duration_ms;
    message_expiry_ms = now_ms + dur_ms;
}
