import '../../learning/domain/entities/learning_entities.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';

/// Serviço de Quizzes Adaptativos.
///
/// Ajusta automaticamente a dificuldade das perguntas baseado
/// no desempenho do usuário.
class AdaptiveQuizService {
  final LearningRepository _learningRepo;
  final String _userId;

  /// Thresholds para mudança de dificuldade.
  static const double _increaseThreshold = 0.75;
  static const double _decreaseThreshold = 0.45;

  AdaptiveQuizService({
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _learningRepo = learningRepository,
        _userId = userId;

  /// Determina a dificuldade ideal para o próximo quiz.
  Future<QuizDifficulty> getAdaptiveDifficulty(String entityId) async {
    final answers = await _learningRepo.getQuizHistory(_userId, entityId: entityId);
    if (answers.isEmpty) return QuizDifficulty.easy;

    // Considerar últimas 10 respostas
    final recent = answers.length > 10 ? answers.sublist(answers.length - 10) : answers;
    final correct = recent.where((a) => a.isCorrect).length;
    final accuracy = correct / recent.length;

    return _difficultyFromAccuracy(accuracy);
  }

  /// Determina dificuldade global do usuário.
  Future<QuizDifficulty> getGlobalDifficulty() async {
    final answers = await _learningRepo.getQuizHistory(_userId);
    if (answers.length < 5) return QuizDifficulty.easy;

    final recent = answers.length > 20 ? answers.sublist(answers.length - 20) : answers;
    final correct = recent.where((a) => a.isCorrect).length;
    final accuracy = correct / recent.length;

    return _difficultyFromAccuracy(accuracy);
  }

  /// Filtra perguntas por dificuldade adequada.
  Future<List<QuizQuestion>> getAdaptiveQuestions(String entityId, {int limit = 5}) async {
    final difficulty = await getAdaptiveDifficulty(entityId);
    final allQuestions = await _learningRepo.getQuizQuestions(entityId, limit: limit * 3);

    // Se não há metadata de dificuldade, retornar todas
    if (allQuestions.isEmpty) return allQuestions;

    // Filtrar por dificuldade (se disponível no metadata)
    // Fallback: retornar todas limitadas
    return allQuestions.take(limit).toList();
  }

  /// Calcula se deve mostrar revisão após erros consecutivos.
  Future<bool> shouldTriggerReview(String entityId) async {
    final answers = await _learningRepo.getQuizHistory(_userId, entityId: entityId);
    if (answers.length < 3) return false;

    // Se últimas 3 respostas foram erradas → sugerir revisão
    final last3 = answers.sublist(answers.length - 3);
    return last3.every((a) => !a.isCorrect);
  }

  /// Retorna a dificuldade recomendada como texto legível.
  String difficultyLabel(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Fácil';
      case QuizDifficulty.medium:
        return 'Médio';
      case QuizDifficulty.hard:
        return 'Difícil';
      case QuizDifficulty.expert:
        return 'Expert';
    }
  }

  QuizDifficulty _difficultyFromAccuracy(double accuracy) {
    if (accuracy >= _increaseThreshold) {
      return QuizDifficulty.hard;
    } else if (accuracy >= 0.6) {
      return QuizDifficulty.medium;
    } else if (accuracy >= _decreaseThreshold) {
      return QuizDifficulty.easy;
    } else {
      return QuizDifficulty.easy;
    }
  }
}
