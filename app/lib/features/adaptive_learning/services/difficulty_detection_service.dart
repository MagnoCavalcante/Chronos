import '../../learning/domain/repositories/learning_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';

/// Serviço de Detecção de Dificuldades.
///
/// Identifica automaticamente temas com baixo desempenho.
/// Gera alertas com sugestões de melhoria.
class DifficultyDetectionService {
  final LearningRepository _learningRepo;
  final String _userId;

  /// Limites para detecção.
  static const double _accuracyThreshold = 0.6;
  static const int _pendingReviewsThreshold = 3;
  static const int _excessiveReadTimeThreshold = 1800; // 30 min

  DifficultyDetectionService({
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _learningRepo = learningRepository,
        _userId = userId;

  /// Detecta temas com dificuldade ("Precisam de atenção").
  Future<List<DifficultyAlert>> detectDifficulties() async {
    final alerts = <DifficultyAlert>[];

    // 1. Baixa taxa de acerto
    await _detectLowAccuracy(alerts);

    // 2. Muitas revisões pendentes
    await _detectPendingReviews(alerts);

    // 3. Tempo excessivo de leitura
    await _detectExcessiveReadTime(alerts);

    return alerts;
  }

  /// Verifica se um tópico específico precisa de atenção.
  Future<bool> needsAttention(String entityId) async {
    final answers = await _learningRepo.getQuizHistory(_userId, entityId: entityId);
    if (answers.length < 3) return false;
    final correct = answers.where((a) => a.isCorrect).length;
    return (correct / answers.length) < _accuracyThreshold;
  }

  Future<void> _detectLowAccuracy(List<DifficultyAlert> alerts) async {
    final allAnswers = await _learningRepo.getQuizHistory(_userId);
    final byEntity = <String, List<bool>>{};

    for (final answer in allAnswers) {
      byEntity.putIfAbsent(answer.entityId, () => []);
      byEntity[answer.entityId]!.add(answer.isCorrect);
    }

    for (final entry in byEntity.entries) {
      if (entry.value.length < 3) continue;
      final correct = entry.value.where((c) => c).length;
      final accuracy = correct / entry.value.length;
      if (accuracy < _accuracyThreshold) {
        alerts.add(DifficultyAlert(
          topic: entry.key,
          entityId: entry.key,
          entityType: 'topic',
          reason: DifficultyReason.lowAccuracy,
          metric: accuracy,
          suggestion: 'Revise este conteúdo. Sua taxa de acerto é de '
              '${(accuracy * 100).toStringAsFixed(0)}% (abaixo de ${(_accuracyThreshold * 100).toStringAsFixed(0)}%).',
        ));
      }
    }
  }

  Future<void> _detectPendingReviews(List<DifficultyAlert> alerts) async {
    final reviews = await _learningRepo.getPendingReviews(_userId);
    if (reviews.length >= _pendingReviewsThreshold) {
      // Agrupar por entidade
      final byEntity = <String, int>{};
      for (final r in reviews) {
        byEntity[r.entityId] = (byEntity[r.entityId] ?? 0) + 1;
      }
      for (final entry in byEntity.entries) {
        if (entry.value >= 2) {
          alerts.add(DifficultyAlert(
            topic: entry.key,
            entityId: entry.key,
            entityType: 'topic',
            reason: DifficultyReason.pendingReviews,
            metric: entry.value.toDouble(),
            suggestion: 'Você tem ${entry.value} revisões pendentes deste tema. '
                'Complete as revisões para evitar esquecimento.',
          ));
        }
      }
    }
  }

  Future<void> _detectExcessiveReadTime(List<DifficultyAlert> alerts) async {
    final progress = await _learningRepo.getAllProgress(_userId, limit: 50);
    for (final p in progress) {
      if (p.totalReadTimeSeconds > _excessiveReadTimeThreshold && p.viewCount > 3) {
        alerts.add(DifficultyAlert(
          topic: p.entityName,
          entityId: p.entityId,
          entityType: p.entityType,
          reason: DifficultyReason.excessiveReadTime,
          metric: p.totalReadTimeSeconds.toDouble(),
          suggestion: 'Você passou ${(p.totalReadTimeSeconds / 60).toStringAsFixed(0)} minutos neste conteúdo. '
              'Tente um quiz ou peça ao tutor uma explicação resumida.',
        ));
      }
    }
  }
}
