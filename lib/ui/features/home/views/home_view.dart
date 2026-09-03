import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/core/widgets/tangible_button.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_engine.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_screen.dart';
import 'package:huesort/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:huesort/ui/features/level_select/views/level_select_view.dart';
import 'package:huesort/ui/features/settings/views/settings_view.dart';
import 'package:huesort/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(homeViewModelProvider.notifier).loadProgress(),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.headingDark,
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    int selectedGrid = 5;
    HueSortDifficulty selectedDiff = HueSortDifficulty.medium;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 1.0),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RANDOM PUZZLE',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.subtext,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GRID SIZE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subtext,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${selectedGrid}x$selectedGrid',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: AppColors.surface,
                        thumbColor: const Color(0xFF10B981),
                        overlayColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                      ),
                      child: Slider(
                        value: selectedGrid.toDouble(),
                        min: 3,
                        max: 10,
                        divisions: 7,
                        onChanged: (val) {
                          setModalState(() {
                            selectedGrid = val.round();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DIFFICULTY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subtext,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDiff.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: AppColors.surface,
                        thumbColor: const Color(0xFF10B981),
                        overlayColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                      ),
                      child: Slider(
                        value: selectedDiff.index.toDouble(),
                        min: 0,
                        max: (HueSortDifficulty.values.length - 1).toDouble(),
                        divisions: HueSortDifficulty.values.length - 1,
                        onChanged: (val) {
                          setModalState(() {
                            selectedDiff = HueSortDifficulty.values[val.round()];
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    TangibleButton(
                      text: 'Start Puzzle',
                      height: 48,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HueSortScreen(
                              levelNumber: 1,
                              gridSize: selectedGrid,
                              difficulty: selectedDiff,
                              isRandom: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Top Action Row (App Bar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFCC00),
                    onTap: () => _launchUrl('https://github.com/sidhant947/HueSort'),
                  ),
                  if (state.progress != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24, width: 1.0),
                      ),
                      child: Text(
                        'LEVEL ${state.progress!.currentLevel}',
                        style: const TextStyle(
      
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  _circleButton(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFEF4444),
                    onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                  ),
                ],
              ),
              const Spacer(flex: 3),

              // Rainbow Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1.0),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFFEF4444), // Red
                        Color(0xFFF97316), // Orange
                        Color(0xFFEAB308), // Yellow
                        Color(0xFF22C55E), // Green
                        Color(0xFF3B82F6), // Blue
                        Color(0xFF8B5CF6), // Indigo
                        Color(0xFFEC4899), // Violet
                        Color(0xFFEF4444), // Red (wrap)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Game Title
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Hue Sort',
                  style: TextStyle(

                    fontSize: 62,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // White
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'SORT THE COLORS TO MATCH THE GRADIENT',
                style: TextStyle(

                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(flex: 4),

              // Play Button (Primary CTA)
              TangibleButton(
                text: 'Play',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HueSortScreen(
                              levelNumber: state.progress?.currentLevel ?? 1,
                            ),
                          ),
                        );
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      },
              ),

              const SizedBox(height: 16),

              // Level Select Button
              TangibleButton(
                text: 'Select Level',
                isSecondary: true,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectView(),
                    ),
                  );
                  ref.read(homeViewModelProvider.notifier).loadProgress();
                },
              ),

              const SizedBox(height: 16),

              // Random Puzzle Button
              TangibleButton(
                text: 'Random Puzzle',
                isSecondary: true,
                onPressed: () => _showDifficultyDialog(context),
              ),

              const SizedBox(height: 16),

              // How to Play Button (Secondary Button)
              TangibleButton(
                text: 'How to Play',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToPlayView(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings Button (Secondary Button)
              TangibleButton(
                text: 'Settings',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsView()),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
