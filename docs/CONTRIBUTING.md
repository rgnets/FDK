# Contributing to RG Nets Field Deployment Kit

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Git
- Your favorite IDE (VS Code, Android Studio, IntelliJ)

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Copy `.env.example` to `.env`
4. Update `.env` with your configuration
5. Run `flutter run`

## Development Workflow

### Branch Strategy
```
main           # Production-ready code
├── develop    # Integration branch
└── feature/*  # Feature branches
```

### Commit Convention
We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting, etc)
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance
- `perf`: Performance improvements

#### Examples
```bash
feat(scanner): Add multi-scan accumulation
fix(auth): Resolve QR parsing issue
docs: Update API documentation
```

### Using the Commit Helper
```bash
./scripts/commit.sh feat "Add navigation" "Implemented bottom navigation"
```

## Code Standards

### Dart/Flutter
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Maintain 80% test coverage minimum

### File Organization
```dart
// Good
lib/
  features/
    scanner/
      presentation/
        screens/
          scanner_screen.dart
        widgets/
          scanner_overlay.dart
        providers/
          scanner_provider.dart

// Bad
lib/
  screens/
    scanner.dart
  widgets/
    scanner_stuff.dart
```

### Widget Structure
```dart
// Good
class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const MyWidget({
    super.key,
    required this.title,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Build widget
  }
}
```

### State Management
```dart
// Use Provider pattern
class MyProvider extends ChangeNotifier {
  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Methods
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    // Load data
    
    _isLoading = false;
    notifyListeners();
  }
}
```

## Testing

### Test Categories
1. **Unit Tests**: Business logic
2. **Widget Tests**: UI components
3. **Integration Tests**: Feature flows

### Running Tests
```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/unit/scanner_test.dart
```

### Test Structure
```dart
void main() {
  group('Scanner', () {
    test('should validate QR code', () {
      // Arrange
      final scanner = Scanner();
      
      // Act
      final result = scanner.validate('test');
      
      // Assert
      expect(result, isTrue);
    });
  });
}
```

## Pull Request Process

### Before Creating PR
1. [ ] Run `flutter analyze`
2. [ ] Run `flutter test`
3. [ ] Update documentation
4. [ ] Add/update tests
5. [ ] Self-review changes

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Screenshots
(if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
```

## Code Review Guidelines

### For Reviewers
- Check code style and conventions
- Verify test coverage
- Look for potential bugs
- Suggest improvements
- Be constructive and respectful

### For Authors
- Respond to all comments
- Make requested changes
- Explain complex decisions
- Be open to feedback

## Performance Guidelines

### Images
- Optimize all images before adding
- Use WebP when possible
- Lazy load images in lists
- Cache network images

### Lists
```dart
// Good - Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// Bad - All at once
Column(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

### State Updates
```dart
// Good - Targeted updates
void updateName(String name) {
  _name = name;
  notifyListeners();
}

// Bad - Unnecessary rebuilds
void updateName(String name) {
  _name = name;
  _age = _age;  // Unnecessary
  _email = _email;  // Unnecessary
  notifyListeners();
}
```

## Documentation

### Code Comments
```dart
// Good - Explains why
// We need to delay by 2 seconds to allow the 
// backend to process the previous request
await Future.delayed(Duration(seconds: 2));

// Bad - Explains what (obvious)
// Delay for 2 seconds
await Future.delayed(Duration(seconds: 2));
```

### API Documentation
```dart
/// Validates a QR code for device registration.
/// 
/// The [code] parameter must be a valid QR string.
/// Returns [true] if valid, [false] otherwise.
/// 
/// Throws [FormatException] if code is malformed.
bool validateQRCode(String code) {
  // Implementation
}
```

## Getting Help

- Check existing issues
- Read documentation
- Ask in discussions
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the project's license.