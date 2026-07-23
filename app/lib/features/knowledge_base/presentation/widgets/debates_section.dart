import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import 'reliability_badge.dart';

/// Seção reutilizável de Debates Históricos.
class DebatesSection extends StatelessWidget {
  final List<HistoricalDebate> debates;

  const DebatesSection({super.key, required this.debates});

  @override
  Widget build(BuildContext context) {
    if (debates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.forum_rounded, color: ChronosColors.warning, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Debates Históricos',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...debates.map(_buildDebateCard),
      ],
    );
  }

  Widget _buildDebateCard(HistoricalDebate debate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(ChronosSpacing.md),
        decoration: BoxDecoration(
          color: ChronosColors.surface,
          borderRadius: ChronosRadius.borderRadiusSM,
          border: Border.all(color: ChronosColors.warning.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    debate.titulo,
                    style: ChronosTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ReliabilityBadge(level: debate.statusAtual, compact: true),
              ],
            ),
            const SizedBox(height: ChronosSpacing.sm),
            Text(
              debate.descricao,
              style: ChronosTypography.bodySmall.copyWith(
                color: ChronosColors.textSecondary,
              ),
            ),
            if (debate.posicoes.isNotEmpty) ...[
              const SizedBox(height: ChronosSpacing.sm),
              ...debate.posicoes.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: ChronosColors.textMuted)),
                        Expanded(
                          child: Text(
                            p,
                            style: ChronosTypography.bodySmall.copyWith(
                              color: ChronosColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
