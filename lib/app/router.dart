import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/browser_screen.dart';
import 'package:axomai_browser_mobile/features/settings/presentation/settings_screen.dart';
import 'package:axomai_browser_mobile/features/tabs/presentation/tab_switcher_screen.dart';

/// Provider for application routing configuration.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const BrowserScreen(),
      ),
      GoRoute(
        path: '/tabs',
        name: 'tabs',
        builder: (context, state) => const TabSwitcherScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
