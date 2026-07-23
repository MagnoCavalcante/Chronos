import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Barra de progresso visual com percentual e legendas opcionais.
class StudyProgressBar extends StatelessWidget {
  final double percent;
  final int itemCount;
  final int completedCount;
  final int? estimatedMinutes;

  const StudyProgressBar({
    super.key,
    required this.percent,
    required this.itemCount,
    required this.completedCount,
    this.estimatedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(clamped * 100).toStringAsFixed(0)}% concluído',
              style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '$completedCount / $itemCount itens',
              style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 10,
            backgroundColor: ChronosColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(ChronosColors.accent),
          ),
        ),
        if (estimatedMinutes != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Tempo estimado restante: ${estimatedMinutes}min',
              style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
            ),
          ),
      ],
    );
  }
}
