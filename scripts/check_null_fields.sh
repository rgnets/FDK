#!/bin/bash

# Script to check for null IP/MAC fields in API responses
# These null values would cause the app to crash

echo "========================================"
echo "NULL FIELD CHECK FOR DEVICES"
echo "========================================"
echo ""

API_URL="https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY="xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_endpoint() {
    local endpoint=$1
    local device_type=$2
    local ip_field=$3
    local mac_field=$4
    
    echo -e "${YELLOW}Checking $device_type...${NC}"
    
    # Fetch data
    response=$(curl -s \
        -H "Authorization: Bearer $API_KEY" \
        -H "Accept: application/json" \
        "${API_URL}${endpoint}")
    
    # Count devices with null/missing fields
    total=$(echo "$response" | jq '. | length')
    
    null_ip=$(echo "$response" | jq "[.[] | select(.$ip_field == null or .$ip_field == \"\")] | length")
    null_mac=$(echo "$response" | jq "[.[] | select(.$mac_field == null or .$mac_field == \"\")] | length")
    null_both=$(echo "$response" | jq "[.[] | select((.$ip_field == null or .$ip_field == \"\") and (.$mac_field == null or .$mac_field == \"\"))] | length")
    
    echo "  Total devices: $total"
    
    if [ "$null_ip" -gt 0 ]; then
        echo -e "  ${RED}⚠ Devices with null/empty IP ($ip_field): $null_ip${NC}"
        echo "    These will cause CRASH in _formatNetworkInfo!"
        # Show examples
        echo "    Examples:"
        echo "$response" | jq -r ".[] | select(.$ip_field == null or .$ip_field == \"\") | \"      ID: \" + (.id | tostring) + \", Name: \" + .name" | head -3
    else
        echo -e "  ${GREEN}✓ All devices have IP address${NC}"
    fi
    
    if [ "$null_mac" -gt 0 ]; then
        echo -e "  ${RED}⚠ Devices with null/empty MAC ($mac_field): $null_mac${NC}"
        echo "    These will cause CRASH in _formatNetworkInfo!"
        # Show examples
        echo "    Examples:"
        echo "$response" | jq -r ".[] | select(.$mac_field == null or .$mac_field == \"\") | \"      ID: \" + (.id | tostring) + \", Name: \" + .name" | head -3
    else
        echo -e "  ${GREEN}✓ All devices have MAC address${NC}"
    fi
    
    if [ "$null_both" -gt 0 ]; then
        echo -e "  ${RED}⚠⚠ Devices with BOTH null: $null_both${NC}"
    fi
    
    echo ""
}

echo "Analyzing device fields for null values..."
echo "Note: The app uses force unwrap (!) on IP and MAC fields"
echo "Any null value will cause immediate crash!"
echo ""

# Check each device type with their specific field names
check_endpoint "/api/access_points.json?page_size=0" "Access Points" "ip" "mac"
check_endpoint "/api/media_converters.json?page_size=0" "Media Converters" "ip" "mac"
check_endpoint "/api/switch_devices.json?page_size=0" "Switch Devices" "host" "scratch"
check_endpoint "/api/wlan_devices.json?page_size=0" "WLAN Controllers" "host" "mac"

echo "========================================"
echo "CRASH ANALYSIS"
echo "========================================"
echo ""
echo "The crash occurs in devices_screen.dart _formatNetworkInfo():"
echo "  Line 28: device.ipAddress!.trim()"
echo "  Line 30: device.macAddress!.trim()"
echo ""
echo "These force unwraps (!) will crash if the field is null."
echo ""
echo "Data flow:"
echo "1. API returns device with null/empty IP or MAC"
echo "2. DeviceModel maps fields (may get null)"
echo "3. Device entity has nullable ipAddress/macAddress"
echo "4. _formatNetworkInfo force unwraps → CRASH!"
echo ""
echo -e "${RED}If any devices above show null IP/MAC, that's the crash cause!${NC}"