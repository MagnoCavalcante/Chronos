import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de Conquistas e Gamificação.
///
/// Gerencia badges, XP, níveis, desafios diários e semanais.
class AchievementsService {
  final LearningRepository _repository;
  final String _userId;

  /// XP necessário para cada nível.
  static const Map<UserLevel, int> levelThresholds = {
    UserLevel.novice: 0,
    UserLevel.apprentice: 100,
    UserLevel.scholar: 500,
    UserLevel.historian: 1500,
    UserLevel.master: 4000,
    UserLevel.grandMaster: 10000,
  };

  /// XP concedido por atividade.
  static const Map<StudyActivityType, int> xpPerActivity = {
    StudyActivityType.view: 5,
    StudyActivityType.read: 15,
    StudyActivityType.quiz: 20,
    StudyActivityType.review: 10,
    StudyActivityType.bookmark: 2,
    StudyActivityType.share: 5,
    StudyActivityType.askAI: 10,
  };

  AchievementsService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Obtém todas as conquistas do usuário.
  Future<List<Achievement>> getAchievements() async {
    return _repository.getAchievements(_userId);
  }

  /// Obtém conquistas desbloqueadas.
  Future<List<Achievement>> getUnlockedAchievements() async {
    final all = await getAchievements();
    return all.where((a) => a.unlocked).toList();
  }

  /// Calcula nível baseado no XP total.
  UserLevel calculateLevel(int totalXP) {
    if (totalXP >= 10000) return UserLevel.grandMaster;
    if (totalXP >= 4000) return UserLevel.master;
    if (totalXP >= 1500) return UserLevel.historian;
    if (totalXP >= 500) return UserLevel.scholar;
    if (totalXP >= 100) return UserLevel.apprentice;
    return UserLevel.novice;
  }

  /// Calcula progresso para o próximo nível (0.0 - 1.0).
  double calculateLevelProgress(int totalXP) {
    final current = calculateLevel(totalXP);
    final currentThreshold = levelThresholds[current] ?? 0;

    final levels = UserLevel.values;
    final currentIdx = levels.indexOf(current);
    if (currentIdx >= levels.length - 1) return 1.0;

    final nextThreshold = levelThresholds[levels[currentIdx + 1]] ?? 10000;
    final range = nextThreshold - currentThreshold;
    if (range <= 0) return 1.0;

    return ((totalXP - currentThreshold) / range).clamp(0.0, 1.0);
  }

  /// Concede XP por uma atividade.
  Future<int> grantXP(StudyActivityType activityType) async {
    final xp = xpPerActivity[activityType] ?? 5;
    final stats = await _repository.getStats(_userId);
    final currentXP = stats?.totalXP ?? 0;
    final newXP = currentXP + xp;

    // Atualizar stats com novo XP e nível
    if (stats != null) {
      final updatedStats = UserStudyStats(
        userId: _userId,
        totalStudyTimeSeconds: stats.totalStudyTimeSeconds,
        totalContentsViewed: stats.totalContentsViewed,
        totalCharactersStudied: stats.totalCharactersStudied,
        totalEventsStudied: stats.totalEventsStudied,
        totalCivilizationsStudied: stats.totalCivilizationsStudied,
        totalArtifactsStudied: stats.totalArtifactsStudied,
        totalSourcesConsulted: stats.totalSourcesConsulted,
        totalQuizAnswered: stats.totalQuizAnswered,
        totalQuizCorrect: stats.totalQuizCorrect,
        consecutiveDays: stats.consecutiveDays,
        longestStreak: stats.longestStreak,
        totalXP: newXP,
        level: calculateLevel(newXP),
        hourlyDistribution: stats.hourlyDistribution,
        weeklyProgress: stats.weeklyProgress,
        monthlyProgress: stats.monthlyProgress,
        lastStudyDate: stats.lastStudyDate,
      );
      await _repository.updateStats(updatedStats);
    }

    return xp;
  }

  /// Verifica e desbloqueia conquistas.
  Future<List<Achievement>> checkAndUnlock(UserStudyStats stats) async {
    final achievements = await getAchievements();
    final newlyUnlocked = <Achievement>[];

    // Definir conquistas padrão se não existirem
    if (achievements.isEmpty) {
      await _initDefaultAchievements();
      return [];
    }

    for (final achievement in achievements) {
      if (achievement.unlocked) continue;

      final currentValue = _getAchievementValue(achievement.code, stats);
      if (currentValue >= achievement.requiredValue) {
        await _repository.unlockAchievement(_userId, achievement.code);
        newlyUnlocked.add(achievement);
      } else if (currentValue != achievement.currentValue) {
        await _repository.upsertAchievement(Achievement(
          id: achievement.id,
          code: achievement.code,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          tier: achievement.tier,
          requiredValue: achievement.requiredValue,
          currentValue: currentValue,
        ));
      }
    }

    return newlyUnlocked;
  }

  /// Obtém desafios ativos.
  Future<List<StudyChallenge>> getActiveChallenges() async {
    return _repository.getActiveChallenges(_userId);
  }

  /// Cria desafio diário.
  Future<void> createDailyChallenge({
    required String title,
    required int targetValue,
    int xpReward = 50,
  }) async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    await _repository.createChallenge(StudyChallenge(
      id: '',
      userId: _userId,
      title: title,
      type: ChallengeType.daily,
      targetValue: targetValue,
      xpReward: xpReward,
      startDate: now,
      endDate: endOfDay,
    ));
  }

  /// Cria desafio semanal.
  Future<void> createWeeklyChallenge({
    required String title,
    required int targetValue,
    int xpReward = 200,
  }) async {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));

    await _repository.createChallenge(StudyChallenge(
      id: '',
      userId: _userId,
      title: title,
      type: ChallengeType.weekly,
      targetValue: targetValue,
      xpReward: xpReward,
      startDate: now,
      endDate: endOfWeek,
    ));
  }

  /// Atualiza progresso de desafio.
  Future<void> updateChallengeProgress(String challengeId, int value) async {
    await _repository.updateChallengeProgress(challengeId, value);
  }

  int _getAchievementValue(String code, UserStudyStats stats) {
    switch (code) {
      case 'first_character':
        return stats.totalCharactersStudied;
      case 'roman_explorer':
        return stats.totalContentsViewed; // Simplificado
      case 'antiquity_master':
        return stats.totalContentsViewed;
      case 'contents_100':
        return stats.totalContentsViewed;
      case 'streak_30':
        return stats.consecutiveDays;
      case 'streak_7':
        return stats.consecutiveDays;
      case 'quiz_master':
        return stats.totalQuizCorrect;
      case 'study_hours_10':
        return stats.totalStudyTimeSeconds ~/ 3600;
      default:
        return 0;
    }
  }

  Future<void> _initDefaultAchievements() async {
    final defaults = [
      const Achievement(
        id: '', code: 'first_character', title: 'Primeiro Personagem',
        description: 'Estude seu primeiro personagem histórico.',
        icon: '🥉', tier: AchievementTier.bronze, requiredValue: 1,
      ),
      const Achievement(
        id: '', code: 'streak_7', title: '7 Dias Consecutivos',
        description: 'Estude por 7 dias seguidos.',
        icon: '🔥', tier: AchievementTier.silver, requiredValue: 7,
      ),
      const Achievement(
        id: '', code: 'streak_30', title: '30 Dias Consecutivos',
        description: 'Estude por 30 dias seguidos.',
        icon: '🔥', tier: AchievementTier.gold, requiredValue: 30,
      ),
      const Achievement(
        id: '', code: 'contents_100', title: '100 Conteúdos Estudados',
        description: 'Estude 100 conteúdos diferentes.',
        icon: '📚', tier: AchievementTier.gold, requiredValue: 100,
      ),
      const Achievement(
        id: '', code: 'quiz_master', title: 'Mestre dos Quizzes',
        description: 'Acerte 50 perguntas de quiz.',
        icon: '🧠', tier: AchievementTier.silver, requiredValue: 50,
      ),
      const Achievement(
        id: '', code: 'study_hours_10', title: '10 Horas de Estudo',
        description: 'Acumule 10 horas de estudo.',
        icon: '⏰', tier: AchievementTier.silver, requiredValue: 10,
      ),
      const Achievement(
        id: '', code: 'roman_explorer', title: 'Explorador Romano',
        description: 'Estude 10 conteúdos sobre Roma.',
        icon: '🥈', tier: AchievementTier.silver, requiredValue: 10,
      ),
      const Achievement(
        id: '', code: 'antiquity_master', title: 'Mestre da Antiguidade',
        description: 'Estude 25 conteúdos sobre a Antiguidade.',
        icon: '🥇', tier: AchievementTier.gold, requiredValue: 25,
      ),
    ];

    for (final a in defaults) {
      await _repository.upsertAchievement(Achievement(
        id: a.id,
        code: a.code,
        title: a.title,
        description: a.description,
        icon: a.icon,
        tier: a.tier,
        requiredValue: a.requiredValue,
      ));
    }
  }
}
