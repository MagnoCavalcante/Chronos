import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_search_bar.dart';

/// Barra de pesquisa superior integrada da busca global do CHRONOS.
class SearchInputBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String query;

  const SearchInputBar({
    super.key,
    required this.onChanged,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.md,
        vertical: ChronosSpacing.sm,
      ),
      child: ChronosSearchBar(
        onChanged: onChanged,
        initialValue: query,
        hintText: 'Pesquisar personagens, eras, civilizações, eventos, locais, artefatos e fontes...',
      ),
    );
  }
}
