import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import 'reliability_badge.dart';

/// Seção reutilizável de Consenso Acadêmico.
class ConsensusSection extends StatelessWidget {
  final AcademicConsensus consensus;

  const ConsensusSection({super.key, required this.consensus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: ChronosColors.primary, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Consenso Acadêmico',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(ChronosSpacing.md),
          decoration: BoxDecoration(
            color: ChronosColors.primary.withOpacity(0.05),
            borderRadius: ChronosRadius.borderRadiusMD,
            border: Border.all(color: ChronosColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReliabilityBadge(level: consensus.nivel),
              const SizedBox(height: ChronosSpacing.sm),
              Text(
                consensus.resumo,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
