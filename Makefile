.PHONY: help install-all install-dashboard install-mobile install-vision run-dashboard run-vision run-mobile setup-arduino build-cam flash-cam build-gate flash-gate

help:
	@echo "SIGAP Unified Build System"
	@echo "=========================="
	@echo "Available commands:"
	@echo "  make install-all      - Install dependencies for Dashboard, Mobile, and Vision API"
	@echo "  make install-dashboard- Install Next.js dependencies for Dashboard"
	@echo "  make install-mobile   - Get Flutter dependencies for Mobile app"
	@echo "  make install-vision   - Create venv and install Python deps for Vision API"
	@echo "  make run-dashboard    - Run Dashboard in development mode"
	@echo "  make run-vision       - Run Vision API service"
	@echo "  make run-mobile       - Run Mobile app on emulator/device"
	@echo ""
	@echo "Hardware Commands (requires arduino-cli):"
	@echo "  make setup-arduino    - Install ESP32 core and required libraries"
	@echo "  make build-cam        - Compile ESP32-CAM firmware"
	@echo "  make flash-cam PORT=/dev/ttyUSB0 - Compile and flash ESP32-CAM firmware"
	@echo "  make build-gate       - Compile ESP32 Gate Controller firmware"
	@echo "  make flash-gate PORT=/dev/ttyUSB0 - Compile and flash Gate Controller firmware"

install-all: install-dashboard install-mobile install-vision

install-dashboard:
	@echo "Installing Dashboard dependencies..."
	cd dashboard && npm install

install-mobile:
	@echo "Installing Mobile dependencies..."
	cd mobile && flutter pub get

install-vision:
	@echo "Installing Vision API dependencies..."
	cd vision-api && python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

run-dashboard:
	@echo "Starting Dashboard..."
	cd dashboard && npm run dev

run-vision:
	@echo "Starting Vision API..."
	cd vision-api && . .venv/bin/activate && python main.py

run-mobile:
	@echo "Starting Mobile App..."
	cd mobile && flutter run

# --- ARDUINO CLI CONFIGURATION ---
CAM_FQBN = esp32:esp32:esp32cam
GATE_FQBN = esp32:esp32:nodemcu-32s

setup-arduino:
	@echo "Configuring arduino-cli for ESP32..."
	arduino-cli config init --overwrite || true
	arduino-cli config add board_manager.additional_urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
	arduino-cli core update-index
	arduino-cli core install esp32:esp32
	arduino-cli lib install PubSubClient ESP32Servo

build-cam:
	@echo "Compiling Cam Node..."
	cd cam-node && arduino-cli compile --fqbn $$(CAM_FQBN) sigap-cam-node.ino

flash-cam:
	@ifndef PORT
	$$(error PORT is not set. Usage: make flash-cam PORT=/dev/ttyUSB0)
	@endif
	@echo "Flashing Cam Node to $$(PORT)..."
	cd cam-node && arduino-cli compile --fqbn $$(CAM_FQBN) sigap-cam-node.ino && arduino-cli upload -p $$(PORT) --fqbn $$(CAM_FQBN) sigap-cam-node.ino

build-gate:
	@echo "Compiling Gate Controller..."
	cd gate-controller && arduino-cli compile --fqbn $$(GATE_FQBN) sigap-gate-controller.ino

flash-gate:
	@ifndef PORT
	$$(error PORT is not set. Usage: make flash-gate PORT=/dev/ttyUSB0)
	@endif
	@echo "Flashing Gate Controller to $$(PORT)..."
	cd gate-controller && arduino-cli compile --fqbn $$(GATE_FQBN) sigap-gate-controller.ino && arduino-cli upload -p $$(PORT) --fqbn $$(GATE_FQBN) sigap-gate-controller.ino
