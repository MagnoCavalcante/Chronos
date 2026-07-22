/// Item unificado exibido na Home, Favoritos e Histórico do CHRONOS.
class HomeItem {
  final String entityType;
  final String entityId;
  final String title;
  final String? imageUrl;
  final String? category;
  final String? chronology;
  final DateTime? accessedAt;
  final DateTime? favoritedAt;

  const HomeItem({
    required this.entityType,
    required this.entityId,
    required this.title,
    this.imageUrl,
    this.category,
    this.chronology,
    this.accessedAt,
    this.favoritedAt,
  });

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      chronology: json['chronology'] as String?,
      accessedAt: json['accessed_at'] != null
          ? DateTime.parse(json['accessed_at'] as String)
          : null,
      favoritedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'chronology': chronology,
    };
  }

  HomeItem copyWith({DateTime? accessedAt, DateTime? favoritedAt}) {
    return HomeItem(
      entityType: entityType,
      entityId: entityId,
      title: title,
      imageUrl: imageUrl,
      category: category,
      chronology: chronology,
      accessedAt: accessedAt ?? this.accessedAt,
      favoritedAt: favoritedAt ?? this.favoritedAt,
    );
  }
}
