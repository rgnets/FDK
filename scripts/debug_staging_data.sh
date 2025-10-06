#!/bin/bash

# Debug script to test staging data loading
echo "🔍 Testing staging data loading..."
echo "================================"

# Kill any existing flutter web servers
echo "Killing any existing Flutter processes..."
pkill -f flutter || true
sleep 2

# Start the Flutter web server in background
echo "Starting Flutter web server in staging mode..."
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0 --dart-define=ENVIRONMENT=staging > flutter_output.log 2>&1 &
FLUTTER_PID=$!

# Wait for server to start
echo "Waiting for server to start..."
for i in {1..30}; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✅ Server is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Server failed to start"
        cat flutter_output.log
        exit 1
    fi
    sleep 2
done

# Test the app with curl and capture console output
echo ""
echo "Testing app with curl..."
echo "========================"

# Access the main page
echo "1. Accessing main page..."
curl -s http://localhost:8080 > /dev/null

# Wait a bit for initial load
sleep 3

# Try to trigger data loading by accessing different routes
echo "2. Triggering data loads..."
curl -s http://localhost:8080/#/home > /dev/null
sleep 2

# Check the Flutter output for logs
echo ""
echo "Flutter Console Output:"
echo "======================="
tail -n 100 flutter_output.log | grep -E "(DEVICES_PROVIDER|ROOMS_PROVIDER|API|ERROR|Exception|Success)"

# Also check browser console by using headless Chrome
echo ""
echo "Browser Console Test:"
echo "===================="
google-chrome --headless --disable-gpu --dump-dom --enable-logging --v=1 http://localhost:8080 2>&1 | grep -E "(DEVICES_PROVIDER|ROOMS_PROVIDER|API|Console|Error)" || true

# Clean up
echo ""
echo "Cleaning up..."
kill $FLUTTER_PID 2>/dev/null || true

echo ""
echo "Test complete. Check flutter_output.log for full output."