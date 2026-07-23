import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';

/// Seção reutilizável de Curiosidades, Mitos e Equívocos.
class CuriositiesSection extends StatelessWidget {
  final List<HistoricalCuriosity> curiosities;

  const CuriositiesSection({super.key, required this.curiosities});

  @override
  Widget build(BuildContext context) {
    if (curiosities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: ChronosColors.accent, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Você Sabia?',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...curiosities.map(_buildCuriosityCard),
      ],
    );
  }

  Widget _buildCuriosityCard(HistoricalCuriosity curiosity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(ChronosSpacing.md),
        decoration: BoxDecoration(
          color: ChronosColors.surface,
          borderRadius: ChronosRadius.borderRadiusSM,
          border: Border.all(color: ChronosColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeIcon(curiosity.tipo),
                const SizedBox(width: ChronosSpacing.sm),
                Expanded(
                  child: Text(
                    curiosity.titulo,
                    style: ChronosTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ChronosSpacing.sm),
            Text(
              curiosity.conteudo,
              style: ChronosTypography.bodySmall.copyWith(
                color: ChronosColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String tipo) {
    IconData icon;
    Color color;
    switch (tipo) {
      case 'mito':
        icon = Icons.auto_fix_high_rounded;
        color = ChronosColors.warning;
        break;
      case 'equivoco':
        icon = Icons.error_outline_rounded;
        color = ChronosColors.error;
        break;
      default:
        icon = Icons.lightbulb_outline_rounded;
        color = ChronosColors.accent;
    }
    return Icon(icon, size: 18, color: color);
  }
}
