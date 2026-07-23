import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';

/// Seção reutilizável de Entidades Relacionadas (grafo de conhecimento).
class RelatedEntitiesSection extends StatelessWidget {
  final List<KnowledgeRelation> relations;
  final ValueChanged<KnowledgeRelation>? onTap;

  const RelatedEntitiesSection({
    super.key,
    required this.relations,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relations.isEmpty) return const SizedBox.shrink();

    // Agrupa relações por tipo de entidade alvo
    final grouped = <EntityType, List<KnowledgeRelation>>{};
    for (final r in relations) {
      grouped.putIfAbsent(r.targetType, () => []).add(r);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.hub_rounded, color: ChronosColors.primary, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Conexões',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...grouped.entries.map((entry) => _buildGroup(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildGroup(EntityType type, List<KnowledgeRelation> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.xs, top: ChronosSpacing.sm),
          child: Text(
            _typeLabel(type),
            style: ChronosTypography.labelMedium.copyWith(
              color: ChronosColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: ChronosSpacing.sm,
          runSpacing: ChronosSpacing.xs,
          children: items.map((r) => _buildChip(r)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(KnowledgeRelation relation) {
    return GestureDetector(
      onTap: () => onTap?.call(relation),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ChronosSpacing.sm,
          vertical: ChronosSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _typeColor(relation.targetType).withOpacity(0.1),
          borderRadius: ChronosRadius.borderRadiusSM,
          border: Border.all(color: _typeColor(relation.targetType).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_typeIcon(relation.targetType), size: 14, color: _typeColor(relation.targetType)),
            const SizedBox(width: 4),
            Text(
              relation.targetName,
              style: ChronosTypography.bodySmall.copyWith(
                color: _typeColor(relation.targetType),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(EntityType type) {
    switch (type) {
      case EntityType.character:
        return 'Personagens';
      case EntityType.event:
        return 'Eventos';
      case EntityType.civilization:
        return 'Civilizações';
      case EntityType.artifact:
        return 'Artefatos';
      case EntityType.location:
        return 'Localizações';
      case EntityType.era:
        return 'Eras';
    }
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

  Color _typeColor(EntityType type) {
    switch (type) {
      case EntityType.character:
        return ChronosColors.primary;
      case EntityType.event:
        return ChronosColors.accent;
      case EntityType.civilization:
        return ChronosColors.warning;
      case EntityType.artifact:
        return const Color(0xFF9C27B0);
      case EntityType.location:
        return const Color(0xFF009688);
      case EntityType.era:
        return const Color(0xFF795548);
    }
  }
}
