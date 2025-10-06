#!/bin/bash

# Build verification script for RG Nets FDK

echo "🔍 Verifying RG Nets FDK build..."
echo "================================"

# Check Flutter version
echo ""
echo "📱 Flutter Version:"
flutter --version | head -1

# Run analyzer
echo ""
echo "🔬 Running Flutter Analyzer..."
if flutter analyze; then
    echo "✅ Analysis passed - no issues found"
else
    echo "❌ Analysis failed - please fix issues"
    exit 1
fi

# Run tests
echo ""
echo "🧪 Running Tests..."
if flutter test; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed - please fix failing tests"
    exit 1
fi

# Check if dependencies are up to date
echo ""
echo "📦 Checking Dependencies..."
flutter pub get
echo "✅ Dependencies resolved"

# Verify assets are properly configured
echo ""
echo "🎨 Verifying Assets..."
if grep -q "assets:" pubspec.yaml; then
    echo "✅ Assets configured in pubspec.yaml"
else
    echo "⚠️  No assets configured"
fi

# Check for any TODOs or FIXMEs
echo ""
echo "📝 Checking for TODOs..."
TODO_COUNT=$(grep -r "TODO\|FIXME" lib/ 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "ℹ️  Found $TODO_COUNT TODO/FIXME comments"
else
    echo "✅ No TODO/FIXME comments found"
fi

echo ""
echo "================================"
echo "✅ Build verification complete!"
echo ""
echo "The project is ready for development."
echo "You can run the app with: flutter run"
echo ""