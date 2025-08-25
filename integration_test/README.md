# Zaza Dance Integration Tests

End-to-end testing suite for the Zaza Dance Flutter application.

## 📁 Structure

```
integration_test/
├── README.md                 # This file
├── app_test.dart            # Basic app functionality tests
├── user_journeys_test.dart  # Complete user journey tests
├── test_environment.dart    # Test environment setup
├── fixtures/
│   └── test_data.dart       # Test data and fixtures
├── helpers/
│   └── test_helper.dart     # Testing utilities and helpers
└── page_objects/
    ├── home_page.dart       # Home page interactions
    ├── auth_page.dart       # Authentication page interactions
    ├── gallery_page.dart    # Gallery page interactions
    └── tutorials_page.dart  # Tutorials page interactions
```

## 🚀 Running Tests

### Prerequisites

1. **Flutter SDK** (3.24.0 or later)
2. **Connected device** or **running emulator**
3. **Test environment variables** (optional)

### Environment Variables

Set up test environment variables for full testing:

```bash
export SUPABASE_TEST_URL="https://your-test-project.supabase.co"
export SUPABASE_TEST_ANON_KEY="your-test-anon-key"
```

### Local Testing

#### Run All Integration Tests
```bash
flutter test integration_test/
```

#### Run Specific Test File
```bash
flutter test integration_test/app_test.dart
```

#### Run with Flutter Driver (for CI/CD)
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

#### Run User Journey Tests
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/user_journeys_test.dart
```

### Device-Specific Testing

#### Android
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d android
```

#### iOS
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d ios
```

## 🧪 Test Categories

### 1. Basic App Tests (`app_test.dart`)
- App launch and initialization
- Navigation between main screens
- Content loading and display
- Theme and localization
- Performance benchmarks
- Accessibility features

### 2. User Journey Tests (`user_journeys_test.dart`)
- **New User Journey**: First-time user experience
- **Returning User Journey**: Login and personalized content
- **Content Consumption**: Browsing and watching videos
- **Learning Journey**: Tutorial progression and completion
- **Offline Usage**: Download and offline access
- **Social Interaction**: Sharing and favorites
- **Error Recovery**: Network issues and error handling
- **Accessibility**: Screen reader and keyboard navigation
- **Performance**: Animation and loading performance
- **RTL/Localization**: Hebrew text and RTL layout
- **Theme**: Dark theme with neon effects

## 📄 Page Object Model

The test suite uses the Page Object Model pattern for maintainable and reusable test code:

### HomePage (`page_objects/home_page.dart`)
- Navigation verification
- Content display
- Theme and RTL testing
- Performance testing

### AuthPage (`page_objects/auth_page.dart`)
- Login/registration flows
- Form validation
- Password management
- Profile management

### GalleryPage (`page_objects/gallery_page.dart`)
- Media browsing
- Video playback
- Search and filtering
- Download functionality

### TutorialsPage (`page_objects/tutorials_page.dart`)
- Tutorial browsing
- Video controls
- Progress tracking
- Favorite management

## 🔧 Test Helpers

### TestHelper (`helpers/test_helper.dart`)
- Test environment setup
- Test data creation
- Network simulation
- Authentication helpers
- Cleanup utilities

### TestData (`fixtures/test_data.dart`)
- Static test data
- User credentials
- Content fixtures
- Performance benchmarks
- Error scenarios

## 🏗️ Test Environment

### TestEnvironment (`test_environment.dart`)
- Supabase initialization
- Test database setup
- User management
- Network simulation
- State management

## 📊 Performance Testing

Tests include performance benchmarks:

- **App startup**: < 3 seconds
- **Page navigation**: < 2 seconds
- **Video loading**: < 5 seconds
- **Image loading**: < 3 seconds
- **Search response**: < 1.5 seconds
- **API response**: < 2 seconds

## ♿ Accessibility Testing

Comprehensive accessibility testing includes:

- Screen reader compatibility
- Keyboard navigation
- Semantic labels
- Color contrast
- Touch target sizes
- Text scaling

## 🌐 Localization Testing

RTL and Hebrew language testing:

- Text direction verification
- Layout mirroring
- Font rendering
- Search functionality
- Form input handling

## 🎨 Theme Testing

Dark theme with neon effects:

- Color scheme verification
- Neon glow effects
- Animation performance
- Contrast ratios

## 🤖 CI/CD Integration

### GitHub Actions

Tests run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Daily schedule (2 AM UTC)

### Test Matrix

| Platform | Test Type | Duration |
|----------|-----------|----------|
| Android | Integration | ~20 min |
| iOS | Integration | ~25 min |
| Android | User Journey | ~30 min |
| Android | Performance | ~15 min |
| Android | Accessibility | ~15 min |

### Artifacts

Test results and screenshots are uploaded as artifacts:
- Test screenshots
- Performance reports
- Accessibility results
- Build outputs

## 🔍 Debugging Tests

### Enable Verbose Logging
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --verbose
```

### Screenshot on Failure
Tests automatically capture screenshots on failure, saved to:
- `integration_test/screenshots/`
- `test_driver/screenshots/`

### Debug Mode
Set `kDebugMode = true` for detailed console output during test execution.

## 📝 Writing New Tests

### 1. Follow the Page Object Pattern
```dart
// Create page object
class NewPage {
  final WidgetTester tester;
  NewPage(this.tester);
  
  Finder get newElement => find.byKey(const Key('new_element'));
  
  Future<void> performAction() async {
    await tester.tap(newElement);
    await tester.pumpAndSettle();
  }
}
```

### 2. Use Test Helper Methods
```dart
// Setup test environment
await testHelper.setupTestEnvironment();

// Wait for widgets with timeout
await testHelper.waitForWidget(tester, find.byKey(const Key('element')));

// Cleanup after test
await testHelper.cleanup();
```

### 3. Add Test Data
```dart
// Add to fixtures/test_data.dart
static const Map<String, dynamic> newTestData = {
  'id': 'test-new-item',
  'name': 'שם חדש',
  'value': 123,
};
```

### 4. Handle Hebrew/RTL
```dart
// Verify RTL layout
await homePage.verifyRTLLayout();

// Test Hebrew text
expect(find.textContaining('עברית'), findsOneWidget);
```

## 🐛 Common Issues

### 1. Widget Not Found
- Ensure widgets have unique keys
- Wait for animations to complete with `pumpAndSettle()`
- Check if widget is scrollable and scroll to it first

### 2. Flaky Tests
- Add proper wait conditions
- Use `waitForWidget()` helper with timeouts
- Ensure test data is properly set up

### 3. Performance Tests Failing
- Run tests on consistent hardware
- Check performance benchmarks in `test_data.dart`
- Consider network conditions

### 4. Supabase Connection Issues
- Verify test environment variables
- Check network connectivity
- Ensure test database is accessible

## 📈 Test Metrics

Track test metrics:
- Test execution time
- Success/failure rates
- Code coverage
- Performance benchmarks
- Accessibility compliance

## 🔗 Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Page Object Model](https://martinfowler.com/bliki/PageObject.html)
- [Accessibility Testing](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

## 📞 Support

For questions about the test suite:
1. Check this documentation
2. Review existing test implementations
3. Consult the development team
4. Create an issue in the repository