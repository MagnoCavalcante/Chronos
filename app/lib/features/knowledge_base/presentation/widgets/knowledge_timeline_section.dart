import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import 'reliability_badge.dart';

/// Seção reutilizável de Linha do Tempo de uma entidade.
class KnowledgeTimelineSection extends StatelessWidget {
  final List<TimelineEntry> entries;

  const KnowledgeTimelineSection({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final sorted = List<TimelineEntry>.from(entries)..sort((a, b) => a.ano.compareTo(b.ano));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.timeline_rounded, color: ChronosColors.primary, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Linha do Tempo',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...sorted.asMap().entries.map((mapEntry) => _buildEntry(mapEntry.value, mapEntry.key == sorted.length - 1)),
      ],
    );
  }

  Widget _buildEntry(TimelineEntry entry, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ChronosColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ChronosColors.primary.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: ChronosSpacing.sm),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatYear(entry.ano),
                        style: ChronosTypography.labelMedium.copyWith(
                          color: ChronosColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: ChronosSpacing.sm),
                      if (entry.confiabilidade != ReliabilityLevel.fact)
                        ReliabilityBadge(level: entry.confiabilidade, compact: true),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.titulo,
                    style: ChronosTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entry.descricao != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.descricao!,
                      style: ChronosTypography.bodySmall.copyWith(
                        color: ChronosColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatYear(int year) {
    if (year < 0) return '${year.abs()} a.C.';
    return '$year d.C.';
  }
}
