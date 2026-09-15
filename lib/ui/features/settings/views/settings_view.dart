import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:huesort/ui/core/theme/app_colors.dart';
import 'package:huesort/ui/core/widgets/tangible_button.dart';
import 'package:huesort/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
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
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 28, 28),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show Tiles to Fix',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.headingDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Display counter of incorrect tiles during gameplay',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: ref.watch(showTilesToFixProvider),
                          activeTrackColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            ref.read(showTilesToFixProvider.notifier).toggle(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hint Helper',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.headingDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Display bottom hint button on gameplay screen',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: ref.watch(hintHelperProvider),
                          activeTrackColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            ref.read(hintHelperProvider.notifier).toggle(val);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Theme',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.headingDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your favorite pastel color theme skin',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.subtext,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppThemeSkin.allSkins.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final skin = AppThemeSkin.allSkins[index];
                              final isSelected = ref.watch(themeSkinProvider).id == skin.id;

                              return GestureDetector(
                                onTap: () => ref.read(themeSkinProvider.notifier).setSkin(skin),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: skin.bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF10B981) : Colors.white30,
                                      width: isSelected ? 3.0 : 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 20,
                                          color: skin.headingDark,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  TangibleButton(
                    text: 'Reset Progress',
                    isSecondary: true,
                    onPressed: () => _confirmReset(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1.0),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reset progress?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This clears all level progress and best scores. This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 24),
              TangibleButton(
                text: 'Reset Everything',
                onPressed: () async {
                  await ref.read(homeViewModelProvider.notifier).resetProgress();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
