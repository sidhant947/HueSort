import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/core/widgets/tangible_button.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_engine.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_provider.dart';
import 'package:huesort/ui/providers.dart';

final hueSortViewModelProvider =
    StateNotifierProvider.autoDispose<HueSortViewModel, HueSortState>(
      (ref) => HueSortViewModel(),
    );

class HueSortScreen extends ConsumerStatefulWidget {
  const HueSortScreen({
    super.key,
    required this.levelNumber,
    this.gridSize,
    this.difficulty,
    this.isRandom = false,
  });

  final int levelNumber;
  final int? gridSize;
  final HueSortDifficulty? difficulty;
  final bool isRandom;

  @override
  ConsumerState<HueSortScreen> createState() => _HueSortScreenState();
}

class _HueSortScreenState extends ConsumerState<HueSortScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(hueSortViewModelProvider.notifier).initGame(
        levelNumber: widget.levelNumber,
        gridSize: widget.gridSize,
        difficulty: widget.difficulty,
        isRandom: widget.isRandom,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSkinProvider);
    final state = ref.watch(hueSortViewModelProvider);
    final notifier = ref.read(hueSortViewModelProvider.notifier);

    ref.listen<HueSortState>(hueSortViewModelProvider, (previous, next) {
      if (next.isSolved && !(previous?.isSolved ?? false)) {
        HapticFeedback.heavyImpact();
        if (!widget.isRandom) {
          ref.read(homeViewModelProvider.notifier).completeLevel(widget.levelNumber);
        }
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isRandom
                            ? 'Random Puzzle'
                            : (HueSortEngine.isBossLevel(widget.levelNumber)
                                ? '👑 Boss Level ${widget.levelNumber}'
                                : 'Level ${widget.levelNumber}'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: HueSortEngine.isBossLevel(widget.levelNumber) && !widget.isRandom
                              ? const Color(0xFFFFB800)
                              : AppColors.headingDark,
                        ),
                      ),
                      if (HueSortEngine.isBossLevel(widget.levelNumber) && !widget.isRandom)
                        const Text(
                          'Master the Gradient',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                    ],
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

            if (ref.watch(showTilesToFixProvider))
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
                      '${state.wrongTilesCount} tiles to fix',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availW = constraints.maxWidth - 32;
                    final availH = constraints.maxHeight - 16;
                    final gridSize = availW < availH ? (availW > 0 ? availW : 0.0) : (availH > 0 ? availH : 0.0);
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

                              Widget tile = AnimatedContainer(
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
                              );

                              Widget clickableTile = GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  notifier.selectTile(index);
                                },
                                child: tile,
                              );

                              if (isFixed || state.isSolved) {
                                return clickableTile;
                              }

                              return DragTarget<int>(
                                onWillAcceptWithDetails: (details) => details.data != index && !isFixed,
                                onAcceptWithDetails: (details) {
                                  HapticFeedback.mediumImpact();
                                  notifier.swapTiles(details.data, index);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  final isHovered = candidateData.isNotEmpty;
                                  return Draggable<int>(
                                    data: index,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: (gridSize - ((state.level.size - 1) * 4.0)) / state.level.size,
                                        height: (gridSize - ((state.level.size - 1) * 4.0)) / state.level.size,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: state.currentColors[index],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: tile,
                                    ),
                                    child: isHovered
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: clickableTile,
                                          )
                                        : clickableTile,
                                  );
                                },
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

            if (state.isSolved)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isRandom ? 'Puzzle Complete!' : 'Level Complete!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.headingDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You sorted the colors perfectly!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TangibleButton(
                            text: widget.isRandom ? 'New Puzzle' : 'Next Level',
                            height: 44,
                            onPressed: () {
                              if (widget.isRandom) {
                                ref.read(hueSortViewModelProvider.notifier).newGame();
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HueSortScreen(
                                      levelNumber: widget.levelNumber + 1,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TangibleButton(
                            text: 'Home',
                            height: 44,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 8),
                          TangibleButton(
                            text: 'Buy Me a Coffee',
                            isSecondary: true,
                            height: 44,
                            onPressed: () async {
                              final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (ref.watch(hintHelperProvider))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TangibleButton(
                    text: 'Hint',
                    isSecondary: true,
                    height: 52,
                    onPressed: !state.isSolved
                        ? () {
                            HapticFeedback.mediumImpact();
                            notifier.useHint();
                          }
                        : null,
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
