#!/bin/bash

echo "======================="
echo "APP STATE CHECK"
echo "======================="
echo ""

echo "1. Checking for running Flutter processes:"
echo "----------------------------------------"
ps aux | grep -E "flutter|dart" | grep -v grep

echo ""
echo "2. Checking for build artifacts:"
echo "--------------------------------"
if [ -d "build" ]; then
    echo "Build directory exists"
    echo "Last modified: $(stat -f "%Sm" build 2>/dev/null || stat -c "%y" build 2>/dev/null)"
else
    echo "No build directory found"
fi

echo ""
echo "3. Checking .dart_tool state:"
echo "-----------------------------"
if [ -d ".dart_tool" ]; then
    echo ".dart_tool directory exists"
    echo "Last modified: $(stat -f "%Sm" .dart_tool 2>/dev/null || stat -c "%y" .dart_tool 2>/dev/null)"
else
    echo "No .dart_tool directory found"
fi

echo ""
echo "4. Checking for iOS Simulator/Android Emulator:"
echo "-----------------------------------------------"
if command -v xcrun &> /dev/null; then
    echo "iOS Simulators running:"
    xcrun simctl list devices | grep -A 5 "Booted"
fi

if command -v adb &> /dev/null; then
    echo "Android devices/emulators:"
    adb devices
fi

echo ""
echo "5. Flutter doctor status:"
echo "------------------------"
flutter doctor -v | head -20

echo ""
echo "6. RECOMMENDATIONS:"
echo "==================="
echo "If the app is showing old data despite the code being correct:"
echo ""
echo "1. Stop any running Flutter processes:"
echo "   kill \$(ps aux | grep flutter | grep -v grep | awk '{print \$2}')"
echo ""
echo "2. Clean and rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "3. If using VS Code or Android Studio:"
echo "   - Restart the IDE"
echo "   - Invalidate caches (Android Studio: File > Invalidate Caches)"
echo ""
echo "4. Clear app data on device/simulator:"
echo "   - iOS: Delete app from simulator and reinstall"
echo "   - Android: Settings > Apps > Your App > Clear Data"
echo ""
echo "5. Verify you're running in development mode:"
echo "   flutter run --dart-define=ENV=development"
echo "   OR just: flutter run (development is default)"