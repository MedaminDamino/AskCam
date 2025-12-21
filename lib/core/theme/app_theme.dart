import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB), // Blue 600
      brightness: Brightness.light,
    ).copyWith(
      background: const Color(0xFFF7F8FA),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFEFF2F6),
      outlineVariant: const Color(0xFFD7DEE8),

      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF14B8A6),
      tertiary: const Color(0xFFF59E0B),

      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: const Color(0xFF111827),

      onSurface: const Color(0xFF0F172A),
      onBackground: const Color(0xFF0F172A),
      onSurfaceVariant: const Color(0xFF475569),

      error: const Color(0xFFDC2626),
      onError: Colors.white,
    );

    return _buildTheme(scheme);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
    ).copyWith(
      background: const Color(0xFF0B1220),
      surface: const Color(0xFF0F172A),
      surfaceVariant: const Color(0xFF162238),
      outlineVariant: const Color(0xFF26344D),

      primary: const Color(0xFF3B82F6),
      secondary: const Color(0xFF2DD4BF),
      tertiary: const Color(0xFFFBBF24),

      onPrimary: const Color(0xFF07101F),
      onSecondary: const Color(0xFF07101F),
      onTertiary: const Color(0xFF07101F),

      onSurface: const Color(0xFFE5E7EB),
      onBackground: const Color(0xFFE5E7EB),
      onSurfaceVariant: const Color(0xFFB6C2D3),

      error: const Color(0xFFF87171),
      onError: const Color(0xFF0B1220),
    );

    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final notoArabic = GoogleFonts.notoSansArabic();
    final poppins = GoogleFonts.poppins();

    final fallbackFonts = <String>[
      if (notoArabic.fontFamily != null) notoArabic.fontFamily!,
    ];

    final baseTextTheme =
    GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);

    final textTheme = baseTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamilyFallback: fallbackFonts,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: poppins.fontFamily,
      fontFamilyFallback: fallbackFonts,
      scaffoldBackgroundColor: scheme.background,
      cardColor: scheme.surface,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onBackground,
        iconTheme: IconThemeData(color: scheme.onBackground),
      ),

      iconTheme: IconThemeData(color: scheme.onSurface),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.md),
          ),
          padding: AppSpacing.vertical(AppSpacing.md),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.md),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          padding: AppSpacing.vertical(AppSpacing.md),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.circular(AppRadius.md),
          ),
          padding: AppSpacing.vertical(AppSpacing.sm),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surface,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),

      // ✅ FIX: DialogThemeData (not DialogTheme)
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.lg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.lg),
        ),
      ),

      // ✅ FIX: CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
