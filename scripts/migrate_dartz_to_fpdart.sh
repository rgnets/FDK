#!/bin/bash

# Script to migrate from dartz to fpdart

echo "Starting migration from dartz to fpdart..."

# Find all Dart files
find . -name "*.dart" -type f | while read -r file; do
    # Skip the migration script itself and any generated files
    if [[ "$file" == *".g.dart" ]] || [[ "$file" == *".freezed.dart" ]]; then
        continue
    fi
    
    # Check if file contains dartz imports
    if grep -q "import.*dartz" "$file"; then
        echo "Processing: $file"
        
        # Create backup
        cp "$file" "$file.bak"
        
        # Replace import statements
        sed -i "s/import 'package:dartz\/dartz.dart';/import 'package:fpdart\/fpdart.dart';/g" "$file"
        
        # Replace Either<L, R> usage patterns
        # Note: fpdart uses the same Either<L, R> syntax, so no change needed for type declarations
        
        # Replace fold method calls (fpdart uses match instead of fold)
        # This is more complex and might need manual review
        # For now, we'll just flag files that use fold for manual review
        
        if grep -q "\.fold(" "$file"; then
            echo "  WARNING: $file contains .fold() calls that may need manual migration to .match()"
        fi
        
        # Replace Right() and Left() constructors (same in fpdart)
        # No change needed as fpdart uses the same constructors
        
        echo "  Migrated imports in $file"
    fi
done

echo "Migration complete!"
echo "Please review files with .fold() calls for manual migration to .match() if needed."
echo "Backup files created with .bak extension"