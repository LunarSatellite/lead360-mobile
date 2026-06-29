import 'package:flutter/material.dart';

/// Dark-green "Bato" identity mirrored from the web app (gold-on-green).
/// Tokens map to the web's tailwind config: bg #0A0F0D, brand #00D97E,
/// gold text #FFD84D, glass surfaces, 0.5px-style hairline borders.
class AppColors {
  static const bg = Color(0xFF0A0F0D);
  static const bgCard = Color(0xFF111916);
  static const bgElevated = Color(0xFF162019);
  static const glass1 = Color(0xFF182420);
  static const glass2 = Color(0xFF1E2E26);
  static const borderSubtle = Color(0xFF1E2E26);
  static const borderMedium = Color(0xFF253D32);

  static const brand = Color(0xFF00D97E);
  static const brandDark = Color(0xFF00B368);

  static const textPrimary = Color(0xFFFFD84D); // warm gold
  static const textSecondary = Color(0xFFBFA200);
  static const textMuted = Color(0xFF8A7E3A);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFF43F5E);
  static const info = Color(0xFF60A5FA);
  static const violet = Color(0xFFA78BFA);

  /// Signature accent gradient (logos, CTAs, hero) — matches the web's 135° brand gradient.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00FFAA), Color(0xFF00B368)],
  );
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.brand,
    onPrimary: AppColors.bg,
    secondary: AppColors.brandDark,
    surface: AppColors.bgCard,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: scheme,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      color: AppColors.glass1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF080A09),
      indicatorColor: AppColors.brand.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    ),
  );
}
