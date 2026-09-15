import 'package:flutter/material.dart';
import 'package:huesort/ui/core/theme/app_colors.dart';

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  static ThemeData getTheme(AppThemeSkin skin) => ThemeData(
    pageTransitionsTheme: _noTransitionTheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: skin.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: skin.headingDark,
      ),
      iconTheme: IconThemeData(color: skin.headingDark),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E2E6),
      thickness: 1,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: skin.headingDark),
      displayMedium: TextStyle(color: skin.headingDark),
      displaySmall: TextStyle(color: skin.headingDark),
      headlineLarge: TextStyle(color: skin.headingDark),
      headlineMedium: TextStyle(color: skin.headingDark),
      headlineSmall: TextStyle(color: skin.headingDark),
      titleLarge: TextStyle(color: skin.headingDark),
      titleMedium: TextStyle(color: skin.headingDark),
      bodyLarge: TextStyle(color: skin.headingDark, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: skin.subtext, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(color: skin.headingDark, fontWeight: FontWeight.w500),
    ),
  );
}
