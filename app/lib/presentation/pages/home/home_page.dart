import 'package:flutter/material.dart';
import '../../../core/home/home_item.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../../core/navigation/route_names.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/chronos_section_header.dart';
import '../../widgets/home_card.dart';
import '../favorites/favorites_page.dart';
import '../search/global_search_page.dart';

/// HomePage inteligente e dinâmica para o ecossistema CHRONOS.
///
/// Apresenta conteúdo baseado no banco de dados: continue explorando, destaques,
/// sugestão aleatória, linha do tempo e carrosséis por categoria.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
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

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GlobalSearchPage()),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FavoritesPage()),
    );
  }

  void _openSettings() {
    Navigator.of(context).pushNamed(RouteNames.settings);
  }

  void _openItem(HomeItem item) {
    _controller.onItemOpened(item);
    ChronosSnackBar.show(
      context,
      message: 'Abrir detalhes de "${item.title}" (Sprint futura).',
    );
  }

  Widget _buildContinueStudyingCard(HomeItem item) {
    return ChronosCard(
      onTap: () => _openItem(item),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill_rounded, color: ChronosColors.accent, size: 40),
        title: Text(item.title, style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(
          item.category ?? 'Em estudo',
          style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: ChronosColors.textMuted),
      ),
    );
  }

  void _surpriseMe() {
    _controller.surpriseMe().then((_) {
      final surprise = _controller.state.surprise;
      if (surprise != null && mounted) {
        ChronosSnackBar.show(
          context,
          message: 'Surpreenda-me: ${surprise.title}',
        );
      }
    });
  }

  void _openEraSearch(String label) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GlobalSearchPage()),
    );
    ChronosSnackBar.show(
      context,
      message: 'Pesquisa filtrada por "$label" será aplicada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return ChronosPage(
      scrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.lg, vertical: ChronosSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          ChronosSpacing.vSizedBoxLG,
          _buildSearchBar(context),
          ChronosSpacing.vSizedBoxLG,
          if (state.continueStudying != null) ...[
            const ChronosSectionHeader(title: 'Continue Estudando', icon: Icons.play_circle_fill_rounded),
            ChronosSpacing.vSizedBoxSM,
            _buildContinueStudyingCard(state.continueStudying!),
            ChronosSpacing.vSizedBoxLG,
          ],
          if (state.recommendations.isNotEmpty || state.isLoading) ...[
            const ChronosSectionHeader(title: 'Recomendado para você', icon: Icons.lightbulb_rounded),
            ChronosSpacing.vSizedBoxSM,
            _buildHorizontalList(state.recommendations, loading: state.isLoading),
            ChronosSpacing.vSizedBoxLG,
          ],
          if (state.continueExploring.isNotEmpty || state.isLoading) ...[
            const ChronosSectionHeader(title: 'Continue Explorando', icon: Icons.history_rounded),
            ChronosSpacing.vSizedBoxSM,
            _buildHorizontalList(state.continueExploring, loading: state.isLoading),
            ChronosSpacing.vSizedBoxLG,
          ],
          const ChronosSectionHeader(title: 'Destaques da Semana', icon: Icons.star_rounded),
          ChronosSpacing.vSizedBoxSM,
          _buildHorizontalList(state.highlights, loading: state.isLoading),
          ChronosSpacing.vSizedBoxLG,
          _buildSurpriseMeCard(context),
          ChronosSpacing.vSizedBoxLG,
          const ChronosSectionHeader(title: 'Linha do Tempo', icon: Icons.timeline_rounded),
          ChronosSpacing.vSizedBoxSM,
          _buildTimelineCarousel(),
          ChronosSpacing.vSizedBoxLG,
          ..._buildCategorySections(state),
          if (state.error != null) ...[
            ChronosSpacing.vSizedBoxLG,
            Text(state.error!, style: ChronosTypography.bodyMedium.copyWith(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const Icon(Icons.explore_rounded, size: 40),
        ),
        ChronosSpacing.hSizedBoxSM,
        Expanded(
          child: Text(
            'CHRONOS',
            style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ChronosIconButton(
          tooltip: 'Favoritos',
          icon: Icons.bookmark_border_rounded,
          onPressed: _openFavorites,
        ),
        ChronosIconButton(
          tooltip: 'Configurações',
          icon: Icons.settings_outlined,
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Busca Global',
      child: ChronosCard(
        borderColor: ChronosColors.border,
        borderWidth: 1.0,
        padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.md),
        onTap: _openSearch,
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: ChronosColors.textMuted, size: 22),
            ChronosSpacing.hSizedBoxMD,
            Expanded(
              child: Text(
                'Pesquisar eras, personagens, locais, eventos...',
                style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textMuted),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: ChronosColors.surfaceLight, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.tune_rounded, color: ChronosColors.textMuted, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<HomeItem> items, {required bool loading}) {
    if (loading && items.isEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
          itemBuilder: (_, __) => _SkeletonCard(),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Nenhum item encontrado.')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
        itemBuilder: (context, index) {
          final item = items[index];
          final isFav = _controller.state.favorites.any((f) => f.entityId == item.entityId);
          return HomeCard(
            item: item,
            isFavorite: isFav,
            onTap: () => _openItem(item),
            onFavorite: () => _controller.toggleFavorite(item),
          );
        },
      ),
    );
  }

  Widget _buildSurpriseMeCard(BuildContext context) {
    return ChronosCard(
      onTap: _surpriseMe,
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChronosColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.casino_rounded, color: ChronosColors.accent),
          ),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Surpreenda-me',
                  style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Descubra um personagem, evento, artefato, localização ou civilização aleatórios.',
                  style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: ChronosColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildTimelineCarousel() {
    final eras = [
      _TimelineEra('Pré-História', Icons.landscape_rounded),
      _TimelineEra('Antiguidade', Icons.account_balance_rounded),
      _TimelineEra('Idade Média', Icons.castle_rounded),
      _TimelineEra('Idade Moderna', Icons.explore_rounded),
      _TimelineEra('Idade Contemporânea', Icons.rocket_launch_rounded),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: eras.length,
        separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
        itemBuilder: (context, index) {
          final era = eras[index];
          return SizedBox(
            width: 120,
            child: ChronosChip(
              label: era.label,
              leadingIcon: era.icon,
              onTap: () => _openEraSearch(era.label),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCategorySections(HomeState state) {
    return state.categories.entries.expand((entry) {
      final items = entry.value;
      return [
        ChronosSectionHeader(title: entry.key, icon: _iconForCategory(entry.key)),
        ChronosSpacing.vSizedBoxSM,
        _buildHorizontalList(items, loading: state.isLoading),
        ChronosSpacing.vSizedBoxLG,
      ];
    }).toList();
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Civilizações':
        return Icons.account_balance_rounded;
      case 'Personagens':
        return Icons.people_alt_rounded;
      case 'Eventos':
        return Icons.history_edu_rounded;
      case 'Artefatos':
        return Icons.museum_rounded;
      case 'Localizações':
        return Icons.public_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }
}

class _TimelineEra {
  final String label;
  final IconData icon;

  const _TimelineEra(this.label, this.icon);
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: ChronosColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChronosSkeleton(width: 160, height: 100, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          Padding(
            padding: EdgeInsets.all(ChronosSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChronosSkeleton(width: 120, height: 14),
                SizedBox(height: 8),
                ChronosSkeleton(width: 80, height: 12),
                SizedBox(height: 4),
                ChronosSkeleton(width: 60, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
