import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';

/// Seção "Continue Estudando" — recomendações baseadas no grafo de conhecimento.
class ContinueStudyingSection extends StatelessWidget {
  final List<KnowledgeRelation> suggestions;
  final ValueChanged<KnowledgeRelation>? onTap;

  const ContinueStudyingSection({
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
              Icon(Icons.auto_stories_rounded, color: ChronosColors.accent, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Continue Estudando',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: ChronosSpacing.sm),
            itemBuilder: (context, index) => _buildCard(suggestions[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(KnowledgeRelation relation) {
    return GestureDetector(
      onTap: () => onTap?.call(relation),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(ChronosSpacing.sm),
        decoration: BoxDecoration(
          color: ChronosColors.surface,
          borderRadius: ChronosRadius.borderRadiusMD,
          border: Border.all(color: ChronosColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _typeIcon(relation.targetType),
              size: 18,
              color: ChronosColors.accent,
            ),
            const SizedBox(height: ChronosSpacing.xs),
            Text(
              relation.targetName,
              style: ChronosTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: ChronosColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _typeLabel(relation.targetType),
              style: ChronosTypography.labelSmall.copyWith(
                color: ChronosColors.textMuted,
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

  String _typeLabel(EntityType type) {
    switch (type) {
      case EntityType.character:
        return 'Personagem';
      case EntityType.event:
        return 'Evento';
      case EntityType.civilization:
        return 'Civilização';
      case EntityType.artifact:
        return 'Artefato';
      case EntityType.location:
        return 'Localização';
      case EntityType.era:
        return 'Era';
    }
  }
}
