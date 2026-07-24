/// CHRONOS Adaptive Learning — Domain Entities
///
/// Módulo independente para aprendizagem adaptativa e tutor inteligente.
/// Perfil versionado, recomendações com explainability, preparado para ML.

// ============================================================
// Enums
// ============================================================

/// Nível estimado do aprendiz.
enum LearnerLevel { beginner, intermediate, advanced }

/// Formato de conteúdo preferido.
enum ContentFormatPreference { text, timeline, map, ai, quiz }

/// Objetivo do estudo.
enum StudyObjective { enem, vestibular, university, curiosity, professional }

/// Modo do tutor.
enum TutorMode {
  explainBeginner,
  explainIntermediate,
  explainAdvanced,
  summarize1min,
  summarize5min,
  createAnalogy,
  createPracticalExample,
  highlightForExam,
}

/// Dificuldade de quiz.
enum QuizDifficulty { easy, medium, hard, expert }

/// Tipo de recomendação.
enum RecommendationType {
  continueStudying,
  review,
  newContent,
  difficultyBased,
  goalBased,
  pathBased,
  relatedContent,
}

/// Período do relatório.
enum ReportPeriod { weekly, monthly }

// ============================================================
// Perfil de Aprendizagem (versionado)
// ============================================================

class LearnerProfile {
  final String id;
  final String userId;
  final int version;
  final LearnerLevel estimatedLevel;
  final List<String> masteredTopics;
  final List<String> difficultTopics;
  final List<String> favoriteTopics;
  final double averageStudySpeedMinPerContent;
  final double quizAccuracyRate;
  final double averageTimePerContentSeconds;
  final List<ContentFormatPreference> formatPreferences;
  final StudyObjective primaryObjective;
  final int availableMinutesPerDay;
  final Map<String, double> topicAccuracy;
  final DateTime lastUpdatedAt;
  final DateTime createdAt;

  const LearnerProfile({
    required this.id,
    required this.userId,
    this.version = 1,
    this.estimatedLevel = LearnerLevel.beginner,
    this.masteredTopics = const [],
    this.difficultTopics = const [],
    this.favoriteTopics = const [],
    this.averageStudySpeedMinPerContent = 10.0,
    this.quizAccuracyRate = 0.0,
    this.averageTimePerContentSeconds = 600.0,
    this.formatPreferences = const [ContentFormatPreference.text],
    this.primaryObjective = StudyObjective.curiosity,
    this.availableMinutesPerDay = 30,
    this.topicAccuracy = const {},
    required this.lastUpdatedAt,
    required this.createdAt,
  });

  LearnerProfile copyWith({
    String? id,
    String? userId,
    int? version,
    LearnerLevel? estimatedLevel,
    List<String>? masteredTopics,
    List<String>? difficultTopics,
    List<String>? favoriteTopics,
    double? averageStudySpeedMinPerContent,
    double? quizAccuracyRate,
    double? averageTimePerContentSeconds,
    List<ContentFormatPreference>? formatPreferences,
    StudyObjective? primaryObjective,
    int? availableMinutesPerDay,
    Map<String, double>? topicAccuracy,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
  }) =>
      LearnerProfile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        version: version ?? this.version,
        estimatedLevel: estimatedLevel ?? this.estimatedLevel,
        masteredTopics: masteredTopics ?? this.masteredTopics,
        difficultTopics: difficultTopics ?? this.difficultTopics,
        favoriteTopics: favoriteTopics ?? this.favoriteTopics,
        averageStudySpeedMinPerContent: averageStudySpeedMinPerContent ?? this.averageStudySpeedMinPerContent,
        quizAccuracyRate: quizAccuracyRate ?? this.quizAccuracyRate,
        averageTimePerContentSeconds: averageTimePerContentSeconds ?? this.averageTimePerContentSeconds,
        formatPreferences: formatPreferences ?? this.formatPreferences,
        primaryObjective: primaryObjective ?? this.primaryObjective,
        availableMinutesPerDay: availableMinutesPerDay ?? this.availableMinutesPerDay,
        topicAccuracy: topicAccuracy ?? this.topicAccuracy,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory LearnerProfile.fromJson(Map<String, dynamic> json) => LearnerProfile(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        version: json['version'] as int? ?? 1,
        estimatedLevel: LearnerLevel.values.firstWhere(
          (e) => e.name == (json['estimated_level'] as String? ?? 'beginner'),
          orElse: () => LearnerLevel.beginner,
        ),
        masteredTopics: (json['mastered_topics'] as List?)?.cast<String>() ?? [],
        difficultTopics: (json['difficult_topics'] as List?)?.cast<String>() ?? [],
        favoriteTopics: (json['favorite_topics'] as List?)?.cast<String>() ?? [],
        averageStudySpeedMinPerContent: (json['avg_study_speed'] as num?)?.toDouble() ?? 10.0,
        quizAccuracyRate: (json['quiz_accuracy_rate'] as num?)?.toDouble() ?? 0.0,
        averageTimePerContentSeconds: (json['avg_time_per_content'] as num?)?.toDouble() ?? 600.0,
        formatPreferences: (json['format_preferences'] as List?)
                ?.map((e) => ContentFormatPreference.values.firstWhere(
                      (f) => f.name == e,
                      orElse: () => ContentFormatPreference.text,
                    ))
                .toList() ??
            [ContentFormatPreference.text],
        primaryObjective: StudyObjective.values.firstWhere(
          (e) => e.name == (json['primary_objective'] as String? ?? 'curiosity'),
          orElse: () => StudyObjective.curiosity,
        ),
        availableMinutesPerDay: json['available_minutes_per_day'] as int? ?? 30,
        topicAccuracy: (json['topic_accuracy'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            {},
        lastUpdatedAt: DateTime.tryParse(json['last_updated_at'] as String? ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'version': version,
        'estimated_level': estimatedLevel.name,
        'mastered_topics': masteredTopics,
        'difficult_topics': difficultTopics,
        'favorite_topics': favoriteTopics,
        'avg_study_speed': averageStudySpeedMinPerContent,
        'quiz_accuracy_rate': quizAccuracyRate,
        'avg_time_per_content': averageTimePerContentSeconds,
        'format_preferences': formatPreferences.map((e) => e.name).toList(),
        'primary_objective': primaryObjective.name,
        'available_minutes_per_day': availableMinutesPerDay,
        'topic_accuracy': topicAccuracy,
        'last_updated_at': lastUpdatedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

// ============================================================
// Recomendação Adaptativa (com explainability)
// ============================================================

class AdaptiveRecommendation {
  final String id;
  final String userId;
  final String entityId;
  final String entityType;
  final String entityName;
  final RecommendationType type;
  final String reason;
  final double score;
  final int priority;
  final DateTime generatedAt;
  final bool dismissed;

  const AdaptiveRecommendation({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    required this.type,
    required this.reason,
    this.score = 0.0,
    this.priority = 0,
    required this.generatedAt,
    this.dismissed = false,
  });

  factory AdaptiveRecommendation.fromJson(Map<String, dynamic> json) => AdaptiveRecommendation(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        type: RecommendationType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'newContent'),
          orElse: () => RecommendationType.newContent,
        ),
        reason: json['reason'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        priority: json['priority'] as int? ?? 0,
        generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ?? DateTime.now(),
        dismissed: json['dismissed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'type': type.name,
        'reason': reason,
        'score': score,
        'priority': priority,
        'generated_at': generatedAt.toIso8601String(),
        'dismissed': dismissed,
      };
}

// ============================================================
// Plano de Estudo Personalizado
// ============================================================

class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final StudyObjective objective;
  final int availableMinutesPerDay;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyPlan> dailyPlans;
  final int targetXp;
  final DateTime createdAt;

  const StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.objective = StudyObjective.curiosity,
    this.availableMinutesPerDay = 30,
    required this.weekStart,
    required this.weekEnd,
    this.dailyPlans = const [],
    this.targetXp = 100,
    required this.createdAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        objective: StudyObjective.values.firstWhere(
          (e) => e.name == (json['objective'] as String? ?? 'curiosity'),
          orElse: () => StudyObjective.curiosity,
        ),
        availableMinutesPerDay: json['available_minutes_per_day'] as int? ?? 30,
        weekStart: DateTime.tryParse(json['week_start'] as String? ?? '') ?? DateTime.now(),
        weekEnd: DateTime.tryParse(json['week_end'] as String? ?? '') ?? DateTime.now(),
        dailyPlans: (json['daily_plans'] as List?)
                ?.map((d) => DailyPlan.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
        targetXp: json['target_xp'] as int? ?? 100,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'objective': objective.name,
        'available_minutes_per_day': availableMinutesPerDay,
        'week_start': weekStart.toIso8601String(),
        'week_end': weekEnd.toIso8601String(),
        'daily_plans': dailyPlans.map((d) => d.toJson()).toList(),
        'target_xp': targetXp,
        'created_at': createdAt.toIso8601String(),
      };
}

class DailyPlan {
  final int dayOfWeek;
  final List<PlanItem> items;
  final int estimatedMinutes;

  const DailyPlan({
    required this.dayOfWeek,
    this.items = const [],
    this.estimatedMinutes = 30,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) => DailyPlan(
        dayOfWeek: json['day_of_week'] as int? ?? 1,
        items: (json['items'] as List?)
                ?.map((i) => PlanItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
        estimatedMinutes: json['estimated_minutes'] as int? ?? 30,
      );

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'items': items.map((i) => i.toJson()).toList(),
        'estimated_minutes': estimatedMinutes,
      };
}

class PlanItem {
  final String entityId;
  final String entityType;
  final String entityName;
  final PlanItemType type;
  final int estimatedMinutes;
  final bool completed;

  const PlanItem({
    required this.entityId,
    required this.entityType,
    required this.entityName,
    this.type = PlanItemType.read,
    this.estimatedMinutes = 10,
    this.completed = false,
  });

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        type: PlanItemType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'read'),
          orElse: () => PlanItemType.read,
        ),
        estimatedMinutes: json['estimated_minutes'] as int? ?? 10,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'type': type.name,
        'estimated_minutes': estimatedMinutes,
        'completed': completed,
      };
}

enum PlanItemType { read, review, quiz }

// ============================================================
// Relatório de Aprendizagem
// ============================================================

class LearningReport {
  final String id;
  final String userId;
  final ReportPeriod period;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalStudyTimeSeconds;
  final int contentsCompleted;
  final double quizAccuracy;
  final int quizAnswered;
  final List<String> masteredTopics;
  final List<String> topicsToReview;
  final Map<String, double> topicEvolution;
  final List<String> recommendations;
  final DateTime generatedAt;

  const LearningReport({
    required this.id,
    required this.userId,
    required this.period,
    required this.periodStart,
    required this.periodEnd,
    this.totalStudyTimeSeconds = 0,
    this.contentsCompleted = 0,
    this.quizAccuracy = 0.0,
    this.quizAnswered = 0,
    this.masteredTopics = const [],
    this.topicsToReview = const [],
    this.topicEvolution = const {},
    this.recommendations = const [],
    required this.generatedAt,
  });

  factory LearningReport.fromJson(Map<String, dynamic> json) => LearningReport(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        period: ReportPeriod.values.firstWhere(
          (e) => e.name == (json['period'] as String? ?? 'weekly'),
          orElse: () => ReportPeriod.weekly,
        ),
        periodStart: DateTime.tryParse(json['period_start'] as String? ?? '') ?? DateTime.now(),
        periodEnd: DateTime.tryParse(json['period_end'] as String? ?? '') ?? DateTime.now(),
        totalStudyTimeSeconds: json['total_study_time_seconds'] as int? ?? 0,
        contentsCompleted: json['contents_completed'] as int? ?? 0,
        quizAccuracy: (json['quiz_accuracy'] as num?)?.toDouble() ?? 0.0,
        quizAnswered: json['quiz_answered'] as int? ?? 0,
        masteredTopics: (json['mastered_topics'] as List?)?.cast<String>() ?? [],
        topicsToReview: (json['topics_to_review'] as List?)?.cast<String>() ?? [],
        topicEvolution: (json['topic_evolution'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            {},
        recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
        generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'period': period.name,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'total_study_time_seconds': totalStudyTimeSeconds,
        'contents_completed': contentsCompleted,
        'quiz_accuracy': quizAccuracy,
        'quiz_answered': quizAnswered,
        'mastered_topics': masteredTopics,
        'topics_to_review': topicsToReview,
        'topic_evolution': topicEvolution,
        'recommendations': recommendations,
        'generated_at': generatedAt.toIso8601String(),
      };
}

// ============================================================
// Detecção de Dificuldade
// ============================================================

class DifficultyAlert {
  final String topic;
  final String entityId;
  final String entityType;
  final DifficultyReason reason;
  final double metric;
  final String suggestion;

  const DifficultyAlert({
    required this.topic,
    required this.entityId,
    required this.entityType,
    required this.reason,
    required this.metric,
    required this.suggestion,
  });
}

enum DifficultyReason { lowAccuracy, pendingReviews, excessiveReadTime }

// ============================================================
// Explicação Contextual
// ============================================================

class ContextualExplanation {
  final String questionId;
  final String correctAnswer;
  final String explanation;
  final String contentLink;
  final List<String> relatedEvents;
  final List<String> relatedCharacters;

  const ContextualExplanation({
    required this.questionId,
    required this.correctAnswer,
    required this.explanation,
    required this.contentLink,
    this.relatedEvents = const [],
    this.relatedCharacters = const [],
  });
}

// ============================================================
// Interface ML-Ready (Adapter para futuro ML)
// ============================================================

/// Interface abstrata para o motor de recomendação.
/// Permite substituição futura por modelo de ML.
abstract class RecommendationStrategy {
  Future<List<AdaptiveRecommendation>> generateRecommendations({
    required LearnerProfile profile,
    required int limit,
  });
}
