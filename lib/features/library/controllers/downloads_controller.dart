import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/library/data/database_helper.dart';
import 'package:axomai_browser_mobile/features/library/domain/download_item.dart';

/// State representation for Downloads.
class DownloadsState {
  final List<DownloadItem> items;
  final bool isLoading;

  const DownloadsState({this.items = const [], this.isLoading = false});

  DownloadsState copyWith({List<DownloadItem>? items, bool? isLoading}) {
    return DownloadsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller managing downloaded items.
class DownloadsNotifier extends StateNotifier<DownloadsState> {
  final DatabaseHelper _dbHelper;

  DownloadsNotifier(this._dbHelper) : super(const DownloadsState()) {
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    state = state.copyWith(isLoading: true);
    final downloads = await _dbHelper.getAllDownloads();
    state = state.copyWith(items: downloads, isLoading: false);
  }

  Future<void> addDownload({
    required String fileName,
    required String url,
    required String filePath,
    required int fileSize,
  }) async {
    final item = DownloadItem(
      fileName: fileName,
      url: url,
      filePath: filePath,
      fileSize: fileSize,
      createdAt: DateTime.now(),
    );
    await _dbHelper.insertDownload(item);
    await loadDownloads();
  }

  Future<void> deleteDownload(int id) async {
    await _dbHelper.deleteDownload(id);
    await loadDownloads();
  }
}

/// Provider exposing Downloads state.
final downloadsControllerProvider =
    StateNotifierProvider<DownloadsNotifier, DownloadsState>((ref) {
      final dbHelper = ref.watch(databaseHelperProvider);
      return DownloadsNotifier(dbHelper);
    });
