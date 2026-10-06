import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/reader/data/reader_extractor.dart';
import 'package:axomai_browser_mobile/features/reader/data/reader_repository.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_article.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_settings.dart';

class ReaderState {
  final ReaderArticle? article;
  final bool isReaderOpen;
  final bool isLoading;
  final ReaderSettings settings;

  const ReaderState({
    this.article,
    this.isReaderOpen = false,
    this.isLoading = false,
    this.settings = const ReaderSettings(),
  });

  ReaderState copyWith({
    ReaderArticle? article,
    bool? isReaderOpen,
    bool? isLoading,
    ReaderSettings? settings,
  }) {
    return ReaderState(
      article: article ?? this.article,
      isReaderOpen: isReaderOpen ?? this.isReaderOpen,
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
    );
  }
}

final readerRepositoryProvider = Provider<ReaderRepository>((ref) {
  return ReaderRepository();
});

final readerControllerProvider =
    StateNotifierProvider<ReaderController, ReaderState>((ref) {
      final repo = ref.watch(readerRepositoryProvider);
      return ReaderController(repo);
    });

class ReaderController extends StateNotifier<ReaderState> {
  final ReaderRepository _repository;

  ReaderController(this._repository) : super(const ReaderState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.getSettings();
    state = state.copyWith(settings: settings);
  }

  Future<bool> openReader(
    InAppWebViewController? webController, {
    String? fallbackTitle,
    String? fallbackUrl,
  }) async {
    state = state.copyWith(isLoading: true);

    ReaderArticle? article = await ReaderExtractor.extractFromWebView(
      webController,
    );

    if (article == null && fallbackTitle != null && fallbackUrl != null) {
      article = ReaderArticle(
        title: fallbackTitle,
        contentHtml:
            '<p>Unable to extract article text automatically from this page. You can view the original page directly.</p>',
        textContent:
            'Unable to extract article text automatically from this page.',
        url: fallbackUrl,
        extractedAt: DateTime.now(),
      );
    }

    if (article != null) {
      state = state.copyWith(
        article: article,
        isReaderOpen: true,
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  void closeReader() {
    state = state.copyWith(isReaderOpen: false);
  }

  Future<void> updateSettings(ReaderSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _repository.saveSettings(newSettings);
  }

  Future<void> setTheme(ReaderTheme theme) async {
    await updateSettings(state.settings.copyWith(theme: theme));
  }

  Future<void> setFontFamily(ReaderFontFamily family) async {
    await updateSettings(state.settings.copyWith(fontFamily: family));
  }

  Future<void> increaseFontSize() async {
    final newSize = (state.settings.fontSize + 2).clamp(12.0, 32.0);
    await updateSettings(state.settings.copyWith(fontSize: newSize));
  }

  Future<void> decreaseFontSize() async {
    final newSize = (state.settings.fontSize - 2).clamp(12.0, 32.0);
    await updateSettings(state.settings.copyWith(fontSize: newSize));
  }
}
