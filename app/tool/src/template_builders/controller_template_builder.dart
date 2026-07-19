import '../feature_context.dart';
import 'template_builder.dart';

class ControllerTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/${context.singularSnake}.dart';
import '../../domain/usecases/get_${context.featureName}_usecase.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para ${context.featurePascal}.
///
/// Herda de [BaseController<List<${context.singularPascal}>>] para gerenciar de forma limpa e unificada
/// os estados de carregamento, erro, vazio e atualização automática com medição de performance.
class ${context.featurePascal}Controller extends BaseController<List<${context.singularPascal}>> {
  final Get${context.featurePascal}UseCase _get${context.featurePascal}UseCase;

  ${context.featurePascal}Controller({
    Get${context.featurePascal}UseCase? useCase,
  }) : _get${context.featurePascal}UseCase = useCase ?? locate<Get${context.featurePascal}UseCase>(),
       super(initialData: const []);

  /// Getter auxiliar para compatibilidade e listagem de itens.
  List<${context.singularPascal}> get items => data ?? const [];

  /// Mapeamento de erro para manter compatibilidade com nomes de propriedades da UI.
  Failure? get failure => error;

  /// Método reativo para disparar a carga da coleção de ${context.featurePascal}.
  Future<void> load${context.featurePascal}() async {
    await execute(
      () => _get${context.featurePascal}UseCase(),
      tag: '${context.featurePascal}Controller',
    );
  }

  @override
  Future<void> retry() async {
    await load${context.featurePascal}();
  }

  @override
  Future<void> refresh() async {
    await load${context.featurePascal}();
  }
}
''';
  }
}
