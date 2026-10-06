import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/privacy/controllers/privacy_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/presentation/widgets/clear_data_dialog.dart';

/// Interactive Privacy Shield bottom sheet providing per-site protection controls.
class PrivacyShieldSheet extends ConsumerWidget {
  final String currentUrl;

  const PrivacyShieldSheet({super.key, required this.currentUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final privacyState = ref.watch(privacyControllerProvider);
    final privacyNotifier = ref.read(privacyControllerProvider.notifier);

    final isWhitelisted = privacyNotifier.isOriginWhitelisted(currentUrl);
    final isShieldActive =
        privacyState.settings.adBlockEnabled && !isWhitelisted;
    final isHttps = currentUrl.startsWith('https://');

    String host = 'Current Website';
    try {
      final uri = Uri.parse(currentUrl);
      if (uri.host.isNotEmpty) host = uri.host;
    } catch (_) {}

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isShieldActive
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isShieldActive
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: isShieldActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Axomai Privacy Shield',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statistics Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.block_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${privacyState.pageBlockedCount} Trackers & Ads Blocked on this page',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Per-site Protection Switch
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enhanced Protection for this site'),
              subtitle: Text(
                isShieldActive
                    ? 'Blocking known ad networks & tracking telemetry.'
                    : 'Protections paused for this site.',
              ),
              value: isShieldActive,
              onChanged: (_) => privacyNotifier.toggleSiteWhitelist(currentUrl),
            ),
            const Divider(),

            // Connection Security
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isHttps ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: isHttps
                    ? const Color(0xFF2E7D32)
                    : theme.colorScheme.error,
              ),
              title: Text(
                isHttps ? 'Secure Connection' : 'Not Secure (HTTP)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isHttps
                    ? 'Your connection to $host is encrypted.'
                    : 'Information you submit may be visible to network observers.',
              ),
            ),
            const Divider(),

            // Clear Browsing Data Shortcut
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear Browsing Data'),
              subtitle: const Text('Wipe cookies, cache, and history'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (ctx) => const ClearDataDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
