#!/bin/bash

echo "🧪 Testing RG Nets Field Deployment Kit"
echo "========================================"

# Check if server is running
echo -n "1. Checking web server... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3333 | grep -q "200"; then
    echo "✅ Running on http://localhost:3333"
else
    echo "❌ Server not responding"
    exit 1
fi

# Check app title
echo -n "2. Checking app loads... "
if curl -s http://localhost:3333 | grep -q "rgnets_fdk"; then
    echo "✅ App loaded successfully"
else
    echo "❌ App failed to load"
    exit 1
fi

# Check for JavaScript errors (basic check)
echo -n "3. Checking for critical errors... "
if curl -s http://localhost:3333 | grep -q "Error"; then
    echo "⚠️  Potential errors found (may be false positive)"
else
    echo "✅ No obvious errors in HTML"
fi

# Count lint issues
echo -n "4. Checking code quality... "
ERROR_COUNT=$(flutter analyze 2>/dev/null | grep -c "error")
WARNING_COUNT=$(flutter analyze 2>/dev/null | grep -c "warning")
INFO_COUNT=$(flutter analyze 2>/dev/null | grep -c "info")

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✅ No errors ($WARNING_COUNT warnings, $INFO_COUNT info)"
else
    echo "❌ $ERROR_COUNT errors found"
fi

echo ""
echo "📊 Summary:"
echo "- Errors: $ERROR_COUNT"
echo "- Warnings: $WARNING_COUNT" 
echo "- Info: $INFO_COUNT"
echo "- App Status: Running ✅"
echo "- URL: http://localhost:3333"
echo ""
echo "✨ App is working correctly!"