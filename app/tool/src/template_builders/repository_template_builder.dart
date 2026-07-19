import '../feature_context.dart';

class RepositoryTemplateBuilder {
  String buildInterface(FeatureContext context) {
    return '''import 'package:chronos/core/utils/result.dart';
import '../entities/${context.singularSnake}.dart';

/// Contrato (Interface) de Repositório de ${context.singularPascal} para o ecossistema CHRONOS.
abstract class ${context.singularPascal}Repository {
  /// Recupera todos(as) os(as) ${context.featurePascal} publicados(as) e ativos(as).
  Future<Result<List<${context.singularPascal}>>> getAll${context.featurePascal}();
}
''';
  }

  String buildImplementation(FeatureContext context) {
    return '''import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/${context.singularSnake}.dart';
import '../../domain/repositories/${context.singularSnake}_repository.dart';
import '../datasources/${context.singularSnake}_remote_datasource.dart';

/// Implementação concreta do repositório de ${context.singularPascal} na camada de Dados (Data Layer).
class ${context.singularPascal}RepositoryImpl implements ${context.singularPascal}Repository {
  final ${context.singularPascal}RemoteDataSource _remoteDataSource;
  static const String _tag = '${context.singularPascal}RepositoryImpl';

  ${context.singularPascal}RepositoryImpl({${context.singularPascal}RemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? locate<${context.singularPascal}RemoteDataSource>();

  @override
  Future<Result<List<${context.singularPascal}>>> getAll${context.featurePascal}() async {
    ChronosLogger.info(
      'Iniciando a operação de carregamento de todos(as) os(as) ${context.featurePascal}...',
      tag: _tag,
    );

    try {
      final models = await _remoteDataSource.getAll${context.featurePascal}();

      ChronosLogger.info(
        'Operação concluída com sucesso! Total de registros carregados: \${models.length}',
        tag: _tag,
      );

      return Result.success(List.unmodifiable(models));
    } on ${context.singularPascal}DataSourceException catch (e) {
      ChronosLogger.error(
        'Falha ocorrida na fonte de dados de ${context.featureCamel}. Tipo de Exceção: \${e.type}. Mensagem: \${e.message}',
        tag: _tag,
        error: e.originalError,
      );

      Failure failure;
      switch (e.type) {
        case ${context.singularPascal}DataSourceErrorType.network:
          failure = NetworkFailure(e.message, originalError: e.originalError);
          break;
        case ${context.singularPascal}DataSourceErrorType.authentication:
          failure = AuthenticationFailure(e.message, originalError: e.originalError);
          break;
        case ${context.singularPascal}DataSourceErrorType.database:
          failure = DatabaseFailure(e.message, originalError: e.originalError);
          break;
        case ${context.singularPascal}DataSourceErrorType.emptyResponse:
          failure = ValidationFailure(e.message, originalError: e);
          break;
        case ${context.singularPascal}DataSourceErrorType.unknown:
          failure = UnknownFailure(e.message, originalError: e.originalError);
          break;
      }
      return Result.failure(failure);
    } catch (e) {
      ChronosLogger.error(
        'Erro inesperado na ponte de dados do repositório de ${context.featureCamel}: \$e',
        tag: _tag,
        error: e,
      );

      return Result.failure(UnknownFailure(
        'Erro inesperado na ponte de dados do repositório: \$e',
        originalError: e,
      ));
    }
  }
}
''';
  }
}
