import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/library/presentation/widgets/bookmarks_tab_view.dart';
import 'package:axomai_browser_mobile/features/library/presentation/widgets/downloads_tab_view.dart';
import 'package:axomai_browser_mobile/features/library/presentation/widgets/history_tab_view.dart';

/// Unified Library screen holding Bookmarks, History, and Downloads.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Library',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bookmark_outline), text: 'Bookmarks'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(
                icon: Icon(Icons.download_for_offline_outlined),
                text: 'Downloads',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [BookmarksTabView(), HistoryTabView(), DownloadsTabView()],
        ),
      ),
    );
  }
}
