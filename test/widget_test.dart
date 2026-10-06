import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/app/app.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/address_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/browser_navigation_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Axomai Browser initializes with AddressBar and NavigationBar', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AxomaiApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AddressBar and Bottom Navigation Bar are present
    expect(find.byType(AddressBar), findsOneWidget);
    expect(find.byType(BrowserNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsWidgets);
  });
}
