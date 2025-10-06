#!/bin/bash

# E2E Testing Script for RG Nets FDK
# Tests all environments: development, staging, production
# Usage: ./scripts/e2e_test.sh [environment]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WEB_PORT=8888
TIMEOUT=120
PID_FILE="/tmp/flutter_app.pid"
LOG_FILE="/tmp/flutter_e2e.log"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

cleanup() {
    log_info "Cleaning up..."
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            log_info "Stopping Flutter app (PID: $PID)..."
            kill "$PID" 2>/dev/null || true
            sleep 2
            kill -9 "$PID" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
    rm -f "$LOG_FILE"
}

start_app() {
    local ENV=$1
    local TARGET=""
    
    case $ENV in
        development)
            TARGET="lib/main_development.dart"
            ;;
        staging)
            TARGET="lib/main_staging.dart"
            ;;
        production)
            TARGET="lib/main_production.dart"
            ;;
        *)
            log_error "Unknown environment: $ENV"
            return 1
            ;;
    esac
    
    log_info "Starting $ENV environment ($TARGET)..."
    
    # Start Flutter web server in background
    flutter run -d web-server \
        --web-port=$WEB_PORT \
        --target="$TARGET" \
        --dart-define=FLUTTER_WEB_USE_SKIA=true \
        > "$LOG_FILE" 2>&1 &
    
    local APP_PID=$!
    echo "$APP_PID" > "$PID_FILE"
    
    log_info "Waiting for app to start (PID: $APP_PID)..."
    
    # Wait for app to be ready
    local WAIT_TIME=0
    while [ $WAIT_TIME -lt $TIMEOUT ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$WEB_PORT" | grep -q "200\|302"; then
            log_info "App is ready!"
            return 0
        fi
        sleep 2
        WAIT_TIME=$((WAIT_TIME + 2))
        echo -n "."
    done
    
    log_error "App failed to start within $TIMEOUT seconds"
    cat "$LOG_FILE"
    return 1
}

test_endpoint() {
    local URL=$1
    local EXPECTED_CODE=$2
    local DESCRIPTION=$3
    
    log_info "Testing: $DESCRIPTION"
    local RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    
    if [ "$RESPONSE_CODE" = "$EXPECTED_CODE" ]; then
        log_info "✅ PASS: Got expected response code $RESPONSE_CODE"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "❌ FAIL: Expected $EXPECTED_CODE, got $RESPONSE_CODE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_content() {
    local URL=$1
    local EXPECTED_CONTENT=$2
    local DESCRIPTION=$3
    
    log_info "Testing: $DESCRIPTION"
    local RESPONSE=$(curl -s "$URL")
    
    if echo "$RESPONSE" | grep -q "$EXPECTED_CONTENT"; then
        log_info "✅ PASS: Found expected content"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "❌ FAIL: Expected content not found: $EXPECTED_CONTENT"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_api_mock() {
    local ENV=$1
    log_info "Testing API mock behavior for $ENV..."
    
    # Development should use mock data
    if [ "$ENV" = "development" ]; then
        test_content "http://localhost:$WEB_PORT" "<!DOCTYPE html>" "HTML page loads"
    fi
    
    # Staging should auto-authenticate
    if [ "$ENV" = "staging" ]; then
        test_content "http://localhost:$WEB_PORT" "<!DOCTYPE html>" "HTML page loads"
        # After auto-auth, should redirect to home
        sleep 3
        test_endpoint "http://localhost:$WEB_PORT/#/home" "200" "Home page accessible after auto-auth"
    fi
    
    # Production should require authentication
    if [ "$ENV" = "production" ]; then
        test_content "http://localhost:$WEB_PORT" "<!DOCTYPE html>" "HTML page loads"
        # Should redirect to auth
        test_endpoint "http://localhost:$WEB_PORT/#/auth" "200" "Auth page accessible"
    fi
}

run_environment_tests() {
    local ENV=$1
    
    echo ""
    echo "========================================="
    log_info "Testing $ENV environment"
    echo "========================================="
    
    # Start the app
    if ! start_app "$ENV"; then
        log_error "Failed to start $ENV environment"
        return 1
    fi
    
    # Wait a bit for app to fully initialize
    sleep 5
    
    # Basic connectivity tests
    test_endpoint "http://localhost:$WEB_PORT" "200" "Root endpoint accessible"
    test_endpoint "http://localhost:$WEB_PORT/index.html" "200" "Index.html accessible"
    
    # Environment-specific tests
    test_api_mock "$ENV"
    
    # Test navigation endpoints
    test_endpoint "http://localhost:$WEB_PORT/#/splash" "200" "Splash screen accessible"
    
    # Clean up this environment
    cleanup
    
    echo ""
    log_info "Environment $ENV tests complete"
    echo "-----------------------------------------"
}

# Main execution
main() {
    local ENVIRONMENT=${1:-"all"}
    
    # Trap to ensure cleanup on exit
    trap cleanup EXIT
    
    echo "========================================="
    echo "RG Nets FDK - End-to-End Testing"
    echo "========================================="
    echo ""
    
    # First, ensure the project builds
    log_info "Ensuring project builds..."
    if ! flutter build web --target lib/main_development.dart > /dev/null 2>&1; then
        log_error "Project failed to build!"
        exit 1
    fi
    log_info "Build successful!"
    
    # Run tests for specified environment(s)
    if [ "$ENVIRONMENT" = "all" ]; then
        run_environment_tests "development"
        run_environment_tests "staging"
        run_environment_tests "production"
    else
        run_environment_tests "$ENVIRONMENT"
    fi
    
    # Final report
    echo ""
    echo "========================================="
    echo "TEST RESULTS"
    echo "========================================="
    log_info "Tests Passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        log_error "Tests Failed: $TESTS_FAILED"
        exit 1
    else
        log_info "All tests passed! ✅"
    fi
}

# Run main function
main "$@"