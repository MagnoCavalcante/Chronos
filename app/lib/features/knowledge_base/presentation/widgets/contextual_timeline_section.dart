import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import '../widgets/reliability_badge.dart';

/// Linha do Tempo Contextual com destaque para Antes/Durante/Depois.
class ContextualTimelineSection extends StatelessWidget {
  final List<TimelineEntry> entries;
  final int? highlightYear;

  const ContextualTimelineSection({
    super.key,
    required this.entries,
    this.highlightYear,
  });

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
        if (highlightYear != null) _buildContextLabels(sorted),
        ...sorted.asMap().entries.map((mapEntry) =>
            _buildEntry(mapEntry.value, mapEntry.key == sorted.length - 1)),
      ],
    );
  }

  Widget _buildContextLabels(List<TimelineEntry> sorted) {
    final before = sorted.where((e) => e.ano < highlightYear!).length;
    final during = sorted.where((e) => e.ano == highlightYear!).length;
    final after = sorted.where((e) => e.ano > highlightYear!).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
      child: Row(
        children: [
          _buildContextChip('Antes', before, ChronosColors.info),
          const SizedBox(width: ChronosSpacing.sm),
          _buildContextChip('Durante', during, ChronosColors.accent),
          const SizedBox(width: ChronosSpacing.sm),
          _buildContextChip('Depois', after, ChronosColors.warning),
        ],
      ),
    );
  }

  Widget _buildContextChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: ChronosRadius.borderRadiusSM,
      ),
      child: Text(
        '$label ($count)',
        style: ChronosTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildEntry(TimelineEntry entry, bool isLast) {
    final isHighlighted = highlightYear != null && entry.ano == highlightYear;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: isHighlighted ? 14 : 12,
                  height: isHighlighted ? 14 : 12,
                  decoration: BoxDecoration(
                    color: isHighlighted ? ChronosColors.accent : ChronosColors.primary,
                    shape: BoxShape.circle,
                    border: isHighlighted
                        ? Border.all(color: ChronosColors.accent, width: 2)
                        : null,
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: ChronosSpacing.md),
              padding: isHighlighted
                  ? const EdgeInsets.all(ChronosSpacing.sm)
                  : null,
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: ChronosColors.accent.withOpacity(0.1),
                      borderRadius: ChronosRadius.borderRadiusSM,
                      border: Border.all(color: ChronosColors.accent.withOpacity(0.3)),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatYear(entry.ano),
                        style: ChronosTypography.labelMedium.copyWith(
                          color: isHighlighted ? ChronosColors.accent : ChronosColors.primary,
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
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
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
