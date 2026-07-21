import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../widgets/chronos_section_header.dart';

/// HomePage unificada para o ecossistema CHRONOS.
///
/// Desenvolvida com base nas diretrizes da camada Experience Layer, utilizando exclusivamente
/// os componentes oficiais reutilizáveis do Design System (ChronosCard, ChronosSectionHeader, etc.).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChronosPage(
      scrollable: true,
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          ChronosSpacing.vSizedBoxLG,
          _buildSearchBarPlaceholder(context),
          ChronosSpacing.vSizedBoxXL,
          const ChronosSectionHeader(
            title: 'Fendas Temporais',
            subtitle: 'Explore o conhecimento através das dimensões da história antiga.',
            icon: Icons.auto_stories_rounded,
          ),
          ChronosSpacing.vSizedBoxMD,
          _buildFeatureGrid(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorar o Tempo',
          style: ChronosTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: ChronosColors.textPrimary,
          ),
        ),
        ChronosSpacing.vSizedBoxXXS,
        Text(
          'Navegue pelas eras e desvende os mistérios da civilização humana.',
          style: ChronosTypography.bodyMedium.copyWith(
            color: ChronosColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarPlaceholder(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Busca Global',
      hint: 'Toque para pesquisar em todo o acervo do CHRONOS',
      child: ChronosCard(
        borderColor: ChronosColors.border,
        borderWidth: 1.0,
        padding: const EdgeInsets.symmetric(
          horizontal: ChronosSpacing.md,
          vertical: ChronosSpacing.md,
        ),
        onTap: () {
          // Mostrar feedback ou redirecionar para a aba de busca futuramente
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A busca unificada global será ativada nas próximas etapas.'),
              backgroundColor: ChronosColors.accent,
            ),
          );
        },
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: ChronosColors.textMuted,
              size: 22,
            ),
            ChronosSpacing.hSizedBoxMD,
            Expanded(
              child: Text(
                'Pesquisar eras, personagens, locais, eventos...',
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textMuted,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ChronosColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: ChronosColors.textMuted,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final List<_FeatureItem> features = [
      _FeatureItem(
        title: 'Eras Históricas',
        description: 'Os grandes marcos cronológicos que dividem a odisseia humana.',
        icon: Icons.hourglass_empty_rounded,
        route: RouteNames.eras,
        accentColor: Colors.amber,
      ),
      _FeatureItem(
        title: 'Eventos Históricos',
        description: 'Batalhas, tratados, descobertas e fendas temporais fundamentais.',
        icon: Icons.history_edu_rounded,
        route: RouteNames.events,
        accentColor: Colors.deepOrange,
      ),
      _FeatureItem(
        title: 'Personagens Notáveis',
        description: 'Líderes, pensadores, reis e heróis que moldaram o rumo do mundo.',
        icon: Icons.people_alt_rounded,
        route: RouteNames.historicalCharacters,
        accentColor: Colors.blueAccent,
      ),
      _FeatureItem(
        title: 'Civilizações Antigas',
        description: 'Impérios, cidades-estado e culturas ancestrais catalogadas.',
        icon: Icons.account_balance_rounded,
        route: RouteNames.civilizations,
        accentColor: Colors.teal,
      ),
      _FeatureItem(
        title: 'Artefatos & Relíquias',
        description: 'Manuscritos, ferramentas, esculturas e invenções fascinantes.',
        icon: Icons.museum_rounded,
        route: RouteNames.artifacts,
        accentColor: Colors.indigo,
      ),
      _FeatureItem(
        title: 'Localizações',
        description: 'Sítios arqueológicos, monumentos e mapas georeferenciados.',
        icon: Icons.public_rounded,
        route: RouteNames.locations,
        accentColor: Colors.green,
      ),
    ];

    return ChronosResponsive(
      mobile: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildFeatureCard(context, features[index]);
        },
      ),
      tablet: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: ChronosSpacing.md,
          mainAxisSpacing: ChronosSpacing.md,
          childAspectRatio: 2.2,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildFeatureCard(context, features[index]);
        },
      ),
      desktop: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: ChronosSpacing.lg,
          mainAxisSpacing: ChronosSpacing.lg,
          childAspectRatio: 2.0,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildFeatureCard(context, features[index]);
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature) {
    return ChronosCard(
      margin: const EdgeInsets.only(bottom: ChronosSpacing.md),
      borderColor: feature.accentColor.withOpacity(0.2),
      borderWidth: 1.0,
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      onTap: () {
        Navigator.of(context).pushNamed(feature.route);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feature.accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature.icon,
              color: feature.accentColor,
              size: 24,
            ),
          ),
          ChronosSpacing.hSizedBoxLG,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  feature.title,
                  style: ChronosTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ChronosColors.textPrimary,
                  ),
                ),
                ChronosSpacing.vSizedBoxXS,
                Text(
                  feature.description,
                  style: ChronosTypography.bodySmall.copyWith(
                    color: ChronosColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.chevron_right_rounded,
              color: ChronosColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;

  const _FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
  });
}
