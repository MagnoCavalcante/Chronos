import '../feature_context.dart';
import 'template_builder.dart';

class ScreenTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import 'package:flutter/material.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';
import '../../domain/entities/${context.singularSnake}.dart';
import '../controllers/${context.featureName}_controller.dart';
import '../widgets/${context.singularSnake}_card.dart';
import '../widgets/${context.singularSnake}_empty.dart';
import '../widgets/${context.singularSnake}_error.dart';
import '../widgets/${context.singularSnake}_loading.dart';

/// Tela principal para exibição, busca e navegação de ${context.featurePascal} do CHRONOS.
class ${context.featurePascal}Screen extends StatefulWidget {
  final ${context.featurePascal}Controller? controller;

  const ${context.featurePascal}Screen({
    super.key,
    this.controller,
  });

  @override
  State<${context.featurePascal}Screen> createState() => _${context.featurePascal}ScreenState();
}

class _${context.featurePascal}ScreenState extends State<${context.featurePascal}Screen> {
  late final ${context.featurePascal}Controller _controller;
  static const String _tag = '${context.featurePascal}Screen';

  @override
  void initState() {
    super.initState();
    ChronosLogger.info('Iniciando ciclo de vida da tela de ${context.featurePascal}...', tag: _tag);

    _controller = widget.controller ?? locate<${context.featurePascal}Controller>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load${context.featurePascal}();
    });
  }

  @override
  void dispose() {
    ChronosLogger.info('Liberando recursos e saindo da tela de ${context.featurePascal}.', tag: _tag);
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ChronosLogger.info('Disparando atualização manual de ${context.featureCamel}...', tag: _tag);
    final stopwatch = Stopwatch()..start();
    await _controller.load${context.featurePascal}();
    stopwatch.stop();
    ChronosLogger.info('Atualização manual de ${context.featureCamel} finalizada em \${stopwatch.elapsedMilliseconds}ms.', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'CHRONOS — ${context.featurePascal}',
      actions: [
        ChronosIconButton(
          tooltip: 'Sincronizar',
          icon: ChronosIcons.sync,
          onPressed: _handleRefresh,
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ChronosPage(
            onRefresh: _handleRefresh,
            child: _buildBodyContent(),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const ${context.singularPascal}Loading();
    }

    if (_controller.hasError) {
      return ${context.singularPascal}Error(
        failure: _controller.failure!,
        onRetry: _controller.load${context.featurePascal},
      );
    }

    if (_controller.isEmpty) {
      return ${context.singularPascal}Empty(
        onRefresh: _controller.load${context.featurePascal},
      );
    }

    final itemsList = _controller.items;
    return ChronosList<${context.singularPascal}>(
      items: itemsList,
      showSeparator: false,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.sm, vertical: ChronosSpacing.xs),
      itemBuilder: (context, item, index) {
        return ${context.singularPascal}Card(
          item: item,
          onTap: () {
            ChronosSnackBar.show(
              context,
              message: 'Visualizando detalhes do item "\${item.nome}".',
              type: ChronosSnackBarType.info,
            );
          },
        );
      },
    );
  }
}
''';
  }
}
