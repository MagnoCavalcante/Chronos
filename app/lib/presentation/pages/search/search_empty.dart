import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_chip.dart';
import '../../../core/presentation/widgets/chronos_empty_state.dart';

/// Tela ou estado de busca vazia, cobrindo dois cenários:
/// 1. Estado Inicial de Boas-Vindas (sem query de busca).
/// 2. Estado de Sem Resultados (com query que não encontrou correspondências).
class SearchEmpty extends StatelessWidget {
  final String query;
  final List<String> history;
  final List<String> popularSearches;
  final ValueChanged<String>? onSuggestionSelected;
  final VoidCallback? onClearFilters;

  const SearchEmpty({
    super.key,
    required this.query,
    this.history = const [],
    this.popularSearches = const [],
    this.onSuggestionSelected,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInitialState = query.trim().isEmpty;

    if (isInitialState) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(ChronosSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(ChronosSpacing.lg),
              decoration: BoxDecoration(
                color: ChronosColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ChronosColors.accent.withValues(alpha: 0.15),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                size: 48,
                color: ChronosColors.accent,
              ),
            ),
            ChronosSpacing.vSizedBoxLG,
            Text(
              'Explorador do Acervo Temporal',
              style: ChronosTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: ChronosColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            ChronosSpacing.vSizedBoxSM,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
              child: Text(
                'Digite termos históricos ou navegue pelas abas para iniciar uma indexação e varredura profunda em Eras, Eventos, Figuras e Artefatos reais.',
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (history.isNotEmpty) ...[
              ChronosSpacing.vSizedBoxLG,
              _buildSectionTitle('Pesquisas recentes'),
              ChronosSpacing.vSizedBoxSM,
              _buildChips(history),
            ],
            if (popularSearches.isNotEmpty) ...[
              ChronosSpacing.vSizedBoxLG,
              _buildSectionTitle('Pesquisas populares'),
              ChronosSpacing.vSizedBoxSM,
              _buildChips(popularSearches),
            ],
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ChronosSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: ChronosColors.textMuted,
            ),
            ChronosSpacing.vSizedBoxLG,
            Text(
              'Nenhuma fenda temporal encontrada',
              style: ChronosTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: ChronosColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            ChronosSpacing.vSizedBoxSM,
            Text(
              'Não localizamos registros para "$query" nos parâmetros e filtros selecionados.',
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onClearFilters != null) ...[
              ChronosSpacing.vSizedBoxMD,
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Limpar Filtros e Termo'),
                style: TextButton.styleFrom(
                  foregroundColor: ChronosColors.accent,
                  textStyle: ChronosTypography.labelMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: ChronosTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: ChronosColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChips(List<String> items) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: ChronosSpacing.sm,
        runSpacing: ChronosSpacing.sm,
        children: items.map((item) {
          return ChronosChip(
            label: item,
            onTap: onSuggestionSelected == null ? null : () => onSuggestionSelected!(item),
          );
        }).toList(),
      ),
    );
  }
}
