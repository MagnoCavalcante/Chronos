import 'package:flutter/material.dart';
import '../../core/crud/crud_module_configs.dart';
import '../../core/crud/crud_screen.dart';
import '../../presentation/pages/navigation/app_shell.dart';
import '../../presentation/screens/eras_screen.dart';
import '../presentation/widgets/widgets.dart';
import '../theme/theme.dart';
import 'route_names.dart';

/// Centralizador e definidor do Roteamento do ecossistema CHRONOS.
///
/// Todas as rotas nominais devem ser resolvidas através deste roteador para
/// garantir consistência, suporte a Guardas de Rota e manutenibilidade centralizada.
class AppRouter {
  AppRouter._();

  /// Retorna a rota padrão inicial da aplicação.
  static String get initialRoute => RouteNames.home;

  /// Retorna o mapa completo de rotas registradas no sistema.
  static Map<String, WidgetBuilder> get routes => {
        RouteNames.home: (context) => const AppShell(),
        RouteNames.eras: (context) => const ErasScreen(),
        RouteNames.civilizations: (context) => CrudScreen(config: CrudModuleConfigs.civilizations),
        RouteNames.historicalCharacters: (context) => CrudScreen(config: CrudModuleConfigs.historicalCharacters),
        RouteNames.events: (context) => CrudScreen(config: CrudModuleConfigs.historicalEvents),
        RouteNames.artifacts: (context) => CrudScreen(config: CrudModuleConfigs.artifacts),
        RouteNames.locations: (context) => CrudScreen(config: CrudModuleConfigs.historicalLocations),
        RouteNames.sources: (context) => CrudScreen(config: CrudModuleConfigs.historicalSources),
        RouteNames.settings: (context) => const _FutureSprintPlaceholderScreen(
              title: 'Configurações do CHRONOS',
              description: 'O painel de preferências, sincronização offline de dados e ajustes visuais será liberado na Sprint 5.6.',
              icon: Icons.settings_rounded,
            ),
        RouteNames.about: (context) => const _FutureSprintPlaceholderScreen(
              title: 'Sobre o Projeto',
              description: 'O manifesto técnico de engenharia de software do ecossistema CHRONOS será adicionado na Sprint 5.6.',
              icon: Icons.info_outline_rounded,
            ),
      };

  /// Gerador de rotas dinâmicas nativo para tratar parâmetros e falhas de rota.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // Fallback em caso de rota inválida ou não registrada
    return MaterialPageRoute(
      builder: (context) => ChronosScaffold(
        title: 'Recurso Não Encontrado',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(ChronosSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 54,
                ),
                const SizedBox(height: ChronosSpacing.md),
                Text(
                  'Rota inexistente no CHRONOS',
                  style: ChronosTypography.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ChronosSpacing.sm),
                Text(
                  'O caminho nominal "${settings.name}" solicitado não foi mapeado no roteador principal.',
                  style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ChronosSpacing.xl),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tela de placeholder visual de altíssimo nível para recursos em Sprints de entrega futuras.
class _FutureSprintPlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _FutureSprintPlaceholderScreen({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: title,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ChronosSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ChronosColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: ChronosColors.accent,
                  size: 36,
                ),
              ),
              const SizedBox(height: ChronosSpacing.xl),
              Text(
                'Em Desenvolvimento',
                style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ChronosSpacing.md),
              Text(
                description,
                style: ChronosTypography.bodyMedium.copyWith(
                  color: ChronosColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ChronosSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retornar à Base'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChronosColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
