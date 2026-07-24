import '../../learning/domain/repositories/learning_repository.dart';
import '../../learning_paths/domain/repositories/learning_paths_repository.dart';
import '../domain/entities/adaptive_learning_entities.dart';
import '../domain/repositories/adaptive_learning_repository.dart';

/// Serviço de Planos de Estudo Personalizados.
///
/// Gera automaticamente um plano semanal baseado no perfil,
/// objetivo, tempo disponível e progresso atual.
class StudyPlanService {
  final AdaptiveLearningRepository _adaptiveRepo;
  final LearningRepository _learningRepo;
  final LearningPathsRepository _pathsRepo;
  final String _userId;

  StudyPlanService({
    required AdaptiveLearningRepository adaptiveRepository,
    required LearningRepository learningRepository,
    required LearningPathsRepository pathsRepository,
    String userId = 'local_user',
  })  : _adaptiveRepo = adaptiveRepository,
        _learningRepo = learningRepository,
        _pathsRepo = pathsRepository,
        _userId = userId;

  /// Gera plano semanal personalizado.
  Future<StudyPlan> generateWeeklyPlan({
    required LearnerProfile profile,
  }) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final minutesPerDay = profile.availableMinutesPerDay;

    final dailyPlans = <DailyPlan>[];

    for (int day = 1; day <= 7; day++) {
      final items = await _generateDayItems(
        profile: profile,
        dayOfWeek: day,
        availableMinutes: minutesPerDay,
      );
      dailyPlans.add(DailyPlan(
        dayOfWeek: day,
        items: items,
        estimatedMinutes: items.fold(0, (sum, i) => sum + i.estimatedMinutes),
      ));
    }

    // Calcular XP alvo
    final totalItems = dailyPlans.fold(0, (sum, d) => sum + d.items.length);
    final targetXp = totalItems * 15;

    final plan = StudyPlan(
      id: '',
      userId: _userId,
      title: _generateTitle(profile),
      objective: profile.primaryObjective,
      availableMinutesPerDay: minutesPerDay,
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailyPlans: dailyPlans,
      targetXp: targetXp,
      createdAt: now,
    );

    await _adaptiveRepo.savePlan(plan);
    return plan;
  }

  /// Obtém plano atual.
  Future<StudyPlan?> getCurrentPlan() async {
    return _adaptiveRepo.getCurrentPlan(_userId);
  }

  Future<List<PlanItem>> _generateDayItems({
    required LearnerProfile profile,
    required int dayOfWeek,
    required int availableMinutes,
  }) async {
    final items = <PlanItem>[];
    var remainingMinutes = availableMinutes;

    // 1. Revisões pendentes (20% do tempo)
    final reviews = await _learningRepo.getPendingReviews(_userId);
    final reviewBudget = (availableMinutes * 0.2).round();
    for (final review in reviews.take(2)) {
      if (remainingMinutes <= 0) break;
      final time = reviewBudget ~/ 2;
      items.add(PlanItem(
        entityId: review.entityId,
        entityType: review.entityType,
        entityName: review.entityName,
        type: PlanItemType.review,
        estimatedMinutes: time.clamp(5, 15),
      ));
      remainingMinutes -= time;
    }

    // 2. Quiz (10% do tempo)
    if (remainingMinutes > 5) {
      final quizTime = (availableMinutes * 0.1).round().clamp(5, 10);
      final recentHistory = await _learningRepo.getRecentHistory(_userId, limit: 3);
      if (recentHistory.isNotEmpty) {
        items.add(PlanItem(
          entityId: recentHistory.first.entityId,
          entityType: recentHistory.first.entityType,
          entityName: recentHistory.first.entityName,
          type: PlanItemType.quiz,
          estimatedMinutes: quizTime,
        ));
        remainingMinutes -= quizTime;
      }
    }

    // 3. Conteúdo novo (70% do tempo)
    if (remainingMinutes > 5) {
      final inProgressPaths = await _pathsRepo.getInProgressPaths(_userId);
      if (inProgressPaths.isNotEmpty) {
        final pathProgress = inProgressPaths.first;
        final path = await _pathsRepo.getPath(pathProgress.pathId);
        if (path != null && path.modules.isNotEmpty) {
          for (final module in path.modules) {
            if (remainingMinutes <= 5) break;
            for (final content in module.contents) {
              if (remainingMinutes <= 5) break;
              final time = (remainingMinutes / 2).round().clamp(5, 15);
              items.add(PlanItem(
                entityId: content.entityId,
                entityType: content.entityType,
                entityName: content.entityName,
                type: PlanItemType.read,
                estimatedMinutes: time,
              ));
              remainingMinutes -= time;
            }
          }
        }
      }
    }

    return items;
  }

  String _generateTitle(LearnerProfile profile) {
    switch (profile.primaryObjective) {
      case StudyObjective.enem:
        return 'Plano ENEM - Semana';
      case StudyObjective.vestibular:
        return 'Plano Vestibular - Semana';
      case StudyObjective.university:
        return 'Plano Universitário - Semana';
      case StudyObjective.professional:
        return 'Plano Profissional - Semana';
      case StudyObjective.curiosity:
        return 'Plano de Estudo - Semana';
    }
  }
}
