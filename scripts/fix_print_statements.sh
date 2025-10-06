#!/bin/bash

# Script to replace print statements with logger calls
echo "Replacing print statements with logger calls..."

# First, let's find all Dart files with print statements
FILES=$(find lib -name "*.dart" -type f)

for file in $FILES; do
  if grep -q "print(" "$file"; then
    echo "Processing: $file"
    
    # Check if file already imports logger
    if ! grep -q "import 'package:logger/logger.dart';" "$file"; then
      # Add logger import after the first import statement
      sed -i "/^import /a import 'package:logger/logger.dart';" "$file"
    fi
    
    # Check if file has a logger instance
    if ! grep -q "final.*logger\s*=" "$file" && ! grep -q "late.*Logger.*logger" "$file"; then
      # Add logger instance after class declaration
      sed -i "/^class [A-Z][a-zA-Z]* /a \ \ static final logger = Logger();" "$file"
    fi
    
    # Replace print statements with logger.d (debug level)
    # Handle multi-line prints carefully
    sed -i "s/print(/logger.d(/g" "$file"
  fi
done

echo "Print statement replacement complete!"