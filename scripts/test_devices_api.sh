#!/bin/bash

# Script to test the devices API endpoints
# This simulates what the Flutter app does when loading devices

echo "========================================"
echo "DEVICES API TEST SCRIPT"
echo "========================================"
echo ""

# Configuration from CLAUDE.md
API_URL="https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY="xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Testing API endpoints..."
echo "Base URL: $API_URL"
echo ""

# Function to test an endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo -e "${YELLOW}Testing: $description${NC}"
    echo "Endpoint: $endpoint"
    
    # Make the request with field selection (as the app does)
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Accept: application/json" \
        "${API_URL}${endpoint}")
    
    # Extract HTTP status code
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Status: $http_code${NC}"
        
        # Parse and display device count
        if command -v jq &> /dev/null; then
            # Count devices based on response structure
            if echo "$body" | jq -e '.results' > /dev/null 2>&1; then
                count=$(echo "$body" | jq '.results | length')
                echo "  Device count: $count"
                
                # Show first device structure
                if [ "$count" -gt 0 ]; then
                    echo "  First device structure:"
                    echo "$body" | jq '.results[0] | keys' | head -20
                    
                    # Check for null values that could cause crashes
                    echo "  Checking for null fields in first device:"
                    ip=$(echo "$body" | jq -r '.results[0].ip_address // .results[0].ip // "null"')
                    mac=$(echo "$body" | jq -r '.results[0].mac_address // .results[0].mac // "null"')
                    name=$(echo "$body" | jq -r '.results[0].name // "null"')
                    
                    if [ "$ip" = "null" ]; then
                        echo -e "    ${RED}⚠ IP Address is null${NC}"
                    else
                        echo "    IP: $ip"
                    fi
                    
                    if [ "$mac" = "null" ]; then
                        echo -e "    ${RED}⚠ MAC Address is null${NC}"
                    else
                        echo "    MAC: $mac"
                    fi
                    
                    if [ "$name" = "null" ]; then
                        echo -e "    ${RED}⚠ Name is null${NC}"
                    else
                        echo "    Name: $name"
                    fi
                fi
            elif echo "$body" | jq -e '. | type == "array"' > /dev/null 2>&1; then
                count=$(echo "$body" | jq '. | length')
                echo "  Device count: $count (direct array)"
            else
                echo "  Response structure:"
                echo "$body" | jq 'keys' 2>/dev/null || echo "  Could not parse JSON"
            fi
        else
            echo "  Response length: ${#body} bytes"
        fi
    else
        echo -e "${RED}✗ Status: $http_code${NC}"
        echo "  Error: $body" | head -5
    fi
    echo ""
}

# Test each device endpoint as the app does
echo "1. Testing Access Points"
test_endpoint "/api/access_points.json?page_size=0" "Access Points (Full)"
test_endpoint "/api/access_points.json?page_size=0&only=id,name,type,status,ip_address,mac_address" "Access Points (With field selection)"

echo "2. Testing Media Converters (ONTs)"
test_endpoint "/api/media_converters.json?page_size=0" "Media Converters (Full)"
test_endpoint "/api/media_converters.json?page_size=0&only=id,name,type,status,ip,mac" "Media Converters (With field selection)"

echo "3. Testing Switch Devices"
test_endpoint "/api/switch_devices.json?page_size=0" "Switch Devices (Full)"
test_endpoint "/api/switch_devices.json?page_size=0&only=id,name,nickname,online,host,scratch" "Switch Devices (With field selection)"

echo "4. Testing WLAN Devices"
test_endpoint "/api/wlan_devices.json?page_size=0" "WLAN Devices (Full)"
test_endpoint "/api/wlan_devices.json?page_size=0&only=id,name,device,online,host,mac" "WLAN Devices (With field selection)"

echo "========================================"
echo "SUMMARY"
echo "========================================"
echo ""
echo "Check the results above for:"
echo "1. Any endpoints returning non-200 status"
echo "2. Devices with null IP or MAC addresses (crash cause)"
echo "3. Unexpected response structures"
echo "4. Empty device lists"
echo ""
echo "The app will crash if:"
echo "- Any device has null ipAddress or macAddress (force unwrap in _formatNetworkInfo)"
echo "- Response structure doesn't match expected format"
echo "- Provider initialization fails"