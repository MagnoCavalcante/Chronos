/// Tipo de feedback do usuário.
enum FeedbackType {
  suggestion,
  problem,
  praise,
}

/// Entrada de feedback do usuário.
class UserFeedback {
  final String id;
  final FeedbackType type;
  final String message;
  final String? email;
  final String? screenContext;
  final DateTime createdAt;
  final FeedbackStatus status;

  const UserFeedback({
    required this.id,
    required this.type,
    required this.message,
    this.email,
    this.screenContext,
    required this.createdAt,
    this.status = FeedbackStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'message': message,
        'email': email,
        'screenContext': screenContext,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status.name,
      };

  factory UserFeedback.fromJson(Map<String, dynamic> json) => UserFeedback(
        id: json['id'] as String,
        type: FeedbackType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => FeedbackType.suggestion,
        ),
        message: json['message'] as String,
        email: json['email'] as String?,
        screenContext: json['screenContext'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        status: FeedbackStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => FeedbackStatus.pending,
        ),
      );
}

/// Status do feedback.
enum FeedbackStatus {
  pending,
  sent,
  acknowledged,
}
