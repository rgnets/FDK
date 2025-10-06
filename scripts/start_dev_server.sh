#!/bin/bash

# Script to start Flutter development server with verbose logging
# This will help identify the exact crash point

echo "========================================"
echo "STARTING FLUTTER DEVELOPMENT SERVER"
echo "========================================"
echo ""
echo "Configuration:"
echo "  - Verbose logging enabled"
echo "  - Web server on port 8080"
echo "  - API monitoring enabled"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH"
    exit 1
fi

# Kill any existing Flutter processes
echo "Cleaning up existing Flutter processes..."
pkill -f flutter || true
sleep 2

# Clean build artifacts
echo "Cleaning build artifacts..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Generate code
echo "Generating code with build_runner..."
dart run build_runner build --delete-conflicting-outputs

# Start the web server with verbose logging
echo ""
echo "Starting Flutter web server..."
echo "Server will be available at: http://localhost:8080"
echo ""
echo "IMPORTANT: Watch for crash logs below"
echo "========================================"
echo ""

# Run with verbose logging to capture crash details
flutter run -d web-server \
    --web-port=8080 \
    --web-hostname=0.0.0.0 \
    --dart-define=VERBOSE_LOGGING=true \
    --verbose 2>&1 | tee flutter_server.log