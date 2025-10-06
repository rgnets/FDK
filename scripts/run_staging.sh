#!/bin/bash

# Run the RG Nets FDK in staging mode
# Staging mode connects to the interurban test API with read-only credentials

echo "Starting RG Nets FDK in STAGING mode..."
echo "================================================"
echo "Environment: Staging"
echo "Data Source: Live API (interurban test environment)"
echo "API Server: vgw1-01.dal-interurban.mdu.attwifi.com"
echo "Authentication: Auto (using test credentials)"
echo "Debug Banner: Hidden"
echo "================================================"

# Kill any existing servers on the port
lsof -ti:8091 | xargs kill -9 2>/dev/null || true

# IMPORTANT: Use --web-hostname=0.0.0.0 to allow external connections
# Without this, the server only listens on localhost and won't be accessible
echo "Starting staging server on port 8091 (all interfaces)..."

# Pass required environment variables for staging authentication
# These are needed for the staging environment to connect to the API
flutter run -d web-server \
  --web-hostname=0.0.0.0 \
  --web-port=8091 \
  --dart-define=STAGING_API_KEY=xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r \
  --dart-define=TEST_API_LOGIN=fetoolreadonly \
  --dart-define=TEST_API_FQDN=vgw1-01.dal-interurban.mdu.attwifi.com \
  -t lib/main_staging.dart &

echo ""
echo "🔍 Inspecting staging API dataset..."
echo ""

# Run the dataset inspection script to show actual API data
python3 scripts/inspect_staging_dataset.py

# Check if inspection was successful
if [ $? -ne 0 ]; then
    echo "❌ Dataset inspection failed. Check API connectivity."
    echo "Continuing with app launch anyway..."
fi

echo ""
echo "⏳ Server is starting... (this may take 20-30 seconds)"
echo ""
echo "Once started, the staging server will be accessible at:"
echo "- http://localhost:8091"
echo "- http://127.0.0.1:8091"
echo "- http://[your-ip]:8091 (from other devices)"
echo ""
echo "Check browser console for API debug logs"
echo "Press Ctrl+C to stop the server"

# Wait for interrupt
wait