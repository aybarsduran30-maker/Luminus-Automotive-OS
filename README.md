# Luminus Automotive OS

A digital instrument cluster simulation developed with **C++17** and **Qt 6 (Quick / QML, Multimedia)**.

---

## Features

* **Dual-Layer Architecture:** C++ backend telemetry simulation connected to Qt Quick UI.
* **Live Video Background:** Looping MP4 backgrounds via QtMultimedia.
* **Gauge Sweep:** Startup sweep animation for speed and RPM needles.
* **Vehicle Telematics:** Tire pressure (TPMS), chassis load, and diagnostics modes.
* **Trip Computer:** Distance tracking, fuel usage calculation, and trip logging.
* **Cluster Modes:** Dual Ring, Minimal HUD, and Performance layouts.

---

## Tech Stack

* **Language:** C++17
* **Framework:** Qt 6.5+ (Quick, Multimedia)
* **Build System:** CMake 3.16+

---

## Project Structure

```text
├── assets/            # Background videos and vehicle renders
├── include/           # C++ headers (telemetry, CAN models)
├── src/               # Main entry and backend logic
├── ui/                # QML files and resources
├── CMakeLists.txt
└── README.md


Controls
Up Arrow: Accelerate

Down Arrow: Brake

Mouse: Menu and navigation control

Build & Run

mkdir build
cd build
cmake ..
cmake --build . --config Release
.\Release\LuminusOS.exe

