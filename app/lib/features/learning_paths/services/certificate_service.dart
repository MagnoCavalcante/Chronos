import '../domain/entities/learning_path_entities.dart';
import '../domain/repositories/learning_paths_repository.dart';

/// Serviço de Certificados.
///
/// Gera certificados automaticamente ao concluir trilhas.
/// Preparado para exportação em PDF futura.
class CertificateService {
  final LearningPathsRepository _repository;
  final String _userId;

  CertificateService({
    required LearningPathsRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Gera certificado ao concluir uma trilha.
  Future<PathCertificate> issueCertificate({
    required String pathId,
    required String pathName,
    required String userName,
    required int totalTimeSeconds,
    required int totalContentsCompleted,
    required int xpEarned,
  }) async {
    final certificate = PathCertificate(
      id: '',
      userId: _userId,
      userName: userName,
      pathId: pathId,
      pathName: pathName,
      completedAt: DateTime.now(),
      totalTimeSeconds: totalTimeSeconds,
      totalContentsCompleted: totalContentsCompleted,
      xpEarned: xpEarned,
    );

    await _repository.issueCertificate(certificate);
    return certificate;
  }

  /// Obtém todos os certificados do usuário.
  Future<List<PathCertificate>> getCertificates() async {
    return _repository.getCertificates(_userId);
  }

  /// Verifica se o usuário já possui certificado para uma trilha.
  Future<bool> hasCertificate(String pathId) async {
    final certs = await getCertificates();
    return certs.any((c) => c.pathId == pathId);
  }
}
