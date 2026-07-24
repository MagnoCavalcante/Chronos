import '../domain/repositories/adaptive_learning_repository.dart';

/// Serviço de Privacidade.
///
/// Permite ao usuário exportar ou excluir todos os dados
/// de aprendizagem de forma segura.
class LearningPrivacyService {
  final AdaptiveLearningRepository _repository;
  final String _userId;

  LearningPrivacyService({
    required AdaptiveLearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Exporta todos os dados do usuário (perfil, recomendações, planos, relatórios).
  Future<Map<String, dynamic>> exportAllData() async {
    return _repository.exportAllData(_userId);
  }

  /// Exclui todos os dados de aprendizagem do usuário.
  Future<void> deleteAllData() async {
    await _repository.deleteAllData(_userId);
  }

  /// Verifica se o usuário tem dados armazenados.
  Future<bool> hasStoredData() async {
    final profile = await _repository.getProfile(_userId);
    return profile != null;
  }
}
