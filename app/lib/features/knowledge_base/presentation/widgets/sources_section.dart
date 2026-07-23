import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/knowledge_entities.dart';
import 'reliability_badge.dart';

/// Seção reutilizável de Fontes e Referências Bibliográficas.
class SourcesSection extends StatelessWidget {
  final List<HistoricalSource> sources;

  const SourcesSection({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: ChronosColors.primary, size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Fontes e Referências',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...sources.map(_buildSourceCard),
      ],
    );
  }

  Widget _buildSourceCard(HistoricalSource source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(ChronosSpacing.md),
        decoration: BoxDecoration(
          color: ChronosColors.surface,
          borderRadius: ChronosRadius.borderRadiusSM,
          border: Border.all(color: ChronosColors.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    source.titulo,
                    style: ChronosTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ReliabilityBadge(level: source.confiabilidade, compact: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              source.autor,
              style: ChronosTypography.bodySmall.copyWith(
                color: ChronosColors.textSecondary,
              ),
            ),
            if (source.livro != null) ...[
              const SizedBox(height: 2),
              Text(
                source.livro!,
                style: ChronosTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ChronosColors.textSecondary,
                ),
              ),
            ],
            if (source.anoPublicacao != null) ...[
              const SizedBox(height: 2),
              Text(
                '${source.anoPublicacao}',
                style: ChronosTypography.bodySmall.copyWith(
                  color: ChronosColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
