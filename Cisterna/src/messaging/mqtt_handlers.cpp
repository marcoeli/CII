// MQTT Message Handlers Implementation

#include "mqtt_handlers.h"
#include "../domain/cistern_controller.h"
#include "../include/config.h"
#include "../include/resource_names.h"
#include "../include/topic_builder.h"
#include "../network/mqtt_manager.h"
#include "../network/network_manager.h" // [NEW] For NTP sync check
#include "../network/wifi_manager.h"
#include "../persistence/config_manager.h"
#include "../provisioning/provisioning.h"
#include "../services/pump_actuation.h"
#include "ArduinoJson.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>
#include <time.h> // [NEW] For time()


static const char *TAG = "MQTT_HDLR";

int mqtt_handlers_init(void) {
  ESP_LOGI(TAG, "MQTT handlers V2.4 initialized");
  return 0;
}

// Helper: Get timestamp (Epoch if synced, Uptime if not)
static uint64_t get_smart_timestamp(void) {
  if (network_manager_is_ntp_synced()) {
    time_t now;
    time(&now);
    return (uint64_t)now;
  }
  // Fallback: uptime in seconds
  return esp_timer_get_time() / 1000000;
}

void mqtt_handlers_on_provisioning_response(const char *payload) {
  // This is now handled by provisioning.c directly
  // But we keep this for any additional high-level logic if needed
  ESP_LOGI(TAG, "Provisioning response received in handlers");
}

void mqtt_handlers_on_pump_command(pump_id_t pump_id, const char *payload) {
  ESP_LOGI(TAG, "Pump %d command: %s", pump_id, payload);

  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, payload);

  if (error) {
    ESP_LOGE(TAG, "JSON parse error");
    return;
  }

  const char *action = doc["action"] | "";
  JsonObject params = doc["params"];

  if (strcmp(action, "START") == 0) {
    bool force = false;
    if (!params.isNull()) {
      force = params["force"] | false;
    } else {
      // Fallback for flat JSON (Backward Compatibility)
      force = doc["force"] | false;
    }
    pump_start(pump_id, "mqtt_command", force);
  } else if (strcmp(action, "STOP") == 0) {
    pump_stop(pump_id, "mqtt_command");
  } else if (strcmp(action, "SET_MODE") == 0) {
    const char *mode_str = "";

    if (!params.isNull()) {
      mode_str = params["mode"] | "";
    } else {
      // Fallback
      mode_str = doc["mode"] | "";
    }

    if (strcmp(mode_str, "AUTO") == 0) {
      pump_set_mode(pump_id, PUMP_MODE_AUTO);
    } else if (strcmp(mode_str, "MANUAL") == 0) {
      pump_set_mode(pump_id, PUMP_MODE_MANUAL);
    }
  }

  // Publish updated pump state
  pump_state_t state = pump_get_state(pump_id);
  mqtt_handlers_publish_pump_state(pump_id, &state);
  ESP_LOGI(TAG, "Published pump %d state after command", pump_id);
}

void mqtt_handlers_on_config_command(const char *payload) {
  ESP_LOGI(TAG, "Config command received");

  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, payload);

  if (error) {
    ESP_LOGE(TAG, "JSON parse error");
    return;
  }

  // Handle tank config updates
  if (doc["tank"].is<JsonObject>()) {
    tank_config_t tank_cfg;
    memset(&tank_cfg, 0, sizeof(tank_cfg));

    const char *shape = doc["tank"]["shape"];
    tank_cfg.shape = (strcmp(shape, "cylindrical") == 0)
                         ? TANK_SHAPE_CYLINDRICAL
                         : TANK_SHAPE_RECTANGULAR;

    tank_cfg.height_cm = doc["tank"]["height"];
    tank_cfg.width_cm = doc["tank"]["width"];
    tank_cfg.depth_cm = doc["tank"]["depth"];
    tank_cfg.diameter_top_cm = doc["tank"]["diameter_top"];
    tank_cfg.diameter_bottom_cm = doc["tank"]["diameter_bottom"];
    tank_cfg.sensor_offset_cm = doc["tank"]["sensor_offset"];

    config_save_tank_config(&tank_cfg);
    level_measurement_set_config(&tank_cfg);

    ESP_LOGI(TAG, "Tank configuration updated");
  }

  // Handle report interval update (relaxed type check)
  if (doc["report_interval"].is<JsonVariant>()) {
    uint32_t interval = doc["report_interval"].as<uint32_t>();
    if (interval > 0) {
      config_save_report_interval(interval);
      ESP_LOGI(TAG, "Report interval updated to %lu seconds",
               (unsigned long)interval);
    }
  }

  // Handle resource names update
  if (doc["pump_names"].is<JsonArray>() || doc["level_names"].is<JsonArray>()) {
    resource_names_t names;
    // Load current names first to preserve existing ones if only partial update
    if (resource_names_load(&names) != 0) {
      resource_names_set_defaults(&names);
    }

    bool names_updated = false;

    if (doc["pump_names"].is<JsonArray>()) {
      JsonArray pumps = doc["pump_names"];
      names.pump_count = 0;
      for (const char *name : pumps) {
        if (names.pump_count < MAX_PUMPS) {
          strncpy(names.pump_names[names.pump_count], name,
                  RESOURCE_NAME_LEN - 1);
          names.pump_names[names.pump_count][RESOURCE_NAME_LEN - 1] = '\0';
          names.pump_count++;
        }
      }
      names_updated = true;
    }

    if (doc["level_names"].is<JsonArray>()) {
      JsonArray levels = doc["level_names"];
      names.level_count = 0;
      for (const char *name : levels) {
        if (names.level_count < MAX_LEVELS) {
          strncpy(names.level_names[names.level_count], name,
                  RESOURCE_NAME_LEN - 1);
          names.level_names[names.level_count][RESOURCE_NAME_LEN - 1] = '\0';
          names.level_count++;
        }
      }
      names_updated = true;
    }

    if (names_updated) {
      resource_names_save(&names);
      topic_builder_reload(); // Reload cache with new names
      ESP_LOGI(TAG, "Resource names updated and cache reloaded");

      // Re-subscribe to new resource topics might be needed if not using
      // wildcards For now, listing updated names
      for (int i = 0; i < names.pump_count; i++)
        ESP_LOGI(TAG, "Pump %d: %s", i, names.pump_names[i]);
    }
  }
}

void mqtt_handlers_on_message(const char *topic, const char *payload, int len) {
  ESP_LOGI(TAG, "Message on topic: %s", topic);

  // Check if it's a provisioning response (Legacy fallback or V2.4 context)
  if (strstr(topic, "resposta/") != NULL) {
    provisioning_parse_response(payload);
    return;
  }

  // Guard: only process operational topics if provisioned
  if (!config_is_provisioned())
    return;

  // Pump 1 command
  const char *p1_cmd = topic_get_pump_command(0);
  if (p1_cmd && strcmp(topic, p1_cmd) == 0) {
    mqtt_handlers_on_pump_command(PUMP_1, payload);
    return;
  }

  // Pump 2 command
  const char *p2_cmd = topic_get_pump_command(1);
  if (p2_cmd && strcmp(topic, p2_cmd) == 0) {
    mqtt_handlers_on_pump_command(PUMP_2, payload);
    return;
  }

  // Config command (Generic r/+/config logic or specific)
  // Check for config suffix (resource config)
  size_t topic_len = strlen(topic);
  if (topic_len > 7 && strcmp(topic + topic_len - 7, "/config") == 0) {
    mqtt_handlers_on_config_command(payload);
    return;
  }
}

void mqtt_handlers_publish_heartbeat(void) {
  if (!config_is_provisioned())
    return;

  const char *topic = topic_get_status();
  if (!topic)
    return;

  JsonDocument doc;
  doc["contract"] = "2.4";
  doc["state"] = "ONLINE";
  doc["role"] = "CISTERN_NODE";
  doc["fw"] = FIRMWARE_VERSION;
  doc["uptime"] = esp_timer_get_time() / 1000000;
  doc["rssi"] = wifi_manager_get_rssi();
  doc["ts"] = get_smart_timestamp();

  // Hardware Info
  JsonObject hw = doc["hw"].to<JsonObject>();
  hw["vendor"] = "ICODZ";
  hw["model"] = "CISTERN_NODE_V1";
  hw["rev"] = "1.0";

  // Capabilities (Resources)
  JsonArray capabilities = doc["capabilities"].to<JsonArray>();

  // Capability 1: Water Level
  JsonObject cap_level = capabilities.add<JsonObject>();
  cap_level["type"] = "WATER_LEVEL";
  JsonArray res_level = cap_level["resources"].to<JsonArray>();
  JsonObject r1 = res_level.add<JsonObject>();
  r1["id"] = "water.level.cistern";
  r1["label"] = "Cisterna"; // Default label
  r1["domain"] = "water";
  r1["kind"] = "level";

  // Capability 2: Water Actuator (Pumps)
  JsonObject cap_pump = capabilities.add<JsonObject>();
  cap_pump["type"] = "WATER_ACTUATOR";
  JsonArray res_pump = cap_pump["resources"].to<JsonArray>();

  JsonObject p1 = res_pump.add<JsonObject>();
  p1["id"] = "water.pump.cistern_pump_1";
  p1["label"] = "Bomba 1";
  p1["domain"] = "water";
  p1["kind"] = "pump";

  JsonObject p2 = res_pump.add<JsonObject>();
  p2["id"] = "water.pump.cistern_pump_2";
  p2["label"] = "Bomba 2";
  p1["domain"] = "water";
  p1["kind"] = "pump";

  JsonArray controls = cap_pump["controls"].to<JsonArray>();
  controls.add("START");
  controls.add("STOP");
  controls.add("SET_MODE");

  // Allocate payload buffer on heap to avoid stack overflow in MQTT task
  char *payload = (char *)malloc(2048); // 2KB to be safe with full V2.4 payload
  if (!payload) {
    ESP_LOGE(TAG, "Failed to allocate memory for heartbeat payload");
    return;
  }

  size_t len = serializeJson(doc, payload, 2048);
  if (len == 0) {
    ESP_LOGE(TAG, "Failed to serialize heartbeat");
    free(payload);
    return;
  }

  mqtt_manager_publish(topic, payload, 1, true); // QoS=1, Retain=true
  ESP_LOGI(TAG, "Heartbeat V2.4 sent to: %s", topic);

  free(payload);
}

void mqtt_handlers_publish_level(const level_measurement_t *level) {
  if (!level || !level->valid)
    return;
  if (!config_is_provisioned())
    return;

  // Use dynamic topic from resource names
  const char *topic = topic_get_level(0);
  if (!topic)
    return;

  JsonDocument doc;
  doc["liters"] = level->liters;
  doc["percent"] = level->percent;
  doc["distance_cm"] = level->distance_cm;

  const char *alert_str = "";
  switch (level->alert) {
  case LEVEL_ALERT_OVERFLOW:
    alert_str = "OVERFLOW";
    break;
  case LEVEL_ALERT_HIGH:
    alert_str = "HIGH";
    break;
  case LEVEL_ALERT_NORMAL:
    alert_str = "NORMAL";
    break;
  case LEVEL_ALERT_LOW:
    alert_str = "LOW";
    break;
  case LEVEL_ALERT_CRITICAL_LOW:
    alert_str = "CRITICAL_LOW";
    break;
  }
  doc["alert"] = alert_str;
  doc["ts"] = get_smart_timestamp();

  char payload[256]; // Small enough for stack
  serializeJson(doc, payload, sizeof(payload));

  mqtt_manager_publish(topic, payload, 1, true);
}

void mqtt_handlers_publish_pump_state(pump_id_t pump_id,
                                      const pump_state_t *state) {
  if (!state)
    return;
  if (!config_is_provisioned())
    return;

  // Use dynamic topic from resource names
  const char *topic = topic_get_pump_state(pump_id);
  if (!topic)
    return;

  JsonDocument doc;
  doc["running"] = state->running;
  doc["mode"] = (state->mode == PUMP_MODE_AUTO) ? "AUTO" : "MANUAL";
  doc["reason"] = state->reason;
  doc["ts"] = get_smart_timestamp();

  char payload[256];
  serializeJson(doc, payload, sizeof(payload));

  mqtt_manager_publish(topic, payload, 1, true);
}

void mqtt_handlers_subscribe_operational(const char *username) {
  // In V2.4, we ignore the 'username' argument for subscription path
  // construction. We use the ACL list stored in NVS.

  char acl_topics[512] = {0};
  if (config_get_acl_topics(acl_topics, sizeof(acl_topics)) == 0) {
    ESP_LOGI(TAG, "Subscribing to topics from ACL: %s", acl_topics);

    // Split by semicolon and subscribe
    char *topic = strtok(acl_topics, ";");
    while (topic != NULL) {
      if (strlen(topic) > 0) {
        mqtt_manager_subscribe(topic, 1);
        ESP_LOGI(TAG, "ACL Subscribed: %s", topic);
      }
      topic = strtok(NULL, ";");
    }
  } else {
    ESP_LOGW(TAG, "No ACL topics found in NVS. Device might be restricted.");

    // Fallback: subscribe to its own command topics just in case
    for (int i = 0; i < 2; i++) {
      const char *cmd = topic_get_pump_command(i);
      if (cmd) {
        mqtt_manager_subscribe(cmd, 1);
        ESP_LOGI(TAG, "Fallback Subscribed: %s", cmd);
      }
    }
  }

  ESP_LOGI(TAG, "Operational subscriptions completed (V2.4)");
}
