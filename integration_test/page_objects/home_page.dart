import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class HomePage {
  final WidgetTester tester;

  HomePage(this.tester);

  // Finders for home page elements
  Finder get homeScreen => find.byKey(const Key('home_screen'));
  Finder get appLogo => find.byKey(const Key('zaza_logo'));
  Finder get navigationBar => find.byType(BottomNavigationBar);
  Finder get homeNavItem => find.byKey(const Key('nav_home'));
  Finder get galleryNavItem => find.byKey(const Key('nav_gallery'));
  Finder get tutorialsNavItem => find.byKey(const Key('nav_tutorials'));
  Finder get updatesNavItem => find.byKey(const Key('nav_updates'));
  Finder get profileNavItem => find.byKey(const Key('nav_profile'));
  
  // Content finders
  Finder get welcomeText => find.textContaining('ברוכים הבאים');
  Finder get featuredContent => find.byKey(const Key('featured_content'));
  Finder get quickActions => find.byKey(const Key('quick_actions'));
  
  // Theme verification finders
  Finder get darkBackground => find.byKey(const Key('dark_background'));
  Finder get neonText => find.byKey(const Key('neon_text'));
  Finder get gradientBackground => find.byKey(const Key('gradient_background'));

  /// Verify that the home screen is displayed
  Future<void> verifyHomeScreenIsDisplayed() async {
    expect(homeScreen, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Verify navigation bar is present and has correct items
  Future<void> verifyNavigationBarIsPresent() async {
    expect(navigationBar, findsOneWidget);
    expect(homeNavItem, findsOneWidget);
    expect(galleryNavItem, findsOneWidget);
    expect(tutorialsNavItem, findsOneWidget);
    expect(updatesNavItem, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Verify app logo is visible
  Future<void> verifyAppLogoIsVisible() async {
    expect(appLogo, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Navigate to gallery page
  Future<void> navigateToGallery() async {
    await tester.tap(galleryNavItem);
    await tester.pumpAndSettle();
  }

  /// Navigate to tutorials page
  Future<void> navigateToTutorials() async {
    await tester.tap(tutorialsNavItem);
    await tester.pumpAndSettle();
  }

  /// Navigate to updates page
  Future<void> navigateToUpdates() async {
    await tester.tap(updatesNavItem);
    await tester.pumpAndSettle();
  }

  /// Navigate to profile page
  Future<void> navigateToProfile() async {
    await tester.tap(profileNavItem);
    await tester.pumpAndSettle();
  }

  /// Navigate back to home page
  Future<void> navigateToHome() async {
    await tester.tap(homeNavItem);
    await tester.pumpAndSettle();
  }

  /// Verify RTL layout is working correctly
  Future<void> verifyRTLLayout() async {
    // Check if text direction is RTL
    final directionality = tester.widget<Directionality>(
      find.ancestor(
        of: find.byType(MaterialApp),
        matching: find.byType(Directionality),
      ),
    );
    expect(directionality.textDirection, TextDirection.rtl);
    await tester.pumpAndSettle();
  }

  /// Verify Hebrew text displays correctly
  Future<void> verifyHebrewTextDisplays() async {
    // Check for Hebrew text elements
    expect(find.textContaining('זזה'), findsWidgets);
    await tester.pumpAndSettle();
  }

  /// Verify dark theme is active
  Future<void> verifyDarkThemeIsActive() async {
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.brightness, Brightness.dark);
    await tester.pumpAndSettle();
  }

  /// Verify neon effects are visible
  Future<void> verifyNeonEffectsAreVisible() async {
    // Look for widgets with glow effects
    expect(find.byKey(const Key('neon_glow')), findsWidgets);
    await tester.pumpAndSettle();
  }

  /// Test animation performance
  Future<void> testAnimationPerformance() async {
    // Trigger animations and measure performance
    final stopwatch = Stopwatch()..start();
    
    // Trigger page transition animation
    await navigateToGallery();
    await navigateToHome();
    
    stopwatch.stop();
    
    // Assert that animations complete within reasonable time
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
  }

  /// Verify accessibility labels are present
  Future<void> verifyAccessibilityLabels() async {
    // Check semantic labels
    expect(find.bySemanticsLabel('דף הבית'), findsWidgets);
    expect(find.bySemanticsLabel('גלריה'), findsWidgets);
    expect(find.bySemanticsLabel('שיעורים'), findsWidgets);
    await tester.pumpAndSettle();
  }

  /// Test keyboard navigation
  Future<void> testKeyboardNavigation() async {
    // Focus on navigation items and test keyboard navigation
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
  }

  /// Verify featured content is displayed
  Future<void> verifyFeaturedContentIsDisplayed() async {
    expect(featuredContent, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Verify quick actions are available
  Future<void> verifyQuickActionsAreAvailable() async {
    expect(quickActions, findsOneWidget);
    await tester.pumpAndSettle();
  }

  /// Scroll to see more content
  Future<void> scrollToSeeMoreContent() async {
    await tester.drag(homeScreen, const Offset(0, -300));
    await tester.pumpAndSettle();
  }

  /// Test pull to refresh functionality
  Future<void> testPullToRefresh() async {
    await tester.drag(homeScreen, const Offset(0, 300));
    await tester.pumpAndSettle();
    
    // Verify refresh indicator appeared and content reloaded
    expect(find.byType(RefreshIndicator), findsOneWidget);
  }

  /// Verify app drawer can be opened
  Future<void> verifyAppDrawerCanBeOpened() async {
    // Look for drawer button
    final drawerButton = find.byIcon(Icons.menu);
    if (drawerButton.evaluate().isNotEmpty) {
      await tester.tap(drawerButton);
      await tester.pumpAndSettle();
      
      // Verify drawer is open
      expect(find.byType(Drawer), findsOneWidget);
      
      // Close drawer
      await tester.tapAt(const Offset(50, 300));
      await tester.pumpAndSettle();
    }
  }

  /// Verify search functionality if available
  Future<void> verifySearchFunctionality() async {
    final searchButton = find.byIcon(Icons.search);
    if (searchButton.evaluate().isNotEmpty) {
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      
      // Enter search term
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'ריקוד');
        await tester.pumpAndSettle();
        
        // Verify search results
        expect(find.textContaining('ריקוד'), findsWidgets);
      }
    }
  }
}