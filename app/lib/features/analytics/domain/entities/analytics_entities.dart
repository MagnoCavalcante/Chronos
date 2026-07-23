/// Tipo de evento analítico registrado localmente.
enum AnalyticsEventType {
  export,
  share,
  favorite,
  view,
  search,
  presentation,
}

/// Evento analítico local.
class AnalyticsEvent {
  final String id;
  final AnalyticsEventType type;
  final String entityType;
  final String entityId;
  final String? format;
  final DateTime timestamp;
  final int? durationMs;
  final Map<String, dynamic>? metadata;

  const AnalyticsEvent({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    this.format,
    required this.timestamp,
    this.durationMs,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'entityType': entityType,
        'entityId': entityId,
        'format': format,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'durationMs': durationMs,
      };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
        id: json['id'] as String,
        type: AnalyticsEventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AnalyticsEventType.view,
        ),
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        format: json['format'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        durationMs: json['durationMs'] as int?,
      );
}

/// Resumo analítico local.
class AnalyticsSummary {
  final int totalExports;
  final String? mostUsedFormat;
  final String? mostSharedContent;
  final int averageReadingTimeMs;
  final String? mostFavoritedContent;
  final Map<String, int> formatCounts;
  final Map<String, int> entityTypeCounts;

  const AnalyticsSummary({
    required this.totalExports,
    this.mostUsedFormat,
    this.mostSharedContent,
    required this.averageReadingTimeMs,
    this.mostFavoritedContent,
    required this.formatCounts,
    required this.entityTypeCounts,
  });
}
