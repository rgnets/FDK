#!/bin/bash

echo "=================================="
echo "Running API Field Analysis Scripts"
echo "=================================="
echo ""

echo "Step 1: Checking Access Points for pms_room_id field..."
echo "---------------------------------------------------------"
flutter run scripts/check_access_points_fields.dart
echo ""
echo ""

echo "Step 2: Checking Media Converters for pms_room_id field..."
echo "------------------------------------------------------------"
flutter run scripts/check_media_converters_fields.dart
echo ""
echo ""

echo "Step 3: Comparing Room IDs with Device Naming Patterns..."
echo "----------------------------------------------------------"
flutter run scripts/compare_rooms_devices_names.dart
echo ""

echo "=================================="
echo "Analysis Complete"
echo "=================================="
echo ""
echo "Key things to look for:"
echo "1. Do access points and media converters have pms_room_id field?"
echo "2. Do device names match their assigned room IDs?"
echo "3. Is room 203 showing devices with '411' in their names?"
echo "4. Is room 411 showing devices with '203' in their names?"