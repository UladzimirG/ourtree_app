import 'package:flutter/material.dart';

/// Палитра, перенесённая из `src/index.css` оригинального React-проекта.
abstract final class AppColors {
  static const Color ink = Color(0xFF2A1B12);
  static const Color inkSoft = Color(0xFF5A3D28);
  static const Color paper = Color(0xFFFFF4DE);
  static const Color sticker = Color(0xFFFFFAF1);
  static const Color kraft = Color(0xFFC4A06A);
  static const Color kraftDark = Color(0xFF6F4B2A);
  static const Color moss = Color(0xFF4E5C38);
  static const Color terracotta = Color(0xFFA44B2C);
  static const Color background = Color(0xFFB98B5C);
  static const Color shadow = Color(0x522A180A);
  static const Color softShadow = Color(0x332A180A);
  static const Color tape = Color(0xB8E8D6A0);
  static const Color activeWash = Color(0x1FB45B38);
  static const Color mossWash = Color(0x1F4E5C38);
  static const Color kraftWash = Color(0x33C4A06A);
  static const Color whiteWash = Color(0xB3FFFFFF);
  static const Color scrim = Color(0x613B2A1D);
}

/// Тема приложения: бумажные поверхности, серифные заголовки и тёплые акценты.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.terracotta,
      onPrimary: AppColors.sticker,
      secondary: AppColors.moss,
      onSecondary: AppColors.sticker,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.sticker,
      outline: AppColors.kraftDark,
    ),
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: _serif(base.textTheme.displayLarge, 44),
    displayMedium: _serif(base.textTheme.displayMedium, 36),
    headlineLarge: _serif(base.textTheme.headlineLarge, 32),
    headlineMedium: _serif(base.textTheme.headlineMedium, 28),
    headlineSmall: _serif(base.textTheme.headlineSmall, 22),
    titleLarge: _serif(base.textTheme.titleLarge, 20),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 1.45,
      color: AppColors.ink,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 1.45,
      color: AppColors.ink,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      fontSize: 12.5,
      height: 1.35,
      color: AppColors.inkSoft,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: AppColors.ink,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(color: AppColors.paper),
      behavior: SnackBarBehavior.floating,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.moss,
        foregroundColor: AppColors.sticker,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.inkSoft),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.terracotta,
    ),
  );
}

TextStyle? _serif(TextStyle? base, double size) => base?.copyWith(
      fontFamily: 'Georgia',
      fontFamilyFallback: const <String>['Times New Roman', 'serif'],
      fontWeight: FontWeight.w700,
      fontSize: size,
      height: 1.1,
      letterSpacing: -0.3,
      color: AppColors.ink,
    );
