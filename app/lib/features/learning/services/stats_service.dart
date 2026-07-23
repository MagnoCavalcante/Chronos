import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de Estatísticas de Estudo.
///
/// Fornece: horas estudadas, dias consecutivos, horário favorito,
/// evolução semanal/mensal, assuntos mais estudados.
class StatsService {
  final LearningRepository _repository;
  final String _userId;

  StatsService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Obtém estatísticas gerais do usuário.
  Future<UserStudyStats> getStats() async {
    final stats = await _repository.getStats(_userId);
    return stats ?? UserStudyStats(userId: _userId);
  }

  /// Registra uma sessão de estudo nas estatísticas.
  Future<void> recordStudySession({
    required String entityType,
    required int durationSeconds,
  }) async {
    final stats = await getStats();
    final now = DateTime.now();
    final hour = now.hour;
    final weekKey = '${now.year}-${_weekNumber(now).toString().padLeft(2, '0')}';
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Atualizar distribuição horária
    final hourly = Map<int, int>.from(stats.hourlyDistribution);
    hourly[hour] = (hourly[hour] ?? 0) + 1;

    // Atualizar progresso semanal
    final weekly = Map<String, int>.from(stats.weeklyProgress);
    weekly[weekKey] = (weekly[weekKey] ?? 0) + (durationSeconds ~/ 60);

    // Atualizar progresso mensal
    final monthly = Map<String, int>.from(stats.monthlyProgress);
    monthly[monthKey] = (monthly[monthKey] ?? 0) + (durationSeconds ~/ 60);

    // Calcular dias consecutivos
    int consecutiveDays = stats.consecutiveDays;
    int longestStreak = stats.longestStreak;
    if (stats.lastStudyDate != null) {
      final daysSinceLastStudy = now.difference(stats.lastStudyDate!).inDays;
      if (daysSinceLastStudy == 1) {
        consecutiveDays++;
      } else if (daysSinceLastStudy > 1) {
        consecutiveDays = 1;
      }
      // Mesmo dia: não incrementa
    } else {
      consecutiveDays = 1;
    }
    if (consecutiveDays > longestStreak) {
      longestStreak = consecutiveDays;
    }

    // Contadores por tipo
    int characters = stats.totalCharactersStudied;
    int events = stats.totalEventsStudied;
    int civilizations = stats.totalCivilizationsStudied;
    int artifacts = stats.totalArtifactsStudied;
    int sources = stats.totalSourcesConsulted;

    switch (entityType) {
      case 'character':
        characters++;
        break;
      case 'event':
        events++;
        break;
      case 'civilization':
        civilizations++;
        break;
      case 'artifact':
        artifacts++;
        break;
      case 'source':
        sources++;
        break;
    }

    final updated = UserStudyStats(
      userId: _userId,
      totalStudyTimeSeconds: stats.totalStudyTimeSeconds + durationSeconds,
      totalContentsViewed: stats.totalContentsViewed + 1,
      totalCharactersStudied: characters,
      totalEventsStudied: events,
      totalCivilizationsStudied: civilizations,
      totalArtifactsStudied: artifacts,
      totalSourcesConsulted: sources,
      totalQuizAnswered: stats.totalQuizAnswered,
      totalQuizCorrect: stats.totalQuizCorrect,
      consecutiveDays: consecutiveDays,
      longestStreak: longestStreak,
      totalXP: stats.totalXP,
      level: stats.level,
      hourlyDistribution: hourly,
      weeklyProgress: weekly,
      monthlyProgress: monthly,
      lastStudyDate: now,
    );

    await _repository.updateStats(updated);
  }

  /// Registra resultado de quiz nas estatísticas.
  Future<void> recordQuizResult({required bool isCorrect}) async {
    final stats = await getStats();
    final updated = UserStudyStats(
      userId: _userId,
      totalStudyTimeSeconds: stats.totalStudyTimeSeconds,
      totalContentsViewed: stats.totalContentsViewed,
      totalCharactersStudied: stats.totalCharactersStudied,
      totalEventsStudied: stats.totalEventsStudied,
      totalCivilizationsStudied: stats.totalCivilizationsStudied,
      totalArtifactsStudied: stats.totalArtifactsStudied,
      totalSourcesConsulted: stats.totalSourcesConsulted,
      totalQuizAnswered: stats.totalQuizAnswered + 1,
      totalQuizCorrect: stats.totalQuizCorrect + (isCorrect ? 1 : 0),
      consecutiveDays: stats.consecutiveDays,
      longestStreak: stats.longestStreak,
      totalXP: stats.totalXP,
      level: stats.level,
      hourlyDistribution: stats.hourlyDistribution,
      weeklyProgress: stats.weeklyProgress,
      monthlyProgress: stats.monthlyProgress,
      lastStudyDate: stats.lastStudyDate,
    );
    await _repository.updateStats(updated);
  }

  /// Obtém horário favorito de estudo.
  int? getFavoriteHour(UserStudyStats stats) {
    if (stats.hourlyDistribution.isEmpty) return null;
    return stats.hourlyDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Número da semana ISO.
  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
