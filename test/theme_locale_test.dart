import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/app/app.dart';
import 'package:axomai_browser_mobile/core/theme/app_theme_type.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/core/localization/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('ThemeNotifier changes and persists theme type and mode', () async {
    final notifier = ThemeNotifier(prefs);

    expect(notifier.state.themeType, AppThemeType.teaGarden);
    expect(notifier.state.themeMode, ThemeMode.system);

    await notifier.setThemeType(AppThemeType.gamosaCrimson);
    expect(notifier.state.themeType, AppThemeType.gamosaCrimson);
    expect(prefs.getString('axomai_theme_type'), 'gamosaCrimson');

    await notifier.setThemeMode(ThemeMode.dark);
    expect(notifier.state.themeMode, ThemeMode.dark);
    expect(prefs.getString('axomai_theme_mode'), 'dark');
  });

  test('LocaleNotifier changes and persists locale', () async {
    final notifier = LocaleNotifier(prefs);

    expect(notifier.state, isNull);

    await notifier.setLocale(const Locale('hi'));
    expect(notifier.state?.languageCode, 'hi');
    expect(prefs.getString('axomai_selected_locale'), 'hi');

    await notifier.setLocale(const Locale('as'));
    expect(notifier.state?.languageCode, 'as');
    expect(prefs.getString('axomai_selected_locale'), 'as');
  });

  testWidgets('Settings screen renders theme and language options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const AxomaiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on settings button
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify theme presets are visible
    expect(find.text('Tea Garden'), findsOneWidget);
    expect(find.text('Gamosa Crimson'), findsOneWidget);
    expect(find.text('Obsidian Dark Glass'), findsOneWidget);

    // Verify languages are visible
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी (Hindi)'), findsOneWidget);
    expect(find.text('অসমীয়া (Assamese)'), findsOneWidget);
  });
}
