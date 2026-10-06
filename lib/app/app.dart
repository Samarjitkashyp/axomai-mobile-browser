import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/app/router.dart';
import 'package:axomai_browser_mobile/core/constants/app_constants.dart';
import 'package:axomai_browser_mobile/core/localization/locale_controller.dart';
import 'package:axomai_browser_mobile/core/theme/app_theme.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Root application widget configuring Theme, Router, and Riverpod.
class AxomaiApp extends ConsumerWidget {
  const AxomaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeControllerProvider);
    final selectedLocale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(
        themeType: themeState.themeType,
        brightness: Brightness.light,
        locale: selectedLocale,
      ),
      darkTheme: AppTheme.buildTheme(
        themeType: themeState.themeType,
        brightness: Brightness.dark,
        locale: selectedLocale,
      ),
      themeMode: themeState.themeMode,
      locale: selectedLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
