import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hyprmenu/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HyprMenuApp());

    // Verify that the app builds.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
