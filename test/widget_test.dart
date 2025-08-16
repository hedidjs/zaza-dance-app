// Basic widget test for Zaza Dance app

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zaza_dance/main.dart';

void main() {
  testWidgets('Zaza Dance app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ZazaDanceApp()));

    // Wait for initial render
    await tester.pump();

    // Verify that the app has basic structure (looking for MaterialApp)
    expect(tester.allWidgets.any((widget) => widget.runtimeType.toString().contains('Material')), isTrue);
  });
}
