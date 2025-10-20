// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App boots to Dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ProviderScope(child: AppRoot()));

    // Avoid pumpAndSettle since there may be perpetual animations.
    bool found = false;
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Pesândinho').evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    expect(found, isTrue, reason: 'Dashboard title not found after waiting.');
  });
}
