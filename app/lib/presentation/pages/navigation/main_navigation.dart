import 'package:flutter/material.dart';
import '../../widgets/chronos_empty_view.dart';
import '../favorites/favorites_page.dart';
import '../home/home_page.dart';
import '../timeline/timeline_page.dart';
import '../search/global_search_page.dart';

/// Enum contendo as abas e seções centrais de navegação no CHRONOS.
enum ChronosTab {
  home,
  timeline,
  mapa,
  busca,
  favoritos,
  configuracoes,
}

/// Extensão comercial do enum [ChronosTab] facilitando a extração de rótulos,
/// ícones e widgets correspondentes a cada aba do sistema.
extension ChronosTabExtension on ChronosTab {
  String get label {
    switch (this) {
      case ChronosTab.home:
        return 'Home';
      case ChronosTab.timeline:
        return 'Timeline';
      case ChronosTab.mapa:
        return 'Mapa';
      case ChronosTab.busca:
        return 'Busca';
      case ChronosTab.favoritos:
        return 'Favoritos';
      case ChronosTab.configuracoes:
        return 'Ajustes';
    }
  }

  IconData get icon {
    switch (this) {
      case ChronosTab.home:
        return Icons.explore_outlined;
      case ChronosTab.timeline:
        return Icons.timeline_rounded;
      case ChronosTab.mapa:
        return Icons.map_outlined;
      case ChronosTab.busca:
        return Icons.search_rounded;
      case ChronosTab.favoritos:
        return Icons.bookmark_border_rounded;
      case ChronosTab.configuracoes:
        return Icons.settings_outlined;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case ChronosTab.home:
        return Icons.explore;
      case ChronosTab.timeline:
        return Icons.timeline_rounded;
      case ChronosTab.mapa:
        return Icons.map;
      case ChronosTab.busca:
        return Icons.search_rounded;
      case ChronosTab.favoritos:
        return Icons.bookmark;
      case ChronosTab.configuracoes:
        return Icons.settings;
    }
  }

  Widget buildWidget() {
    switch (this) {
      case ChronosTab.home:
        return const HomePage();
      case ChronosTab.timeline:
        return const TimelinePage();
      case ChronosTab.mapa:
        return const ChronosEmptyView(
          icon: Icons.map_rounded,
          title: 'Map Engine',
          description: 'O mapeador georreferenciado e arqueológico interativo do CHRONOS será integrado na Sprint 5.4.',
        );
      case ChronosTab.busca:
        return const GlobalSearchPage();
      case ChronosTab.favoritos:
        return const FavoritesPage();
      case ChronosTab.configuracoes:
        return const ChronosEmptyView(
          icon: Icons.settings_rounded,
          title: 'Painel do Viajante do Tempo',
          description: 'Ajustes de sincronização, conexões com o Supabase e preferências visuais do aplicativo.',
        );
    }
  }
}
