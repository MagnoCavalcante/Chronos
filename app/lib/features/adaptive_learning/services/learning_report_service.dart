import '../../learning/domain/entities/learning_entities.dart';
import '../../learning/domain/repositories/learning_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';
import '../domain/repositories/adaptive_learning_repository.dart';

/// Serviço de Relatórios de Aprendizagem.
///
/// Gera relatórios semanais e mensais com estatísticas,
/// evolução por tema, recomendações da próxima semana.
class LearningReportService {
  final AdaptiveLearningRepository _adaptiveRepo;
  final LearningRepository _learningRepo;
  final String _userId;

  LearningReportService({
    required AdaptiveLearningRepository adaptiveRepository,
    required LearningRepository learningRepository,
    String userId = 'local_user',
  })  : _adaptiveRepo = adaptiveRepository,
        _learningRepo = learningRepository,
        _userId = userId;

  /// Gera relatório semanal.
  Future<LearningReport> generateWeeklyReport() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1 + 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _generateReport(ReportPeriod.weekly, weekStart, weekEnd);
  }

  /// Gera relatório mensal.
  Future<LearningReport> generateMonthlyReport() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month - 1, 1);
    final monthEnd = DateTime(now.year, now.month, 0);
    return _generateReport(ReportPeriod.monthly, monthStart, monthEnd);
  }

  /// Obtém último relatório.
  Future<LearningReport?> getLatestReport(ReportPeriod period) async {
    return _adaptiveRepo.getLatestReport(_userId, period);
  }

  /// Obtém histórico de relatórios.
  Future<List<LearningReport>> getReports({int limit = 10}) async {
    return _adaptiveRepo.getReports(_userId, limit: limit);
  }

  Future<LearningReport> _generateReport(ReportPeriod period, DateTime start, DateTime end) async {
    final history = await _learningRepo.getHistory(_userId, limit: 500);
    final stats = await _learningRepo.getStats(_userId);
    final quizHistory = await _learningRepo.getQuizHistory(_userId);

    // Filtrar por período
    final periodHistory = history.where((r) =>
        r.startedAt.isAfter(start) && r.startedAt.isBefore(end.add(const Duration(days: 1)))).toList();
    final periodQuiz = quizHistory.where((a) => true).toList(); // Simplificado - idealmente filtrar por data

    // Calcular métricas
    final totalTime = periodHistory.fold(0, (sum, r) => sum + r.durationSeconds);
    final contentsCompleted = periodHistory.where((r) => r.activityType == StudyActivityType.read).length;
    final quizCorrect = periodQuiz.where((a) => a.isCorrect).length;
    final quizAccuracy = periodQuiz.isNotEmpty ? quizCorrect / periodQuiz.length : 0.0;

    // Evolução por tema
    final topicCounts = <String, double>{};
    for (final r in periodHistory) {
      topicCounts[r.entityType] = (topicCounts[r.entityType] ?? 0) + 1;
    }

    // Tópicos dominados e a revisar
    final topicAccuracy = <String, List<bool>>{};
    for (final a in periodQuiz) {
      topicAccuracy.putIfAbsent(a.entityId, () => []);
      topicAccuracy[a.entityId]!.add(a.isCorrect);
    }
    final mastered = topicAccuracy.entries
        .where((e) => e.value.length >= 3 && e.value.where((c) => c).length / e.value.length >= 0.8)
        .map((e) => e.key)
        .toList();
    final toReview = topicAccuracy.entries
        .where((e) => e.value.length >= 3 && e.value.where((c) => c).length / e.value.length < 0.5)
        .map((e) => e.key)
        .toList();

    // Recomendações
    final recommendations = <String>[];
    if (toReview.isNotEmpty) recommendations.add('Revisar temas com dificuldade: ${toReview.take(3).join(", ")}');
    if (totalTime < 1800) recommendations.add('Aumentar tempo de estudo (meta: 30min/dia)');
    if (quizAccuracy < 0.6) recommendations.add('Focar em revisão antes de avançar');
    if (mastered.isNotEmpty) recommendations.add('Avançar para conteúdos mais complexos em: ${mastered.take(2).join(", ")}');

    final report = LearningReport(
      id: '',
      userId: _userId,
      period: period,
      periodStart: start,
      periodEnd: end,
      totalStudyTimeSeconds: totalTime,
      contentsCompleted: contentsCompleted,
      quizAccuracy: quizAccuracy,
      quizAnswered: periodQuiz.length,
      masteredTopics: mastered,
      topicsToReview: toReview,
      topicEvolution: topicCounts,
      recommendations: recommendations,
      generatedAt: DateTime.now(),
    );

    await _adaptiveRepo.saveReport(report);
    return report;
  }
}
