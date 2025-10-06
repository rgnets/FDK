#!/bin/bash

# Script to monitor Flutter app and detect crash patterns
# Run this while navigating to the devices view

echo "========================================"
echo "FLUTTER CRASH MONITOR"
echo "========================================"
echo ""
echo "This script monitors for common crash patterns"
echo "Run this in parallel with the Flutter app"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Log file to monitor
LOG_FILE="flutter_server.log"

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${YELLOW}Creating log file: $LOG_FILE${NC}"
    touch "$LOG_FILE"
fi

echo "Monitoring $LOG_FILE for crash patterns..."
echo "Navigate to the Devices view in the app to trigger the crash"
echo ""
echo "Watching for:"
echo "  - Null reference errors"
echo "  - Provider initialization failures"
echo "  - JSON parsing errors"
echo "  - Widget rebuild issues"
echo ""
echo "========================================"
echo ""

# Function to analyze line for crash patterns
analyze_line() {
    local line=$1
    
    # Check for null reference errors
    if echo "$line" | grep -qi "null.*assertion\|null.*error\|null.*exception\|noSuchMethod\|cannot.*null"; then
        echo -e "${RED}[NULL ERROR]${NC} $line"
        echo "  LIKELY CAUSE: Force unwrapping null value in _formatNetworkInfo"
        return 0
    fi
    
    # Check for provider errors
    if echo "$line" | grep -qi "provider.*error\|provider.*exception\|notifier.*error\|riverpod"; then
        echo -e "${RED}[PROVIDER ERROR]${NC} $line"
        echo "  LIKELY CAUSE: Provider initialization or circular dependency"
        return 0
    fi
    
    # Check for JSON parsing errors
    if echo "$line" | grep -qi "json.*error\|json.*exception\|type.*cast\|type.*error\|_TypeError"; then
        echo -e "${RED}[JSON ERROR]${NC} $line"
        echo "  LIKELY CAUSE: Unexpected JSON structure or type mismatch"
        return 0
    fi
    
    # Check for rebuild issues
    if echo "$line" | grep -qi "setState.*during.*build\|rebuild.*during.*build\|infinite.*loop"; then
        echo -e "${RED}[REBUILD ERROR]${NC} $line"
        echo "  LIKELY CAUSE: State update during build causing infinite loop"
        return 0
    fi
    
    # Check for specific device view errors
    if echo "$line" | grep -qi "DevicesScreen\|devices_screen\|_formatNetworkInfo\|deviceUIStateNotifier"; then
        if echo "$line" | grep -qi "error\|exception\|failed"; then
            echo -e "${YELLOW}[DEVICES VIEW]${NC} $line"
            return 0
        fi
    fi
    
    # Check for API errors
    if echo "$line" | grep -qi "401\|403\|404\|500\|api.*error\|fetch.*failed"; then
        echo -e "${YELLOW}[API ERROR]${NC} $line"
        return 0
    fi
    
    # Log navigation events
    if echo "$line" | grep -qi "navigat.*devices\|route.*devices"; then
        echo -e "${BLUE}[NAVIGATION]${NC} Navigating to devices view..."
        return 0
    fi
    
    return 1
}

# Monitor the log file
tail -f "$LOG_FILE" 2>/dev/null | while read -r line; do
    analyze_line "$line"
done &

TAIL_PID=$!

# Also monitor Flutter's debug output if running
if pgrep -f "flutter run" > /dev/null; then
    echo -e "${GREEN}Flutter process detected, monitoring...${NC}"
fi

echo "Press Ctrl+C to stop monitoring"
echo ""

# Handle cleanup
trap "kill $TAIL_PID 2>/dev/null; exit" INT TERM

# Keep script running
wait $TAIL_PID