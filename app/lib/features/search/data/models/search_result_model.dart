import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.id,
    required super.entityType,
    required super.title,
    required super.subtitle,
    required super.summary,
    super.imageUrl,
    super.chronologyValue,
    required super.createdAt,
    required super.tags,
    required super.relevance,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return SearchResultModel(
      id: json['entity_id'].toString(),
      entityType: json['entity_type'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      chronologyValue: (json['chronology_value'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      tags: rawTags is List ? rawTags.map((tag) => tag.toString()).toList(growable: false) : const [],
      relevance: (json['relevance'] as num?)?.toInt() ?? 0,
    );
  }
}
