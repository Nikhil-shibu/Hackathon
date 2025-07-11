# Thrive Mind - Flutter App Makefile

# Install dependencies
install:
	flutter pub get

# Run the app on web server
run-web:
	flutter run -d web-server --web-port 8080

# Run the app on Chrome
run-chrome:
	flutter run -d chrome --web-port 8080

# Build for web
build-web:
	flutter build web

# Clean build artifacts
clean:
	flutter clean

# Run tests
test:
	flutter test

# Format code
format:
	flutter format .

# Analyze code
analyze:
	flutter analyze

# Get dependencies and run on web
start: install run-web

# Complete setup and run
setup: clean install run-web

# Help
help:
	@echo "Available commands:"
	@echo "  install     - Install Flutter dependencies"
	@echo "  run-web     - Run app on web server (localhost:8080)"
	@echo "  run-chrome  - Run app on Chrome browser"
	@echo "  build-web   - Build app for web deployment"
	@echo "  clean       - Clean build artifacts"
	@echo "  test        - Run tests"
	@echo "  format      - Format code"
	@echo "  analyze     - Analyze code"
	@echo "  start       - Install dependencies and run on web"
	@echo "  setup       - Clean, install, and run on web"
	@echo "  help        - Show this help message"

.PHONY: install run-web run-chrome build-web clean test format analyze start setup help
