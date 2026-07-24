import '../../domain/entities/adaptive_learning_entities.dart';
import '../../domain/repositories/adaptive_learning_repository.dart';
import '../datasources/adaptive_learning_remote_datasource.dart';

class AdaptiveLearningRepositoryImpl implements AdaptiveLearningRepository {
  final AdaptiveLearningRemoteDataSource _remote;

  AdaptiveLearningRepositoryImpl({required AdaptiveLearningRemoteDataSource remote}) : _remote = remote;

  @override
  Future<LearnerProfile?> getProfile(String userId) async {
    final data = await _remote.fetchProfile(userId);
    if (data == null) return null;
    return LearnerProfile.fromJson(data);
  }

  @override
  Future<void> upsertProfile(LearnerProfile profile) async {
    await _remote.upsertProfile(profile.toJson()..remove('id'));
  }

  @override
  Future<List<LearnerProfile>> getProfileHistory(String userId) async {
    final data = await _remote.fetchProfileHistory(userId);
    return data.map(LearnerProfile.fromJson).toList();
  }

  @override
  Future<List<AdaptiveRecommendation>> getRecommendations(String userId, {int limit = 10}) async {
    final data = await _remote.fetchRecommendations(userId, limit: limit);
    return data.map(AdaptiveRecommendation.fromJson).toList();
  }

  @override
  Future<void> saveRecommendations(List<AdaptiveRecommendation> recommendations) async {
    final data = recommendations.map((r) => r.toJson()..remove('id')).toList();
    await _remote.insertRecommendations(data);
  }

  @override
  Future<void> dismissRecommendation(String recommendationId) async {
    await _remote.dismissRecommendation(recommendationId);
  }

  @override
  Future<void> clearRecommendations(String userId) async {
    await _remote.clearRecommendations(userId);
  }

  @override
  Future<StudyPlan?> getCurrentPlan(String userId) async {
    final data = await _remote.fetchCurrentPlan(userId);
    if (data == null) return null;
    return StudyPlan.fromJson(data);
  }

  @override
  Future<void> savePlan(StudyPlan plan) async {
    await _remote.upsertPlan(plan.toJson()..remove('id'));
  }

  @override
  Future<List<StudyPlan>> getPlanHistory(String userId, {int limit = 10}) async {
    final data = await _remote.fetchPlanHistory(userId, limit: limit);
    return data.map(StudyPlan.fromJson).toList();
  }

  @override
  Future<LearningReport?> getLatestReport(String userId, ReportPeriod period) async {
    final data = await _remote.fetchLatestReport(userId, period.name);
    if (data == null) return null;
    return LearningReport.fromJson(data);
  }

  @override
  Future<void> saveReport(LearningReport report) async {
    await _remote.insertReport(report.toJson()..remove('id'));
  }

  @override
  Future<List<LearningReport>> getReports(String userId, {int limit = 10}) async {
    final data = await _remote.fetchReports(userId, limit: limit);
    return data.map(LearningReport.fromJson).toList();
  }

  @override
  Future<Map<String, dynamic>> exportAllData(String userId) async {
    return _remote.exportAllData(userId);
  }

  @override
  Future<void> deleteAllData(String userId) async {
    await _remote.deleteAllData(userId);
  }
}
