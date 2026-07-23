import 'package:flutter/material.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'main_navigation.dart';

/// AppShell oficial e responsiva do ecossistema CHRONOS.
///
/// Atua como a casca estrutural (Shell Layout) e o roteador principal de abas reativo.
/// Responsável por gerenciar AppBar, BottomNavigationBar (Mobile), NavigationRail (Tablet/Desktop)
/// e injetar as áreas de conteúdo da Experience Layer sem quebrar em diferentes dispositivos.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  ChronosTab _currentTab = ChronosTab.home;

  @override
  Widget build(BuildContext context) {
    return ChronosResponsive(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  /// Constrói o visual móvel otimizado com AppBar dedicada e BottomNavigationBar persistente.
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: _buildAppBar(isMobile: true),
      body: _buildPageTransitionBody(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ChronosColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab.index,
          onTap: (index) {
            setState(() {
              _currentTab = ChronosTab.values[index];
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: ChronosColors.surface,
          selectedItemColor: ChronosColors.accent,
          unselectedItemColor: ChronosColors.textMuted,
          selectedLabelStyle: ChronosTypography.labelSmall.copyWith(color: ChronosColors.accent),
          unselectedLabelStyle: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
          items: ChronosTab.values.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.selectedIcon),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Constrói o visual para tablets utilizando trilhos de navegação laterais compactos (NavigationRail).
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      body: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: ChronosColors.border, width: 1.0),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _currentTab.index,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTab = ChronosTab.values[index];
                });
              },
              backgroundColor: ChronosColors.surface,
              selectedIconTheme: const IconThemeData(color: ChronosColors.accent),
              unselectedIconTheme: const IconThemeData(color: ChronosColors.textMuted),
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: ChronosTypography.labelSmall.copyWith(color: ChronosColors.accent),
              unselectedLabelTextStyle: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.explore_rounded,
                    color: ChronosColors.accent,
                    size: 32,
                  ),
                ),
              ),
              destinations: ChronosTab.values.map((tab) {
                return NavigationRailDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: Text(tab.label),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: ChronosColors.background,
              appBar: _buildAppBar(isMobile: false),
              body: _buildPageTransitionBody(),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o visual desktop amplo com menu de navegação robusto lateral estendido de alto nível.
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: ChronosColors.surface,
              border: Border(
                right: BorderSide(color: ChronosColors.border, width: 1.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarHeader(),
                const Divider(color: ChronosColors.border, height: 1.0),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md, horizontal: ChronosSpacing.sm),
                    children: ChronosTab.values.map((tab) {
                      final bool isSelected = _currentTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Material(
                          color: isSelected ? ChronosColors.accent.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                          child: ListTile(
                            dense: true,
                            onTap: () {
                              setState(() {
                                _currentTab = tab;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            leading: Icon(
                              isSelected ? tab.selectedIcon : tab.icon,
                              color: isSelected ? ChronosColors.accent : ChronosColors.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              tab.label,
                              style: ChronosTypography.bodyMedium.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? ChronosColors.textPrimary : ChronosColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _buildSidebarFooter(),
              ],
            ),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: ChronosColors.background,
              appBar: _buildAppBar(isMobile: false),
              body: _buildPageTransitionBody(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool isMobile}) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile) ...[
            const Icon(
              Icons.explore_rounded,
              color: ChronosColors.accent,
              size: 24,
            ),
            ChronosSpacing.hSizedBoxSM,
          ],
          Text(
            'CHRONOS',
            style: ChronosTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: ChronosColors.textPrimary,
            ),
          ),
        ],
      ),
      centerTitle: isMobile,
      backgroundColor: ChronosColors.surface,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      shape: const Border(
        bottom: BorderSide(color: ChronosColors.border, width: 1.0),
      ),
      actions: [
        ChronosIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notificações',
          onPressed: () {},
        ),
        ChronosIconButton(
          icon: Icons.account_circle_outlined,
          tooltip: 'Perfil',
          onPressed: () => Navigator.of(context).pushNamed(RouteNames.profile),
        ),
        ChronosSpacing.hSizedBoxMD,
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.xl, vertical: ChronosSpacing.xl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ChronosColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: ChronosColors.accent,
              size: 24,
            ),
          ),
          ChronosSpacing.hSizedBoxMD,
          Text(
            'CHRONOS',
            style: ChronosTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: ChronosColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return const Padding(
      padding: EdgeInsets.all(ChronosSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHRONOS v5.0.0',
            style: ChronosTypography.codeSmall,
          ),
          SizedBox(height: 2),
          Text(
            'Conectado à fenda temporal',
            style: TextStyle(fontSize: 10, color: ChronosColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTransitionBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.01, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<ChronosTab>(_currentTab),
        child: _currentTab.buildWidget(),
      ),
    );
  }
}
