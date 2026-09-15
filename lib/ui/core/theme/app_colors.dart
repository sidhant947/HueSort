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
    AppThemeSkin(
      id: 'rose',
      name: 'Rose',
      bg: Color(0xFFF4C2C2),
      surface: Color(0xFFE8B0B0),
      primary: Color(0xFFD98A99),
      headingDark: Color(0xFF3D1A24),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF6E3B4B),
    ),
    AppThemeSkin(
      id: 'mint',
      name: 'Mint',
      bg: Color(0xFFB4E1C6),
      surface: Color(0xFF9ECDAF),
      primary: Color(0xFF7CB892),
      headingDark: Color(0xFF113821),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF2F5E42),
    ),
    AppThemeSkin(
      id: 'lavender',
      name: 'Lavender',
      bg: Color(0xFFD6C7FF),
      surface: Color(0xFFC0AFF2),
      primary: Color(0xFFA08AE5),
      headingDark: Color(0xFF271554),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF4C3487),
    ),
    AppThemeSkin(
      id: 'sky',
      name: 'Sky',
      bg: Color(0xFFAEDDF8),
      surface: Color(0xFF96CBEA),
      primary: Color(0xFF6FB3DC),
      headingDark: Color(0xFF0F364C),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF2A5975),
    ),
    AppThemeSkin(
      id: 'peach',
      name: 'Peach',
      bg: Color(0xFFFFC8A2),
      surface: Color(0xFFF3B287),
      primary: Color(0xFFE59463),
      headingDark: Color(0xFF4D2006),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF7A3E1B),
    ),
    AppThemeSkin(
      id: 'butter',
      name: 'Butter',
      bg: Color(0xFFFCE38A),
      surface: Color(0xFFECCD6B),
      primary: Color(0xFFD9B348),
      headingDark: Color(0xFF4A3804),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF735A12),
    ),
    AppThemeSkin(
      id: 'matcha',
      name: 'Matcha',
      bg: Color(0xFFC8E695),
      surface: Color(0xFFB0D27B),
      primary: Color(0xFF92B958),
      headingDark: Color(0xFF223807),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF466319),
    ),
    AppThemeSkin(
      id: 'periwinkle',
      name: 'Periwinkle',
      bg: Color(0xFFB9C6ED),
      surface: Color(0xFF9FAFD9),
      primary: Color(0xFF7B91C9),
      headingDark: Color(0xFF132047),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF33467A),
    ),
    AppThemeSkin(
      id: 'coral',
      name: 'Coral',
      bg: Color(0xFFFFB7B2),
      surface: Color(0xFFEFA09B),
      primary: Color(0xFFD67F7A),
      headingDark: Color(0xFF4A1613),
      headingWhite: Color(0xFFFFFFFF),
      subtext: Color(0xFF782D28),
    ),
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
