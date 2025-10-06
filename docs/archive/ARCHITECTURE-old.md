# Architecture Decision Records (ADR)

## Project Architecture Overview

### Clean Architecture + MVVM Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Views (Screens & Widgets)                │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │         ViewModels (State Management)            │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │    Use Cases    │    Entities    │   Services    │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Repositories  │  Data Sources  │    Models      │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Current Implementation Status

### Implemented Architecture Components
✅ **Clean Architecture Layers**:
- **Presentation**: Screens, Widgets, Providers
- **Domain**: Models, Business Logic  
- **Data**: Repositories, Services, API Client

✅ **Dependency Injection**:
- Service locator pattern with GetIt
- All dependencies registered in `service_locator.dart`
- Providers created via factories

✅ **State Management**:
- Provider with ChangeNotifier
- BaseProvider class for common functionality
- Feature-specific providers (Auth, Devices, Rooms, etc.)

## Key Architectural Decisions

### 1. State Management: Provider + GetIt ✅ **Implemented**
**Decision**: Use Provider for state management with GetIt for dependency injection
**Rationale**: 
- Provider is simple, performant, and well-documented
- GetIt provides compile-time safe DI
- Both are mature and stable
**Implementation**:
- MultiProvider wrapper in main.dart
- BaseProvider with common error handling
- GetIt service locator with lazy singleton pattern
**Alternatives Considered**: Riverpod, Bloc, MobX

### 2. Navigation: go_router ✅ **Implemented**
**Decision**: Use go_router for declarative routing
**Rationale**:
- Type-safe routing
- Deep linking support
- Web URL support
- Guard/redirect capabilities
**Implementation**:
- ShellRoute with bottom navigation
- 12 screens with proper routing
- Route guards for auth flow
**Alternatives Considered**: Navigator 2.0, auto_route

### 3. Network Layer: Dio ✅ **Implemented**
**Decision**: Use Dio for HTTP requests
**Implementation**:
- ApiService wrapper with typed methods
- Interceptors for auth headers
- Auto-logout on 401 responses
- Test credentials for development
**Rationale**:
- Interceptor support for auth/logging
- Request/response transformation
- Timeout and retry handling
- File upload progress tracking
**Alternatives Considered**: http package, Chopper

### 4. Local Storage: SharedPreferences + Secure Storage
**Decision**: SharedPreferences for settings, flutter_secure_storage for credentials
**Rationale**:
- Simple key-value storage for preferences
- Encrypted storage for sensitive data
- Platform-optimized implementations
**Alternatives Considered**: Hive, SQLite, Drift

### 5. Code Generation: Minimal
**Decision**: Avoid heavy code generation initially
**Rationale**:
- Faster development iteration
- Easier to understand codebase
- Can add later if needed
**Future Considerations**: json_serializable, freezed, built_value

## Folder Structure

```
lib/
├── core/
│   ├── constants/      # App constants
│   ├── theme/          # Theme and styling
│   ├── utils/          # Utilities and helpers
│   └── widgets/        # Shared widgets
│
├── features/           # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── scanner/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── devices/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── rooms/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── services/           # App-wide services
│   ├── api/
│   ├── storage/
│   └── navigation/
│
└── main.dart          # Entry point
```

## Data Flow

```
User Action → View → ViewModel → Use Case → Repository → Data Source
                ↑                                              ↓
                └──────────────── State Update ←──────────────┘
```

## Dependency Rules

1. **Presentation** depends on **Domain**
2. **Data** depends on **Domain**
3. **Domain** depends on nothing
4. **Core** is available to all layers
5. **Features** are independent of each other

## Testing Strategy

```
├── test/
│   ├── unit/           # Business logic tests
│   ├── widget/         # Widget tests
│   └── integration/    # Integration tests
│
├── test_driver/        # E2E tests
│
└── coverage/           # Coverage reports
```

## Error Handling

### Hierarchy
1. **Domain Exceptions**: Business logic errors
2. **Data Exceptions**: Network, parsing, storage errors
3. **Presentation Errors**: User-friendly messages

### Error Flow
```
Data Layer Exception
    ↓
Domain Layer (transform/wrap)
    ↓
Presentation Layer (user message)
    ↓
UI (snackbar/dialog)
```

## Security Considerations

1. **No hardcoded credentials**
2. **Secure storage for sensitive data**
3. **Certificate pinning for production**
4. **Input validation at domain layer**
5. **API key rotation support**

## Performance Guidelines

1. **Lazy loading**: Load data on demand
2. **Image caching**: Use CachedNetworkImage
3. **List optimization**: Use ListView.builder
4. **State management**: Minimize rebuilds
5. **Network optimization**: Batch requests when possible

## Platform-Specific Code

```dart
// Use platform checks sparingly
if (Platform.isIOS) {
  // iOS specific code
} else if (Platform.isAndroid) {
  // Android specific code
} else if (kIsWeb) {
  // Web specific code
}
```

## Code Style

1. **File naming**: snake_case.dart
2. **Class naming**: PascalCase
3. **Variable naming**: camelCase
4. **Constants**: SCREAMING_SNAKE_CASE or lowerCamelCase
5. **Private members**: _prefixWithUnderscore
6. **Line length**: 80 characters (relaxed to 120 for better readability)

## Future Considerations

### Phase 2 Additions
- [ ] GraphQL support
- [ ] WebSocket for real-time updates
- [ ] Background task processing
- [ ] Biometric authentication

### Phase 3 Additions
- [ ] Offline-first architecture
- [ ] Multi-language support
- [ ] A/B testing framework
- [ ] Feature flags system

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2024-01-17 | Use Material Icons initially | Speed of development over custom assets |
| 2024-01-17 | Provider over Riverpod | Simpler, mature, well-documented |
| 2024-01-17 | go_router over auto_route | Better web support, simpler API |
| 2024-01-17 | Minimal code generation | Faster iteration, clearer code |

## References

- [Flutter Architecture Samples](https://fluttersamples.com/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model–view–viewmodel)
- [Provider Documentation](https://pub.dev/packages/provider)
- [go_router Documentation](https://pub.dev/packages/go_router)