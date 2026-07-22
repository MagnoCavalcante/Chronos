import 'package:flutter/material.dart';

/// Níveis de intensidade de um relacionamento histórico.
enum RelationStrength {
  direct(100),
  strong(75),
  medium(50),
  weak(25);

  final int threshold;
  const RelationStrength(this.threshold);

  static RelationStrength fromScore(int score) {
    if (score >= 90) return RelationStrength.direct;
    if (score >= 60) return RelationStrength.strong;
    if (score >= 35) return RelationStrength.medium;
    return RelationStrength.weak;
  }
}

/// Categorias de relacionamento que a interface pode apresentar.
enum RelationType {
  civilization('Civilização'),
  historicalCharacter('Personagem'),
  historicalEvent('Evento'),
  historicalLocation('Localização'),
  artifact('Artefato'),
  historicalSource('Fonte'),
  contemporary('Contemporâneo'),
  unknown('Desconhecido');

  final String label;
  const RelationType(this.label);
}

/// Item unificado de relacionamento retornado pela RelationshipEngine.
class RelatedItem {
  final String id;
  final String slug;
  final String entityType;
  final String title;
  final String description;
  final int? year;
  final String? imageUrl;
  final String? color;
  final String relationType;
  final int strength;

  const RelatedItem({
    required this.id,
    required this.slug,
    required this.entityType,
    required this.title,
    required this.description,
    this.year,
    this.imageUrl,
    this.color,
    required this.relationType,
    required this.strength,
  });

  factory RelatedItem.fromJson(Map<String, dynamic> json) {
    return RelatedItem(
      id: json['id'] as String,
      slug: json['slug'] as String,
      entityType: json['entity_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      year: json['year'] as int?,
      imageUrl: json['image_url'] as String?,
      color: json['color'] as String?,
      relationType: json['relation_type'] as String,
      strength: (json['strength'] as num?)?.toInt() ?? 50,
    );
  }

  RelationStrength get relationStrength => RelationStrength.fromScore(strength);

  String get periodLabel {
    if (year == null) return 'Data desconhecida';
    return year! < 0 ? '${year!.abs()} a.C.' : '$year d.C.';
  }
}
