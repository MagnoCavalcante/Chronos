import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço da Biblioteca de Mídia.
///
/// Gerencia imagens, vídeos, documentos, áudios e miniaturas.
/// Organização por pastas e tags.
class MediaLibraryService {
  final AdminRepository _repository;
  static const _tag = 'MediaLibraryService';

  MediaLibraryService({required AdminRepository repository})
      : _repository = repository;

  /// Lista mídias com filtros opcionais.
  Future<List<MediaAsset>> list({
    MediaType? type,
    String? folder,
    int limit = 50,
  }) =>
      _repository.listMedia(type: type, folder: folder, limit: limit);

  /// Registra um novo arquivo de mídia.
  Future<MediaAsset> upload({
    required String fileName,
    required String url,
    required MediaType type,
    required String uploadedBy,
    int sizeBytes = 0,
    String? folder,
    List<String> tags = const [],
    String? altText,
    int? width,
    int? height,
  }) async {
    final now = DateTime.now();
    final asset = MediaAsset(
      id: '${now.millisecondsSinceEpoch}_media',
      fileName: fileName,
      url: url,
      type: type,
      sizeBytes: sizeBytes,
      folder: folder,
      tags: tags,
      uploadedBy: uploadedBy,
      altText: altText,
      width: width,
      height: height,
      createdAt: now,
    );

    final saved = await _repository.saveMedia(asset);

    await _repository.logAudit(AuditLogEntry(
      id: '${now.millisecondsSinceEpoch}_upload',
      userId: uploadedBy,
      action: AuditActionType.create,
      entityName: fileName,
      details: {'type': type.name, 'size': sizeBytes, 'folder': folder},
      createdAt: now,
    ));

    ChronosLogger.info('Mídia registrada: $fileName ($type)', tag: _tag);
    return saved;
  }

  /// Exclui mídia.
  Future<void> delete({
    required String mediaId,
    required String userId,
  }) async {
    await _repository.deleteMedia(mediaId);
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_deleteMedia',
      userId: userId,
      action: AuditActionType.delete,
      entityId: mediaId,
      entityName: 'media',
      createdAt: DateTime.now(),
    ));
    ChronosLogger.info('Mídia excluída: $mediaId', tag: _tag);
  }

  /// Lista pastas distintas.
  Future<List<String>> listFolders() async {
    final allMedia = await _repository.listMedia(limit: 500);
    final folders = <String>{};
    for (final m in allMedia) {
      if (m.folder != null && m.folder!.isNotEmpty) {
        folders.add(m.folder!);
      }
    }
    return folders.toList()..sort();
  }

  /// Busca mídia por tags.
  Future<List<MediaAsset>> searchByTags(List<String> tags) async {
    final allMedia = await _repository.listMedia(limit: 500);
    return allMedia
        .where((m) => tags.any((t) => m.tags.contains(t)))
        .toList();
  }
}
