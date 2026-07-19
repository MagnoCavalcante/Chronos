import '../feature_context.dart';
import 'template_builder.dart';

class UseCaseTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/${context.singularSnake}.dart';
import '../repositories/${context.singularSnake}_repository.dart';

/// Caso de Uso (UseCase) com responsabilidade única de recuperar ${context.featurePascal} ativos(as).
class Get${context.featurePascal}UseCase {
  final ${context.singularPascal}Repository _repository;

  Get${context.featurePascal}UseCase({${context.singularPascal}Repository? repository})
      : _repository = repository ?? locate<${context.singularPascal}Repository>();

  Future<Result<List<${context.singularPascal}>>> call() async {
    return await _repository.getAll${context.featurePascal}();
  }
}
''';
  }
}
