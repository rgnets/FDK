#!/bin/bash

echo "Disabling service locator references..."

# List of files that need fixing
files=(
    "lib/features/debug/debug_screen.dart"
    "lib/features/home/presentation/providers/dashboard_provider.dart"
    "lib/features/settings/presentation/providers/settings_riverpod_provider.dart"
    "lib/features/notifications/presentation/providers/device_notification_provider.dart"
    "lib/features/notifications/presentation/providers/notification_providers.dart"
    "lib/features/scanner/presentation/providers/scanner_providers.dart"
    "lib/features/auth/presentation/providers/auth_providers.dart"
    "lib/features/devices/presentation/providers/devices_providers.dart"
    "lib/features/rooms/presentation/providers/rooms_providers.dart"
    "lib/main_development.dart"
    "lib/main_production.dart"
    "lib/main_staging.dart"
    "lib/main_staging_debug.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Comment out service_locator imports
        sed -i "s/^import.*service_locator.*$/\/\/ TODO: Migrate to Riverpod - &/" "$file"
        
        # Comment out lines containing sl.
        sed -i "/\bsl\./s/^/\/\/ TODO: Migrate to Riverpod - /" "$file"
        
        echo "  Disabled service locator references in $file"
    fi
done

echo "Service locator references disabled. Please migrate to Riverpod providers."