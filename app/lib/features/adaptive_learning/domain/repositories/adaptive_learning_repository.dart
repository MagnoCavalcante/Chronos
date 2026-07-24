import '../entities/adaptive_learning_entities.dart';

/// Contrato do repositório de Adaptive Learning.
abstract class AdaptiveLearningRepository {
  // Perfil
  Future<LearnerProfile?> getProfile(String userId);
  Future<void> upsertProfile(LearnerProfile profile);
  Future<List<LearnerProfile>> getProfileHistory(String userId);

  // Recomendações
  Future<List<AdaptiveRecommendation>> getRecommendations(String userId, {int limit = 10});
  Future<void> saveRecommendations(List<AdaptiveRecommendation> recommendations);
  Future<void> dismissRecommendation(String recommendationId);
  Future<void> clearRecommendations(String userId);

  // Plano de estudo
  Future<StudyPlan?> getCurrentPlan(String userId);
  Future<void> savePlan(StudyPlan plan);
  Future<List<StudyPlan>> getPlanHistory(String userId, {int limit = 10});

  // Relatórios
  Future<LearningReport?> getLatestReport(String userId, ReportPeriod period);
  Future<void> saveReport(LearningReport report);
  Future<List<LearningReport>> getReports(String userId, {int limit = 10});

  // Privacy
  Future<Map<String, dynamic>> exportAllData(String userId);
  Future<void> deleteAllData(String userId);
}
