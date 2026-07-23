import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Motor de Quiz inteligente.
///
/// Gera perguntas a partir das entidades, registra acertos, erros e tempo de resposta.
/// Preparado para receber perguntas geradas por IA no futuro.
class QuizEngineService {
  final LearningRepository _repository;
  final String _userId;

  QuizEngineService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Obtém perguntas de quiz para uma entidade.
  Future<List<QuizQuestion>> getQuestions(String entityId, {int limit = 5}) async {
    return _repository.getQuizQuestions(entityId, limit: limit);
  }

  /// Registra resposta do usuário.
  Future<QuizAnswer> submitAnswer({
    required String questionId,
    required String entityId,
    required int selectedIndex,
    required int correctIndex,
    required int responseTimeMs,
  }) async {
    final isCorrect = selectedIndex == correctIndex;
    final answer = QuizAnswer(
      id: '',
      userId: _userId,
      questionId: questionId,
      entityId: entityId,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      answeredAt: DateTime.now(),
    );

    await _repository.saveQuizAnswer(answer);
    return answer;
  }

  /// Obtém estatísticas de quiz do usuário para uma entidade.
  Future<QuizStats> getEntityQuizStats(String entityId) async {
    final answers = await _repository.getQuizHistory(_userId, entityId: entityId);
    if (answers.isEmpty) return const QuizStats.empty();

    final correct = answers.where((a) => a.isCorrect).length;
    final totalTime = answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);

    return QuizStats(
      totalAnswered: answers.length,
      totalCorrect: correct,
      averageResponseTimeMs: totalTime ~/ answers.length,
      accuracy: correct / answers.length,
    );
  }

  /// Obtém estatísticas gerais de quiz do usuário.
  Future<QuizStats> getOverallQuizStats() async {
    final answers = await _repository.getQuizHistory(_userId);
    if (answers.isEmpty) return const QuizStats.empty();

    final correct = answers.where((a) => a.isCorrect).length;
    final totalTime = answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);

    return QuizStats(
      totalAnswered: answers.length,
      totalCorrect: correct,
      averageResponseTimeMs: totalTime ~/ answers.length,
      accuracy: correct / answers.length,
    );
  }
}

/// Estatísticas de quiz.
class QuizStats {
  final int totalAnswered;
  final int totalCorrect;
  final int averageResponseTimeMs;
  final double accuracy;

  const QuizStats({
    required this.totalAnswered,
    required this.totalCorrect,
    required this.averageResponseTimeMs,
    required this.accuracy,
  });

  const QuizStats.empty()
      : totalAnswered = 0,
        totalCorrect = 0,
        averageResponseTimeMs = 0,
        accuracy = 0.0;
}
