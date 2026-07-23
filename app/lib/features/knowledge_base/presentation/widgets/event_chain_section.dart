import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import '../../services/knowledge_graph_service.dart';

/// Seção de Cadeia de Acontecimentos.
/// Mostra: Antecedentes → Evento Atual → Consequências → Eventos Posteriores
class EventChainSection extends StatelessWidget {
  final String currentName;
  final EventChainData chain;
  final ValueChanged<KnowledgeRelation>? onTap;

  const EventChainSection({
    super.key,
    required this.currentName,
    required this.chain,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (chain.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: ChronosColors.info, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Cadeia de Acontecimentos',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Antecedentes
        if (chain.before.isNotEmpty) ...[
          _buildLabel('Eventos Anteriores'),
          ...chain.before.map((r) => _buildChainItem(r, false)),
          _buildArrow(),
        ],
        // Evento atual
        _buildCurrentEvent(currentName),
        // Consequências
        if (chain.after.isNotEmpty) ...[
          _buildArrow(),
          _buildLabel('Consequências'),
          ...chain.after.map((r) => _buildChainItem(r, false)),
        ],
        // Contemporâneos
        if (chain.during.isNotEmpty) ...[
          const SizedBox(height: ChronosSpacing.md),
          _buildLabel('Eventos Contemporâneos'),
          ...chain.during.map((r) => _buildChainItem(r, true)),
        ],
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.xs),
      child: Text(
        text,
        style: ChronosTypography.labelMedium.copyWith(
          color: ChronosColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildChainItem(KnowledgeRelation relation, bool isDuring) {
    return GestureDetector(
      onTap: () => onTap?.call(relation),
      child: Padding(
        padding: const EdgeInsets.only(bottom: ChronosSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ChronosSpacing.md,
            vertical: ChronosSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: ChronosColors.surface,
            borderRadius: ChronosRadius.borderRadiusSM,
            border: Border.all(
              color: isDuring
                  ? ChronosColors.info.withOpacity(0.3)
                  : ChronosColors.accent.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isDuring ? Icons.compare_arrows_rounded : Icons.event_rounded,
                size: 16,
                color: isDuring ? ChronosColors.info : ChronosColors.accent,
              ),
              const SizedBox(width: ChronosSpacing.sm),
              Expanded(
                child: Text(
                  relation.targetName,
                  style: ChronosTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: ChronosColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentEvent(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.md,
        vertical: ChronosSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ChronosColors.accent.withOpacity(0.15),
        borderRadius: ChronosRadius.borderRadiusMD,
        border: Border.all(color: ChronosColors.accent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 18, color: ChronosColors.accent),
          const SizedBox(width: ChronosSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: ChronosTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: ChronosColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.xs),
      child: Center(
        child: Icon(Icons.arrow_downward_rounded, size: 20, color: ChronosColors.accent),
      ),
    );
  }
}
