#!/bin/bash

# Run the RG Nets FDK in development mode
# Development mode uses mock data and requires no authentication

echo "Starting RG Nets FDK in DEVELOPMENT mode..."
echo "================================================"
echo "Environment: Development"
echo "Data Source: Mock/Synthetic Data"
echo "Authentication: Not Required"
echo "Debug Banner: Visible"
echo "================================================"

# Kill any existing servers on the port
lsof -ti:8089 | xargs kill -9 2>/dev/null || true

# Build the development version
echo "Building development version..."
flutter build web -t lib/main_development.dart

# Start the server
echo "Starting development server on port 8089..."
cd build/web && python3 -m http.server 8089 &

echo ""
echo "✅ Development server started!"
echo "Access at: http://localhost:8089"
echo ""
echo "Features:"
echo "- Mock data for testing"
echo "- No authentication required"
echo "- Debug tools enabled"
echo ""
echo "Press Ctrl+C to stop the server"

# Wait for interrupt
wait