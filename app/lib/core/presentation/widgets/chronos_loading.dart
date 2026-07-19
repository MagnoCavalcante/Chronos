import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';

/// Indicador de Carregamento centralizado oficial do CHRONOS.
///
/// Oferece um feedback de processamento unificado e elegante com mensagem descritiva opcional.
class ChronosLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const ChronosLoading({
    super.key,
    this.message,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ChronosColors.accent;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
