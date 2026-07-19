import 'package:flutter/material.dart';
import 'chronos_colors.dart';
import 'chronos_typography.dart';
import 'chronos_radius.dart';

/// Centralização e definição oficial do Tema Material 3 do CHRONOS.
///
/// Combina todos os Design Tokens de cores, tipografia, cantos e sombras do sistema.
abstract class ChronosTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ChronosColors.background,
      
      // Esquema de Cores Central
      colorScheme: const ColorScheme.dark(
        primary: ChronosColors.accent,
        onPrimary: ChronosColors.textOnAccent,
        secondary: ChronosColors.primaryLight,
        onSecondary: ChronosColors.textPrimary,
        surface: ChronosColors.surface,
        onSurface: ChronosColors.textPrimary,
        error: ChronosColors.error,
        onError: ChronosColors.white,
      ),

      // Tipografia Padrão do Sistema
      fontFamily: ChronosTypography.sansFamily,
      textTheme: const TextTheme(
        displayLarge: ChronosTypography.displayLarge,
        displayMedium: ChronosTypography.displayMedium,
        displaySmall: ChronosTypography.displaySmall,
        titleLarge: ChronosTypography.titleLarge,
        titleMedium: ChronosTypography.titleMedium,
        titleSmall: ChronosTypography.titleSmall,
        bodyLarge: ChronosTypography.bodyLarge,
        bodyMedium: ChronosTypography.bodyMedium,
        bodySmall: ChronosTypography.bodySmall,
        labelLarge: ChronosTypography.labelLarge,
        labelMedium: ChronosTypography.labelMedium,
        labelSmall: ChronosTypography.labelSmall,
      ),

      // Configuração de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ChronosColors.background,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: ChronosTypography.sansFamily,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: ChronosColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: ChronosColors.textPrimary,
        ),
      ),

      // Configuração de Cards
      cardTheme: CardTheme(
        color: ChronosColors.surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: ChronosRadius.shapeMD,
      ),

      // Estilização dos Botões Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChronosColors.accent,
          foregroundColor: ChronosColors.textOnAccent,
          textStyle: ChronosTypography.labelLarge.copyWith(color: ChronosColors.textOnAccent),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: ChronosRadius.shapeMD,
          elevation: 2,
        ),
      ),

      // Estilização de TextFields / Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ChronosColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textMuted),
        labelStyle: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
        errorStyle: ChronosTypography.bodySmall.copyWith(color: ChronosColors.error),
        border: OutlineInputBorder(
          borderRadius: ChronosRadius.borderRadiusMD,
          borderSide: const BorderSide(color: ChronosColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ChronosRadius.borderRadiusMD,
          borderSide: const BorderSide(color: ChronosColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ChronosRadius.borderRadiusMD,
          borderSide: const BorderSide(color: ChronosColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ChronosRadius.borderRadiusMD,
          borderSide: const BorderSide(color: ChronosColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ChronosRadius.borderRadiusMD,
          borderSide: const BorderSide(color: ChronosColors.error, width: 1.5),
        ),
      ),

      // Configuração de Divisores
      dividerTheme: const DividerThemeData(
        color: ChronosColors.divider,
        thickness: 1,
        space: 1,
      ),

      // SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ChronosColors.surfaceLight,
        contentTextStyle: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: ChronosRadius.shapeSM,
      ),
    );
  }
}
