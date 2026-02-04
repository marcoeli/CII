// OTA Manager - Over-The-Air Update Manager
// Handles firmware updates via MQTT

#ifndef OTA_MANAGER_H
#define OTA_MANAGER_H

#include <stdint.h>
#include <stdbool.h>

// OTA status
typedef enum {
    OTA_STATUS_IDLE,
    OTA_STATUS_DOWNLOADING,
    OTA_STATUS_VALIDATING,
    OTA_STATUS_UPDATING,
    OTA_STATUS_SUCCESS,
    OTA_STATUS_FAILED
} ota_status_t;

// OTA error codes
typedef enum {
    OTA_ERR_NONE = 0,
    OTA_ERR_DOWNLOAD_FAILED,
    OTA_ERR_INVALID_IMAGE,
    OTA_ERR_FLASH_FAILED,
    OTA_ERR_VALIDATION_FAILED,
    OTA_ERR_NO_SPACE
} ota_error_t;

// Initialize OTA manager
int ota_manager_init(void);

// Start OTA update from URL
int ota_manager_start_update(const char* url);

// Get current OTA status
ota_status_t ota_manager_get_status(void);

// Get OTA progress (0-100%)
uint8_t ota_manager_get_progress(void);

// Check if rollback is available
bool ota_manager_can_rollback(void);

// Perform rollback to previous firmware
int ota_manager_rollback(void);

// Mark current firmware as valid (after successful boot)
void ota_manager_mark_valid(void);

// Get error code
ota_error_t ota_manager_get_error(void);

#endif // OTA_MANAGER_H
