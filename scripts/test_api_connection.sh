#!/bin/bash

# Test RG Nets API connection using curl
# This script tests the API endpoints with the test credentials

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test credentials
FQDN="vgw1-01.dal-interurban.mdu.attwifi.com"
LOGIN="fetoolreadonly"
API_KEY="xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"
BASE_URL="https://${FQDN}"

echo "=========================================="
echo "RG Nets API Connection Test"
echo "Server: ${BASE_URL}"
echo "Login: ${LOGIN}"
echo "API Key: ${API_KEY:0:20}..."
echo "=========================================="

# Function to test an endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo ""
    echo "Testing: ${description}"
    echo "Endpoint: ${endpoint}"
    echo "------------------------------------------"
    
    # Make the request
    response=$(curl -s -w "\n%{http_code}" -k \
        -H "Accept: application/json" \
        -H "X-API-Login: ${LOGIN}" \
        -H "X-API-Key: ${API_KEY}" \
        "${BASE_URL}${endpoint}?api_key=${API_KEY}" 2>/dev/null)
    
    # Extract status code (last line)
    http_code=$(echo "$response" | tail -n1)
    # Extract body (all but last line)
    body=$(echo "$response" | sed '$d')
    
    case $http_code in
        200)
            echo -e "${GREEN}✅ SUCCESS${NC} - Status: ${http_code}"
            
            # Try to parse JSON and show summary
            if command -v jq &> /dev/null; then
                # Check if it's paginated
                if echo "$body" | jq -e '.count' &> /dev/null; then
                    count=$(echo "$body" | jq '.count')
                    page=$(echo "$body" | jq '.page // 1')
                    page_size=$(echo "$body" | jq '.page_size // 30')
                    echo "  Paginated response:"
                    echo "  - Total items: ${count}"
                    echo "  - Page: ${page}"
                    echo "  - Page size: ${page_size}"
                    
                    # Show first item if available
                    if [ "$count" -gt 0 ]; then
                        echo "  - First item sample:"
                        echo "$body" | jq '.results[0]' 2>/dev/null | head -n 6
                    fi
                    
                # Check if it's an array
                elif echo "$body" | jq -e 'type == "array"' &> /dev/null; then
                    count=$(echo "$body" | jq 'length')
                    echo "  Array response with ${count} items"
                    
                    if [ "$count" -gt 0 ]; then
                        echo "  - First item sample:"
                        echo "$body" | jq '.[0]' 2>/dev/null | head -n 6
                    fi
                    
                # It's an object
                else
                    echo "  Object response:"
                    echo "$body" | jq '.' 2>/dev/null | head -n 10
                fi
            else
                # No jq available, show raw response (truncated)
                echo "  Response preview:"
                echo "$body" | head -c 200
                echo "..."
            fi
            ;;
            
        404)
            echo -e "${RED}❌ NOT FOUND${NC} - Endpoint does not exist"
            ;;
            
        401)
            echo -e "${RED}❌ UNAUTHORIZED${NC} - Check API credentials"
            ;;
            
        000)
            echo -e "${RED}❌ CONNECTION ERROR${NC} - Cannot reach server"
            ;;
            
        *)
            echo -e "${YELLOW}⚠️  UNEXPECTED${NC} - Status: ${http_code}"
            echo "  Response: $(echo "$body" | head -c 200)"
            ;;
    esac
}

# Test various endpoints
test_endpoint "/api/whoami.json" "Authentication Check"
test_endpoint "/api/devices.json" "Generic Devices"
test_endpoint "/api/access_points.json" "Access Points"
test_endpoint "/api/switch_devices.json" "Switch Devices"
test_endpoint "/api/wlan_devices.json" "WLAN Devices"
test_endpoint "/api/pms_rooms.json" "PMS Rooms"
test_endpoint "/api/media_converters.json" "Media Converters (ONTs)"

echo ""
echo "=========================================="
echo "Test completed!"
echo "=========================================="