/// CHRONOS Sprint 9.4.0 — Admin Studio V1
///
/// Entidades do Painel Administrativo.
/// CMS especializado em História com fluxo editorial,
/// versionamento, auditoria, mídia e permissões granulares.

// ============================================================
// Enums
// ============================================================

/// Papel do usuário no sistema.
enum AdminRole {
  superAdmin('Super Administrador'),
  admin('Administrador'),
  editor('Editor'),
  reviewer('Revisor'),
  translator('Tradutor'),
  moderator('Moderador'),
  premiumUser('Usuário Premium'),
  freeUser('Usuário Gratuito');

  final String label;
  const AdminRole(this.label);
}

/// Status editorial de um conteúdo.
enum EditorialStatus {
  draft('Rascunho'),
  inReview('Em Revisão'),
  approved('Aprovado'),
  published('Publicado'),
  archived('Arquivado');

  final String label;
  const EditorialStatus(this.label);
}

/// Tipo de entidade gerenciável.
enum AdminEntityType {
  character('Personagem'),
  event('Evento'),
  civilization('Civilização'),
  artifact('Artefato'),
  location('Localização'),
  source('Fonte'),
  learningPath('Trilha'),
  quiz('Quiz');

  final String label;
  const AdminEntityType(this.label);
}

/// Tipo de ação auditável.
enum AuditActionType {
  login,
  logout,
  create,
  update,
  delete,
  publish,
  archive,
  restore,
  approve,
  reject,
  importData,
  exportData,
  roleChange,
  permissionChange,
}

/// Tipo de mídia.
enum MediaType {
  image('Imagem'),
  video('Vídeo'),
  document('Documento'),
  audio('Áudio'),
  thumbnail('Miniatura');

  final String label;
  const MediaType(this.label);
}

/// Tipo de bloco do editor visual.
enum EditorBlockType {
  heading,
  paragraph,
  image,
  video,
  table,
  quote,
  observation,
  fact,
  theory,
  debate,
  footnote,
  reference,
}

/// Tipo de sugestão do assistente editorial.
enum AssistantSuggestionType {
  incompleteField('Campo incompleto'),
  relationSuggestion('Sugestão de relação'),
  chronologyInconsistency('Inconsistência cronológica'),
  sourceSuggestion('Sugestão de fonte'),
  classificationSuggestion('Classificação Fato/Teoria/Debate');

  final String label;
  const AssistantSuggestionType(this.label);
}

/// Formato de importação/exportação.
enum DataFormat { csv, json, markdown, pdf }

/// Módulo com permissão controlável.
enum AdminModule {
  dashboard,
  characters,
  events,
  civilizations,
  artifacts,
  locations,
  sources,
  learningPaths,
  quizzes,
  media,
  users,
  audit,
  importExport,
  settings,
}

// ============================================================
// Estatísticas do Dashboard
// ============================================================

class AdminDashboardStats {
  final int totalUsers;
  final int activeUsersToday;
  final int publishedContents;
  final int contentsInReview;
  final int characters;
  final int events;
  final int civilizations;
  final int artifacts;
  final int locations;
  final int sources;
  final int learningPaths;
  final int quizzes;
  final int aiSessions;
  final Map<String, int> growthByMonth;

  const AdminDashboardStats({
    this.totalUsers = 0,
    this.activeUsersToday = 0,
    this.publishedContents = 0,
    this.contentsInReview = 0,
    this.characters = 0,
    this.events = 0,
    this.civilizations = 0,
    this.artifacts = 0,
    this.locations = 0,
    this.sources = 0,
    this.learningPaths = 0,
    this.quizzes = 0,
    this.aiSessions = 0,
    this.growthByMonth = const {},
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) =>
      AdminDashboardStats(
        totalUsers: json['total_users'] as int? ?? 0,
        activeUsersToday: json['active_users_today'] as int? ?? 0,
        publishedContents: json['published_contents'] as int? ?? 0,
        contentsInReview: json['contents_in_review'] as int? ?? 0,
        characters: json['characters'] as int? ?? 0,
        events: json['events'] as int? ?? 0,
        civilizations: json['civilizations'] as int? ?? 0,
        artifacts: json['artifacts'] as int? ?? 0,
        locations: json['locations'] as int? ?? 0,
        sources: json['sources'] as int? ?? 0,
        learningPaths: json['learning_paths'] as int? ?? 0,
        quizzes: json['quizzes'] as int? ?? 0,
        aiSessions: json['ai_sessions'] as int? ?? 0,
        growthByMonth: Map<String, int>.from(
            json['growth_by_month'] as Map? ?? {}),
      );
}

// ============================================================
// Usuário Administrativo
// ============================================================

class AdminUser {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = AdminRole.freeUser,
    this.permissions = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  AdminUser copyWith({
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
    DateTime? lastLoginAt,
  }) =>
      AdminUser(
        id: id,
        name: name,
        email: email,
        role: role ?? this.role,
        permissions: permissions ?? this.permissions,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'permissions': permissions.map((p) => p.toJson()).toList(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: AdminRole.values.firstWhere(
          (e) => e.name == (json['role'] as String? ?? 'freeUser'),
          orElse: () => AdminRole.freeUser,
        ),
        permissions: (json['permissions'] as List?)
                ?.map((p) =>
                    AdminPermission.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.tryParse(json['last_login_at'] as String)
            : null,
      );

  /// Verifica se o usuário pode realizar ação em um módulo.
  bool canPerform(AdminModule module, PermissionAction action) {
    if (role == AdminRole.superAdmin) return true;
    return permissions.any(
        (p) => p.module == module && p.actions.contains(action));
  }
}

// ============================================================
// Permissões Granulares
// ============================================================

enum PermissionAction { read, create, update, delete, publish, approve }

class AdminPermission {
  final AdminModule module;
  final List<PermissionAction> actions;

  const AdminPermission({
    required this.module,
    this.actions = const [],
  });

  Map<String, dynamic> toJson() => {
        'module': module.name,
        'actions': actions.map((a) => a.name).toList(),
      };

  factory AdminPermission.fromJson(Map<String, dynamic> json) =>
      AdminPermission(
        module: AdminModule.values.firstWhere(
          (e) => e.name == (json['module'] as String? ?? 'dashboard'),
          orElse: () => AdminModule.dashboard,
        ),
        actions: (json['actions'] as List?)
                ?.map((a) => PermissionAction.values.firstWhere(
                      (e) => e.name == (a as String),
                      orElse: () => PermissionAction.read,
                    ))
                .toList() ??
            [],
      );
}

// ============================================================
// Versionamento de Conteúdo
// ============================================================

class ContentVersion {
  final String id;
  final String entityId;
  final AdminEntityType entityType;
  final int versionNumber;
  final Map<String, dynamic> data;
  final String authorId;
  final String authorName;
  final String? changeDescription;
  final DateTime createdAt;

  const ContentVersion({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.versionNumber,
    this.data = const {},
    required this.authorId,
    this.authorName = '',
    this.changeDescription,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_id': entityId,
        'entity_type': entityType.name,
        'version_number': versionNumber,
        'data': data,
        'author_id': authorId,
        'author_name': authorName,
        'change_description': changeDescription,
        'created_at': createdAt.toIso8601String(),
      };

  factory ContentVersion.fromJson(Map<String, dynamic> json) =>
      ContentVersion(
        id: json['id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: AdminEntityType.values.firstWhere(
          (e) => e.name == (json['entity_type'] as String? ?? 'character'),
          orElse: () => AdminEntityType.character,
        ),
        versionNumber: json['version_number'] as int? ?? 1,
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        authorId: json['author_id'] as String? ?? '',
        authorName: json['author_name'] as String? ?? '',
        changeDescription: json['change_description'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}

// ============================================================
// Fluxo Editorial
// ============================================================

class EditorialEntry {
  final String id;
  final String entityId;
  final AdminEntityType entityType;
  final EditorialStatus status;
  final String createdBy;
  final String? reviewedBy;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final DateTime? publishedAt;
  final DateTime? archivedAt;

  const EditorialEntry({
    required this.id,
    required this.entityId,
    required this.entityType,
    this.status = EditorialStatus.draft,
    required this.createdBy,
    this.reviewedBy,
    this.approvedBy,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
    this.approvedAt,
    this.publishedAt,
    this.archivedAt,
  });

  EditorialEntry copyWith({
    EditorialStatus? status,
    String? reviewedBy,
    String? approvedBy,
    String? rejectionReason,
    DateTime? reviewedAt,
    DateTime? approvedAt,
    DateTime? publishedAt,
    DateTime? archivedAt,
  }) =>
      EditorialEntry(
        id: id,
        entityId: entityId,
        entityType: entityType,
        status: status ?? this.status,
        createdBy: createdBy,
        reviewedBy: reviewedBy ?? this.reviewedBy,
        approvedBy: approvedBy ?? this.approvedBy,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        createdAt: createdAt,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        approvedAt: approvedAt ?? this.approvedAt,
        publishedAt: publishedAt ?? this.publishedAt,
        archivedAt: archivedAt ?? this.archivedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_id': entityId,
        'entity_type': entityType.name,
        'status': status.name,
        'created_by': createdBy,
        'reviewed_by': reviewedBy,
        'approved_by': approvedBy,
        'rejection_reason': rejectionReason,
        'created_at': createdAt.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
        'approved_at': approvedAt?.toIso8601String(),
        'published_at': publishedAt?.toIso8601String(),
        'archived_at': archivedAt?.toIso8601String(),
      };

  factory EditorialEntry.fromJson(Map<String, dynamic> json) =>
      EditorialEntry(
        id: json['id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityType: AdminEntityType.values.firstWhere(
          (e) => e.name == (json['entity_type'] as String? ?? 'character'),
          orElse: () => AdminEntityType.character,
        ),
        status: EditorialStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'draft'),
          orElse: () => EditorialStatus.draft,
        ),
        createdBy: json['created_by'] as String? ?? '',
        reviewedBy: json['reviewed_by'] as String?,
        approvedBy: json['approved_by'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.tryParse(json['reviewed_at'] as String)
            : null,
        approvedAt: json['approved_at'] != null
            ? DateTime.tryParse(json['approved_at'] as String)
            : null,
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'] as String)
            : null,
        archivedAt: json['archived_at'] != null
            ? DateTime.tryParse(json['archived_at'] as String)
            : null,
      );
}

// ============================================================
// Log de Auditoria
// ============================================================

class AuditLogEntry {
  final String id;
  final String userId;
  final String userName;
  final AuditActionType action;
  final String? entityId;
  final AdminEntityType? entityType;
  final String? entityName;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final DateTime createdAt;

  const AuditLogEntry({
    required this.id,
    required this.userId,
    this.userName = '',
    required this.action,
    this.entityId,
    this.entityType,
    this.entityName,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'action': action.name,
        'entity_id': entityId,
        'entity_type': entityType?.name,
        'entity_name': entityName,
        'details': details,
        'ip_address': ipAddress,
        'created_at': createdAt.toIso8601String(),
      };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      AuditLogEntry(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        userName: json['user_name'] as String? ?? '',
        action: AuditActionType.values.firstWhere(
          (e) => e.name == (json['action'] as String? ?? 'login'),
          orElse: () => AuditActionType.login,
        ),
        entityId: json['entity_id'] as String?,
        entityType: json['entity_type'] != null
            ? AdminEntityType.values.firstWhere(
                (e) => e.name == json['entity_type'],
                orElse: () => AdminEntityType.character,
              )
            : null,
        entityName: json['entity_name'] as String?,
        details: json['details'] != null
            ? Map<String, dynamic>.from(json['details'] as Map)
            : null,
        ipAddress: json['ip_address'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}

// ============================================================
// Biblioteca de Mídia
// ============================================================

class MediaAsset {
  final String id;
  final String fileName;
  final String url;
  final MediaType type;
  final int sizeBytes;
  final String? folder;
  final List<String> tags;
  final String uploadedBy;
  final String? altText;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const MediaAsset({
    required this.id,
    required this.fileName,
    required this.url,
    required this.type,
    this.sizeBytes = 0,
    this.folder,
    this.tags = const [],
    required this.uploadedBy,
    this.altText,
    this.width,
    this.height,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'file_name': fileName,
        'url': url,
        'type': type.name,
        'size_bytes': sizeBytes,
        'folder': folder,
        'tags': tags,
        'uploaded_by': uploadedBy,
        'alt_text': altText,
        'width': width,
        'height': height,
        'created_at': createdAt.toIso8601String(),
      };

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: json['id'] as String? ?? '',
        fileName: json['file_name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: MediaType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'image'),
          orElse: () => MediaType.image,
        ),
        sizeBytes: json['size_bytes'] as int? ?? 0,
        folder: json['folder'] as String?,
        tags: List<String>.from(json['tags'] as List? ?? []),
        uploadedBy: json['uploaded_by'] as String? ?? '',
        altText: json['alt_text'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}

// ============================================================
// Editor Visual — Bloco de Conteúdo
// ============================================================

class EditorBlock {
  final String id;
  final EditorBlockType type;
  final Map<String, dynamic> data;
  final int order;

  const EditorBlock({
    required this.id,
    required this.type,
    this.data = const {},
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'order': order,
      };

  factory EditorBlock.fromJson(Map<String, dynamic> json) => EditorBlock(
        id: json['id'] as String? ?? '',
        type: EditorBlockType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'paragraph'),
          orElse: () => EditorBlockType.paragraph,
        ),
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        order: json['order'] as int? ?? 0,
      );
}

// ============================================================
// Sugestão do Assistente Editorial
// ============================================================

class EditorAssistantSuggestion {
  final String id;
  final String entityId;
  final AssistantSuggestionType type;
  final String title;
  final String description;
  final String? suggestedValue;
  final String? fieldName;
  final bool isApplied;
  final bool isDismissed;
  final DateTime createdAt;

  const EditorAssistantSuggestion({
    required this.id,
    required this.entityId,
    required this.type,
    required this.title,
    required this.description,
    this.suggestedValue,
    this.fieldName,
    this.isApplied = false,
    this.isDismissed = false,
    required this.createdAt,
  });

  EditorAssistantSuggestion copyWith({
    bool? isApplied,
    bool? isDismissed,
  }) =>
      EditorAssistantSuggestion(
        id: id,
        entityId: entityId,
        type: type,
        title: title,
        description: description,
        suggestedValue: suggestedValue,
        fieldName: fieldName,
        isApplied: isApplied ?? this.isApplied,
        isDismissed: isDismissed ?? this.isDismissed,
        createdAt: createdAt,
      );
}

// ============================================================
// Conteúdo Gerenciável (wrapper genérico para CRUD)
// ============================================================

class ManagedContent {
  final String id;
  final AdminEntityType entityType;
  final String name;
  final EditorialStatus status;
  final Map<String, dynamic> fields;
  final List<String> tags;
  final List<EditorBlock> blocks;
  final String createdBy;
  final String? updatedBy;
  final int currentVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ManagedContent({
    required this.id,
    required this.entityType,
    required this.name,
    this.status = EditorialStatus.draft,
    this.fields = const {},
    this.tags = const [],
    this.blocks = const [],
    required this.createdBy,
    this.updatedBy,
    this.currentVersion = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  ManagedContent copyWith({
    String? name,
    EditorialStatus? status,
    Map<String, dynamic>? fields,
    List<String>? tags,
    List<EditorBlock>? blocks,
    String? updatedBy,
    int? currentVersion,
    DateTime? updatedAt,
  }) =>
      ManagedContent(
        id: id,
        entityType: entityType,
        name: name ?? this.name,
        status: status ?? this.status,
        fields: fields ?? this.fields,
        tags: tags ?? this.tags,
        blocks: blocks ?? this.blocks,
        createdBy: createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        currentVersion: currentVersion ?? this.currentVersion,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_type': entityType.name,
        'name': name,
        'status': status.name,
        'fields': fields,
        'tags': tags,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'created_by': createdBy,
        'updated_by': updatedBy,
        'current_version': currentVersion,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ManagedContent.fromJson(Map<String, dynamic> json) =>
      ManagedContent(
        id: json['id'] as String? ?? '',
        entityType: AdminEntityType.values.firstWhere(
          (e) => e.name == (json['entity_type'] as String? ?? 'character'),
          orElse: () => AdminEntityType.character,
        ),
        name: json['name'] as String? ?? '',
        status: EditorialStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'draft'),
          orElse: () => EditorialStatus.draft,
        ),
        fields: Map<String, dynamic>.from(json['fields'] as Map? ?? {}),
        tags: List<String>.from(json['tags'] as List? ?? []),
        blocks: (json['blocks'] as List?)
                ?.map((b) => EditorBlock.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [],
        createdBy: json['created_by'] as String? ?? '',
        updatedBy: json['updated_by'] as String?,
        currentVersion: json['current_version'] as int? ?? 1,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
                DateTime.now(),
      );
}

// ============================================================
// Importação — Resultado
// ============================================================

class ImportResult {
  final int totalRecords;
  final int imported;
  final int skipped;
  final int errors;
  final List<String> errorMessages;

  const ImportResult({
    this.totalRecords = 0,
    this.imported = 0,
    this.skipped = 0,
    this.errors = 0,
    this.errorMessages = const [],
  });
}
