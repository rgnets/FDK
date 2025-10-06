#!/bin/bash

# Script to update all main*.dart files to remove service locator references

echo "Updating main files to use Riverpod providers..."

files=(
    "lib/main_development.dart"
    "lib/main_production.dart"
    "lib/main_staging.dart"
    "lib/main_staging_debug.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Comment out service_locator import
        sed -i "s|import 'package:rgnets_fdk/core/di/service_locator.dart';|// Removed service locator - using Riverpod providers|g" "$file"
        
        # Comment out initServiceLocator calls
        sed -i "s|await initServiceLocator();|// Removed - using Riverpod providers|g" "$file"
        
        # Add SharedPreferences import if not present
        if ! grep -q "import 'package:shared_preferences/shared_preferences.dart';" "$file"; then
            sed -i "/import 'package:flutter_riverpod/a\import 'package:shared_preferences/shared_preferences.dart';" "$file"
        fi
        
        # Add core providers import if not present
        if ! grep -q "import 'package:rgnets_fdk/core/providers/core_providers.dart';" "$file"; then
            sed -i "/import 'package:flutter_riverpod/a\import 'package:rgnets_fdk/core/providers/core_providers.dart';" "$file"
        fi
        
        echo "  Updated $file"
    fi
done

echo "Main files updated successfully!"