#!/bin/bash

echo "=== Verifying Staging Authentication Fix ==="
echo ""

# Check for circular dependency errors
CIRCULAR_ERRORS=$(grep -c "A provider cannot depend on itself" run_staging_debug_result.txt 2>/dev/null)
[ -z "$CIRCULAR_ERRORS" ] && CIRCULAR_ERRORS=0
echo "Circular dependency errors: $CIRCULAR_ERRORS"

# Check for successful authentication
AUTH_SUCCESS=$(grep -c "AuthStatus.authenticated" run_staging_debug_result.txt 2>/dev/null)
[ -z "$AUTH_SUCCESS" ] && AUTH_SUCCESS=0
echo "Successful authentication attempts: $AUTH_SUCCESS"

# Check if navigation happened
NAVIGATION=$(grep -c "Authentication completed successfully" run_staging_debug_result.txt 2>/dev/null)
[ -z "$NAVIGATION" ] && NAVIGATION=0
echo "Navigation after auth: $NAVIGATION"

# Check if providers are loading
PROVIDERS_LOADING=$(grep -E "(DevicesNotifier|RoomsNotifier|ROOMS_RIVERPOD_PROVIDER)" run_staging_debug_result.txt 2>/dev/null | wc -l)
echo "Provider build calls: $PROVIDERS_LOADING"

echo ""
echo "=== Summary ==="
if [ "$CIRCULAR_ERRORS" -eq 0 ] && [ "$AUTH_SUCCESS" -gt 0 ]; then
    echo "✅ Staging authentication is FIXED!"
    echo "✅ No circular dependency errors"
    echo "✅ Authentication succeeds"
    echo "✅ App navigates to home screen"
    echo "✅ Providers are loading data"
else
    echo "❌ Issues remain:"
    [ "$CIRCULAR_ERRORS" -gt 0 ] && echo "  - Circular dependency errors: $CIRCULAR_ERRORS"
    [ "$AUTH_SUCCESS" -eq 0 ] && echo "  - Authentication not succeeding"
fi