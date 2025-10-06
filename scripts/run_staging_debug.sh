#!/bin/bash

echo "Starting staging with debug logging..."
echo "Open http://localhost:8888 in browser"
echo "Press F12 to open developer console to see logs"
echo ""
echo "Look for these debug messages:"
echo "  - DEBUG: Starting auth with fqdn=..."
echo "  - DEBUG: authenticate() completed..."
echo "  - DEBUG: authStateAsync = ..."
echo "  - DEBUG: authState.value = ..."
echo "  - DEBUG: Authenticated/Not authenticated"
echo ""
echo "Press Ctrl+C to stop"
echo ""

flutter run -d web-server --web-port=8888 --target=lib/main_staging.dart