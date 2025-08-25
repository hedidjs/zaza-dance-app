import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zaza_dance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple Integration Tests', () {
    testWidgets('App launches without crashing', (tester) async {
      try {
        // Launch the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        // Just verify the app launched - look for any widget
        expect(find.byType(MaterialApp), findsOneWidget);
        
        print('✅ App launched successfully!');
      } catch (e) {
        print('❌ App launch failed: $e');
        rethrow;
      }
    });

    testWidgets('App shows some content after launch', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        
        // Look for any text widget to ensure UI is rendered
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);
        
        print('✅ App shows content successfully!');
      } catch (e) {
        print('❌ Content display failed: $e');
        rethrow;
      }
    });
  });
}