/// CHRONOS Learning Engine V1 — Domain Entities
///
/// Módulo independente para toda a lógica de aprendizagem.
/// Preparado para suportar flashcards, simulados, trilhas e desafios futuros.

/// Status de estudo de um conteúdo.
enum StudyStatus {
  notStarted,
  inProgress,
  studied,
  reviewLater,
  veryImportant,
  difficult,
  mastered,
}

/// Nível de gamificação do usuário.
enum UserLevel {
  novice,       // 0-99 XP
  apprentice,   // 100-499 XP
  scholar,      // 500-1499 XP
  historian,    // 1500-3999 XP
  master,       // 4000-9999 XP
  grandMaster,  // 10000+ XP
}

/// Tipo de atividade de estudo registrada.
enum StudyActivityType {
  view,
  read,
  quiz,
  review,
  bookmark,
  share,
  askAI,
}

/// Tipo de desafio.
enum ChallengeType {
  daily,
  weekly,
}

/// Registro individual de atividade de estudo.
class StudyRecord {
  final String id;
  final String userId;
  final String entityId;
  final String entityType;
  final String entityName;
  final StudyActivityType activityType;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  const StudyRecord({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    required this.activityType,
    this.durationSeconds = 0,
    required this.startedAt,
    this.completedAt,
    this.metadata,
  });

  factory StudyRecord.fromJson(Map<String, dynamic> json) => StudyRecord(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        activityType: StudyActivityType.values.firstWhere(
          (e) => e.name == (json['activity_type'] as String? ?? 'view'),
          orElse: () => StudyActivityType.view,
        ),
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'activity_type': activityType.name,
        'duration_seconds': durationSeconds,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'metadata': metadata,
      };
}

/// Progresso do usuário em uma entidade específica.
class StudyProgress {
  final String id;
  final String userId;
  final String entityId;
  final String entityType;
  final String entityName;
  final StudyStatus status;
  final int totalReadTimeSeconds;
  final int viewCount;
  final DateTime firstAccess;
  final DateTime lastAccess;
  final DateTime? lastReview;
  final int reviewCount;
  final double masteryLevel; // 0.0 - 1.0

  const StudyProgress({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    this.status = StudyStatus.notStarted,
    this.totalReadTimeSeconds = 0,
    this.viewCount = 0,
    required this.firstAccess,
    required this.lastAccess,
    this.lastReview,
    this.reviewCount = 0,
    this.masteryLevel = 0.0,
  });

  factory StudyProgress.fromJson(Map<String, dynamic> json) => StudyProgress(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        status: StudyStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'notStarted'),
          orElse: () => StudyStatus.notStarted,
        ),
        totalReadTimeSeconds: json['total_read_time_seconds'] as int? ?? 0,
        viewCount: json['view_count'] as int? ?? 0,
        firstAccess: DateTime.tryParse(json['first_access'] as String? ?? '') ?? DateTime.now(),
        lastAccess: DateTime.tryParse(json['last_access'] as String? ?? '') ?? DateTime.now(),
        lastReview: json['last_review'] != null
            ? DateTime.tryParse(json['last_review'] as String)
            : null,
        reviewCount: json['review_count'] as int? ?? 0,
        masteryLevel: (json['mastery_level'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'status': status.name,
        'total_read_time_seconds': totalReadTimeSeconds,
        'view_count': viewCount,
        'first_access': firstAccess.toIso8601String(),
        'last_access': lastAccess.toIso8601String(),
        'last_review': lastReview?.toIso8601String(),
        'review_count': reviewCount,
        'mastery_level': masteryLevel,
      };

  StudyProgress copyWith({
    StudyStatus? status,
    int? totalReadTimeSeconds,
    int? viewCount,
    DateTime? lastAccess,
    DateTime? lastReview,
    int? reviewCount,
    double? masteryLevel,
  }) => StudyProgress(
        id: id,
        userId: userId,
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        status: status ?? this.status,
        totalReadTimeSeconds: totalReadTimeSeconds ?? this.totalReadTimeSeconds,
        viewCount: viewCount ?? this.viewCount,
        firstAccess: firstAccess,
        lastAccess: lastAccess ?? this.lastAccess,
        lastReview: lastReview ?? this.lastReview,
        reviewCount: reviewCount ?? this.reviewCount,
        masteryLevel: masteryLevel ?? this.masteryLevel,
      );
}

/// Agendamento de revisão (Spaced Repetition).
class ReviewSchedule {
  final String id;
  final String userId;
  final String entityId;
  final String entityType;
  final String entityName;
  final DateTime scheduledFor;
  final int intervalDays; // 1, 3, 7, 15, 30
  final int repetition; // número da repetição atual
  final double easeFactor; // SM-2 ease factor
  final bool completed;

  const ReviewSchedule({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    required this.scheduledFor,
    this.intervalDays = 1,
    this.repetition = 0,
    this.easeFactor = 2.5,
    this.completed = false,
  });

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) => ReviewSchedule(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        scheduledFor: DateTime.tryParse(json['scheduled_for'] as String? ?? '') ?? DateTime.now(),
        intervalDays: json['interval_days'] as int? ?? 1,
        repetition: json['repetition'] as int? ?? 0,
        easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'scheduled_for': scheduledFor.toIso8601String(),
        'interval_days': intervalDays,
        'repetition': repetition,
        'ease_factor': easeFactor,
        'completed': completed,
      };
}

/// Pergunta de quiz.
class QuizQuestion {
  final String id;
  final String entityId;
  final String entityType;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        question: json['question'] as String? ?? '',
        options: List<String>.from(json['options'] as List? ?? []),
        correctIndex: json['correct_index'] as int? ?? 0,
        explanation: json['explanation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_id': entityId,
        'entity_type': entityType,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
      };
}

/// Resposta do usuário a um quiz.
class QuizAnswer {
  final String id;
  final String userId;
  final String questionId;
  final String entityId;
  final int selectedIndex;
  final bool isCorrect;
  final int responseTimeMs;
  final DateTime answeredAt;

  const QuizAnswer({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.entityId,
    required this.selectedIndex,
    required this.isCorrect,
    this.responseTimeMs = 0,
    required this.answeredAt,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => QuizAnswer(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        questionId: json['question_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        selectedIndex: json['selected_index'] as int? ?? 0,
        isCorrect: json['is_correct'] as bool? ?? false,
        responseTimeMs: json['response_time_ms'] as int? ?? 0,
        answeredAt: DateTime.tryParse(json['answered_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'question_id': questionId,
        'entity_id': entityId,
        'selected_index': selectedIndex,
        'is_correct': isCorrect,
        'response_time_ms': responseTimeMs,
        'answered_at': answeredAt.toIso8601String(),
      };
}

/// Meta de estudo.
class StudyGoal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool completed;

  const StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    required this.createdAt,
    this.deadline,
    this.completed = false,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  factory StudyGoal.fromJson(Map<String, dynamic> json) => StudyGoal(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        type: GoalType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'dailyMinutes'),
          orElse: () => GoalType.dailyMinutes,
        ),
        targetValue: json['target_value'] as int? ?? 0,
        currentValue: json['current_value'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'] as String)
            : null,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'type': type.name,
        'target_value': targetValue,
        'current_value': currentValue,
        'created_at': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'completed': completed,
      };
}

/// Tipo de meta.
enum GoalType {
  dailyMinutes,
  readCharacters,
  readEvents,
  readCivilizations,
  completeCivilization,
  quizScore,
  consecutiveDays,
  totalContents,
}

/// Conquista/badge.
class Achievement {
  final String id;
  final String code;
  final String title;
  final String description;
  final String icon; // emoji ou asset
  final AchievementTier tier;
  final int requiredValue;
  final int currentValue;
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    this.description = '',
    this.icon = '🏆',
    this.tier = AchievementTier.bronze,
    this.requiredValue = 1,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedAt,
  });

  double get progress => requiredValue > 0 ? (currentValue / requiredValue).clamp(0.0, 1.0) : 0.0;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String? ?? '',
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '🏆',
        tier: AchievementTier.values.firstWhere(
          (e) => e.name == (json['tier'] as String? ?? 'bronze'),
          orElse: () => AchievementTier.bronze,
        ),
        requiredValue: json['required_value'] as int? ?? 1,
        currentValue: json['current_value'] as int? ?? 0,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlocked_at'] != null
            ? DateTime.tryParse(json['unlocked_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'icon': icon,
        'tier': tier.name,
        'required_value': requiredValue,
        'current_value': currentValue,
        'unlocked': unlocked,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };
}

/// Nível do badge.
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// Estatísticas gerais do usuário.
class UserStudyStats {
  final String userId;
  final int totalStudyTimeSeconds;
  final int totalContentsViewed;
  final int totalCharactersStudied;
  final int totalEventsStudied;
  final int totalCivilizationsStudied;
  final int totalArtifactsStudied;
  final int totalSourcesConsulted;
  final int totalQuizAnswered;
  final int totalQuizCorrect;
  final int consecutiveDays;
  final int longestStreak;
  final int totalXP;
  final UserLevel level;
  final Map<int, int> hourlyDistribution; // hour -> count
  final Map<String, int> weeklyProgress; // 'YYYY-WW' -> minutes
  final Map<String, int> monthlyProgress; // 'YYYY-MM' -> minutes
  final DateTime? lastStudyDate;

  const UserStudyStats({
    required this.userId,
    this.totalStudyTimeSeconds = 0,
    this.totalContentsViewed = 0,
    this.totalCharactersStudied = 0,
    this.totalEventsStudied = 0,
    this.totalCivilizationsStudied = 0,
    this.totalArtifactsStudied = 0,
    this.totalSourcesConsulted = 0,
    this.totalQuizAnswered = 0,
    this.totalQuizCorrect = 0,
    this.consecutiveDays = 0,
    this.longestStreak = 0,
    this.totalXP = 0,
    this.level = UserLevel.novice,
    this.hourlyDistribution = const {},
    this.weeklyProgress = const {},
    this.monthlyProgress = const {},
    this.lastStudyDate,
  });

  double get quizAccuracy =>
      totalQuizAnswered > 0 ? totalQuizCorrect / totalQuizAnswered : 0.0;

  Duration get totalStudyTime => Duration(seconds: totalStudyTimeSeconds);

  factory UserStudyStats.fromJson(Map<String, dynamic> json) => UserStudyStats(
        userId: json['user_id'] as String? ?? '',
        totalStudyTimeSeconds: json['total_study_time_seconds'] as int? ?? 0,
        totalContentsViewed: json['total_contents_viewed'] as int? ?? 0,
        totalCharactersStudied: json['total_characters_studied'] as int? ?? 0,
        totalEventsStudied: json['total_events_studied'] as int? ?? 0,
        totalCivilizationsStudied: json['total_civilizations_studied'] as int? ?? 0,
        totalArtifactsStudied: json['total_artifacts_studied'] as int? ?? 0,
        totalSourcesConsulted: json['total_sources_consulted'] as int? ?? 0,
        totalQuizAnswered: json['total_quiz_answered'] as int? ?? 0,
        totalQuizCorrect: json['total_quiz_correct'] as int? ?? 0,
        consecutiveDays: json['consecutive_days'] as int? ?? 0,
        longestStreak: json['longest_streak'] as int? ?? 0,
        totalXP: json['total_xp'] as int? ?? 0,
        level: UserLevel.values.firstWhere(
          (e) => e.name == (json['level'] as String? ?? 'novice'),
          orElse: () => UserLevel.novice,
        ),
        hourlyDistribution: (json['hourly_distribution'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(int.parse(k), v as int)) ?? {},
        weeklyProgress: (json['weekly_progress'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ?? {},
        monthlyProgress: (json['monthly_progress'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ?? {},
        lastStudyDate: json['last_study_date'] != null
            ? DateTime.tryParse(json['last_study_date'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'total_study_time_seconds': totalStudyTimeSeconds,
        'total_contents_viewed': totalContentsViewed,
        'total_characters_studied': totalCharactersStudied,
        'total_events_studied': totalEventsStudied,
        'total_civilizations_studied': totalCivilizationsStudied,
        'total_artifacts_studied': totalArtifactsStudied,
        'total_sources_consulted': totalSourcesConsulted,
        'total_quiz_answered': totalQuizAnswered,
        'total_quiz_correct': totalQuizCorrect,
        'consecutive_days': consecutiveDays,
        'longest_streak': longestStreak,
        'total_xp': totalXP,
        'level': level.name,
        'hourly_distribution': hourlyDistribution.map((k, v) => MapEntry('$k', v)),
        'weekly_progress': weeklyProgress,
        'monthly_progress': monthlyProgress,
        'last_study_date': lastStudyDate?.toIso8601String(),
      };
}

/// Desafio (diário ou semanal).
class StudyChallenge {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool completed;

  const StudyChallenge({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.xpReward = 50,
    required this.startDate,
    required this.endDate,
    this.completed = false,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isExpired => DateTime.now().isAfter(endDate);

  factory StudyChallenge.fromJson(Map<String, dynamic> json) => StudyChallenge(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        type: ChallengeType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'daily'),
          orElse: () => ChallengeType.daily,
        ),
        targetValue: json['target_value'] as int? ?? 0,
        currentValue: json['current_value'] as int? ?? 0,
        xpReward: json['xp_reward'] as int? ?? 50,
        startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? DateTime.now(),
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'type': type.name,
        'target_value': targetValue,
        'current_value': currentValue,
        'xp_reward': xpReward,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'completed': completed,
      };
}
