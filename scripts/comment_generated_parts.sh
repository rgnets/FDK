#!/bin/bash

echo "Temporarily commenting out generated part statements..."

# Find all Dart files with part statements for .g.dart files
find lib -name "*.dart" -type f | while read -r file; do
    if grep -q "^part '.*\.g\.dart';" "$file"; then
        echo "Processing: $file"
        # Comment out the part statement
        sed -i "s/^part '\(.*\.g\.dart\)';/\/\/ TODO: Uncomment after build_runner - part '\1';/" "$file"
    fi
done

echo "Part statements commented out. Remember to uncomment after fixing build_runner!"