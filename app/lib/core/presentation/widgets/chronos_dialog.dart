import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';
import '../../theme/chronos_spacing.dart';
import '../../theme/chronos_typography.dart';

/// Diálogo oficial (Modal) do CHRONOS.
///
/// Componente que herda do design tokens para apresentar diálogos com cabeçalho,
/// corpo de texto livre e uma lista estruturada de ações (botões).
class ChronosDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const ChronosDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  /// Atalho estático para exibir o diálogo de forma centralizada e padronizada.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: ChronosColors.black.withValues(alpha: 0.6),
      builder: (context) => ChronosDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChronosColors.surface,
      surfaceTintColor: ChronosColors.transparent,
      shape: ChronosRadius.shapeLG,
      titlePadding: const EdgeInsets.fromLTRB(
        ChronosSpacing.xxl,
        ChronosSpacing.xxl,
        ChronosSpacing.xxl,
        ChronosSpacing.md,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.xxl,
      ),
      actionsPadding: const EdgeInsets.all(ChronosSpacing.lg),
      title: Text(
        title,
        style: ChronosTypography.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: DefaultTextStyle(
          style: ChronosTypography.bodyMedium,
          child: content,
        ),
      ),
      actions: actions,
    );
  }
}
