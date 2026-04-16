.PHONY: help install-all install-dashboard install-mobile install-vision run-dashboard run-vision run-mobile

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
	@echo "Note: Hardware nodes (cam-node & gate-controller) should be flashed via Arduino IDE."

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
