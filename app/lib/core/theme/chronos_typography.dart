import 'package:flutter/material.dart';
import 'chronos_colors.dart';

/// Design Tokens de Tipografia para o ecossistema CHRONOS.
///
/// Define as fontes, tamanhos, pesos e espaçamentos padrão de texto.
abstract class ChronosTypography {
  // Nomes das Famílias de Fontes
  static const String sansFamily = 'Inter';
  static const String monoFamily = 'JetBrains Mono';

  // Display Typography (Grandes títulos, cabeçalhos de destaque)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: ChronosColors.textPrimary,
  );

  // Title Typography (Cabeçalhos de seções, títulos de cards)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: ChronosColors.textPrimary,
  );

  // Body Typography (Textos corridos, descrições)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: ChronosColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.4,
    color: ChronosColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.3,
    color: ChronosColors.textMuted,
  );

  // Label Typography (Botões, tags, badges)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: ChronosColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: ChronosColors.textPrimary,
  );

  // Code/Mono Typography (Anos, anos a.C., IDs, código, estatísticas)
  static const TextStyle codeMedium = TextStyle(
    fontFamily: monoFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ChronosColors.textSecondary,
  );

  static const TextStyle codeSmall = TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ChronosColors.textMuted,
  );
}
