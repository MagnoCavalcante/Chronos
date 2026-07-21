import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'search_controller.dart';
import 'search_result_card.dart';
import 'search_empty.dart';

/// Container dinâmico para renderizar a lista de resultados da busca global.
class SearchResults extends StatelessWidget {
  final List<SearchResultItem> results;
  final String query;
  final VoidCallback? onClearFilters;

  const SearchResults({
    super.key,
    required this.results,
    required this.query,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return SearchEmpty(
        query: query,
        onClearFilters: onClearFilters,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha com contador de resultados
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ChronosSpacing.md,
            vertical: ChronosSpacing.xs,
          ),
          child: Text(
            '${results.length} ${results.length == 1 ? 'resultado encontrado' : 'resultados encontrados'}',
            style: ChronosTypography.codeSmall.copyWith(
              color: ChronosColors.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Lista rolável de resultados
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return SearchResultCard(
                key: ValueKey('${item.display.id}_${item.display.type}'),
                item: item,
                query: query,
              );
            },
          ),
        ),
      ],
    );
  }
}
