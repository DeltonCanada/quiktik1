import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiktik1/utils/error_handler.dart';

void main() {
  group('Error Handler Tests', () {
    testWidgets('ErrorDialog renders correctly', (WidgetTester tester) async {
      const testTitle = 'Test Error';
      const testMessage = 'Test error message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDialog(
              title: testTitle,
              message: testMessage,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    test('QuikTikErrorHandler singleton', () {
      final handler1 = QuikTikErrorHandler();
      final handler2 = QuikTikErrorHandler();
      expect(handler1, same(handler2));
    });
  });
}
