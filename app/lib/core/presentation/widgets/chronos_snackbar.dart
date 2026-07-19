import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';
import '../../theme/chronos_typography.dart';

enum ChronosSnackBarType { success, error, info, warning }

/// Utilitário oficial de SnackBar do CHRONOS.
///
/// Oferece métodos simples para disparar alertas semânticos e uniformizados na tela.
abstract class ChronosSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    ChronosSnackBarType type = ChronosSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color color;
    IconData icon;

    switch (type) {
      case ChronosSnackBarType.success:
        color = ChronosColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ChronosSnackBarType.error:
        color = ChronosColors.error;
        icon = Icons.error_outline_rounded;
        break;
      case ChronosSnackBarType.warning:
        color = ChronosColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case ChronosSnackBarType.info:
        color = ChronosColors.info;
        icon = Icons.info_outline_rounded;
        break;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Remove snackbar atual para evitar empilhamento lento
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: ChronosColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: ChronosRadius.shapeSM,
        margin: const EdgeInsets.all(16.0),
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
