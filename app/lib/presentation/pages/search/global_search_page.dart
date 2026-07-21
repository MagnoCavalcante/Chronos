import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_page.dart';
import '../../widgets/chronos_loading_view.dart';
import '../../widgets/chronos_error_view.dart';
import 'search_controller.dart';
import 'search_bar.dart';
import 'search_filters.dart';
import 'search_results.dart';
import 'search_loading.dart';

/// Tela unificada e interativa de Busca Global do CHRONOS.
///
/// Desenvolvida como parte do EPIC 3 da Experience Layer e sob a metodologia
/// Content-Driven Development. Permite filtrar e ordenar dinamicamente as entidades
/// reais indexadas do Knowledge Engine.
class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  late final ChronosSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = locate<ChronosSearchController>();

    // Dispara a carga e indexação de dados de forma assíncrona após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ChronosPage(
            scrollable: false, // Controle de scroll interno nas sub-visões
            padding: EdgeInsets.zero,
            onRefresh: () async {
              _controller.dispose();
              final newController = locate<ChronosSearchController>();
              await newController.initialize();
            },
            child: Column(
              children: [
                // Barra Superior de Entrada de Pesquisa
                SearchInputBar(
                  query: _controller.query,
                  onChanged: _controller.updateQuery,
                ),

                // Filtros de Categoria e Opções de Ordenação
                SearchFilters(
                  selectedCategory: _controller.selectedCategory,
                  selectedSort: _controller.selectedSort,
                  onCategoryChanged: _controller.updateCategory,
                  onSortChanged: _controller.updateSort,
                ),

                // Área do Conteúdo Principal Dinâmico
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Resolve o Widget apropriado de acordo com o estado do motor de busca
  Widget _buildMainContent() {
    if (_controller.isLoading && !_controller.isInitialized) {
      return const ChronosLoadingView(
        message: 'Indexando acervo de fendas temporais...',
        icon: Icons.travel_explore_rounded,
      );
    }

    if (_controller.errorMessage != null) {
      return ChronosErrorView(
        message: _controller.errorMessage,
        onRetry: () => _controller.initialize(),
      );
    }

    if (_controller.isLoading && _controller.isInitialized) {
      return const SearchLoading();
    }

    return SearchResults(
      results: _controller.filteredResults,
      query: _controller.query,
      onClearFilters: () {
        _controller.updateQuery('');
        _controller.updateCategory('Todos');
        _controller.updateSort('Relevância');
      },
    );
  }
}
