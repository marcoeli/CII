// MQTT Manager Implementation (ESP-MQTT wrapper)

#include "mqtt_manager.h"
#include "../include/config.h"
#include "../provisioning/provisioning.h"
#include "../persistence/config_manager.h"
#include "mqtt_client.h"
#include "esp_log.h"
#include <string.h>
#include <time.h>

static const char *TAG = "MQTT_MGR";

static esp_mqtt_client_handle_t mqtt_client = NULL;
static mqtt_status_t current_status = MQTT_STATUS_DISCONNECTED;
static int current_mode = 0; // 0=None, 1=Setup, 2=Operational
static mqtt_message_cb_t message_callback = NULL;
static mqtt_connected_cb_t connected_callback = NULL;
static mqtt_disconnected_cb_t disconnected_callback = NULL;
static bool is_started = false;

bool mqtt_manager_is_started(void) {
    return is_started;
}

int mqtt_manager_get_mode(void) {
    return current_mode;
}

// MQTT event handler
// Buffer for accumulating fragmented provisioning response
static char provisioning_buffer[4096];
static int provisioning_buffer_len = 0;

// MQTT event handler
static void mqtt_event_handler(void *handler_args, esp_event_base_t base,
                                int32_t event_id, void *event_data) {
    esp_mqtt_event_handle_t event = (esp_mqtt_event_handle_t)event_data;
    
    switch ((esp_mqtt_event_id_t)event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "MQTT connected");
            current_status = MQTT_STATUS_CONNECTED;
            
            // If not provisioned, do provisioning flow
            if (!config_is_provisioned()) {
                ESP_LOGI(TAG, "Starting provisioning flow V2.4...");
                
                char tenant[64] = {0}, home[64] = {0};
                config_get_context(tenant, sizeof(tenant), home, sizeof(home));
                
                // Step 1: Subscribe to response topic FIRST
                const char* correlation_id = provisioning_get_correlation_id();
                char response_topic[256];
                snprintf(response_topic, sizeof(response_topic), "setup/%s/%s/resposta/%s", 
                         tenant, home, correlation_id);
                int sub_result = esp_mqtt_client_subscribe(event->client, response_topic, 1);
                ESP_LOGI(TAG, "Subscribed to: %s (msg_id=%d)", response_topic, sub_result);
                
                // Step 2: Build and publish registration payload
                char *payload = provisioning_build_registration_payload();
                if (payload && strlen(payload) > 0) {
                    char reg_topic[256];
                    snprintf(reg_topic, sizeof(reg_topic), "setup/%s/%s/registro", tenant, home);
                    
                    ESP_LOGI(TAG, "Sending Registration Payload: %s", payload);
                    int msg_id = esp_mqtt_client_publish(event->client, reg_topic, payload, strlen(payload), 1, 0);
                    ESP_LOGI(TAG, "Registration published to %s (msg_id=%d)", reg_topic, msg_id);
                } else {
                    ESP_LOGE(TAG, "Failed to build registration payload");
                }
            }
            
            if (connected_callback) {
                connected_callback();
            }
            break;
            
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGW(TAG, "MQTT disconnected");
            current_status = MQTT_STATUS_DISCONNECTED;
            if (disconnected_callback) {
                disconnected_callback();
            }
            break;
            
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "MQTT message received: %.*s", event->topic_len, event->topic);
            
            // Handle Provisioning Response (Accumulate Fragmented Data)
            if (!config_is_provisioned()) {
                // Check if it's the start of a message
                if (event->current_data_offset == 0) {
                    provisioning_buffer_len = 0;
                    memset(provisioning_buffer, 0, sizeof(provisioning_buffer));
                }
                
                // Accumulate
                if (provisioning_buffer_len + event->data_len < sizeof(provisioning_buffer)) {
                    memcpy(provisioning_buffer + provisioning_buffer_len, event->data, event->data_len);
                    provisioning_buffer_len += event->data_len;
                } else {
                    ESP_LOGE(TAG, "Provisioning buffer overflow!");
                }
                
                // Check if message is complete
                if (provisioning_buffer_len >= event->total_data_len) {
                    ESP_LOGI(TAG, "Provisioning response complete (%d bytes), parsing...", provisioning_buffer_len);
                    provisioning_parse_response(provisioning_buffer);
                    
                    // Disconnect to force reconnection with new credentials
                    esp_mqtt_client_disconnect(event->client);
                }
            }
            
            if (message_callback) {
                // Null-terminate topic and data
                char topic[256] = {0};
                char data[2048] = {0};  // Increased for ACL response
                
                int topic_len = (event->topic_len < 255) ? event->topic_len : 255;
                int data_len = (event->data_len < 2047) ? event->data_len : 2047;
                
                strncpy(topic, event->topic, topic_len);
                strncpy(data, event->data, data_len);
                
                message_callback(topic, data, data_len);
            }
            break;
            
        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "MQTT error");
            current_status = MQTT_STATUS_ERROR;
            break;
            
        default:
            break;
    }
}

int mqtt_manager_init(void) {
    ESP_LOGI(TAG, "MQTT manager initialized");
    return 0;
}

int mqtt_manager_connect_setup(void) {
    ESP_LOGI(TAG, "Connecting in SETUP mode: %s@%s:%d",
            SETUP_MQTT_USERNAME, SETUP_MQTT_BROKER, SETUP_MQTT_PORT);
    
    // Build proper MQTT URI with port
    #ifdef PROVISIONING_MODE
    char uri[128];
    snprintf(uri, sizeof(uri), "mqtt://%s:%d", SETUP_MQTT_BROKER, SETUP_MQTT_PORT);
    #else
    char uri[128];
    snprintf(uri, sizeof(uri), "mqtts://%s:%d", SETUP_MQTT_BROKER, SETUP_MQTT_PORT);
    #endif
    
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = uri,
        .credentials.username = SETUP_MQTT_USERNAME,
        .credentials.authentication.password = SETUP_MQTT_PASSWORD,
        .session.keepalive = 60,
        .network.timeout_ms = 5000,
        .broker.verification.skip_cert_common_name_check = true, // For testing
        .task.stack_size = 8192, // Increase stack size for huge Provisioning Response
    };
    
    if (mqtt_client) {
        esp_mqtt_client_destroy(mqtt_client);
    }
    
    mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    if (!mqtt_client) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return -1;
    }
    
    esp_mqtt_client_register_event(mqtt_client, ESP_EVENT_ANY_ID, 
                                   mqtt_event_handler, NULL);
    
    current_status = MQTT_STATUS_CONNECTING;
    esp_mqtt_client_start(mqtt_client);
    is_started = true;
    current_mode = 1; // Setup Mode
    
    return 0;
}

#include "../include/certificates.h"

int mqtt_manager_connect_operational(const char* username, const char* password,
                                     const char* broker, uint16_t port) {
    if (is_started) {
        ESP_LOGW(TAG, "MQTT already started, ignoring connect request");
        return 0;
    }

    time_t now;
    time(&now);
    struct tm timeinfo;
    localtime_r(&now, &timeinfo);
    ESP_LOGI(TAG, "System Time at Connect: %s", asctime(&timeinfo));

    ESP_LOGI(TAG, "Connecting in OPERATIONAL mode: %s@%s:%d",
            username, broker, port);
    
    // Default to 8883 if not specified or standard HTTP port
    if (port == 0 || port == 1883) port = 8883;
    
    char uri[128];
    snprintf(uri, sizeof(uri), "mqtts://%s:%d", broker, port);
    ESP_LOGI(TAG, "Using MQTTS (TLS) on port %d", port);
    
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = uri,
        .broker.verification.certificate = mqtt_self_signed_pem, // Use self‑signed server certificate
        .broker.verification.skip_cert_common_name_check = true, // Server uses self‑signed cert, skip CN check
        
        .credentials.client_id = username,  // Use username as client ID
        .credentials.username = username,
        .credentials.authentication.password = password,
        .session.keepalive = 60,
        .network.timeout_ms = 10000,
        .task.stack_size = 8192, // Increase stack size for V2.4 payloads
    };
    
    if (mqtt_client) {
        esp_mqtt_client_destroy(mqtt_client);
    }
    
    mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    if (!mqtt_client) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return -1;
    }
    
    esp_mqtt_client_register_event(mqtt_client, ESP_EVENT_ANY_ID, 
                                   mqtt_event_handler, NULL);
    
    current_status = MQTT_STATUS_CONNECTING;
    esp_mqtt_client_start(mqtt_client);
    is_started = true;
    current_mode = 2; // Operational Mode
    
    return 0;
}

void mqtt_manager_disconnect(void) {
    if (mqtt_client) {
        esp_mqtt_client_stop(mqtt_client);
        esp_mqtt_client_destroy(mqtt_client);
        mqtt_client = NULL;
    }
    current_status = MQTT_STATUS_DISCONNECTED;
    is_started = false;
    current_mode = 0; // Reset mode
}

int mqtt_manager_publish(const char* topic, const char* payload, int qos, bool retain) {
    if (!mqtt_client || current_status != MQTT_STATUS_CONNECTED) {
        ESP_LOGW(TAG, "Cannot publish - not connected");
        return -1;
    }
    
    int msg_id = esp_mqtt_client_publish(mqtt_client, topic, payload, 
                                         strlen(payload), qos, retain ? 1 : 0);
    
    if (msg_id >= 0) {
        ESP_LOGI(TAG, "Published to %s (msg_id=%d)", topic, msg_id);
        return 0;
    }
    
    ESP_LOGE(TAG, "Failed to publish to %s", topic);
    return -1;
}

int mqtt_manager_subscribe(const char* topic, int qos) {
    if (!mqtt_client || current_status != MQTT_STATUS_CONNECTED) {
        ESP_LOGW(TAG, "Cannot subscribe - not connected");
        return -1;
    }
    
    int msg_id = esp_mqtt_client_subscribe(mqtt_client, topic, qos);
    
    if (msg_id >= 0) {
        ESP_LOGI(TAG, "Subscribed to %s (msg_id=%d)", topic, msg_id);
        return 0;
    }
    
    ESP_LOGE(TAG, "Failed to subscribe to %s", topic);
    return -1;
}

int mqtt_manager_unsubscribe(const char* topic) {
    if (!mqtt_client) {
        return -1;
    }
    
    esp_mqtt_client_unsubscribe(mqtt_client, topic);
    return 0;
}

mqtt_status_t mqtt_manager_get_status(void) {
    return current_status;
}

void mqtt_manager_set_message_callback(mqtt_message_cb_t cb) {
    message_callback = cb;
}

void mqtt_manager_set_connection_callbacks(mqtt_connected_cb_t connected_cb,
                                           mqtt_disconnected_cb_t disconnected_cb) {
    connected_callback = connected_cb;
    disconnected_callback = disconnected_cb;
}
