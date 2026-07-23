/// Prioridade de um bug.
enum BugPriority { critical, high, medium, low }

/// Status de um bug.
enum BugStatus { open, inProgress, fixed, wontFix, deferred }

/// Categoria de um bug.
enum BugCategory {
  ui,
  navigation,
  data,
  performance,
  crash,
  network,
  auth,
  export,
  ai,
  map,
  other,
}

/// Registro de Bug para o sistema de tracking.
class BugReport {
  final String id;
  final String description;
  final BugPriority priority;
  final BugCategory category;
  final String? responsavel;
  final BugStatus status;
  final String? versionFixed;
  final String? steps;
  final String? expectedBehavior;
  final String? actualBehavior;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const BugReport({
    required this.id,
    required this.description,
    required this.priority,
    required this.category,
    this.responsavel,
    this.status = BugStatus.open,
    this.versionFixed,
    this.steps,
    this.expectedBehavior,
    this.actualBehavior,
    required this.createdAt,
    this.resolvedAt,
  });

  BugReport copyWith({
    BugStatus? status,
    String? versionFixed,
    String? responsavel,
    DateTime? resolvedAt,
  }) {
    return BugReport(
      id: id,
      description: description,
      priority: priority,
      category: category,
      responsavel: responsavel ?? this.responsavel,
      status: status ?? this.status,
      versionFixed: versionFixed ?? this.versionFixed,
      steps: steps,
      expectedBehavior: expectedBehavior,
      actualBehavior: actualBehavior,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'priority': priority.name,
        'category': category.name,
        'responsavel': responsavel,
        'status': status.name,
        'versionFixed': versionFixed,
        'steps': steps,
        'expectedBehavior': expectedBehavior,
        'actualBehavior': actualBehavior,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
      };

  factory BugReport.fromJson(Map<String, dynamic> json) => BugReport(
        id: json['id'] as String,
        description: json['description'] as String,
        priority: BugPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => BugPriority.medium,
        ),
        category: BugCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => BugCategory.other,
        ),
        responsavel: json['responsavel'] as String?,
        status: BugStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BugStatus.open,
        ),
        versionFixed: json['versionFixed'] as String?,
        steps: json['steps'] as String?,
        expectedBehavior: json['expectedBehavior'] as String?,
        actualBehavior: json['actualBehavior'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        resolvedAt: json['resolvedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['resolvedAt'] as int)
            : null,
      );
}
