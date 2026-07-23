import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';

/// Seção "Talvez você também queira estudar" — descoberta inteligente.
class DiscoverySection extends StatelessWidget {
  final List<KnowledgeRelation> suggestions;
  final ValueChanged<KnowledgeRelation>? onTap;

  const DiscoverySection({
    super.key,
    required this.suggestions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.explore_rounded, color: ChronosColors.info, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Talvez você também queira estudar',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: ChronosSpacing.sm,
          runSpacing: ChronosSpacing.sm,
          children: suggestions.map(_buildSuggestion).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestion(KnowledgeRelation relation) {
    return GestureDetector(
      onTap: () => onTap?.call(relation),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ChronosSpacing.md,
          vertical: ChronosSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: ChronosColors.info.withOpacity(0.08),
          borderRadius: ChronosRadius.borderRadiusSM,
          border: Border.all(color: ChronosColors.info.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_typeIcon(relation.targetType), size: 14, color: ChronosColors.info),
            const SizedBox(width: ChronosSpacing.xs),
            Text(
              relation.targetName,
              style: ChronosTypography.bodySmall.copyWith(
                color: ChronosColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(EntityType type) {
    switch (type) {
      case EntityType.character:
        return Icons.person_rounded;
      case EntityType.event:
        return Icons.event_rounded;
      case EntityType.civilization:
        return Icons.account_balance_rounded;
      case EntityType.artifact:
        return Icons.diamond_rounded;
      case EntityType.location:
        return Icons.place_rounded;
      case EntityType.era:
        return Icons.timeline_rounded;
    }
  }
}
