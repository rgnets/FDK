#!/bin/bash

echo "🌐 Testing staging app in headless browser..."
echo "============================================"

# Use Chrome with console logging enabled
timeout 30 google-chrome \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --enable-logging \
    --log-level=0 \
    --dump-dom \
    --virtual-time-budget=10000 \
    http://localhost:8081 2>&1 | grep -E "(DEVICES_PROVIDER|ROOMS_PROVIDER|HOME_SCREEN|API|Console|Error|Warning)" > browser_console_output.txt

echo "Browser console output:"
cat browser_console_output.txt

echo ""
echo "Full browser output saved to browser_console_output.txt"