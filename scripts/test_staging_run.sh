#!/bin/bash

echo "🚀 Testing Staging Environment Run"
echo "=================================="

# Kill any existing Flutter processes
pkill -f flutter || true

# Run Flutter in staging mode with logging
echo "Starting Flutter web server in staging mode..."
timeout 15 flutter run -d web-server --web-port 8083 --dart-define=ENVIRONMENT=staging 2>&1 | tee staging_run.log &

# Wait for server to start
sleep 10

# Check if server is running
if curl -s http://localhost:8083 > /dev/null 2>&1; then
    echo "✅ Staging server is running on http://localhost:8083"
    echo ""
    echo "📝 Server logs preview:"
    grep -E "(Environment|API|staging|Staging)" staging_run.log | head -10
else
    echo "❌ Server failed to start"
fi

# Kill the server
pkill -f flutter || true

echo ""
echo "✅ Staging test complete"