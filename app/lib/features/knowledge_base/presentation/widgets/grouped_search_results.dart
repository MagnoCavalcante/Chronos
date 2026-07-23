import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import '../../services/knowledge_graph_service.dart';

/// Widget de resultados de busca agrupados por tipo de entidade.
class GroupedSearchResults extends StatelessWidget {
  final GroupedSearchResult result;
  final ValueChanged<KnowledgeEntry>? onEntryTap;

  const GroupedSearchResults({
    super.key,
    required this.result,
    this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: ChronosColors.textMuted),
            const SizedBox(height: ChronosSpacing.md),
            Text(
              'Nenhum resultado para "${result.query}"',
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    // Ordem de exibição dos grupos
    final order = [
      EntityType.character,
      EntityType.event,
      EntityType.civilization,
      EntityType.artifact,
      EntityType.location,
      EntityType.era,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
          child: Text(
            '${result.totalCount} resultado${result.totalCount != 1 ? 's' : ''} para "${result.query}"',
            style: ChronosTypography.bodySmall.copyWith(
              color: ChronosColors.textMuted,
            ),
          ),
        ),
        ...order
            .where((t) => result.groups.containsKey(t))
            .map((t) => _buildGroup(t, result.groups[t]!)),
      ],
    );
  }

  Widget _buildGroup(EntityType type, List<KnowledgeEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
          child: Row(
            children: [
              Icon(_typeIcon(type), size: 16, color: _typeColor(type)),
              const SizedBox(width: ChronosSpacing.xs),
              Text(
                _typeLabel(type),
                style: ChronosTypography.labelMedium.copyWith(
                  color: _typeColor(type),
                ),
              ),
              const SizedBox(width: ChronosSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _typeColor(type).withOpacity(0.15),
                  borderRadius: ChronosRadius.borderRadiusSM,
                ),
                child: Text(
                  '${entries.length}',
                  style: ChronosTypography.labelSmall.copyWith(
                    color: _typeColor(type),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...entries.map((e) => _buildEntryItem(e, type)),
        const SizedBox(height: ChronosSpacing.sm),
      ],
    );
  }

  Widget _buildEntryItem(KnowledgeEntry entry, EntityType type) {
    return GestureDetector(
      onTap: () => onEntryTap?.call(entry),
      child: Padding(
        padding: const EdgeInsets.only(bottom: ChronosSpacing.xs),
        child: Container(
          padding: const EdgeInsets.all(ChronosSpacing.md),
          decoration: BoxDecoration(
            color: ChronosColors.surface,
            borderRadius: ChronosRadius.borderRadiusSM,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.nome,
                      style: ChronosTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.periodoHistorico != null)
                      Text(
                        entry.periodoHistorico!,
                        style: ChronosTypography.bodySmall.copyWith(
                          color: ChronosColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: ChronosColors.textMuted),
            ],
          ),
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
