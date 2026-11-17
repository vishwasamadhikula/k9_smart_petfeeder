import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// This imports your main app code. 
// If your project name is NOT 'k9_smart', change this line to match your project name.
import 'package:k9_smart/main.dart';

void main() {
  testWidgets('K9 Smart App smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // We changed 'MyApp' to 'K9SmartApp' to match your main.dart
    await tester.pumpWidget(const K9SmartApp());

    // 2. Simple Verify: Check if the AppBar title exists.
    // This confirms the app started and loaded the home page.
    expect(find.text('K9 Smart Dashboard'), findsOneWidget);
  });
}