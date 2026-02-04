# Hardware Map - ESP32 DevKit V1 (Cisterna Firmware)

**Chip**: ESP32-D0WD-V3 (revision v3.1)  
**Features**: WiFi, BT, Dual Core, 240MHz, VRef calibration in efuse  
**Flash**: 4MB  
**MAC**: 94:51:dc:4c:78:48  
**Crystal**: 40MHz

---

## Pinout Reference

**Orientação**: Antena WiFi para CIMA / Porta USB para BAIXO

### Lado Esquerdo (Top to Bottom)
| Pin | GPIO | Function | Notes |
| :--- | :--- | :--- | :--- |
| EN | - | Reset/Enable | Boot button |
| VP | 36 | ADC1_0 | Input Only |
| VN | 39 | ADC1_3 | Input Only |
| D34 | 34 | ADC1_6 | Input Only |
| D35 | 35 | ADC1_7 | Input Only |
| D32 | 32 | Touch / ADC1_4 | - |
| D33 | 33 | Touch / ADC1_5 | - |
| D25 | 25 | DAC1 / ADC2_8 | **RELAY_PUMP_1** |
| D26 | 26 | DAC2 / ADC2_9 | **RELAY_PUMP_2** |
| D27 | 27 | ADC2_7 / Touch | - |
| D14 | 14 | ADC2_6 / Touch | Boot fail if HIGH |
| D12 | 12 | ADC2_5 / Touch | Boot fail if HIGH |
| D13 | 13 | ADC2_4 / Touch | - |
| GND | - | Ground | - |
| VIN | - | 5V Input | USB power |

### Lado Direito (Top to Bottom)
| Pin | GPIO | Function | Notes |
| :--- | :--- | :--- | :--- |
| D23 | 23 | VSPI MOSI | **ULTRASONIC_TRIG** |
| D22 | 22 | I2C SCL | **I2C_SCL (Display)** |
| TX0 | 1 | Serial TX | Avoid - used for debug |
| RX0 | 3 | Serial RX | Avoid - used for debug |
| D21 | 21 | I2C SDA | **I2C_SDA (Display)** |
| D19 | 19 | VSPI MISO | **ULTRASONIC_ECHO** |
| D18 | 18 | VSPI SCK | - |
| D5 | 5 | VSPI SS | - |
| TX2 | 17 | Serial 2 TX | - |
| RX2 | 16 | Serial 2 RX | - |
| D4 | 4 | ADC2_0 / Touch | - |
| D2 | 2 | LED / Boot | Onboard LED (blue) |
| D15 | 15 | ADC2_3 / Touch / Boot | Must be LOW on boot |
| GND | - | Ground | - |
| 3V3 | - | 3.3V Output | Low current only |

---

## Cisterna Firmware Pin Assignment

| Component | GPIO | Notes |
| :--- | :--- | :--- |
| **Ultrasonic Trig** | GPIO 23 | Trigger pulse |
| **Ultrasonic Echo** | GPIO 19 | Echo response (moved from 22 to avoid I2C conflict) |
| **I2C SDA (Display)** | GPIO 21 | OLED Display data |
| **I2C SCL (Display)** | GPIO 22 | OLED Display clock |
| **Relay Pump 1** | GPIO 25 | SSR-40 control |
| **Relay Pump 2** | GPIO 26 | SSR-40 control |
| **Button Up** | GPIO 32 | Navigation |
| **Button Down** | GPIO 33 | Navigation |
| **Button Select** | GPIO 34 | Confirm (Input Only) |
| **Button Back** | GPIO 35 | Return (Input Only) |

---

## Mapeamento de Recursos V2.4 (Imutável)

| Componente | GPIO | Resource ID | Kind |
| :--- | :--- | :--- | :--- |
| **Relay Pump 1** | 25 | `water.pump.cistern_pump_1` | `water.pump` |
| **Relay Pump 2** | 26 | `water.pump.cistern_pump_2` | `water.pump` |
| **Ultrasonic Sensor** | 23/19 | `water.level.cistern` | `water.level` |

---

## Important Notes

### Input Only Pins
GPIOs **34, 35, 36 (VP), 39 (VN)** cannot be used as outputs. They are read-only.

### ADC2 Limitation
When WiFi is active, **ADC2 pins (0, 2, 4, 12-15, 25-27)** cannot be used for analog readings. Use **ADC1 (32-39)** for sensors when WiFi is enabled.

### Boot Pins
- **GPIO 2**: Must be LOW or floating during boot
- **GPIO 12**: Boot fails if HIGH during boot
- **GPIO 15**: Must be LOW during boot

### Hardware Conflict Resolution
The original design had GPIO 22 shared between I2C SCL and Ultrasonic Echo, causing bus contention. This has been resolved by moving the Echo pin to GPIO 19.
