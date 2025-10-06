#!/bin/bash

# Test: Monitor API with curl while app is running

API_URL="https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY="xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

echo "========================================================"
echo "CURL API MONITOR (Run alongside staging app)"
echo "========================================================"
echo ""
echo "This script will monitor the API every 3 seconds"
echo "Run this in parallel with: ./scripts/run_staging.sh"
echo "Press Ctrl+C to stop"
echo ""
echo "--------------------------------------------------------"

iteration=0
zero_count=0

while true; do
    iteration=$((iteration + 1))
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo ""
    echo "[$timestamp] Check #$iteration:"
    
    # Test access_points endpoint
    response=$(curl -s -w "\n%{http_code}\n%{time_total}" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Accept: application/json" \
        "$API_URL/api/access_points.json?page_size=0" \
        2>/dev/null)
    
    # Extract status code and time
    http_code=$(echo "$response" | tail -n 2 | head -n 1)
    time_total=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -2)
    
    # Count items
    if [ "$http_code" = "200" ]; then
        # Try to count items (handles both array and object with results)
        if echo "$body" | grep -q '"results":\['; then
            # Object with results array
            item_count=$(echo "$body" | grep -o '"id":' | wc -l)
            format="Map with results[]"
        elif echo "$body" | head -c 1 | grep -q '\['; then
            # Direct array
            item_count=$(echo "$body" | grep -o '"id":' | wc -l)
            format="List"
        else
            item_count=0
            format="Unknown"
        fi
        
        if [ "$item_count" -eq 0 ]; then
            echo "  🚨 ZERO ITEMS! Format: $format, Time: ${time_total}s"
            echo "  Response first 200 chars: $(echo "$body" | head -c 200)"
            zero_count=$((zero_count + 1))
        else
            echo "  ✅ $item_count items, Format: $format, Time: ${time_total}s"
        fi
    else
        echo "  ❌ HTTP $http_code, Time: ${time_total}s"
        echo "  Response: $(echo "$body" | head -c 200)"
    fi
    
    # Summary every 10 iterations
    if [ $((iteration % 10)) -eq 0 ]; then
        echo ""
        echo "========================================"
        echo "SUMMARY after $iteration checks:"
        echo "  Zero responses: $zero_count/$iteration"
        if [ "$zero_count" -gt 0 ]; then
            echo "  🚨 INTERMITTENT ZEROS DETECTED!"
        fi
        echo "========================================"
    fi
    
    sleep 3
done