# Contributing to Smart Trip Planner Flutter

Thank you for your interest in contributing to Smart Trip Planner Flutter! This document provides guidelines and instructions for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.7.2
- Dart SDK ^3.7.2
- Git
- Your favorite IDE (VS Code, Android Studio, IntelliJ)

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smart_trip_planner_flutter.git
   cd smart_trip_planner_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

3. **Set up environment**
   ```bash
   cp .env.example .env
   # Add your API keys to .env
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔄 Development Workflow

### Branch Naming Convention

- `feature/your-feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Critical production fixes
- `docs/documentation-update` - Documentation changes

### Development Process

1. Create a new branch from `main`
2. Make your changes
3. Write/update tests
4. Run the test suite
5. Commit your changes
6. Push to your fork
7. Create a Pull Request

## 📝 Coding Standards

### Flutter/Dart Guidelines

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use `dart format` for consistent formatting
- Follow the existing architecture patterns
- Write self-documenting code with clear variable names

### Architecture Principles

- **Clean Architecture**: Separate concerns into layers (Data, Domain, Presentation)
- **Feature-based Structure**: Organize code by features, not by file types
- **Dependency Injection**: Use service locators for dependency management
- **Repository Pattern**: Abstract data sources behind repository interfaces

### Code Style

```dart
// ✅ Good: Clear, descriptive names
class TripPlanningRepository {
  Future<Either<Failure, TripItinerary>> generateItinerary({
    required String userPrompt,
    required List<ChatMessage> conversationHistory,
  }) async {
    // Implementation
  }
}

// ❌ Bad: Unclear, abbreviated names
class TripRepo {
  Future<dynamic> gen(String p, List<dynamic> h) async {
    // Implementation
  }
}
```

### File Organization

```
lib/
├── core/                    # Shared core components
├── features/               # Feature-specific modules
│   └── feature_name/
│       ├── data/           # Data layer (models, datasources, repositories)
│       ├── domain/         # Domain layer (entities, usecases, repositories)
│       └── presentation/   # Presentation layer (pages, widgets, blocs)
└── shared/                 # Cross-feature shared components
```

## 🧪 Testing Guidelines

### Test Categories

1. **Unit Tests** - Test individual functions/classes
2. **Widget Tests** - Test UI components
3. **Integration Tests** - Test feature workflows

### Writing Tests

```dart
// Unit test example
group('TripPlanningRepository', () {
  late TripPlanningRepository repository;
  late MockAIAgentService mockAIService;

  setUp(() {
    mockAIService = MockAIAgentService();
    repository = TripPlanningRepository(mockAIService);
  });

  test('should return trip itinerary when generation succeeds', () async {
    // Arrange
    const userPrompt = 'Plan a 3-day trip to Tokyo';
    when(() => mockAIService.generateItinerary(any()))
        .thenAnswer((_) async => const Right(mockItinerary));

    // Act
    final result = await repository.generateItinerary(
      userPrompt: userPrompt,
      conversationHistory: [],
    );

    // Assert
    expect(result, isA<Right<Failure, TripItinerary>>());
  });
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/data/repositories/trip_planning_repository_test.dart
```

## 📨 Commit Message Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

### Examples

```bash
feat(chat): add streaming response support
fix(storage): resolve hive box initialization issue
docs: update API integration guide
test(auth): add unit tests for authentication service
```

## 🔀 Pull Request Process

### Before Submitting

1. **Code Quality**
   - [ ] Code follows the style guidelines
   - [ ] Self-review completed
   - [ ] No unused imports or dead code
   - [ ] All tests pass

2. **Testing**
   - [ ] New functionality has tests
   - [ ] Existing tests still pass
   - [ ] Code coverage maintained/improved

3. **Documentation**
   - [ ] Code is well-commented
   - [ ] README updated if needed
   - [ ] API documentation updated

### PR Description Template

Use the provided PR template to describe:
- What changes were made
- Why they were made
- How to test the changes
- Any breaking changes

### Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Peer Review**: At least one reviewer approval required
3. **Final Review**: Maintainer approval for merge

## 🔧 Development Tools

### Recommended VS Code Extensions

- Dart
- Flutter
- Bracket Pair Colorizer
- GitLens
- Thunder Client (for API testing)

### Useful Commands

```bash
# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format .

# Clean and get dependencies
flutter clean && flutter pub get
```

## 🐛 Reporting Issues

When reporting issues, please:

1. Use the issue templates provided
2. Include steps to reproduce
3. Provide relevant logs/screenshots
4. Specify environment details

## 💡 Feature Requests

For feature requests:

1. Use the feature request template
2. Explain the use case clearly
3. Consider existing alternatives
4. Provide implementation suggestions if possible

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)

## 🤝 Community

- Join discussions in Issues and PRs
- Be respectful and constructive
- Help others learn and grow
- Share your knowledge and experience

---

Thank you for contributing to Smart Trip Planner Flutter! 🚀
