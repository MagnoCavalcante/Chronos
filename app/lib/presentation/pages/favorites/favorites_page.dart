import 'package:flutter/material.dart';
import '../../../core/home/home_item.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../controllers/favorites_controller.dart';
import '../../widgets/chronos_empty_view.dart';
import '../../widgets/home_card.dart';

/// Tela de Favoritos do CHRONOS com filtros, pesquisa e ordenação.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final FavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController();
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openItem(HomeItem item) {
    ChronosSnackBar.show(
      context,
      message: 'Abrir detalhes de "${item.title}" (Sprint futura).',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final width = MediaQuery.of(context).size.width - ChronosSpacing.lg * 2;

    return ChronosScaffold(
      title: 'Favoritos',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.lg, vertical: ChronosSpacing.md),
        child: Column(
          children: [
            _buildSearchField(),
            ChronosSpacing.vSizedBoxSM,
            _buildFilterChips(),
            ChronosSpacing.vSizedBoxSM,
            _buildSortDropdown(),
            ChronosSpacing.vSizedBoxMD,
            Expanded(
              child: _buildBody(width, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _controller.setQuery,
      decoration: InputDecoration(
        hintText: 'Pesquisar favoritos...',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(color: ChronosColors.textPrimary),
    );
  }

  Widget _buildFilterChips() {
    final categories = _controller.state.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: _controller.state.filterCategory == null,
            onSelected: (_) => _controller.setFilter(null),
          ),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(left: ChronosSpacing.xs),
              child: ChoiceChip(
                label: Text(category),
                selected: _controller.state.filterCategory == category,
                onSelected: (_) => _controller.setFilter(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButtonFormField<String>(
      value: _controller.state.sortBy,
      decoration: const InputDecoration(labelText: 'Ordenar por', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: 'recentes', child: Text('Mais recentes')),
        DropdownMenuItem(value: 'antigos', child: Text('Mais antigos')),
        DropdownMenuItem(value: 'nome', child: Text('Nome')),
      ],
      onChanged: (value) {
        if (value != null) _controller.setSort(value);
      },
    );
  }

  Widget _buildBody(double width, FavoritesState state) {
    if (state.isLoading && state.filteredFavorites.isEmpty) {
      return _buildSkeletonList();
    }

    if (state.filteredFavorites.isEmpty) {
      return const ChronosEmptyView(
        icon: Icons.bookmark_border_rounded,
        title: 'Nenhum favorito encontrado',
        description: 'Explore o acervo e favorite personagens, eventos, artefatos, localizações e civilizações.',
      );
    }

    return RefreshIndicator(
      color: ChronosColors.accent,
      backgroundColor: ChronosColors.background,
      onRefresh: _controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.filteredFavorites.length,
        separatorBuilder: (_, __) => ChronosSpacing.vSizedBoxSM,
        itemBuilder: (context, index) {
          final item = state.filteredFavorites[index];
          return HomeCard(
            item: item,
            width: width,
            isFavorite: true,
            onTap: () => _openItem(item),
            onFavorite: () => _controller.toggleFavorite(item),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => ChronosSpacing.vSizedBoxSM,
      itemBuilder: (_, __) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: ChronosColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            ChronosSkeleton(width: 120, height: 120, borderRadius: BorderRadius.horizontal(left: Radius.circular(12))),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(ChronosSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChronosSkeleton(width: 180, height: 16),
                    SizedBox(height: 8),
                    ChronosSkeleton(width: 120, height: 12),
                    SizedBox(height: 4),
                    ChronosSkeleton(width: 80, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
