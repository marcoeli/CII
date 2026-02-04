// Web Server - HTTP Server with REST API
// Serves web interface and provides REST endpoints

#ifndef WEB_SERVER_H
#define WEB_SERVER_H

#include <stdint.h>
#include <stdbool.h>

// Initialize web server
int web_server_init(void);

// Start web server
int web_server_start(void);

// Stop web server
void web_server_stop(void);

// Check if server is running
bool web_server_is_running(void);

#endif // WEB_SERVER_H
