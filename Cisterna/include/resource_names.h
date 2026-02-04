#ifndef RESOURCE_NAMES_H
#define RESOURCE_NAMES_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_PUMPS 4
#define MAX_LEVELS 2
#define RESOURCE_NAME_LEN 32

typedef struct {
    char pump_names[MAX_PUMPS][RESOURCE_NAME_LEN];
    uint8_t pump_count;
    char level_names[MAX_LEVELS][RESOURCE_NAME_LEN];
    uint8_t level_count;
} resource_names_t;

/**
 * @brief Save resource names to NVS
 * @param names Pointer to resource names structure
 * @return 0 on success, -1 on error
 */
int resource_names_save(const resource_names_t* names);

/**
 * @brief Load resource names from NVS
 * @param names Pointer to structure to fill
 * @return 0 on success, -1 if not found or error
 */
int resource_names_load(resource_names_t* names);

/**
 * @brief Set default resource names based on hardware
 * @param names Pointer to structure to fill with defaults
 */
void resource_names_set_defaults(resource_names_t* names);

/**
 * @brief Check if resource names are configured
 * @return true if configured, false otherwise
 */
bool resource_names_is_configured(void);

/**
 * @brief Clear resource names from NVS
 */
void resource_names_clear(void);

#ifdef __cplusplus
}
#endif

#endif // RESOURCE_NAMES_H
