# RG Nets FDK - Makefile for testing and development

.PHONY: help test e2e health verify clean build lint fix run-dev run-staging run-prod

# Default target
help:
	@echo "RG Nets FDK - Available commands:"
	@echo ""
	@echo "  make test          - Run all unit tests"
	@echo "  make e2e           - Run end-to-end tests for all environments"
	@echo "  make health        - Run health checks on all environments"
	@echo "  make verify        - Verify all environments are working"
	@echo "  make lint          - Run linter"
	@echo "  make fix           - Auto-fix lint issues"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make build         - Build all environments"
	@echo ""
	@echo "  make run-dev       - Run development environment"
	@echo "  make run-staging   - Run staging environment"
	@echo "  make run-prod      - Run production environment"
	@echo ""
	@echo "  make regression    - Run regression test suite"
	@echo "  make ci            - Run CI/CD pipeline locally"

# Testing targets
test:
	@echo "Running unit tests..."
	@flutter test

test-integration:
	@echo "Running integration tests..."
	@flutter test test/integration/

e2e:
	@echo "Running E2E tests..."
	@./scripts/e2e_test.sh all

health:
	@echo "Running health checks..."
	@dart run scripts/health_check.dart

verify:
	@echo "Verifying all environments..."
	@./scripts/verify_environments.sh

regression: lint test test-integration
	@echo "Running regression tests..."
	@flutter test test/performance_tests.dart --timeout=5m

# Code quality
lint:
	@echo "Running linter..."
	@flutter analyze lib/

fix:
	@echo "Auto-fixing issues..."
	@dart fix --apply
	@dart format lib/ test/

format:
	@echo "Formatting code..."
	@dart format lib/ test/ scripts/

# Build targets
build: build-dev build-staging build-prod

build-dev:
	@echo "Building development..."
	@flutter build web --target lib/main_development.dart

build-staging:
	@echo "Building staging..."
	@flutter build web --target lib/main_staging.dart

build-prod:
	@echo "Building production..."
	@flutter build web --target lib/main_production.dart

build-apk:
	@echo "Building APK..."
	@flutter build apk --target lib/main_production.dart

# Run targets
run-dev:
	@echo "Starting development environment..."
	@flutter run -d chrome --target lib/main_development.dart

run-staging:
	@echo "Starting staging environment..."
	@flutter run -d chrome --target lib/main_staging.dart

run-prod:
	@echo "Starting production environment..."
	@flutter run -d chrome --target lib/main_production.dart

# Clean
clean:
	@echo "Cleaning..."
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@rm -f pubspec.lock

# CI/CD simulation
ci: clean
	@echo "Running CI/CD pipeline..."
	@echo "Step 1: Installing dependencies..."
	@flutter pub get
	@echo "Step 2: Checking format..."
	@dart format --output=none --set-exit-if-changed lib/
	@echo "Step 3: Running linter..."
	@flutter analyze lib/
	@echo "Step 4: Running tests..."
	@flutter test
	@echo "Step 5: Building all environments..."
	@make build
	@echo "Step 6: Running E2E tests..."
	@make e2e
	@echo "✅ CI/CD pipeline completed successfully!"

# Quick checks before commit
pre-commit: format lint test
	@echo "✅ Pre-commit checks passed!"

# Watch for changes and run tests
watch:
	@echo "Watching for changes..."
	@nodemon -e dart -x "flutter test"

# Generate coverage report
coverage:
	@echo "Generating coverage report..."
	@flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report generated at coverage/html/index.html"

# Docker targets (if needed in future)
docker-build:
	@echo "Building Docker image..."
	@docker build -t rgnets-fdk .

docker-run:
	@echo "Running in Docker..."
	@docker run -p 8080:8080 rgnets-fdk