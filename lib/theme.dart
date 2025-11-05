import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalaxyColors {
  // Core palette derived from screenshot hues
  static const Color midnight = Color(0xFF2E3E5C);
  static const Color slate = Color(0xFF3C4D6B);
  static const Color panel = Color(0xFF4E6184);
  static const Color sky = Color(0xFF3A8DFF);
  static const Color lilac = Color(0xFF9C8CFF);
  static const Color aqua = Color(0xFF2ED8A7);
  static const Color yellow = Color(0xFFF5C443);
  static const Color danger = Color(0xFFEA6B6B);
}

ThemeData buildGalaxyTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: GalaxyColors.sky,
      onPrimary: Colors.white,
      secondary: GalaxyColors.lilac,
      onSecondary: Colors.white,
      surface: isDark ? GalaxyColors.midnight : Colors.white,
      onSurface: isDark ? const Color(0xFFE9EDF7) : Colors.black,
      error: GalaxyColors.danger,
      onError: Colors.white,
      tertiary: GalaxyColors.aqua,
      onTertiary: Colors.black,
      surfaceContainerHighest: GalaxyColors.panel,
      surfaceContainerLow: GalaxyColors.slate,
      surfaceTint: GalaxyColors.sky,
      outline: const Color(0x334C5A79),
    ),
  );

  TextTheme applyFallbacks(TextTheme theme) {
    List<String> fallbacks = const [
      'Noto Sans KR',
      'Roboto',
      'Noto Sans',
      'Apple SD Gothic Neo',
      'Segoe UI',
      'sans-serif',
    ];

    TextStyle? withFallback(TextStyle? s) =>
        s?.copyWith(fontFamilyFallback: fallbacks);

    return theme.copyWith(
      displayLarge: withFallback(theme.displayLarge),
      displayMedium: withFallback(theme.displayMedium),
      displaySmall: withFallback(theme.displaySmall),
      headlineLarge: withFallback(theme.headlineLarge),
      headlineMedium: withFallback(theme.headlineMedium),
      headlineSmall: withFallback(theme.headlineSmall),
      titleLarge: withFallback(theme.titleLarge),
      titleMedium: withFallback(theme.titleMedium),
      titleSmall: withFallback(theme.titleSmall),
      bodyLarge: withFallback(theme.bodyLarge),
      bodyMedium: withFallback(theme.bodyMedium),
      bodySmall: withFallback(theme.bodySmall),
      labelLarge: withFallback(theme.labelLarge),
      labelMedium: withFallback(theme.labelMedium),
      labelSmall: withFallback(theme.labelSmall),
    );
  }

  final interBase = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    // Strengthen headline weights to match design intent
    headlineSmall: GoogleFonts.inter(
      textStyle: base.textTheme.headlineSmall,
      fontWeight: FontWeight.w700,
    ),
  );

  // Apply Noto Sans KR fallbacks for Korean rendering
  final textTheme = applyFallbacks(interBase);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: const Color(0xFF2C3E5E),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: base.colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: GalaxyColors.panel.withOpacity(0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GalaxyColors.panel.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: base.colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: base.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: GalaxyColors.sky, width: 2),
      ),
    ),
  );
}
