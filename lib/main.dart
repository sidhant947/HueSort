import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/hive_service.dart';
import '../ui/core/theme/app_theme.dart';
import '../ui/providers.dart';
import '../ui/features/home/views/home_view.dart';

import '../ui/core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const HueSortApp(),
    ),
  );
}

class HueSortApp extends ConsumerWidget {
  const HueSortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(themeSkinProvider);
    AppColors.setSkin(skin);

    return MaterialApp(
      title: 'Hue Sort',
      theme: AppTheme.getTheme(skin),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
