/// Status de progresso de um item de estudo.
enum StudyStatus { notStarted, inStudy, completed, review }

extension StudyStatusExtension on StudyStatus {
  String get apiValue => switch (this) {
    StudyStatus.notStarted => 'not_started',
    StudyStatus.inStudy => 'in_study',
    StudyStatus.completed => 'completed',
    StudyStatus.review => 'review',
  };

  String get label => switch (this) {
    StudyStatus.notStarted => 'Não iniciado',
    StudyStatus.inStudy => 'Em estudo',
    StudyStatus.completed => 'Concluído',
    StudyStatus.review => 'Revisar depois',
  };

  static StudyStatus fromString(String value) => switch (value) {
    'in_study' => StudyStatus.inStudy,
    'completed' => StudyStatus.completed,
    'review' => StudyStatus.review,
    _ => StudyStatus.notStarted,
  };
}

/// Coleção de estudo personalizada.
class Collection {
  final String id;
  final String userId;
  final String slug;
  final String title;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Collection({
    required this.id,
    required this.userId,
    required this.slug,
    required this.title,
    this.description,
    this.coverUrl,
    this.isPublic = false,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        coverUrl: json['cover_url'] as String?,
        isPublic: json['is_public'] as bool? ?? false,
        ativo: json['ativo'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'slug': slug,
        'title': title,
        'description': description,
        'cover_url': coverUrl,
        'is_public': isPublic,
        'ativo': ativo,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Item dentro de uma coleção (referência polimórfica).
class CollectionItem {
  final String id;
  final String collectionId;
  final String entityType;
  final String entityId;
  final int orderIndex;
  final String? notes;
  final DateTime addedAt;

  const CollectionItem({
    required this.id,
    required this.collectionId,
    required this.entityType,
    required this.entityId,
    this.orderIndex = 0,
    this.notes,
    required this.addedAt,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) => CollectionItem(
        id: json['id'] as String,
        collectionId: json['collection_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        orderIndex: json['order_index'] as int? ?? 0,
        notes: json['notes'] as String?,
        addedAt: DateTime.parse(json['added_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection_id': collectionId,
        'entity_type': entityType,
        'entity_id': entityId,
        'order_index': orderIndex,
        'notes': notes,
        'added_at': addedAt.toIso8601String(),
      };
}

/// Progresso de estudo de uma entidade.
class StudyProgress {
  final String id;
  final String userId;
  final String entityType;
  final String entityId;
  final StudyStatus status;
  final int progressPercent;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalStudyTimeSeconds;
  final DateTime updatedAt;

  const StudyProgress({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    this.status = StudyStatus.notStarted,
    this.progressPercent = 0,
    this.startedAt,
    this.completedAt,
    this.totalStudyTimeSeconds = 0,
    required this.updatedAt,
  });

  factory StudyProgress.fromJson(Map<String, dynamic> json) => StudyProgress(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        status: StudyStatusExtension.fromString(json['status'] as String),
        progressPercent: json['progress_percent'] as int? ?? 0,
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        totalStudyTimeSeconds: json['total_study_time_seconds'] as int? ?? 0,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'status': status.apiValue,
        'progress_percent': progressPercent,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'total_study_time_seconds': totalStudyTimeSeconds,
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Nota pessoal por entidade.
class Note {
  final String id;
  final String userId;
  final String entityType;
  final String entityId;
  final String? content;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    this.content,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        content: json['content'] as String?,
        summary: json['summary'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'content': content,
        'summary': summary,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Marcação de trecho importante.
class Highlight {
  final String id;
  final String userId;
  final String entityType;
  final String entityId;
  final String selectedText;
  final String? note;
  final String color;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.selectedText,
    this.note,
    this.color = '#FFD700',
    required this.createdAt,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        selectedText: json['selected_text'] as String,
        note: json['note'] as String?,
        color: json['color'] as String? ?? '#FFD700',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'selected_text': selectedText,
        'note': note,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Tag pessoal.
class Tag {
  final String id;
  final String userId;
  final String name;
  final String color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.userId,
    required this.name,
    this.color = '#888888',
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        color: json['color'] as String? ?? '#888888',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Meta de estudo.
class StudyGoal {
  final String id;
  final String userId;
  final String title;
  final String targetType;
  final int targetValue;
  final int currentValue;
  final DateTime? deadline;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetType,
    required this.targetValue,
    this.currentValue = 0,
    this.deadline,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyGoal.fromJson(Map<String, dynamic> json) => StudyGoal(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        targetType: json['target_type'] as String,
        targetValue: json['target_value'] as int,
        currentValue: json['current_value'] as int? ?? 0,
        deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
        completed: json['completed'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'target_type': targetType,
        'target_value': targetValue,
        'current_value': currentValue,
        'deadline': deadline?.toIso8601String(),
        'completed': completed,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Plano de estudo.
class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

/// Item de plano de estudo.
class StudyPlanItem {
  final String id;
  final String planId;
  final int dayNumber;
  final String title;
  final String? entityType;
  final String? entityId;
  final bool completed;
  final DateTime createdAt;

  const StudyPlanItem({
    required this.id,
    required this.planId,
    required this.dayNumber,
    required this.title,
    this.entityType,
    this.entityId,
    this.completed = false,
    required this.createdAt,
  });

  factory StudyPlanItem.fromJson(Map<String, dynamic> json) => StudyPlanItem(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        dayNumber: json['day_number'] as int,
        title: json['title'] as String,
        entityType: json['entity_type'] as String?,
        entityId: json['entity_id'] as String?,
        completed: json['completed'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'day_number': dayNumber,
        'title': title,
        'entity_type': entityType,
        'entity_id': entityId,
        'completed': completed,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Item marcado para revisão futura.
class ReviewItem {
  final String id;
  final String userId;
  final String entityType;
  final String entityId;
  final DateTime reviewDate;
  final int intervalDays;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const ReviewItem({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.reviewDate,
    this.intervalDays = 1,
    this.reviewedAt,
    required this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        reviewDate: DateTime.parse(json['review_date'] as String),
        intervalDays: json['interval_days'] as int? ?? 1,
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.parse(json['reviewed_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'review_date': reviewDate.toIso8601String(),
        'interval_days': intervalDays,
        'reviewed_at': reviewedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

/// Estatísticas de aprendizagem do usuário.
class UserStats {
  final String userId;
  final int totalStudyTimeSeconds;
  final int itemsStudied;
  final int collectionsCompleted;
  final int streakDays;
  final DateTime? lastStudyDate;
  final Map<String, dynamic> weeklyProgress;
  final Map<String, dynamic> monthlyProgress;
  final DateTime updatedAt;

  const UserStats({
    required this.userId,
    this.totalStudyTimeSeconds = 0,
    this.itemsStudied = 0,
    this.collectionsCompleted = 0,
    this.streakDays = 0,
    this.lastStudyDate,
    this.weeklyProgress = const {},
    this.monthlyProgress = const {},
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        userId: json['user_id'] as String,
        totalStudyTimeSeconds: json['total_study_time_seconds'] as int? ?? 0,
        itemsStudied: json['items_studied'] as int? ?? 0,
        collectionsCompleted: json['collections_completed'] as int? ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        lastStudyDate: json['last_study_date'] != null
            ? DateTime.parse(json['last_study_date'] as String)
            : null,
        weeklyProgress: (json['weekly_progress'] as Map<String, dynamic>?) ?? const {},
        monthlyProgress: (json['monthly_progress'] as Map<String, dynamic>?) ?? const {},
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'total_study_time_seconds': totalStudyTimeSeconds,
        'items_studied': itemsStudied,
        'collections_completed': collectionsCompleted,
        'streak_days': streakDays,
        'last_study_date': lastStudyDate?.toIso8601String(),
        'weekly_progress': weeklyProgress,
        'monthly_progress': monthlyProgress,
        'updated_at': updatedAt.toIso8601String(),
      };
}
