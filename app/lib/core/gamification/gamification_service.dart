import 'dart:async';
import '../utils/logger.dart';
import 'achievements_repository.dart';
import 'challenges_repository.dart';
import 'gamification_models.dart';
import 'level_calculator.dart';
import 'notification_service.dart';
import 'profile_repository.dart';
import 'special_collection_service.dart';
import 'titles_repository.dart';
import 'weekly_summary_repository.dart';
import 'xp_repository.dart';

/// Serviço central de gamificação.
///
/// Coordena ganho de XP, sequência, desafios, conquistas, títulos e resumos.
/// Não utiliza mocks: todos os valores são persistidos no Supabase e sincronizados.
class GamificationService {
  final ProfileRepository _profileRepository;
  final XpRepository _xpRepository;
  final AchievementsRepository _achievementsRepository;
  final ChallengesRepository _challengesRepository;
  final TitlesRepository _titlesRepository;
  final WeeklySummaryRepository _weeklySummaryRepository;
  final NotificationService _notificationService;
  final SpecialCollectionService _specialCollectionService;

  GamificationService({
    ProfileRepository? profileRepository,
    XpRepository? xpRepository,
    AchievementsRepository? achievementsRepository,
    ChallengesRepository? challengesRepository,
    TitlesRepository? titlesRepository,
    WeeklySummaryRepository? weeklySummaryRepository,
    NotificationService? notificationService,
    SpecialCollectionService? specialCollectionService,
  })  : _profileRepository = profileRepository ?? ProfileRepository(),
        _xpRepository = xpRepository ?? XpRepository(),
        _achievementsRepository = achievementsRepository ?? AchievementsRepository(),
        _challengesRepository = challengesRepository ?? ChallengesRepository(),
        _titlesRepository = titlesRepository ?? TitlesRepository(),
        _weeklySummaryRepository = weeklySummaryRepository ?? WeeklySummaryRepository(),
        _notificationService = notificationService ?? GamificationNotificationService.instance,
        _specialCollectionService = specialCollectionService ?? SpecialCollectionService();

  /// Retorna perfil gamificado, criando o padrão se necessário.
  Future<UserProfile?> getOrCreateProfile() async {
    return _profileRepository.getProfile();
  }

  /// Retorna dados resumidos para o card da Home.
  Future<HomeGamificationSummary> getHomeSummary() async {
    final profile = await getOrCreateProfile();
    final challenges = await _challengesRepository.getActiveChallenges();
    return HomeGamificationSummary(
      profile: profile,
      challenges: challenges,
      dailyXp: await _dailyXp(),
    );
  }

  /// Registra visualização de conteúdo: +2 XP.
  Future<GamificationEventResult> onViewContent({String? entityType, String? entityId}) async {
    final xp = await _xpRepository.addXp(
      amount: 2,
      source: XpSource.viewContent,
      referenceId: entityId,
      description: 'Visualizou $entityType/$entityId',
    );
    await _challengesRepository.progressChallenge(ChallengeCriteriaType.viewCount, 1);
    await _updateProfileAndTitles(xp.totalXp, xp.currentLevel);
    return await _buildResult(xp);
  }

  /// Registra conclusão de estudo: +10 XP e atualiza sequência.
  Future<GamificationEventResult> onStudyCompleted({String? entityType, String? entityId, int minutes = 0}) async {
    final xp = await _xpRepository.addXp(
      amount: 10,
      source: XpSource.completeStudy,
      referenceId: entityId,
      description: 'Concluiu estudo de $entityType/$entityId',
    );
    await _updateStreak();
    await _challengesRepository.progressChallenge(ChallengeCriteriaType.completeCount, 1);
    await _challengesRepository.progressChallenge(ChallengeCriteriaType.studyMinutes, minutes);
    await _updateProfileAndTitles(xp.totalXp, xp.currentLevel);
    await _checkAchievements(xp.currentLevel);
    return await _buildResult(xp);
  }

  /// Registra conclusão de coleção: +50 XP.
  Future<GamificationEventResult> onCollectionCompleted(String collectionId) async {
    final xp = await _xpRepository.addXp(
      amount: 50,
      source: XpSource.completeCollection,
      referenceId: collectionId,
      description: 'Concluiu coleção $collectionId',
    );
    await _challengesRepository.progressChallenge(ChallengeCriteriaType.createCollection, 1);
    await _updateProfileAndTitles(xp.totalXp, xp.currentLevel);
    await _checkAchievements(xp.currentLevel);
    return await _buildResult(xp);
  }

  /// Registra pesquisa.
  Future<GamificationEventResult> onSearch() async {
    await _challengesRepository.progressChallenge(ChallengeCriteriaType.searchCount, 1);
    return GamificationEventResult();
  }

  /// Registra meta diária concluída: +20 XP.
  Future<GamificationEventResult> onDailyGoalCompleted() async {
    final xp = await _xpRepository.addXp(
      amount: 20,
      source: XpSource.dailyGoal,
      description: 'Meta diária concluída',
    );
    await _updateProfileAndTitles(xp.totalXp, xp.currentLevel);
    return await _buildResult(xp);
  }

  /// Registra conclusão de desafio: +100 XP.
  Future<GamificationEventResult> onChallengeCompleted(String challengeId) async {
    final xp = await _xpRepository.addXp(
      amount: 100,
      source: XpSource.challenge,
      referenceId: challengeId,
      description: 'Desafio concluído: $challengeId',
    );
    await _updateProfileAndTitles(xp.totalXp, xp.currentLevel);
    return await _buildResult(xp);
  }

  /// Atualiza sequência de dias consecutivos.
  Future<int> _updateStreak() async {
    final profile = await _profileRepository.getProfile();
    if (profile == null) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final last = profile.lastStudyDate;

    int streak;
    if (last == null) {
      streak = 1;
    } else {
      final lastDate = DateTime(last.year, last.month, last.day);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 0) {
        streak = profile.streakDays;
      } else if (diff == 1) {
        streak = profile.streakDays + 1;
      } else {
        streak = 1;
      }
    }

    await _profileRepository.updateXpAndLevel(profile.totalXp, profile.currentLevel, profile.titleId);
    // Atualiza streak e last_study_date diretamente, sem alterar XP/level.
    try {
      final client = _xpRepository.client;
      if (client != null) {
        await client.from('user_profiles')
            .update({
              'streak_days': streak,
              'last_study_date': todayDate.toIso8601String(),
              'updated_at': today.toIso8601String(),
            })
            .eq('user_id', profile.userId);
      }
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar sequência', error: e);
    }
    return streak;
  }

  Future<void> _updateProfileAndTitles(int totalXp, int level) async {
    final titles = await _titlesRepository.getCatalog();
    final title = LevelCalculator.titleForProgress(titles, level, totalXp);
    await _profileRepository.updateXpAndLevel(totalXp, level, title?.slug);
    if (title != null) {
      await _titlesRepository.unlockTitle(title.id);
    }
  }

  Future<void> _checkAchievements(int currentLevel) async {
    final userId = _xpRepository.client?.auth.currentUser?.id;
    if (userId == null) return;
    final catalog = await _achievementsRepository.getAchievementsCatalog();
    final userAchievements = await _achievementsRepository.getUserAchievements();
    final profile = await _profileRepository.getProfile();
    if (profile == null) return;

    for (final achievement in catalog) {
      int progress = 0;
      switch (achievement.criteriaType) {
        case AchievementCriteriaType.firstStudy:
          progress = profile.totalXp > 0 ? 1 : 0;
        case AchievementCriteriaType.firstCollection:
          progress = await _countCollections(profile.userId);
        case AchievementCriteriaType.viewCount:
        case AchievementCriteriaType.completeCount:
        case AchievementCriteriaType.studyMinutes:
        case AchievementCriteriaType.searchCount:
          progress = await _countCriteria(achievement.criteriaType, profile.userId);
        case AchievementCriteriaType.streakDays:
          progress = profile.streakDays;
        case AchievementCriteriaType.custom:
          if (achievement.slug == 'historian') progress = currentLevel;
      }
      final existing = userAchievements.firstWhere(
        (ua) => ua.achievementId == achievement.id,
        orElse: () => UserAchievement(
          userId: userId,
          achievementId: achievement.id,
          achievement: achievement,
          progress: 0,
        ),
      );
      if (!existing.isUnlocked || progress > existing.progress) {
        await _achievementsRepository.updateProgress(achievement.id, progress);
      }
      if (!existing.isUnlocked && progress >= achievement.criteriaValue) {
        unawaited(_notificationService.showAchievementUnlocked(achievement.name));
        await _specialCollectionService.unlock(achievement.specialCollectionSlug);
      }
    }
  }

  Future<int> _countCollections(String userId) async {
    try {
      final client = _xpRepository.client;
      if (client == null) return 0;
      final response = await client.from('collections').select('id').eq('user_id', userId);
      return response.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _countCriteria(AchievementCriteriaType criteria, String userId) async {
    try {
      final client = _xpRepository.client;
      if (client == null) return 0;
      switch (criteria) {
        case AchievementCriteriaType.viewCount:
          final response = await client.from('xp_events')
              .select('id')
              .eq('user_id', userId)
              .eq('source', 'view_content');
          return response.length;
        case AchievementCriteriaType.completeCount:
          final response = await client.from('study_progress')
              .select('id')
              .eq('user_id', userId)
              .eq('status', 'completed');
          return response.length;
        case AchievementCriteriaType.studyMinutes:
          final response = await client.from('study_sessions')
              .select('duration_seconds')
              .eq('user_id', userId);
          final totalSeconds = (response as List<dynamic>).fold<int>(0, (s, e) => s + ((e as Map<String, dynamic>)['duration_seconds'] as int? ?? 0));
          return totalSeconds ~/ 60;
        case AchievementCriteriaType.searchCount:
          final response = await client.from('xp_events')
              .select('id')
              .eq('user_id', userId)
              .eq('source', 'view_content');
          return response.length;
        default:
          return 0;
      }
    } catch (_) {
      return 0;
    }
  }

  Future<int> _dailyXp() async {
    final events = await _xpRepository.getRecentEvents(limit: 100);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return events
        .where((e) => e.createdAt.isAfter(start))
        .fold<int>(0, (sum, e) => sum + e.amount);
  }

  Future<GamificationEventResult> _buildResult(XpResult xp) async {
    unawaited(_notificationService.showXpGained(xp.event?.amount ?? 0, xp.totalXp));
    if (xp.leveledUp && xp.newLevel != null) {
      unawaited(_notificationService.showLevelUp(xp.newLevel!));
    }
    return GamificationEventResult(
      xpGained: xp.event?.amount ?? 0,
      totalXp: xp.totalXp,
      currentLevel: xp.currentLevel,
      leveledUp: xp.leveledUp,
      newLevel: xp.newLevel,
    );
  }
}

/// Resumo gamificado para o card da Home.
class HomeGamificationSummary {
  final UserProfile? profile;
  final List<Challenge> challenges;
  final int dailyXp;

  const HomeGamificationSummary({
    this.profile,
    this.challenges = const [],
    this.dailyXp = 0,
  });
}

/// Resultado de um evento gamificado.
class GamificationEventResult {
  final int xpGained;
  final int totalXp;
  final int currentLevel;
  final bool leveledUp;
  final int? newLevel;

  const GamificationEventResult({
    this.xpGained = 0,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.leveledUp = false,
    this.newLevel,
  });
}
