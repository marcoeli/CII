# System Principles (CII)

## 1. Local-First and Autonomous
The system is built on the principle that the home must function even without an internet connection.
- Critical logic (e.g., pump dry-run protection, scheduled tasks) must reside within the device (ESP32).
- The App is a monitor and a remote control, not a brain.

## 2. Broker Remote, Logic Local
We use a cloud-based MQTT broker for remote access, but the loss of connection to the broker must never interrupt local automation.

## 3. Asynchronous Truth
- **Commands are non-blocking**: When you send a command, the system does not wait for a "success" response.
- **State-based Feedback**: The UI only updates when the device publishes its new state back to the broker. This ensures the user sees the real hardware state, not an "intended" state.

## 4. Security (Zero Trust)
- **Dynamic Provisioning**: Devices are not shipped with MQTT credentials. They request them upon first boot using a "Claim Code".
- **Strict ACLs**: Every device is limited to its own namespace. A sensor cannot send commands to an actuator unless explicitly permitted by the orchestrator.

## 5. Domain Separation
- `water`: Hydraulic resources (Cisterns, Pumps).
- `env`: Environmental monitoring (Climate, Air quality).
- `security`: Presence and logical safety.
- `event`: Instant triggers (Doorbells, Alerts).
