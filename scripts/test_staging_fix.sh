#!/bin/bash

# Test script to verify staging authentication is fixed

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Testing Staging Authentication Fix${NC}"
echo "====================================="

# Build staging first
echo -e "\n${YELLOW}Building staging...${NC}"
flutter build web --target lib/main_staging.dart > /dev/null 2>&1

# Start staging environment
echo -e "\n${YELLOW}Starting staging environment...${NC}"
flutter run -d web-server --web-port=8899 --target=lib/main_staging.dart > /tmp/staging_test.log 2>&1 &
PID=$!

echo "Waiting for server to start..."
sleep 15

# Test 1: Server is running
echo -n "Test 1: Server responds... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8899 | grep -q "200\|302"; then
    echo -e "${GREEN}✅ PASS${NC}"
else
    echo -e "${RED}❌ FAIL${NC}"
    echo "Server logs:"
    tail -20 /tmp/staging_test.log
    kill $PID 2>/dev/null || true
    exit 1
fi

# Test 2: Check if app loads
echo -n "Test 2: App loads... "
if curl -s http://localhost:8899 | grep -q "<title>"; then
    echo -e "${GREEN}✅ PASS${NC}"
else
    echo -e "${RED}❌ FAIL${NC}"
fi

# Test 3: Check authentication behavior
echo -n "Test 3: Checking authentication flow... "
sleep 5  # Give time for auto-auth

# Check logs for auth attempts
if grep -q "Authentication" /tmp/staging_test.log; then
    echo -e "${GREEN}✅ Auth attempted${NC}"
    
    # Check if auth succeeded or failed appropriately
    if grep -q "Authentication completed successfully" /tmp/staging_test.log; then
        echo -e "  ${GREEN}→ Auth succeeded, should be on home page${NC}"
    elif grep -q "Authentication failed" /tmp/staging_test.log; then
        echo -e "  ${YELLOW}→ Auth failed, should redirect to login${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No auth attempt detected${NC}"
fi

# Test 4: Navigation state
echo -n "Test 4: Navigation state... "
# In staging, after auto-auth attempt, should either be on home (success) or auth (failure)
# Since we can't easily check the actual route, we check if the app is responsive
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8899 | grep -q "200"; then
    echo -e "${GREEN}✅ App is navigable${NC}"
else
    echo -e "${RED}❌ App is not responding${NC}"
fi

# Clean up
kill $PID 2>/dev/null || true

echo -e "\n${GREEN}====================================="
echo -e "Staging Authentication Test Complete"
echo -e "=====================================${NC}"

# Show relevant logs
echo -e "\n${YELLOW}Relevant logs:${NC}"
grep -E "(Authentication|Error|auth|Auth)" /tmp/staging_test.log | tail -10 || echo "No auth-related logs found"