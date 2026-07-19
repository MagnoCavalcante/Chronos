import 'package:flutter/material.dart';

/// Design Tokens de Cores para o ecossistema CHRONOS.
///
/// Todas as cores da aplicação devem derivar desta classe, evitando valores hardcoded.
abstract class ChronosColors {
  // Paleta Principal (Slate & Amber)
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color primaryDark = Color(0xFF020617); // Slate 950
  
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentLight = Color(0xFFFBBF24); // Amber 400
  static const Color accentDark = Color(0xFFD97706); // Amber 600

  // Cores de Fundo e Superfície
  static const Color background = Color(0xFF0B0F19); // Fundo super escuro
  static const Color surface = Color(0xFF151D30); // Cards e modais
  static const Color surfaceLight = Color(0xFF1E293B); // Containers mais claros

  // Cores de Borda e Divisores
  static const Color border = Color(0xFF1E293B); // Borda padrão
  static const Color borderLight = Color(0xFF334155); // Borda destacada
  static const Color divider = Color(0xFF1E293B); // Divisor sutil

  // Paleta de Texto
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50 (Muito claro)
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400 (Cinza médio)
  static const Color textMuted = Color(0xFF64748B); // Slate 500 (Cinza escuro)
  static const Color textOnAccent = Color(0xFF0F172A); // Slate 900 para contraste com Amber

  // Cores Semânticas / Feedback
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE);

  // Auxiliares
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
