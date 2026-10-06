import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:axomai_browser_mobile/app/app.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/address_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/browser_navigation_bar.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/library/data/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('Axomai Browser initializes with AddressBar and NavigationBar', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dbHelper = DatabaseHelper(factory: databaseFactoryFfi);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseHelperProvider.overrideWithValue(dbHelper),
        ],
        child: const AxomaiApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AddressBar and Bottom Navigation Bar are present
    expect(find.byType(AddressBar), findsOneWidget);
    expect(find.byType(BrowserNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsWidgets);
    expect(find.byIcon(Icons.collections_bookmark_outlined), findsOneWidget);
  });
}
