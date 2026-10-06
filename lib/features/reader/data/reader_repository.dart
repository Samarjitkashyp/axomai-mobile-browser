import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_settings.dart';

/// Repository managing persistence of Reader Mode configurations.
class ReaderRepository {
  final SharedPreferences? prefs;
  static const String _readerSettingsKey = 'axomai_reader_settings';

  ReaderRepository({this.prefs});

  Future<ReaderSettings> getSettings() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final jsonStr = effectivePrefs.getString(_readerSettingsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return ReaderSettings.fromJson(jsonStr);
      } catch (_) {
        return const ReaderSettings();
      }
    }
    return const ReaderSettings();
  }

  Future<void> saveSettings(ReaderSettings settings) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    await effectivePrefs.setString(_readerSettingsKey, settings.toJson());
  }
}
