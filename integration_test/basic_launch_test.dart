import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zaza_dance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Zaza Dance - Basic Launch Tests', () {
    
    testWidgets('App launches and shows MaterialApp', (tester) async {
      print('🚀 Starting app launch test...');
      
      // Launch the app
      app.main();
      
      // Give the app time to initialize
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify MaterialApp exists
      expect(find.byType(MaterialApp), findsOneWidget);
      
      print('✅ MaterialApp found successfully!');
    });

    testWidgets('App shows navigation structure', (tester) async {
      print('🧭 Testing navigation structure...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Look for bottom navigation or drawer - basic navigation elements
      final bottomNav = find.byType(BottomNavigationBar);
      final drawer = find.byType(Drawer);
      final appBar = find.byType(AppBar);
      
      // At least one navigation element should exist
      expect(
        bottomNav.evaluate().isNotEmpty || 
        drawer.evaluate().isNotEmpty || 
        appBar.evaluate().isNotEmpty,
        isTrue,
        reason: 'Expected to find at least one navigation element'
      );
      
      print('✅ Navigation structure found!');
    });

    testWidgets('App displays Hebrew text correctly', (tester) async {
      print('🇮🇱 Testing Hebrew text display...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Look for Hebrew text - try to find any Hebrew content
      final hebrewTexts = [
        find.textContaining('זזה'),
        find.textContaining('דאנס'),
        find.textContaining('ברוכים'),
        find.textContaining('שיעורים'),
        find.textContaining('גלריה'),
      ];
      
      // Should find at least one Hebrew text
      bool foundHebrew = false;
      for (final finder in hebrewTexts) {
        if (finder.evaluate().isNotEmpty) {
          foundHebrew = true;
          break;
        }
      }
      
      expect(foundHebrew, isTrue, reason: 'Expected to find Hebrew text');
      
      print('✅ Hebrew text displayed successfully!');
    });

    testWidgets('App handles basic interactions', (tester) async {
      print('👆 Testing basic interactions...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Try to find any tappable element
      final buttonTypes = [
        find.byType(ElevatedButton),
        find.byType(TextButton),
        find.byType(IconButton),
        find.byType(FloatingActionButton),
        find.byType(InkWell),
        find.byType(GestureDetector),
      ];
      
      Finder? firstButton;
      for (final buttonType in buttonTypes) {
        if (buttonType.evaluate().isNotEmpty) {
          firstButton = buttonType;
          break;
        }
      }
      
      if (firstButton != null) {
        // Try tapping the first button/interactive element
        await tester.tap(firstButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        print('✅ Basic interaction successful!');
      } else {
        print('ℹ️ No interactive elements found, but app is stable');
      }
    });

    testWidgets('App theme displays correctly', (tester) async {
      print('🎨 Testing app theme...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Check for theme elements
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify theme is set
      expect(materialApp.theme, isNotNull);
      
      print('✅ App theme loaded successfully!');
    });

    testWidgets('App performance is acceptable', (tester) async {
      print('⚡ Testing app performance...');
      
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      // App should launch within reasonable time (15 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(15000));
      
      print('✅ App launch performance acceptable: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('App survives orientation change', (tester) async {
      print('🔄 Testing orientation change...');
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Get current size
      final currentSize = tester.view.physicalSize;
      
      // Simulate orientation change by changing screen size
      tester.view.physicalSize = Size(currentSize.height, currentSize.width);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify app still has MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Restore original size
      tester.view.physicalSize = currentSize;
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      print('✅ App handles orientation change successfully!');
    });

  });
}