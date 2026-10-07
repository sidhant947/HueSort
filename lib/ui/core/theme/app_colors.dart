import 'package:flutter/material.dart';

class AppThemeSkin {
  final String id;
  final String name;
  final Color bg;
  final Color surface;
  final Color primary;
  final Color headingDark;
  final Color headingWhite;
  final Color subtext;

  const AppThemeSkin({
    required this.id,
    required this.name,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.headingDark,
    required this.headingWhite,
    required this.subtext,
  });

  static const defaultSkin = AppThemeSkin(
    id: 'charcoal',
    name: 'Charcoal',
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primary: Color(0xFF2C2C2C),
    headingDark: Color(0xFFFFFFFF),
    headingWhite: Color(0xFF121212),
    subtext: Color(0xFFA0A0A0),
  );

  static const List<AppThemeSkin> allSkins = [
    defaultSkin,
  ];
}

class AppColors {
  AppColors._();

  static AppThemeSkin _currentSkin = AppThemeSkin.defaultSkin;

  static void setSkin(AppThemeSkin skin) {
    _currentSkin = skin;
  }

  static Color get primary => _currentSkin.primary;
  static Color get headingDark => _currentSkin.headingDark;
  static Color get headingWhite => _currentSkin.headingWhite;
  static Color get subtext => _currentSkin.subtext;
  static Color get bg => _currentSkin.bg;
  static Color get surface => _currentSkin.surface;
}
