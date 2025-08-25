import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zaza_dance/main.dart' as app;

import 'helpers/test_helper.dart';
import 'page_objects/home_page.dart';
import 'page_objects/auth_page.dart';
import 'page_objects/gallery_page.dart';
import 'page_objects/tutorials_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Journey Tests', () {
    late TestHelper testHelper;
    late HomePage homePage;
    late AuthPage authPage;
    late GalleryPage galleryPage;
    late TutorialsPage tutorialsPage;

    setUpAll(() async {
      testHelper = TestHelper();
      await testHelper.setupTestEnvironment();
    });

    setUp(() async {
      app.main();
      await Future.delayed(const Duration(seconds: 2));
    });

    tearDown(() async {
      await testHelper.cleanup();
    });

    group('New User Journey', () {
      testWidgets('New user can explore app without authentication', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. User opens app and sees home screen
        await homePage.verifyHomeScreenIsDisplayed();
        await homePage.verifyAppLogoIsVisible();
        
        // 2. User explores the gallery
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        await galleryPage.waitForContentToLoad();
        await galleryPage.verifyMediaItemsAreVisible();
        
        // 3. User browses tutorials
        await homePage.navigateToTutorials();
        await tutorialsPage.verifyTutorialsPageIsDisplayed();
        await tutorialsPage.waitForTutorialsToLoad();
        await tutorialsPage.verifyTutorialItemsAreVisible();
        
        // 4. User returns to home
        await homePage.navigateToHome();
        await homePage.verifyHomeScreenIsDisplayed();
      });

      testWidgets('New user can register and access full features', (tester) async {
        authPage = AuthPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Navigate to registration
        await homePage.navigateToProfile();
        await authPage.navigateToRegister();
        
        // 2. Register new user
        await authPage.testValidRegistration();
        
        // 3. Verify access to authenticated features
        await homePage.verifyHomeScreenIsDisplayed();
        await homePage.verifyFeaturedContentIsDisplayed();
      });
    });

    group('Returning User Journey', () {
      testWidgets('Returning user can login and access personalized content', (tester) async {
        authPage = AuthPage(tester);
        homePage = HomePage(tester);
        tutorialsPage = TutorialsPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. User logs in
        await homePage.navigateToProfile();
        await authPage.testValidLogin();
        
        // 2. User sees personalized home content
        await homePage.navigateToHome();
        await homePage.verifyHomeScreenIsDisplayed();
        await homePage.verifyFeaturedContentIsDisplayed();
        
        // 3. User accesses favorite tutorials
        await homePage.navigateToTutorials();
        await tutorialsPage.verifyTutorialsPageIsDisplayed();
        await tutorialsPage.testFavoriteFunctionality();
        
        // 4. User continues previous tutorial
        await tutorialsPage.testTutorialProgressTracking();
      });

      testWidgets('User can manage profile and settings', (tester) async {
        authPage = AuthPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Login and navigate to profile
        await homePage.navigateToProfile();
        await authPage.testValidLogin();
        await authPage.testProfileViewing();
        
        // 2. Edit profile information
        await authPage.testProfileEditing();
        
        // 3. Change password
        await authPage.testPasswordChange();
        
        // 4. Update profile image
        await authPage.testProfileImageUpload();
      });
    });

    group('Content Consumption Journey', () {
      testWidgets('User browses and watches video content', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Browse gallery videos
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        await galleryPage.waitForContentToLoad();
        
        // 2. Watch a video
        await galleryPage.testVideoPlayback();
        await galleryPage.testFullscreenVideoPlayback();
        
        // 3. Share video content
        await galleryPage.testShareFunctionality();
        
        // 4. Browse tutorial videos
        await homePage.navigateToTutorials();
        await tutorialsPage.testTutorialVideoPlayback();
        await tutorialsPage.testVideoControls();
      });

      testWidgets('User filters and searches for specific content', (tester) async {
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Filter gallery by category
        await homePage.navigateToGallery();
        await galleryPage.testCategoryFiltering();
        
        // 2. Filter by media type
        await galleryPage.testMediaTypeFiltering();
        
        // 3. Search gallery content
        await galleryPage.testSearchFunctionality();
        
        // 4. Filter tutorials by difficulty
        await homePage.navigateToTutorials();
        await tutorialsPage.testDifficultyFiltering();
        
        // 5. Search tutorials
        await tutorialsPage.testSearchFunctionality();
      });
    });

    group('Learning Journey', () {
      testWidgets('User follows a complete learning path', (tester) async {
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Start with beginner tutorials
        await homePage.navigateToTutorials();
        await tutorialsPage.testDifficultyFiltering();
        
        // 2. Watch tutorial and track progress
        await tutorialsPage.testTutorialVideoPlayback();
        await tutorialsPage.testTutorialProgressTracking();
        
        // 3. Mark tutorial as favorite
        await tutorialsPage.testFavoriteFunctionality();
        
        // 4. Complete tutorial
        await tutorialsPage.testTutorialCompletionTracking();
        
        // 5. Download for offline viewing
        await tutorialsPage.testTutorialDownload();
      });

      testWidgets('User practices with video controls', (tester) async {
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Open tutorial
        await homePage.navigateToTutorials();
        await tutorialsPage.verifyTutorialItemsAreVisible();
        
        // 2. Use playback speed controls for practice
        await tutorialsPage.testPlaybackSpeedControl();
        
        // 3. Use video quality settings
        await tutorialsPage.testVideoQualitySelection();
        
        // 4. Practice with repeat playback
        await tutorialsPage.testContinuousPlayback();
      });
    });

    group('Offline Usage Journey', () {
      testWidgets('User downloads content for offline use', (tester) async {
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Download gallery content
        await homePage.navigateToGallery();
        await galleryPage.testDownloadFunctionality();
        
        // 2. Download tutorials
        await homePage.navigateToTutorials();
        await tutorialsPage.testTutorialDownload();
        
        // 3. Simulate offline mode
        await testHelper.simulateOfflineMode();
        
        // 4. Access offline content
        await tutorialsPage.testOfflineTutorialAccess();
        await galleryPage.verifyOfflineBehavior();
        
        // 5. Return to online mode
        await testHelper.simulateOnlineMode();
        await galleryPage.verifyOnlineBehavior();
      });
    });

    group('Social Interaction Journey', () {
      testWidgets('User shares and interacts with content', (tester) async {
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Share gallery content
        await homePage.navigateToGallery();
        await galleryPage.testShareFunctionality();
        
        // 2. Share tutorial
        await homePage.navigateToTutorials();
        await tutorialsPage.testTutorialSharing();
        
        // 3. Interact with favorites
        await tutorialsPage.testFavoriteFunctionality();
      });
    });

    group('Error Recovery Journey', () {
      testWidgets('User handles network issues gracefully', (tester) async {
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Start browsing content
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        
        // 2. Simulate network issue
        await testHelper.simulateOfflineMode();
        
        // 3. Verify error handling
        await galleryPage.verifyErrorHandling();
        
        // 4. Restore network and retry
        await testHelper.simulateOnlineMode();
        await galleryPage.verifyOnlineBehavior();
      });

      testWidgets('User recovers from authentication errors', (tester) async {
        authPage = AuthPage(tester);
        homePage = HomePage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Attempt login with invalid credentials
        await homePage.navigateToProfile();
        await authPage.testInvalidLogin();
        
        // 2. Verify error handling
        await authPage.verifyErrorHandling();
        
        // 3. Successfully login with correct credentials
        await authPage.testValidLogin();
        
        // 4. Verify successful authentication
        await authPage.testProfileViewing();
      });
    });

    group('Accessibility Journey', () {
      testWidgets('User navigates app using accessibility features', (tester) async {
        homePage = HomePage(tester);
        authPage = AuthPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Test keyboard navigation
        await homePage.testKeyboardNavigation();
        
        // 2. Test screen reader compatibility
        await homePage.verifyAccessibilityLabels();
        
        // 3. Test authentication accessibility
        await homePage.navigateToProfile();
        await authPage.testAccessibilityFeatures();
      });
    });

    group('Performance Journey', () {
      testWidgets('User experiences smooth performance throughout app', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Test home screen performance
        await homePage.testAnimationPerformance();
        
        // 2. Test navigation performance
        final stopwatch = Stopwatch()..start();
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        
        // 3. Test content loading performance
        await galleryPage.waitForContentToLoad();
        await galleryPage.testInfiniteScrollLoading();
      });
    });

    group('RTL and Localization Journey', () {
      testWidgets('Hebrew user navigates RTL interface correctly', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        tutorialsPage = TutorialsPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Verify RTL layout
        await homePage.verifyRTLLayout();
        await homePage.verifyHebrewTextDisplays();
        
        // 2. Test RTL navigation
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        
        // 3. Test Hebrew content display
        await homePage.navigateToTutorials();
        await tutorialsPage.verifyTutorialsPageIsDisplayed();
        
        // 4. Verify Hebrew search functionality
        await tutorialsPage.testSearchFunctionality();
      });
    });

    group('Theme and Visual Journey', () {
      testWidgets('User experiences consistent dark theme with neon effects', (tester) async {
        homePage = HomePage(tester);
        galleryPage = GalleryPage(tester);
        
        await tester.pumpAndSettle();
        
        // 1. Verify dark theme on home
        await homePage.verifyDarkThemeIsActive();
        await homePage.verifyNeonEffectsAreVisible();
        
        // 2. Verify theme consistency across pages
        await homePage.navigateToGallery();
        await galleryPage.verifyGalleryPageIsDisplayed();
        
        // Theme should be consistent
        await homePage.verifyDarkThemeIsActive();
      });
    });
  });
}