import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Versionamento de Conteúdo.
///
/// Toda edição gera nova versão. Permite visualizar histórico,
/// comparar versões e restaurar versões anteriores.
class ContentVersionService {
  final AdminRepository _repository;
  static const _tag = 'ContentVersionService';

  ContentVersionService({required AdminRepository repository})
      : _repository = repository;

  /// Obtém histórico de versões de uma entidade.
  Future<List<ContentVersion>> getHistory(String entityId) =>
      _repository.getVersions(entityId);

  /// Obtém uma versão específica.
  Future<ContentVersion?> getVersion(String versionId) =>
      _repository.getVersion(versionId);

  /// Compara duas versões e retorna campos diferentes.
  Future<Map<String, VersionDiff>> compareVersions(
      String versionIdA, String versionIdB) async {
    final a = await _repository.getVersion(versionIdA);
    final b = await _repository.getVersion(versionIdB);
    if (a == null || b == null) return {};

    final diffs = <String, VersionDiff>{};
    final allKeys = {...a.data.keys, ...b.data.keys};

    for (final key in allKeys) {
      final valA = a.data[key]?.toString() ?? '';
      final valB = b.data[key]?.toString() ?? '';
      if (valA != valB) {
        diffs[key] = VersionDiff(
          field: key,
          oldValue: valA,
          newValue: valB,
        );
      }
    }

    ChronosLogger.info(
        'Comparação v${a.versionNumber} vs v${b.versionNumber}: '
        '${diffs.length} diferenças',
        tag: _tag);
    return diffs;
  }

  /// Salva uma nova versão.
  Future<void> saveVersion(ContentVersion version) =>
      _repository.saveVersion(version);

  /// Conta total de versões de uma entidade.
  Future<int> getVersionCount(String entityId) async {
    final versions = await _repository.getVersions(entityId);
    return versions.length;
  }
}

/// Diferença entre dois valores de versão.
class VersionDiff {
  final String field;
  final String oldValue;
  final String newValue;

  const VersionDiff({
    required this.field,
    required this.oldValue,
    required this.newValue,
  });
}
