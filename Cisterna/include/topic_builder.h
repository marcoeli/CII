#ifndef TOPIC_BUILDER_H
#define TOPIC_BUILDER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Get pump command topic for given pump index
 * @param pump_index Index of pump (0-based)
 * @return Topic string or NULL if invalid index
 */
const char* topic_get_pump_command(uint8_t pump_index);

/**
 * @brief Get pump state topic for given pump index
 * @param pump_index Index of pump (0-based)
 * @return Topic string or NULL if invalid index
 */
const char* topic_get_pump_state(uint8_t pump_index);

/**
 * @brief Get level topic for given level sensor index
 * @param level_index Index of level sensor (0-based)
 * @return Topic string or NULL if invalid index
 */
const char* topic_get_level(uint8_t level_index);

/**
 * @brief Get device status topic
 * @return Topic string
 */
const char* topic_get_status(void);

/**
 * @brief Force reload of resource names from NVS
 * Call this after updating resource names
 */
void topic_builder_reload(void);

#ifdef __cplusplus
}
#endif

#endif // TOPIC_BUILDER_H
