/// CHRONOS Learning Paths — Domain Entities
///
/// Módulo independente para Trilhas de Aprendizagem.
/// Preparado para milhares de trilhas, premium, multi-idioma, vídeo/áudio/texto.

/// Nível de dificuldade da trilha.
enum PathDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Categoria da trilha.
enum PathCategory {
  antiquity,
  middleAges,
  modernAge,
  contemporaryAge,
  civilizations,
  greatWars,
  philosophy,
  religions,
  empires,
  brazilHistory,
  science,
  arts,
}

/// Status de um módulo.
enum ModuleStatus {
  locked,
  unlocked,
  inProgress,
  completed,
}

/// Status de progresso da trilha.
enum PathStatus {
  notStarted,
  inProgress,
  completed,
}

/// Tipo de conteúdo dentro de um módulo.
enum PathContentType {
  text,
  video,
  audio,
  quiz,
  optional,
}

/// Trilha de Aprendizagem.
class LearningPath {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final PathCategory category;
  final PathDifficulty difficulty;
  final int estimatedMinutes;
  final int totalModules;
  final int totalContents;
  final int xpReward;
  final String? badgeCode;
  final String? authorId;
  final String? authorName;
  final bool isPremium;
  final String locale;
  final int order;
  final DateTime createdAt;
  final List<PathModule> modules;

  const LearningPath({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    this.difficulty = PathDifficulty.beginner,
    this.estimatedMinutes = 60,
    this.totalModules = 0,
    this.totalContents = 0,
    this.xpReward = 100,
    this.badgeCode,
    this.authorId,
    this.authorName,
    this.isPremium = false,
    this.locale = 'pt_BR',
    this.order = 0,
    required this.createdAt,
    this.modules = const [],
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        category: PathCategory.values.firstWhere(
          (e) => e.name == (json['category'] as String? ?? 'antiquity'),
          orElse: () => PathCategory.antiquity,
        ),
        difficulty: PathDifficulty.values.firstWhere(
          (e) => e.name == (json['difficulty'] as String? ?? 'beginner'),
          orElse: () => PathDifficulty.beginner,
        ),
        estimatedMinutes: json['estimated_minutes'] as int? ?? 60,
        totalModules: json['total_modules'] as int? ?? 0,
        totalContents: json['total_contents'] as int? ?? 0,
        xpReward: json['xp_reward'] as int? ?? 100,
        badgeCode: json['badge_code'] as String?,
        authorId: json['author_id'] as String?,
        authorName: json['author_name'] as String?,
        isPremium: json['is_premium'] as bool? ?? false,
        locale: json['locale'] as String? ?? 'pt_BR',
        order: json['order'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        modules: (json['modules'] as List?)
                ?.map((m) => PathModule.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'category': category.name,
        'difficulty': difficulty.name,
        'estimated_minutes': estimatedMinutes,
        'total_modules': totalModules,
        'total_contents': totalContents,
        'xp_reward': xpReward,
        'badge_code': badgeCode,
        'author_id': authorId,
        'author_name': authorName,
        'is_premium': isPremium,
        'locale': locale,
        'order': order,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Módulo dentro de uma trilha.
class PathModule {
  final String id;
  final String pathId;
  final String title;
  final String? description;
  final int order;
  final int totalContents;
  final List<PathContent> contents;

  const PathModule({
    required this.id,
    required this.pathId,
    required this.title,
    this.description,
    this.order = 0,
    this.totalContents = 0,
    this.contents = const [],
  });

  factory PathModule.fromJson(Map<String, dynamic> json) => PathModule(
        id: json['id'] as String? ?? '',
        pathId: json['path_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        order: json['order'] as int? ?? 0,
        totalContents: json['total_contents'] as int? ?? 0,
        contents: (json['contents'] as List?)
                ?.map((c) => PathContent.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'path_id': pathId,
        'title': title,
        'description': description,
        'order': order,
        'total_contents': totalContents,
      };
}

/// Conteúdo individual dentro de um módulo.
class PathContent {
  final String id;
  final String moduleId;
  final String entityId;
  final String entityType;
  final String entityName;
  final PathContentType contentType;
  final int order;
  final bool isOptional;
  final bool isPrerequisite;

  const PathContent({
    required this.id,
    required this.moduleId,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    this.contentType = PathContentType.text,
    this.order = 0,
    this.isOptional = false,
    this.isPrerequisite = false,
  });

  factory PathContent.fromJson(Map<String, dynamic> json) => PathContent(
        id: json['id'] as String? ?? '',
        moduleId: json['module_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: json['entity_type'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        contentType: PathContentType.values.firstWhere(
          (e) => e.name == (json['content_type'] as String? ?? 'text'),
          orElse: () => PathContentType.text,
        ),
        order: json['order'] as int? ?? 0,
        isOptional: json['is_optional'] as bool? ?? false,
        isPrerequisite: json['is_prerequisite'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'module_id': moduleId,
        'entity_id': entityId,
        'entity_type': entityType,
        'entity_name': entityName,
        'content_type': contentType.name,
        'order': order,
        'is_optional': isOptional,
        'is_prerequisite': isPrerequisite,
      };
}

/// Progresso do usuário em uma trilha.
class PathProgress {
  final String id;
  final String userId;
  final String pathId;
  final String pathName;
  final PathStatus status;
  final int completedModules;
  final int completedContents;
  final int totalModules;
  final int totalContents;
  final int totalTimeSeconds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessAt;

  const PathProgress({
    required this.id,
    required this.userId,
    required this.pathId,
    required this.pathName,
    this.status = PathStatus.notStarted,
    this.completedModules = 0,
    this.completedContents = 0,
    this.totalModules = 0,
    this.totalContents = 0,
    this.totalTimeSeconds = 0,
    required this.startedAt,
    this.completedAt,
    required this.lastAccessAt,
  });

  double get progressPercent =>
      totalContents > 0 ? (completedContents / totalContents).clamp(0.0, 1.0) : 0.0;

  factory PathProgress.fromJson(Map<String, dynamic> json) => PathProgress(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        pathId: json['path_id'] as String? ?? '',
        pathName: json['path_name'] as String? ?? '',
        status: PathStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'notStarted'),
          orElse: () => PathStatus.notStarted,
        ),
        completedModules: json['completed_modules'] as int? ?? 0,
        completedContents: json['completed_contents'] as int? ?? 0,
        totalModules: json['total_modules'] as int? ?? 0,
        totalContents: json['total_contents'] as int? ?? 0,
        totalTimeSeconds: json['total_time_seconds'] as int? ?? 0,
        startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
        lastAccessAt: DateTime.tryParse(json['last_access_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'path_id': pathId,
        'path_name': pathName,
        'status': status.name,
        'completed_modules': completedModules,
        'completed_contents': completedContents,
        'total_modules': totalModules,
        'total_contents': totalContents,
        'total_time_seconds': totalTimeSeconds,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'last_access_at': lastAccessAt.toIso8601String(),
      };
}

/// Progresso do usuário em um módulo.
class ModuleProgress {
  final String id;
  final String userId;
  final String moduleId;
  final String pathId;
  final ModuleStatus status;
  final int completedContents;
  final int totalContents;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ModuleProgress({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.pathId,
    this.status = ModuleStatus.locked,
    this.completedContents = 0,
    this.totalContents = 0,
    this.startedAt,
    this.completedAt,
  });

  double get progressPercent =>
      totalContents > 0 ? (completedContents / totalContents).clamp(0.0, 1.0) : 0.0;

  factory ModuleProgress.fromJson(Map<String, dynamic> json) => ModuleProgress(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        moduleId: json['module_id'] as String? ?? '',
        pathId: json['path_id'] as String? ?? '',
        status: ModuleStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'locked'),
          orElse: () => ModuleStatus.locked,
        ),
        completedContents: json['completed_contents'] as int? ?? 0,
        totalContents: json['total_contents'] as int? ?? 0,
        startedAt: json['started_at'] != null
            ? DateTime.tryParse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.tryParse(json['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'module_id': moduleId,
        'path_id': pathId,
        'status': status.name,
        'completed_contents': completedContents,
        'total_contents': totalContents,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };
}

/// Certificado gerado ao concluir uma trilha.
class PathCertificate {
  final String id;
  final String userId;
  final String userName;
  final String pathId;
  final String pathName;
  final DateTime completedAt;
  final int totalTimeSeconds;
  final int totalContentsCompleted;
  final int xpEarned;
  final String? pdfUrl;

  const PathCertificate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.pathId,
    required this.pathName,
    required this.completedAt,
    this.totalTimeSeconds = 0,
    this.totalContentsCompleted = 0,
    this.xpEarned = 0,
    this.pdfUrl,
  });

  factory PathCertificate.fromJson(Map<String, dynamic> json) => PathCertificate(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        userName: json['user_name'] as String? ?? '',
        pathId: json['path_id'] as String? ?? '',
        pathName: json['path_name'] as String? ?? '',
        completedAt: DateTime.tryParse(json['completed_at'] as String? ?? '') ?? DateTime.now(),
        totalTimeSeconds: json['total_time_seconds'] as int? ?? 0,
        totalContentsCompleted: json['total_contents_completed'] as int? ?? 0,
        xpEarned: json['xp_earned'] as int? ?? 0,
        pdfUrl: json['pdf_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'path_id': pathId,
        'path_name': pathName,
        'completed_at': completedAt.toIso8601String(),
        'total_time_seconds': totalTimeSeconds,
        'total_contents_completed': totalContentsCompleted,
        'xp_earned': xpEarned,
        'pdf_url': pdfUrl,
      };
}
