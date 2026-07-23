/// Fontes de ganho de XP.
enum XpSource {
  viewContent,
  completeStudy,
  completeCollection,
  dailyGoal,
  challenge,
  achievement,
  streak,
  custom;

  String get apiValue => switch (this) {
    viewContent => 'view_content',
    completeStudy => 'complete_study',
    completeCollection => 'complete_collection',
    dailyGoal => 'daily_goal',
    challenge => 'challenge',
    achievement => 'achievement',
    streak => 'streak',
    custom => 'custom',
  };

  static XpSource fromString(String value) => switch (value) {
    'view_content' => viewContent,
    'complete_study' => completeStudy,
    'complete_collection' => completeCollection,
    'daily_goal' => dailyGoal,
    'challenge' => challenge,
    'achievement' => achievement,
    'streak' => streak,
    _ => custom,
  };
}

/// Categorias de conquistas.
enum AchievementCategory {
  study,
  collection,
  exploration,
  streak,
  special;

  String get apiValue => switch (this) {
    study => 'study',
    collection => 'collection',
    exploration => 'exploration',
    streak => 'streak',
    special => 'special',
  };

  static AchievementCategory fromString(String value) => switch (value) {
    'collection' => collection,
    'exploration' => exploration,
    'streak' => streak,
    'special' => special,
    _ => study,
  };

  String get label => switch (this) {
    study => 'Estudo',
    collection => 'Coleção',
    exploration => 'Exploração',
    streak => 'Sequência',
    special => 'Especial',
  };
}

/// Tipos de critérios de conquistas.
enum AchievementCriteriaType {
  firstStudy,
  firstCollection,
  viewCount,
  completeCount,
  streakDays,
  studyMinutes,
  searchCount,
  custom;

  String get apiValue => switch (this) {
    firstStudy => 'first_study',
    firstCollection => 'first_collection',
    viewCount => 'view_count',
    completeCount => 'complete_count',
    streakDays => 'streak_days',
    studyMinutes => 'study_minutes',
    searchCount => 'search_count',
    custom => 'custom',
  };

  static AchievementCriteriaType fromString(String value) => switch (value) {
    'first_study' => firstStudy,
    'first_collection' => firstCollection,
    'view_count' => viewCount,
    'complete_count' => completeCount,
    'streak_days' => streakDays,
    'study_minutes' => studyMinutes,
    'search_count' => searchCount,
    _ => custom,
  };
}

/// Tipos de desafios.
enum ChallengeType {
  daily,
  weekly,
  monthly;

  String get apiValue => switch (this) {
    daily => 'daily',
    weekly => 'weekly',
    monthly => 'monthly',
  };

  static ChallengeType fromString(String value) => switch (value) {
    'weekly' => weekly,
    'monthly' => monthly,
    _ => daily,
  };

  String get label => switch (this) {
    daily => 'Diário',
    weekly => 'Semanal',
    monthly => 'Mensal',
  };
}

/// Tipos de critérios de desafios.
enum ChallengeCriteriaType {
  studyMinutes,
  viewCount,
  completeCount,
  searchCount,
  createCollection,
  custom;

  String get apiValue => switch (this) {
    studyMinutes => 'study_minutes',
    viewCount => 'view_count',
    completeCount => 'complete_count',
    searchCount => 'search_count',
    createCollection => 'create_collection',
    custom => 'custom',
  };

  static ChallengeCriteriaType fromString(String value) => switch (value) {
    'study_minutes' => studyMinutes,
    'view_count' => viewCount,
    'complete_count' => completeCount,
    'search_count' => searchCount,
    'create_collection' => createCollection,
    _ => custom,
  };
}

/// Perfil gamificado do usuário.
class UserProfile {
  final String id;
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? titleId;
  final int totalXp;
  final int currentLevel;
  final int streakDays;
  final DateTime? lastStudyDate;
  final DateTime joinedAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.titleId,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.streakDays = 0,
    this.lastStudyDate,
    required this.joinedAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        titleId: json['title_id'] as String?,
        totalXp: json['total_xp'] as int? ?? 0,
        currentLevel: json['current_level'] as int? ?? 1,
        streakDays: json['streak_days'] as int? ?? 0,
        lastStudyDate: json['last_study_date'] == null ? null : DateTime.tryParse(json['last_study_date'] as String),
        joinedAt: DateTime.parse(json['joined_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'title_id': titleId,
        'total_xp': totalXp,
        'current_level': currentLevel,
        'streak_days': streakDays,
        'last_study_date': lastStudyDate?.toIso8601String(),
        'joined_at': joinedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Conquista (badge) do catálogo.
class Achievement {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String icon;
  final AchievementCategory category;
  final AchievementCriteriaType criteriaType;
  final int criteriaValue;
  final int xpReward;
  final String? titleUnlockedSlug;
  final String? specialCollectionSlug;

  const Achievement({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.icon = 'emoji_events',
    required this.category,
    required this.criteriaType,
    this.criteriaValue = 1,
    this.xpReward = 0,
    this.titleUnlockedSlug,
    this.specialCollectionSlug,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        icon: json['icon'] as String? ?? 'emoji_events',
        category: AchievementCategory.fromString(json['category'] as String? ?? 'study'),
        criteriaType: AchievementCriteriaType.fromString(json['criteria_type'] as String? ?? 'custom'),
        criteriaValue: json['criteria_value'] as int? ?? 1,
        xpReward: json['xp_reward'] as int? ?? 0,
        titleUnlockedSlug: json['title_unlocked_slug'] as String?,
        specialCollectionSlug: json['special_collection_slug'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'description': description,
        'icon': icon,
        'category': category.apiValue,
        'criteria_type': criteriaType.apiValue,
        'criteria_value': criteriaValue,
        'xp_reward': xpReward,
        'title_unlocked_slug': titleUnlockedSlug,
        'special_collection_slug': specialCollectionSlug,
      };
}

/// Conquista desbloqueada por um usuário.
class UserAchievement {
  final String userId;
  final String achievementId;
  final Achievement achievement;
  final int progress;
  final DateTime? unlockedAt;

  const UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.achievement,
    this.progress = 0,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  double get progressPercent => criteriaValue > 0 ? (progress / achievement.criteriaValue).clamp(0.0, 1.0) : 0.0;
  int get criteriaValue => achievement.criteriaValue;

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    final achievement = json['achievement'] == null
        ? Achievement.fromJson({})
        : Achievement.fromJson(json['achievement'] as Map<String, dynamic>);
    return UserAchievement(
      userId: json['user_id'] as String? ?? '',
      achievementId: json['achievement_id'] as String? ?? achievement.id,
      achievement: achievement,
      progress: json['progress'] as int? ?? 0,
      unlockedAt: json['unlocked_at'] == null ? null : DateTime.tryParse(json['unlocked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'achievement_id': achievementId,
        'progress': progress,
        'unlocked_at': unlockedAt?.toIso8601String(),
        'achievement': achievement.toJson(),
      };
}

/// Título de historiador.
class Title {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final int minLevel;
  final int minXp;
  final String icon;

  const Title({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.minLevel = 1,
    this.minXp = 0,
    this.icon = 'workspace_premium',
  });

  factory Title.fromJson(Map<String, dynamic> json) => Title(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        minLevel: json['min_level'] as int? ?? 1,
        minXp: json['min_xp'] as int? ?? 0,
        icon: json['icon'] as String? ?? 'workspace_premium',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'description': description,
        'min_level': minLevel,
        'min_xp': minXp,
        'icon': icon,
      };
}

/// Título desbloqueado por um usuário.
class UserTitle {
  final String userId;
  final String titleId;
  final DateTime unlockedAt;

  const UserTitle({
    required this.userId,
    required this.titleId,
    required this.unlockedAt,
  });

  factory UserTitle.fromJson(Map<String, dynamic> json) => UserTitle(
        userId: json['user_id'] as String,
        titleId: json['title_id'] as String,
        unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title_id': titleId,
        'unlocked_at': unlockedAt.toIso8601String(),
      };
}

/// Evento de ganho de XP.
class XpEvent {
  final String id;
  final String userId;
  final int amount;
  final XpSource source;
  final String? referenceId;
  final String? description;
  final DateTime createdAt;

  const XpEvent({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    this.referenceId,
    this.description,
    required this.createdAt,
  });

  factory XpEvent.fromJson(Map<String, dynamic> json) => XpEvent(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        amount: json['amount'] as int,
        source: XpSource.fromString(json['source'] as String),
        referenceId: json['reference_id'] as String?,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'source': source.apiValue,
        'reference_id': referenceId,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Desafio do usuário.
class Challenge {
  final String id;
  final String userId;
  final ChallengeType type;
  final String title;
  final String? description;
  final ChallengeCriteriaType criteriaType;
  final int targetValue;
  final int currentValue;
  final int rewardXp;
  final bool completed;
  final DateTime? completedAt;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.criteriaType,
    this.targetValue = 1,
    this.currentValue = 0,
    this.rewardXp = 0,
    this.completed = false,
    this.completedAt,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
  });

  double get progressPercent => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: ChallengeType.fromString(json['type'] as String),
        title: json['title'] as String,
        description: json['description'] as String?,
        criteriaType: ChallengeCriteriaType.fromString(json['criteria_type'] as String),
        targetValue: json['target_value'] as int? ?? 1,
        currentValue: json['current_value'] as int? ?? 0,
        rewardXp: json['reward_xp'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        completedAt: json['completed_at'] == null ? null : DateTime.tryParse(json['completed_at'] as String),
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.apiValue,
        'title': title,
        'description': description,
        'criteria_type': criteriaType.apiValue,
        'target_value': targetValue,
        'current_value': currentValue,
        'reward_xp': rewardXp,
        'completed': completed,
        'completed_at': completedAt?.toIso8601String(),
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

/// Resumo semanal de estudos.
class WeeklySummary {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalXp;
  final int hoursStudied;
  final int achievementsCount;
  final int collectionsStarted;
  final int collectionsCompleted;
  final List<String> topCategories;
  final DateTime createdAt;

  const WeeklySummary({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    this.totalXp = 0,
    this.hoursStudied = 0,
    this.achievementsCount = 0,
    this.collectionsStarted = 0,
    this.collectionsCompleted = 0,
    this.topCategories = const [],
    required this.createdAt,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) => WeeklySummary(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        weekEnd: DateTime.parse(json['week_end'] as String),
        totalXp: json['total_xp'] as int? ?? 0,
        hoursStudied: json['hours_studied'] as int? ?? 0,
        achievementsCount: json['achievements_count'] as int? ?? 0,
        collectionsStarted: json['collections_started'] as int? ?? 0,
        collectionsCompleted: json['collections_completed'] as int? ?? 0,
        topCategories: (json['top_categories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'week_start': weekStart.toIso8601String(),
        'week_end': weekEnd.toIso8601String(),
        'total_xp': totalXp,
        'hours_studied': hoursStudied,
        'achievements_count': achievementsCount,
        'collections_started': collectionsStarted,
        'collections_completed': collectionsCompleted,
        'top_categories': topCategories,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Entrada de ranking (preparação).
class RankingEntry {
  final String id;
  final String userId;
  final String period;
  final int totalXp;
  final int? rank;
  final DateTime updatedAt;

  const RankingEntry({
    required this.id,
    required this.userId,
    required this.period,
    this.totalXp = 0,
    this.rank,
    required this.updatedAt,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        period: json['period'] as String,
        totalXp: json['total_xp'] as int? ?? 0,
        rank: json['rank'] as int?,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'period': period,
        'total_xp': totalXp,
        'rank': rank,
        'updated_at': updatedAt.toIso8601String(),
      };
}
