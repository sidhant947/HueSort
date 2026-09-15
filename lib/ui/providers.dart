import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huesort/data/repositories/progress_repository.dart';
import 'package:huesort/data/services/hive_service.dart';
import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.watch(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });

final showTilesToFixProvider = StateNotifierProvider<ShowTilesToFixNotifier, bool>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ShowTilesToFixNotifier(hiveService);
});

class ShowTilesToFixNotifier extends StateNotifier<bool> {
  ShowTilesToFixNotifier(this._hiveService)
      : super(_hiveService.getShowTilesToFix());

  final HiveService _hiveService;

  Future<void> toggle(bool value) async {
    state = value;
    await _hiveService.setShowTilesToFix(value);
  }
}

final hintHelperProvider = StateNotifierProvider<HintHelperNotifier, bool>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HintHelperNotifier(hiveService);
});

class HintHelperNotifier extends StateNotifier<bool> {
  HintHelperNotifier(this._hiveService)
      : super(_hiveService.getHintHelper());

  final HiveService _hiveService;

  Future<void> toggle(bool value) async {
    state = value;
    await _hiveService.setHintHelper(value);
  }
}

final themeSkinProvider = StateNotifierProvider<ThemeSkinNotifier, AppThemeSkin>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ThemeSkinNotifier(hiveService);
});

class ThemeSkinNotifier extends StateNotifier<AppThemeSkin> {
  ThemeSkinNotifier(this._hiveService)
      : super(_getSkinById(_hiveService.getThemeSkin()));

  final HiveService _hiveService;

  static AppThemeSkin _getSkinById(String id) {
    return AppThemeSkin.allSkins.firstWhere(
      (skin) => skin.id == id,
      orElse: () => AppThemeSkin.defaultSkin,
    );
  }

  Future<void> setSkin(AppThemeSkin skin) async {
    state = skin;
    await _hiveService.setThemeSkin(skin.id);
  }
}

