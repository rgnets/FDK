#!/bin/bash

# Run the RG Nets FDK in production mode
# Production mode requires real customer credentials via QR code scan

echo "Starting RG Nets FDK in PRODUCTION mode..."
echo "================================================"
echo "Environment: Production"
echo "Data Source: Customer API"
echo "Authentication: Required (scan QR code)"
echo "Debug Banner: Hidden"
echo "================================================"

# Kill any existing servers on the port
lsof -ti:8080 | xargs kill -9 2>/dev/null || true

# Build the production version
echo "Building production version..."
flutter build web -t lib/main.dart

# IMPORTANT: Use --web-hostname=0.0.0.0 for production deployments
echo "Starting production server on port 8080 (all interfaces)..."
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080 -t lib/main.dart &

echo ""
echo "⏳ Server is starting... (this may take 20-30 seconds)"
echo ""
echo "Once started, the production server will be accessible at:"
echo "- http://localhost:8080"
echo "- http://127.0.0.1:8080"
echo "- http://[your-ip]:8080 (from other devices)"
echo ""
echo "⚠️  IMPORTANT: User must scan customer QR code to authenticate"
echo ""
echo "Press Ctrl+C to stop the server"

# Wait for interrupt
wait