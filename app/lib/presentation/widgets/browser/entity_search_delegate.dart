import 'package:flutter/material.dart';
import 'entity_card.dart';
import 'entity_list.dart';
import '../../../core/theme/theme.dart';
import '../chronos_empty_view.dart';

/// Delegate de Pesquisa Nativa unificada e extremamente fluida do Flutter para qualquer Entidade do CHRONOS.
///
/// Oferece suporte completo a acessibilidade, navegação rápida via teclado e atalhos físicos.
class EntitySearchDelegate<T> extends SearchDelegate<T?> {
  final List<T> items;
  final ChronosEntityDisplay Function(T) displayMapper;
  final String searchFieldLabelText;
  final Function(T)? onSelected;

  EntitySearchDelegate({
    required this.items,
    required this.displayMapper,
    this.searchFieldLabelText = 'Pesquisar...',
    this.onSelected,
  }) : super(
          searchFieldLabel: searchFieldLabelText,
          keyboardType: TextInputType.text,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: ChronosColors.surface,
        elevation: 0.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textMuted),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: ChronosColors.textPrimary),
          tooltip: 'Limpar texto',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ChronosColors.textPrimary),
      tooltip: 'Voltar',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFilteredList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFilteredList(context);
  }

  Widget _buildFilteredList(BuildContext context) {
    final filtered = items.where((item) {
      final display = displayMapper(item);
      final cleanQuery = query.toLowerCase().trim();
      return display.title.toLowerCase().contains(cleanQuery) ||
          display.subtitle.toLowerCase().contains(cleanQuery) ||
          (display.description?.toLowerCase().contains(cleanQuery) ?? false) ||
          (display.chronology?.toLowerCase().contains(cleanQuery) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return const ChronosEmptyView(
        icon: Icons.search_off_rounded,
        title: 'Nenhum achado histórico',
        description: 'Tente utilizar outras palavras-chave ou confira se há erros de digitação na busca.',
      );
    }

    return EntityList<T>(
      items: filtered,
      displayMapper: displayMapper,
      viewMode: EntityViewMode.list,
      onTap: (item) {
        if (onSelected != null) {
          onSelected!(item);
        }
        close(context, item);
      },
    );
  }
}
