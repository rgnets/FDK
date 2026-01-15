# RG Nets Field Deployment Kit - Documentation

## 📚 Documentation Structure

This directory contains the technical documentation for the RG Nets Field Deployment Kit Flutter application.

### Core Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Complete system architecture overview, Clean Architecture implementation |
| [REFACTORING_NEXT_STEPS.md](REFACTORING_NEXT_STEPS.md) | **Current refactoring plan and next steps** |
| [README_RUNNING_APP.md](README_RUNNING_APP.md) | How to build and run the application |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Guidelines for contributing to the project |

### WebSocket & Data

| Document | Description |
|----------|-------------|
| [websocket-contracts.md](websocket-contracts.md) | WebSocket contract, message envelope, and resource actions |
| [data-models.md](data-models.md) | Data model definitions and relationships |
| [data-flow-architecture.md](data-flow-architecture.md) | Data flow patterns and state management |

### Features & Implementation

| Document | Description |
|----------|-------------|
| [authentication-flow.md](authentication-flow.md) | Authentication and authorization flow |
| [scanner-business-logic.md](scanner-business-logic.md) | QR/barcode scanner implementation details |
| [notification-system.md](notification-system.md) | Notification system architecture |
| [room-readiness-logic.md](room-readiness-logic.md) | Room management business logic |

### UI/UX & Design

| Document | Description |
|----------|-------------|
| [design-system.md](design-system.md) | Design system and UI components |
| [screen-specifications.md](screen-specifications.md) | Detailed screen specifications |
| [image-handling-requirements.md](image-handling-requirements.md) | Image handling and optimization |

### Development & Operations

| Document | Description |
|----------|-------------|
| [dependencies.md](dependencies.md) | Project dependencies and versions |
| [testing-strategy.md](testing-strategy.md) | Testing approach and guidelines |
| [cicd-pipeline.md](cicd-pipeline.md) | CI/CD pipeline configuration |
| [platform-strategy.md](platform-strategy.md) | Multi-platform deployment strategy |
| [version-management.md](version-management.md) | Version control and release management |
| [certificate-handling.md](certificate-handling.md) | SSL certificate and security handling |

### Additional Resources

- **`data-sources/`** - Data source specifications
- **`views/`** - View-specific documentation

## 🚀 Quick Start

1. **New developers**: Start with [README_RUNNING_APP.md](README_RUNNING_APP.md)
2. **Architecture overview**: Read [ARCHITECTURE.md](ARCHITECTURE.md)
3. **Current work**: Check [REFACTORING_NEXT_STEPS.md](REFACTORING_NEXT_STEPS.md)
4. **Contributing**: Follow [CONTRIBUTING.md](CONTRIBUTING.md)

## 📊 Project Status

- **Architecture Score**: 9.5/10
- **Code Quality**: 0 lint warnings in production
- **Clean Architecture**: ✅ Fully implemented
- **MVVM Pattern**: ✅ Properly configured
- **Riverpod State Management**: ✅ Modern patterns
- **GoRouter Navigation**: ✅ Type-safe routing

## 🔄 Current Focus

The main refactoring priorities are documented in [REFACTORING_NEXT_STEPS.md](REFACTORING_NEXT_STEPS.md):

1. **God Classes Refactoring** - Breaking down large files (>300 lines)
2. **Performance Optimizations** - Lazy loading and caching
3. **Testing Coverage** - Unit, widget, and integration tests
4. **State Management Standardization** - Migrating to Riverpod 2.0 patterns

## 📝 Documentation Maintenance

When updating documentation:
1. Keep documents focused and single-purpose
2. Archive outdated documents to `archive/` folder
3. Update this README when adding new documents
4. Use clear, descriptive filenames
5. Include last updated date in documents when relevant
