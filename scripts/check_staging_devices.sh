#!/bin/bash

echo "🔍 CHECKING STAGING APP DEVICE LOADING"
echo "======================================"

# First, verify the app is running
echo -e "\n1. Checking app status..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:5004 | {
    read status
    if [ "$status" == "200" ]; then
        echo "✅ App is running on port 5004"
    else
        echo "❌ App not responding (status: $status)"
        exit 1
    fi
}

# Check if the app is actually in staging mode by looking at the JS
echo -e "\n2. Checking environment in compiled JS..."
curl -s http://localhost:5004/main.dart.js | grep -o "ENVIRONMENT.*staging" | head -5

# Check for our logging statements
echo -e "\n3. Looking for our logging statements in JS..."
curl -s http://localhost:5004/main.dart.js | grep -o "DEVICE_REPOSITORY.*STAGING" | head -5
curl -s http://localhost:5004/main.dart.js | grep -o "DEVICES_PROVIDER.*build" | head -5

# Look for API calls
echo -e "\n4. Checking for API configuration..."
curl -s http://localhost:5004/main.dart.js | grep -o "vgw1-01.dal-interurban" | head -2
curl -s http://localhost:5004/main.dart.js | grep -o "fetoolreadonly" | head -2

echo -e "\n======================================"
echo "If staging is set correctly, you should see:"
echo "1. ENVIRONMENT references with staging"
echo "2. DEVICE_REPOSITORY logging statements"
echo "3. API URL and credentials"