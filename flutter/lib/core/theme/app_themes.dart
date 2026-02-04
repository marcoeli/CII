import 'package:flutter/material.dart';

/// Enumeração dos temas disponíveis
enum AppThemeMode { nebula, deepOcean, midnight }

/// Sistema de temas do aplicativo
/// Baseado nas especificações em app_ui_ux-espec.md
class AppThemes {
  AppThemes._();

  // ============================================================================
  // CORES DE STATUS (compartilhadas entre temas claros)
  // ============================================================================

  static const Color statusOkLight = Color(0xFF00E676); // Verde Menta
  static const Color statusWarningLight = Color(0xFFFFAB00); // Laranja Solar
  static const Color statusErrorLight = Color(0xFFFF1744); // Vermelho Neon

  // Cores de status para tema escuro
  static const Color statusOkDark = Color(0xFF69F0AE);
  static const Color statusWarningDark = Color(0xFFFFD740);
  static const Color statusErrorDark = Color(0xFFFF5252);

  // ============================================================================
  // OPÇÃO A: NEBULA (Padrão - Moderno)
  // ============================================================================

  static ThemeData get nebulaTheme {
    const primaryPurple = Color(0xFF8E2DE2);
    const primaryPink = Color(0xFFFF0080);
    const accentCyan = Color(0xFF00E5FF);
    const backgroundLight = Color(0xFFF5F7FB);
    const surfaceWhite = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        secondary: accentCyan,
        surface: surfaceWhite,
        error: statusErrorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
      // Extensões customizadas
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          gradientPrimary: const LinearGradient(
            colors: [primaryPurple, primaryPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          statusOk: statusOkLight,
          statusWarning: statusWarningLight,
          statusError: statusErrorLight,
        ),
      ],
    );
  }

  // ============================================================================
  // OPÇÃO B: DEEP OCEAN (Corporativo/Sóbrio)
  // ============================================================================

  static ThemeData get deepOceanTheme {
    const primaryBlue = Color(0xFF1565C0);
    const secondaryTeal = Color(0xFF00695C);
    const backgroundIce = Color(0xFFECEFF1);
    const surfaceWhite = Color(0xFFFFFFFF);
    const statusOkGreen = Color(0xFF2E7D32); // Verde Floresta
    const statusWarningGold = Color(0xFFF57C00); // Amarelo Ouro
    const statusErrorBrick = Color(0xFFC62828); // Vermelho Tijolo

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryTeal,
        surface: surfaceWhite,
        error: statusErrorBrick,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: backgroundIce,
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          gradientPrimary: const LinearGradient(
            colors: [primaryBlue, secondaryTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          statusOk: statusOkGreen,
          statusWarning: statusWarningGold,
          statusError: statusErrorBrick,
        ),
      ],
    );
  }

  // ============================================================================
  // OPÇÃO C: MIDNIGHT (OLED/Dark Mode)
  // ============================================================================

  static ThemeData get midnightTheme {
    const primaryPurple = Color(0xFF311B92);
    const secondaryTeal = Color(0xFF00BFA5);
    const backgroundBlack = Color(0xFF121212);
    const surfaceCharcoal = Color(0xFF1E1E1E);
    const textHigh = Colors.white;
    const textMedium = Color(0xFFB0B0B0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryTeal,
        surface: surfaceCharcoal,
        error: statusErrorDark,
        onPrimary: textHigh,
        onSecondary: Colors.black,
        onSurface: textHigh,
      ),
      scaffoldBackgroundColor: backgroundBlack,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        color: surfaceCharcoal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textHigh,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textHigh),
        bodyMedium: TextStyle(color: textHigh),
        bodySmall: TextStyle(color: textMedium),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          gradientPrimary: const LinearGradient(
            colors: [primaryPurple, secondaryTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          statusOk: statusOkDark,
          statusWarning: statusWarningDark,
          statusError: statusErrorDark,
        ),
      ],
    );
  }

  /// Helper para obter o tema correto baseado no modo
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.nebula:
        return nebulaTheme;
      case AppThemeMode.deepOcean:
        return deepOceanTheme;
      case AppThemeMode.midnight:
        return midnightTheme;
    }
  }

  /// Helper para obter o nome do tema
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.nebula:
        return 'Nebula';
      case AppThemeMode.deepOcean:
        return 'Deep Ocean';
      case AppThemeMode.midnight:
        return 'Midnight';
    }
  }
}

/// Extensão de tema customizada para cores adicionais
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Gradient gradientPrimary;
  final Color statusOk;
  final Color statusWarning;
  final Color statusError;

  const AppThemeExtension({
    required this.gradientPrimary,
    required this.statusOk,
    required this.statusWarning,
    required this.statusError,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Gradient? gradientPrimary,
    Color? statusOk,
    Color? statusWarning,
    Color? statusError,
  }) {
    return AppThemeExtension(
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      statusOk: statusOk ?? this.statusOk,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      gradientPrimary: Gradient.lerp(
        gradientPrimary,
        other.gradientPrimary,
        t,
      )!,
      statusOk: Color.lerp(statusOk, other.statusOk, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
    );
  }

  /// Helper para acessar a extensão a partir do contexto
  static AppThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>()!;
  }
}




