import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zaza_dance/main.dart' as app;

import 'helpers/test_helper.dart';
import 'page_objects/home_page.dart';
import 'page_objects/gallery_page.dart';
import 'page_objects/tutorials_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Zaza Dance E2E Tests', () {
    late TestHelper testHelper;
    late HomePage homePage;
    late GalleryPage galleryPage;
    late TutorialsPage tutorialsPage;

    setUpAll(() async {
      testHelper = TestHelper();
      await testHelper.setupTestEnvironment();
    });

    setUp(() async {
      // Start fresh app for each test
      app.main();
      await Future.delayed(const Duration(seconds: 2));
    });

    tearDown(() async {
      await testHelper.cleanup();
    });

    testWidgets('App launches and displays home screen', (tester) async {
      homePage = HomePage(tester);
      
      // Wait for app to load
      await tester.pumpAndSettle();
      
      // Verify home screen elements are present
      await homePage.verifyHomeScreenIsDisplayed();
      await homePage.verifyNavigationBarIsPresent();
      await homePage.verifyAppLogoIsVisible();
    });

    testWidgets('Navigation between main screens works', (tester) async {
      homePage = HomePage(tester);
      galleryPage = GalleryPage(tester);
      tutorialsPage = TutorialsPage(tester);
      
      await tester.pumpAndSettle();
      
      // Navigate to Gallery
      await homePage.navigateToGallery();
      await galleryPage.verifyGalleryPageIsDisplayed();
      
      // Navigate to Tutorials
      await homePage.navigateToTutorials();
      await tutorialsPage.verifyTutorialsPageIsDisplayed();
      
      // Navigate back to Home
      await homePage.navigateToHome();
      await homePage.verifyHomeScreenIsDisplayed();
    });

    testWidgets('Gallery loads and displays content', (tester) async {
      homePage = HomePage(tester);
      galleryPage = GalleryPage(tester);
      
      await tester.pumpAndSettle();
      
      // Navigate to gallery
      await homePage.navigateToGallery();
      await galleryPage.verifyGalleryPageIsDisplayed();
      
      // Check if content loads
      await galleryPage.waitForContentToLoad();
      await galleryPage.verifyMediaItemsAreVisible();
    });

    testWidgets('Tutorials page loads and displays videos', (tester) async {
      homePage = HomePage(tester);
      tutorialsPage = TutorialsPage(tester);
      
      await tester.pumpAndSettle();
      
      // Navigate to tutorials
      await homePage.navigateToTutorials();
      await tutorialsPage.verifyTutorialsPageIsDisplayed();
      
      // Check if tutorial content loads
      await tutorialsPage.waitForTutorialsToLoad();
      await tutorialsPage.verifyTutorialItemsAreVisible();
    });

    testWidgets('RTL layout works correctly for Hebrew text', (tester) async {
      homePage = HomePage(tester);
      
      await tester.pumpAndSettle();
      
      // Verify RTL layout
      await homePage.verifyRTLLayout();
      await homePage.verifyHebrewTextDisplays();
    });

    testWidgets('Dark theme with neon effects displays correctly', (tester) async {
      homePage = HomePage(tester);
      
      await tester.pumpAndSettle();
      
      // Verify theme elements
      await homePage.verifyDarkThemeIsActive();
      await homePage.verifyNeonEffectsAreVisible();
    });

    testWidgets('App handles network connectivity changes', (tester) async {
      homePage = HomePage(tester);
      galleryPage = GalleryPage(tester);
      
      await tester.pumpAndSettle();
      
      // Test offline behavior
      await testHelper.simulateOfflineMode();
      await homePage.navigateToGallery();
      await galleryPage.verifyOfflineBehavior();
      
      // Test online behavior
      await testHelper.simulateOnlineMode();
      await galleryPage.verifyOnlineBehavior();
    });

    group('Performance Tests', () {
      testWidgets('App animations run smoothly', (tester) async {
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // Test animation performance
        await homePage.testAnimationPerformance();
      });

      testWidgets('Page transitions are smooth', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        
        await tester.pumpAndSettle();
        
        // Test navigation performance
        final stopwatch = Stopwatch()..start();
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        stopwatch.stop();
        
        // Assert navigation takes less than 2 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Screen reader accessibility works', (tester) async {
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // Test semantic labels and accessibility
        await homePage.verifyAccessibilityLabels();
      });

      testWidgets('Keyboard navigation works', (tester) async {
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // Test keyboard navigation
        await homePage.testKeyboardNavigation();
      });
    });
  });
}