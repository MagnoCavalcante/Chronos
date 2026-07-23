import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';

/// Seção "Pessoas Relacionadas" — card visual com relações entre personagens.
class RelatedPeopleSection extends StatelessWidget {
  final List<KnowledgeRelation> people;
  final ValueChanged<KnowledgeRelation>? onTap;

  const RelatedPeopleSection({
    super.key,
    required this.people,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.people_rounded, color: ChronosColors.primary, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Pessoas Relacionadas',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: people.length,
            separatorBuilder: (_, __) => const SizedBox(width: ChronosSpacing.sm),
            itemBuilder: (context, index) => _buildPersonCard(people[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonCard(KnowledgeRelation person) {
    return GestureDetector(
      onTap: () => onTap?.call(person),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(ChronosSpacing.sm),
        decoration: BoxDecoration(
          color: ChronosColors.surface,
          borderRadius: ChronosRadius.borderRadiusMD,
          border: Border.all(color: ChronosColors.primaryLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: ChronosColors.primaryLight,
              child: Icon(Icons.person_rounded, color: ChronosColors.textPrimary, size: 22),
            ),
            const SizedBox(height: ChronosSpacing.xs),
            Text(
              person.targetName,
              style: ChronosTypography.labelSmall.copyWith(
                color: ChronosColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (person.descricao != null) ...[
              const SizedBox(height: 1),
              Text(
                person.descricao!,
                style: ChronosTypography.labelSmall.copyWith(
                  color: ChronosColors.textMuted,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
