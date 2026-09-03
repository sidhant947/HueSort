import 'package:hive_flutter/hive_flutter.dart';

import 'package:huesort/domain/models/user_progress.dart';
import 'user_progress_adapter.dart';

class HiveService {
  static const String _progressBoxName = 'huesort';
  static const String _progressKey = 'progress';

  static const String _settingsBoxName = 'huesort_settings';
  static const String _showTilesToFixKey = 'show_tiles_to_fix';
  static const String _hintHelperKey = 'hint_helper';

  late Box<UserProgress> _progressBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  Future<UserProgress> getProgress() async {
    return _progressBox.get(_progressKey) ?? const UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put(_progressKey, progress);
  }

  Future<void> clearProgress() async {
    await _progressBox.delete(_progressKey);
  }

  bool getShowTilesToFix() {
    return _settingsBox.get(_showTilesToFixKey, defaultValue: true) as bool;
  }

  Future<void> setShowTilesToFix(bool show) async {
    await _settingsBox.put(_showTilesToFixKey, show);
  }

  bool getHintHelper() {
    return _settingsBox.get(_hintHelperKey, defaultValue: false) as bool;
  }

  Future<void> setHintHelper(bool enabled) async {
    await _settingsBox.put(_hintHelperKey, enabled);
  }
}
