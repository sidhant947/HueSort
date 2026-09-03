import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_engine.dart';
import 'package:huesort/ui/features/game/hue_sort/hue_sort_screen.dart';
import 'package:huesort/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;

    // Display a dynamic grid of levels, keeping a buffer of 20 levels ahead of current progress
    final int totalLevelsToShow = math.max(60, currentLevel + 20);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'LEVELS',
                        style: TextStyle(

                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  // Balanced invisible spacer to perfectly center the text
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Grid of levels
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 24, 28, 28), // extra right/bottom padding for 3D shadow
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalLevelsToShow,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isCompleted = levelNumber <= highestCompleted;
                  final isCurrent = levelNumber == currentLevel;
                  final isLocked = levelNumber > currentLevel;

                  return _buildLevelCard(
                    context,
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLocked: isLocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    Color cardBg = AppColors.surface;
    Widget content;
    bool isClickable = !isLocked;

    final isBoss = HueSortEngine.isBossLevel(levelNumber);

    if (isCompleted) {
      cardBg = isBoss ? const Color(0xFFD97706) : const Color(0xFF10B981); // Amber / Emerald
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBoss) ...[
                const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 2),
              ],
              Text(
                '$levelNumber',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.headingWhite,
          ),
        ],
      );
    } else if (isCurrent) {
      cardBg = isBoss ? const Color(0xFFFFB800) : Colors.white;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isBoss) const Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.black87),
          Text(
            '$levelNumber',
            style: TextStyle(
              fontSize: isBoss ? 20 : 26,
              color: isBoss ? Colors.black87 : AppColors.headingWhite,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    } else {
      // Locked state
      cardBg = isBoss
          ? const Color(0xFFFFB800).withValues(alpha: 0.15)
          : AppColors.surface.withValues(alpha: 0.4);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isBoss)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.star_outline_rounded, size: 12, color: Color(0xFFFFB800)),
            ),
          Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: isBoss ? const Color(0xFFFFB800) : AppColors.subtext,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HueSortScreen(levelNumber: levelNumber),
                ),
              );
              // Refresh when returning to update completions
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white24,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
