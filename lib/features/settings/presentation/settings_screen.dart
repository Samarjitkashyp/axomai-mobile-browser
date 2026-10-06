import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/core/constants/app_constants.dart';
import 'package:axomai_browser_mobile/core/localization/locale_controller.dart';
import 'package:axomai_browser_mobile/core/theme/app_theme_type.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/search_engine_controller.dart';
import 'package:axomai_browser_mobile/features/browser/domain/search_engine.dart';
import 'package:axomai_browser_mobile/features/privacy/controllers/privacy_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/presentation/widgets/clear_data_dialog.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Settings screen allowing theme, language, and search engine customization.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final currentLocale = ref.watch(localeControllerProvider);
    final currentSearchEngine = ref.watch(searchEngineControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settings ?? 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildSectionHeader(
            theme,
            Icons.palette_outlined,
            l10n?.appearance ?? 'Appearance',
          ),
          const SizedBox(height: 12),
          _buildThemeModeSelector(context, ref, themeState, l10n),
          const SizedBox(height: 16),
          Text(
            l10n?.theme ?? 'Theme Preset',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildThemePresetsGrid(ref, themeState),
          const SizedBox(height: 24),
          _buildSectionHeader(theme, Icons.search, 'Search Engine'),
          const SizedBox(height: 12),
          _buildSearchEngineSelector(context, ref, currentSearchEngine),
          const SizedBox(height: 24),
          _buildSectionHeader(
            theme,
            Icons.language_outlined,
            l10n?.language ?? 'Language',
          ),
          const SizedBox(height: 12),
          _buildLanguageSelector(context, ref, currentLocale),
          const SizedBox(height: 24),
          _buildSectionHeader(
            theme,
            Icons.shield_outlined,
            'Privacy & Security',
          ),
          const SizedBox(height: 12),
          _buildPrivacyControls(context, ref),
          const SizedBox(height: 24),
          _buildSectionHeader(
            theme,
            Icons.info_outline,
            l10n?.about ?? 'About',
          ),
          const SizedBox(height: 12),
          _buildAboutCard(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: <Widget>[
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
    AppLocalizations? l10n,
  ) {
    return SegmentedButton<ThemeMode>(
      segments: <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          icon: const Icon(Icons.brightness_auto),
          label: Text(l10n?.themeModeSystem ?? 'System'),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode_outlined),
          label: Text(l10n?.themeModeLight ?? 'Light'),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          icon: const Icon(Icons.dark_mode_outlined),
          label: Text(l10n?.themeModeDark ?? 'Dark'),
        ),
      ],
      selected: <ThemeMode>{themeState.themeMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        ref
            .read(themeControllerProvider.notifier)
            .setThemeMode(newSelection.first);
      },
    );
  }

  Widget _buildThemePresetsGrid(WidgetRef ref, ThemeState themeState) {
    return Column(
      children: AppThemeType.values.map((type) {
        final isSelected = themeState.themeType == type;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {
              ref.read(themeControllerProvider.notifier).setThemeType(type);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? type.primaryColor
                      : Colors.grey.withAlpha(50),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [type.primaryColor, type.secondaryColor],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      type.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: type.primaryColor),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchEngineSelector(
    BuildContext context,
    WidgetRef ref,
    SearchEngine currentEngine,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: SearchEngine.values.map((engine) {
          final isSelected = currentEngine == engine;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            title: Text(
              engine.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              ref
                  .read(searchEngineControllerProvider.notifier)
                  .setSearchEngine(engine);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
  ) {
    final activeCode =
        currentLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: SupportedLocales.all.map((locale) {
          final isSelected = activeCode == locale.languageCode;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            title: Text(
              SupportedLocales.getNativeName(locale.languageCode),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(Locale(locale.languageCode));
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrivacyControls(BuildContext context, WidgetRef ref) {
    final privacyState = ref.watch(privacyControllerProvider);
    final privacyNotifier = ref.read(privacyControllerProvider.notifier);

    return Card(
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Block Advertisements'),
            subtitle: const Text('Block known advertising networks'),
            value: privacyState.settings.adBlockEnabled,
            onChanged: (val) => privacyNotifier.toggleAdBlock(val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Block Tracking Telemetry'),
            subtitle: const Text('Prevent behavioural tracking and analytics'),
            value: privacyState.settings.trackerBlockEnabled,
            onChanged: (val) => privacyNotifier.toggleTrackerBlock(val),
          ),
          SwitchListTile.adaptive(
            title: const Text('HTTPS-Only Mode'),
            subtitle: const Text(
              'Automatically upgrade all connections to HTTPS',
            ),
            value: privacyState.settings.httpsOnlyMode,
            onChanged: (val) => privacyNotifier.toggleHttpsOnly(val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Block Third-Party Cookies'),
            subtitle: const Text('Stop cross-site cookie tracking'),
            value: privacyState.settings.blockThirdPartyCookies,
            onChanged: (val) => privacyNotifier.toggleThirdPartyCookies(val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Block Pop-up Windows'),
            subtitle: const Text('Prevent unwanted intrusive popups'),
            value: privacyState.settings.blockPopups,
            onChanged: (val) => privacyNotifier.togglePopups(val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: const Text(
              'Clear Browsing Data',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Delete history, cookies, and cache'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => const ClearDataDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/axomai_logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.explore_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n?.version ?? 'Version'} ${AppConstants.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'No trackers • 100% Privacy',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
