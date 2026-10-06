import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/app/app.dart';
import 'package:axomai_browser_mobile/core/constants/app_constants.dart';

void main() {
  testWidgets('Axomai Browser initializes and shows welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AxomaiApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(
      find.text('Welcome to ${AppConstants.appName}'),
      findsOneWidget,
    );
  });
}
