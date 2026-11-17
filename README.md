# K9 Smart Feeder 🐕
**An IoT-enabled, Automated Pet Feeder for Precise Volumetric Dispensing**

The K9 Smart Feeder is a highly reliable, responsive, Wi-Fi-connected pet feeding system designed to help pet owners schedule, monitor, and manage their dog's meals from anywhere. 

This repository contains the microcontroller source code (ESP32/C++) for the hardware unit, featuring volumetric dispensing, silent motor operation, and real-time synchronization with Firebase.

---

## 🌟 Key Features

Based on the core requirements of the hardware platform, the current application supports:

- **Silent Volumetric Dispensing:** Utilizes a NEMA 17 stepper motor with a DRV8825 driver set to 1/32 microstepping for ultra-quiet, precise operation (15 rotations = 1 portion).
- **Cloud-Synced Scheduling:** An automated itinerary that fetches a 4-meal daily schedule directly from the Firebase Realtime Database.
- **Smart Motor Sleep:** Automatically toggles the motor's EN (Enable) pin to cut power between feeds, preventing heat buildup and humming.
- **Live Hopper Monitoring:** Uses an HC-SR04 ultrasonic sensor to measure kibble levels and alert the app when running low.
- **Live Bowl Weight:** Uses a 10kg load cell with an HX711 amplifier to report the exact weight of food in the bowl to the dashboard, separate from the dispensing logic to prevent sensor drift issues.
- **NTP Time Synchronization:** Pulls real-world time via Wi-Fi for accurate, independent scheduling.
- **Remote "Feed Now" Override:** Trigger a manual feed instantly from an external app connected to the Firebase RTDB.

## 🛠️ Technology Stack

- **Microcontroller:** ESP32 Development Board
- **Motor Control:** NEMA 17 Stepper & DRV8825 Driver
- **Sensors:** 10kg Load Cell (HX711) & HC-SR04 Ultrasonic
- **Framework:** Arduino IDE (C++)
- **Cloud Integration:** Firebase Realtime Database (RTDB)
- **Libraries:** Firebase ESP32 Client (Mobizt), HX711 Arduino Library

## 🚀 Getting Started

Follow these instructions to set up the microcontroller code locally for development and flashing to your ESP32.

### Prerequisites
- Arduino IDE (v2.0 or higher recommended)
- ESP32 Board Manager installed in Arduino IDE
- 12V DC Power Supply (for the stepper motor)

### Installation

1. **Clone the repository:**
   
```bash
   git clone https://github.com/your-username/k9-smart-feeder.git
   cd k9-smart-feeder
```
   
2. **Install required libraries:**
   Open Arduino IDE -> Sketch -> Include Library -> Manage Libraries. Search for and install:
   - `Firebase ESP32 Client` by Mobizt
   - `HX711 Arduino Library` by Bogdan Necula
   
3. **Configure credentials:**
   Open the `.ino` file and update the following variables with your details:
   - `ssid` and `password` (Wi-Fi)
   - `DATABASE_URL` (Firebase URL)
   
4. **Upload to ESP32:**
   Connect your ESP32 via USB, select your COM port and board (e.g., "DOIT ESP32 DEVKIT V1"), and click **Upload**.

## 🗺️ Project Roadmap
This project is being delivered in phases:

- **Phase 1 (MVP) - Current:** Core hardware logic, silent microstepping, volumetric dispensing, basic sensor telemetry, and Firebase RTDB integration.
- **Phase 2 (Mobile App):** Companion mobile application (iOS/Android) for user-friendly schedule management, push notifications, and live dashboard monitoring.
- **Phase 3 (Hardware Premium):** Addition of a battery backup system, an ESP32-CAM for live video feed during meals, and anti-jamming motor reverse logic.

## ⚡ Hardware & Wiring Guidelines
When contributing to or assembling the hardware, please strictly adhere to these safety and wiring rules:

- **12V Isolation:** Only the `VMOT` pin on the DRV8825 should ever receive 12V. Keep 12V far away from the ESP32.
- **Capacitor Protection:** A 100µF capacitor MUST be placed across the 12V (+) and (-) lines directly next to the DRV8825 to prevent power spikes.
- **Microstepping Setup:** Tie `M0`, `M1`, and `M2` on the driver to the ESP32 `3.3V` pin (not 5V) to enable 1/32 microstepping safely.
- **Logic Pins:** Avoid using ESP32 strapping pins (0, 2, 5, 12, 15) for critical outputs to ensure the board boots successfully.
