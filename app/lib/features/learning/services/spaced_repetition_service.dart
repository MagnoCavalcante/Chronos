import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de Revisão Espaçada (Spaced Repetition).
///
/// Implementa algoritmo SM-2 simplificado com intervalos:
/// 1 dia → 3 dias → 7 dias → 15 dias → 30 dias
class SpacedRepetitionService {
  final LearningRepository _repository;
  final String _userId;

  /// Intervalos padrão de revisão em dias.
  static const List<int> defaultIntervals = [1, 3, 7, 15, 30];

  SpacedRepetitionService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Agenda primeira revisão de uma entidade.
  Future<void> scheduleFirstReview({
    required String entityId,
    required String entityType,
    required String entityName,
  }) async {
    final review = ReviewSchedule(
      id: '',
      userId: _userId,
      entityId: entityId,
      entityType: entityType,
      entityName: entityName,
      scheduledFor: DateTime.now().add(const Duration(days: 1)),
      intervalDays: 1,
      repetition: 0,
      easeFactor: 2.5,
    );
    await _repository.scheduleReview(review);
  }

  /// Obtém revisões pendentes para hoje.
  Future<List<ReviewSchedule>> getTodayReviews() async {
    return _repository.getPendingReviews(_userId);
  }

  /// Marca uma revisão como completa e agenda a próxima.
  /// [quality] 0-5 (0=blackout, 5=perfeito) — influencia o próximo intervalo.
  Future<void> completeReview(ReviewSchedule review, {int quality = 4}) async {
    await _repository.completeReview(review.id);

    // Calcular próximo intervalo usando SM-2
    final nextInterval = _calculateNextInterval(
      review.repetition,
      review.intervalDays,
      review.easeFactor,
      quality,
    );

    if (nextInterval != null) {
      final nextReview = ReviewSchedule(
        id: '',
        userId: _userId,
        entityId: review.entityId,
        entityType: review.entityType,
        entityName: review.entityName,
        scheduledFor: DateTime.now().add(Duration(days: nextInterval.days)),
        intervalDays: nextInterval.days,
        repetition: review.repetition + 1,
        easeFactor: nextInterval.easeFactor,
      );
      await _repository.scheduleReview(nextReview);
    }
  }

  /// Verifica se uma entidade tem revisão agendada.
  Future<bool> hasScheduledReview(String entityId) async {
    final reviews = await getTodayReviews();
    return reviews.any((r) => r.entityId == entityId);
  }

  /// Calcula próximo intervalo usando SM-2 simplificado.
  _NextInterval? _calculateNextInterval(
    int repetition,
    int currentInterval,
    double easeFactor,
    int quality,
  ) {
    // Se qualidade < 3, reiniciar ciclo
    if (quality < 3) {
      return _NextInterval(days: 1, easeFactor: easeFactor);
    }

    // Calcular novo ease factor
    final newEF = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    final clampedEF = newEF < 1.3 ? 1.3 : newEF;

    // Calcular próximo intervalo
    int nextDays;
    if (repetition == 0) {
      nextDays = 1;
    } else if (repetition == 1) {
      nextDays = 3;
    } else {
      nextDays = (currentInterval * clampedEF).round();
    }

    // Limitar ao máximo de 30 dias (após isso, considerado dominado)
    if (nextDays > 30) return null; // Dominado, não precisa mais revisar

    return _NextInterval(days: nextDays, easeFactor: clampedEF);
  }
}

class _NextInterval {
  final int days;
  final double easeFactor;

  const _NextInterval({required this.days, required this.easeFactor});
}
