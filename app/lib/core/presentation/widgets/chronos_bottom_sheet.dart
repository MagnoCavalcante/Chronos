import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';
import '../../theme/chronos_spacing.dart';

/// Bottom Sheet unificado e altamente estilizado do CHRONOS.
///
/// Apresenta o conteúdo de forma flutuante a partir da base da tela,
/// incluindo um drag-handle sutil e cantos superiores arredondados de acordo com os tokens.
class ChronosBottomSheet extends StatelessWidget {
  final Widget child;
  final bool showDragHandle;
  final EdgeInsetsGeometry padding;

  const ChronosBottomSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.padding = const EdgeInsets.all(ChronosSpacing.xxl),
  });

  /// Atalho estático para exibir o bottom sheet com o visual unificado do ecossistema.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool showDragHandle = true,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: ChronosColors.surface,
      surfaceTintColor: ChronosColors.transparent,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ChronosRadius.xl),
        ),
      ),
      builder: (context) => ChronosBottomSheet(
        showDragHandle: showDragHandle,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle sutil no cabeçalho
            if (showDragHandle) ...[
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: ChronosColors.borderLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
