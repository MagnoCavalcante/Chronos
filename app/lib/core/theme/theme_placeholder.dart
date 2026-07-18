import 'package:flutter/material.dart';

/// Sistema de Estilos e Temas Visuais do CHRONOS
/// 
/// Centraliza a definição do Design System do aplicativo, incluindo paleta de cores,
/// tipografia personalizada, estilos de cartões, botões e transições visuais
/// condizentes com a identidade premium e confortável do CHRONOS.
class ChronosTheme {
  // Paleta de cores oficial aprovada
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color slateCard = Color(0xFF1E293B);
  static const Color accentBlue = Colors.blueAccent;
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        surface: slateCard,
      ),
    );
  }
}
