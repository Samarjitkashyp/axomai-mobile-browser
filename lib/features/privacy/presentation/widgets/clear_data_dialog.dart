import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/library/controllers/history_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/controllers/privacy_controller.dart';

/// Dialog allowing granular selection of browsing data to wipe.
class ClearDataDialog extends ConsumerStatefulWidget {
  const ClearDataDialog({super.key});

  @override
  ConsumerState<ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends ConsumerState<ClearDataDialog> {
  bool _clearHistory = true;
  bool _clearCookies = true;
  bool _clearCache = true;
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.delete_sweep_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Clear Browsing Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: _clearHistory,
            title: const Text('Browsing History'),
            subtitle: const Text('Clears all recorded page visits'),
            onChanged: (val) => setState(() => _clearHistory = val ?? true),
          ),
          CheckboxListTile(
            value: _clearCookies,
            title: const Text('Cookies & Site Data'),
            subtitle: const Text('Signs you out of most websites'),
            onChanged: (val) => setState(() => _clearCookies = val ?? true),
          ),
          CheckboxListTile(
            value: _clearCache,
            title: const Text('Cached Images & Files'),
            subtitle: const Text('Frees up device storage'),
            onChanged: (val) => setState(() => _clearCache = val ?? true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isClearing ? null : _performClear,
          child: _isClearing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Clear Data'),
        ),
      ],
    );
  }

  Future<void> _performClear() async {
    setState(() => _isClearing = true);

    if (_clearHistory) {
      await ref.read(historyControllerProvider.notifier).clearAllHistory();
    }

    await ref
        .read(privacyControllerProvider.notifier)
        .clearBrowsingData(
          clearCache: _clearCache,
          clearCookies: _clearCookies,
          clearStorage: _clearCookies,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected browsing data cleared successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
