import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../features/search/domain/entities/search_result.dart';
import '../../../features/search/presentation/controllers/search_controller.dart';
import 'search_result_card.dart';
import 'search_empty.dart';

/// Container dinâmico para renderizar a lista de resultados da busca global.
class SearchResults extends StatelessWidget {
  final List<SearchResultItem> results;
  final String query;
  final List<String> history;
  final List<String> popularSearches;
  final ValueChanged<String>? onSuggestionSelected;
  final VoidCallback? onClearFilters;
  final Future<void> Function()? onLoadMore;

  const SearchResults({
    super.key,
    required this.results,
    required this.query,
    this.history = const [],
    this.popularSearches = const [],
    this.onSuggestionSelected,
    this.onClearFilters,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return SearchEmpty(
        query: query,
        history: history,
        popularSearches: popularSearches,
        onSuggestionSelected: onSuggestionSelected,
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 240) {
                onLoadMore?.call();
              }
              return false;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
              children: _buildSections(results),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSections(List<SearchResultItem> items) {
    final groups = <String, List<SearchResultItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.display.type ?? 'Outros', () => []).add(item);
    }
    final orderedLabels = SearchCategory.values
        .where((c) => c != SearchCategory.all)
        .map((c) => c.label)
        .toList();

    final sections = <Widget>[];
    for (final label in orderedLabels) {
      final group = groups[label];
      if (group == null || group.isEmpty) continue;
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: ChronosSpacing.md, bottom: ChronosSpacing.xs),
          child: Text(
            label.toUpperCase(),
            style: ChronosTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textMuted,
            ),
          ),
        ),
      );
      for (final item in group) {
        sections.add(
          SearchResultCard(
            key: ValueKey('${item.display.id}_${item.display.type}'),
            item: item,
            query: query,
          ),
        );
      }
    }
    return sections;
  }
}
