import '../feature_context.dart';
import 'template_builder.dart';

class DataSourceTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chronos/core/config/supabase_config.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../models/${context.singularSnake}_model.dart';

/// Tipos de erro de infraestrutura técnica ocorridos em chamadas de servidores remotos,
/// APIs ou bancos de dados específicos da fonte de dados de ${context.featureCamel}.
enum ${context.singularPascal}DataSourceErrorType {
  network,
  authentication,
  database,
  emptyResponse,
  unknown,
}

/// Exceção técnica específica para a infraestrutura de DataSources de ${context.singularPascal} no ecossistema CHRONOS.
class ${context.singularPascal}DataSourceException implements Exception {
  final String message;
  final ${context.singularPascal}DataSourceErrorType type;
  final Object? originalError;

  const ${context.singularPascal}DataSourceException({
    required this.message,
    required this.type,
    this.originalError,
  });

  const ${context.singularPascal}DataSourceException.network(this.message, {this.originalError})
      : type = ${context.singularPascal}DataSourceErrorType.network;

  const ${context.singularPascal}DataSourceException.authentication(this.message, {this.originalError})
      : type = ${context.singularPascal}DataSourceErrorType.authentication;

  const ${context.singularPascal}DataSourceException.database(this.message, {this.originalError})
      : type = ${context.singularPascal}DataSourceErrorType.database;

  const ${context.singularPascal}DataSourceException.emptyResponse(this.message)
      : type = ${context.singularPascal}DataSourceErrorType.emptyResponse,
        originalError = null;

  const ${context.singularPascal}DataSourceException.unknown(this.message, {this.originalError})
      : type = ${context.singularPascal}DataSourceErrorType.unknown;

  @override
  String toString() => '${context.singularPascal}DataSourceException[\$type]: \$message';
}

/// Contrato de fonte de dados remota de ${context.singularPascal} (${context.featurePascal}).
abstract class ${context.singularPascal}RemoteDataSource {
  /// Recupera todos(as) os(as) ${context.featurePascal} ativos(as) e publicados(as).
  ///
  /// Retorna uma lista imutável de [${context.singularPascal}Model].
  /// Lança uma [${context.singularPascal}DataSourceException] em caso de falha física ou de rede.
  Future<List<${context.singularPascal}Model>> getAll${context.featurePascal}();
}

/// Implementação concreta da fonte de dados remota de ${context.featurePascal} utilizando o cliente oficial do Supabase.
class ${context.singularPascal}RemoteDataSourceImpl implements ${context.singularPascal}RemoteDataSource {
  final SupabaseClient _client;
  static const String _tag = '${context.singularPascal}RemoteDataSource';

  ${context.singularPascal}RemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<List<${context.singularPascal}Model>> getAll${context.featurePascal}() async {
    ChronosLogger.info('Iniciando consulta remota de ${context.featureCamel}...', tag: _tag);

    try {
      final List<dynamic> response = await _client
          .from('${context.featureName}')
          .select()
          .eq('ativo', true)
          .eq('publication_status', PublicationStatus.published.value)
          .order('nome', ascending: true);

      if (response.isEmpty) {
        const errorMsg = 'Nenhum(a) ${context.singularPascal} ativo(a) e publicado(a) foi localizado(a).';
        ChronosLogger.warn(errorMsg, tag: _tag);
        throw const ${context.singularPascal}DataSourceException.emptyResponse(errorMsg);
      }

      final models = response
          .map((item) => ${context.singularPascal}Model.fromJson(item as Map<String, dynamic>))
          .toList();

      ChronosLogger.info(
        'Consulta de ${context.featureCamel} concluída com sucesso! Total de registros: \${models.length}',
        tag: _tag,
      );

      return List.unmodifiable(models);
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301') {
        final errorMsg = 'Acesso não autorizado aos dados de ${context.featureCamel}: \${e.message}';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ${context.singularPascal}DataSourceException.authentication(
          errorMsg,
          originalError: e,
        );
      }
      
      final errorMsg = 'Erro de banco de dados ao buscar ${context.featureCamel}: \${e.message} (Código: \${e.code})';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ${context.singularPascal}DataSourceException.database(
        errorMsg,
        originalError: e,
      );
    } catch (e) {
      if (e is ${context.singularPascal}DataSourceException) rethrow;

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socketexception') ||
          errorStr.contains('connection failed') ||
          errorStr.contains('network') ||
          errorStr.contains('xmlhttprequest')) {
        final errorMsg = 'Falha de conectividade de rede ao comunicar com o servidor Supabase.';
        ChronosLogger.error(errorMsg, tag: _tag, error: e);
        throw ${context.singularPascal}DataSourceException.network(
          errorMsg,
          originalError: e,
        );
      }

      final errorMsg = 'Erro inesperado na fonte de dados de ${context.featureCamel}: \$e';
      ChronosLogger.error(errorMsg, tag: _tag, error: e);
      throw ${context.singularPascal}DataSourceException.unknown(
        errorMsg,
        originalError: e,
      );
    }
  }
}
''';
  }
}
