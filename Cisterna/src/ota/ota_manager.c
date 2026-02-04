// OTA Manager Implementation

#include "ota_manager.h"
#include "esp_ota_ops.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_log.h"
#include "esp_system.h"

static const char *TAG = "OTA_MGR";

static ota_status_t current_status = OTA_STATUS_IDLE;
static ota_error_t last_error = OTA_ERR_NONE;
static uint8_t download_progress = 0;

// HTTP event handler for OTA
static esp_err_t http_event_handler(esp_http_client_event_t *evt) {
    switch(evt->event_id) {
        case HTTP_EVENT_ERROR:
            ESP_LOGE(TAG, "HTTP error");
            break;
        case HTTP_EVENT_ON_CONNECTED:
            ESP_LOGI(TAG, "HTTP connected");
            break;
        case HTTP_EVENT_HEADER_SENT:
            ESP_LOGD(TAG, "HTTP header sent");
            break;
        case HTTP_EVENT_ON_HEADER:
            ESP_LOGD(TAG, "Header: %s: %s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(TAG, "HTTP data received: %d bytes", evt->data_len);
            break;
        case HTTP_EVENT_ON_FINISH:
            ESP_LOGI(TAG, "HTTP session finished");
            break;
        case HTTP_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "HTTP disconnected");
            break;
        default:
            break;
    }
    return ESP_OK;
}

int ota_manager_init(void) {
    ESP_LOGI(TAG, "OTA Manager initialized");
    
    // Check if we need to validate the current firmware
    const esp_partition_t *running = esp_ota_get_running_partition();
    esp_ota_img_states_t ota_state;
    
    if (esp_ota_get_state_partition(running, &ota_state) == ESP_OK) {
        if (ota_state == ESP_OTA_IMG_PENDING_VERIFY) {
            ESP_LOGW(TAG, "First boot after OTA - marking as valid");
            ota_manager_mark_valid();
        }
    }
    
    return 0;
}

int ota_manager_start_update(const char* url) {
    if (!url) {
        ESP_LOGE(TAG, "Invalid URL");
        return -1;
    }
    
    ESP_LOGI(TAG, "Starting OTA update from: %s", url);
    current_status = OTA_STATUS_DOWNLOADING;
    download_progress = 0;
    last_error = OTA_ERR_NONE;
    
    esp_http_client_config_t http_config = {
        .url = url,
        .event_handler = http_event_handler,
        .keep_alive_enable = true,
        .timeout_ms = 30000,
    };
    
    esp_https_ota_config_t ota_config = {
        .http_config = &http_config,
    };
    
    esp_https_ota_handle_t https_ota_handle = NULL;
    esp_err_t err = esp_https_ota_begin(&ota_config, &https_ota_handle);
    
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "OTA begin failed");
        current_status = OTA_STATUS_FAILED;
        last_error = OTA_ERR_DOWNLOAD_FAILED;
        return -1;
    }
    
    // Download and write firmware
    current_status = OTA_STATUS_DOWNLOADING;
    
    while (1) {
        err = esp_https_ota_perform(https_ota_handle);
        if (err != ESP_ERR_HTTPS_OTA_IN_PROGRESS) {
            break;
        }
        
        // Update progress
        int data_read = esp_https_ota_get_image_len_read(https_ota_handle);
        int total_len = esp_https_ota_get_image_size(https_ota_handle);
        if (total_len > 0) {
            download_progress = (data_read * 100) / total_len;
            ESP_LOGI(TAG, "OTA progress: %d%%", download_progress);
        }
    }
    
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "OTA perform failed");
        esp_https_ota_abort(https_ota_handle);
        current_status = OTA_STATUS_FAILED;
        last_error = OTA_ERR_DOWNLOAD_FAILED;
        return -1;
    }
    
    // Validate image
    current_status = OTA_STATUS_VALIDATING;
    
    if (!esp_https_ota_is_complete_data_received(https_ota_handle)) {
        ESP_LOGE(TAG, "Complete data was not received");
        esp_https_ota_abort(https_ota_handle);
        current_status = OTA_STATUS_FAILED;
        last_error = OTA_ERR_INVALID_IMAGE;
        return -1;
    }
    
    // Finish OTA
    current_status = OTA_STATUS_UPDATING;
    err = esp_https_ota_finish(https_ota_handle);
    
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "OTA finish failed");
        current_status = OTA_STATUS_FAILED;
        last_error = OTA_ERR_FLASH_FAILED;
        return -1;
    }
    
    current_status = OTA_STATUS_SUCCESS;
    download_progress = 100;
    
    ESP_LOGI(TAG, "OTA update successful - rebooting...");
    vTaskDelay(pdMS_TO_TICKS(2000));
    esp_restart();
    
    return 0;
}

ota_status_t ota_manager_get_status(void) {
    return current_status;
}

uint8_t ota_manager_get_progress(void) {
    return download_progress;
}

bool ota_manager_can_rollback(void) {
    const esp_partition_t *running = esp_ota_get_running_partition();
    const esp_partition_t *last_invalid = esp_ota_get_last_invalid_partition();
    
    return (last_invalid != NULL && last_invalid != running);
}

int ota_manager_rollback(void) {
    const esp_partition_t *running = esp_ota_get_running_partition();
    const esp_partition_t *last_invalid = esp_ota_get_last_invalid_partition();
    
    if (!last_invalid || last_invalid == running) {
        ESP_LOGW(TAG, "No valid partition to rollback to");
        return -1;
    }
    
    ESP_LOGI(TAG, "Rolling back to previous firmware...");
    
    esp_err_t err = esp_ota_set_boot_partition(last_invalid);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Rollback failed");
        return -1;
    }
    
    ESP_LOGI(TAG, "Rollback successful - rebooting...");
    vTaskDelay(pdMS_TO_TICKS(1000));
    esp_restart();
    
    return 0;
}

void ota_manager_mark_valid(void) {
    ESP_LOGI(TAG, "Marking current firmware as valid");
    esp_err_t err = esp_ota_mark_app_valid_cancel_rollback();
    
    if (err == ESP_OK) {
        ESP_LOGI(TAG, "Current firmware marked as valid");
    } else {
        ESP_LOGW(TAG, "Failed to mark firmware as valid");
    }
}

ota_error_t ota_manager_get_error(void) {
    return last_error;
}
