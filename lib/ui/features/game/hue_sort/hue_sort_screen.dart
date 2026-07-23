import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/core/widgets/tangible_button.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_provider.dart';
import 'package:huesort/ui/features/support/views/support_view.dart';
import 'package:huesort/ui/providers.dart';

final hueSortViewModelProvider =
    StateNotifierProvider.autoDispose<HueSortViewModel, HueSortState>(
      (ref) => HueSortViewModel(),
    );

class HueSortScreen extends ConsumerStatefulWidget {
  const HueSortScreen({super.key, required this.levelNumber, this.isRandom = false});

  final int levelNumber;
  final bool isRandom;

  @override
  ConsumerState<HueSortScreen> createState() => _HueSortScreenState();
}

class _HueSortScreenState extends ConsumerState<HueSortScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hueSortViewModelProvider.notifier).initGame(widget.levelNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hueSortViewModelProvider);
    final notifier = ref.read(hueSortViewModelProvider.notifier);

    ref.listen<HueSortState>(hueSortViewModelProvider, (previous, next) {
      if (next.isSolved && !(previous?.isSolved ?? false)) {
        HapticFeedback.heavyImpact();
        _showCompletionDialog();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    widget.isRandom ? 'RANDOM PUZZLE' : 'LEVEL ${widget.levelNumber}',
                    style: const TextStyle(

                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                  _circleButton(
                    icon: Icons.undo_rounded,
                    iconSize: 20,
                    onTap: notifier.canUndo
                        ? () {
                            HapticFeedback.lightImpact();
                            notifier.undo();
                          }
                        : () {},
                    iconColor: notifier.canUndo
                        ? AppColors.headingDark
                        : AppColors.subtext,
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_on_rounded, size: 18, color: AppColors.headingDark),
                  const SizedBox(width: 8),
                  Text(
                    '${state.wrongTilesCount} TILES TO FIX',
                    style: const TextStyle(

                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gridSize = constraints.maxWidth - 32;
                    return SizedBox(
                      width: gridSize,
                      height: gridSize,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: state.level.size,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: state.level.size * state.level.size,
                            itemBuilder: (context, index) {
                              final isFixed = state.level.fixedIndices.contains(index);
                              final isSelected = state.selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  notifier.selectTile(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: state.currentColors[index],
                                    borderRadius: BorderRadius.circular(
                                      isSelected ? 12 : 4,
                                    ),
                                    border: isSelected
                                        ? Border.all(color: Colors.white, width: 4)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: isFixed
                                      ? Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final Future<void> Function() saveProgress = widget.isRandom
        ? () async {}
        : () => ref.read(progressRepositoryProvider).completeLevel(widget.levelNumber);

    saveProgress().then((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1.0),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.0),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.headingDark,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.isRandom ? 'PUZZLE COMPLETE!' : 'LEVEL COMPLETE!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'You sorted the colors perfectly!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtext,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      if (!widget.isRandom)
                        TangibleButton(
                          text: 'Next Level',
                          height: 50,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HueSortScreen(
                                  levelNumber: widget.levelNumber + 1,
                                ),
                              ),
                            );
                          },
                        ),
                      if (!widget.isRandom) const SizedBox(height: 14),
                      TangibleButton(
                        text: widget.isRandom ? 'New Puzzle' : 'Home',
                        height: 50,
                        onPressed: () {
                          Navigator.pop(context);
                          if (widget.isRandom) {
                            ref.read(hueSortViewModelProvider.notifier).newGame();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TangibleButton(
                        text: 'Buy Me a Coffee',
                        isSecondary: true,
                        height: 50,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportView(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
}
