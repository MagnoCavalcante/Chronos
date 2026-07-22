import 'package:flutter/material.dart';

/// Tipos de entidades suportados na Timeline.
enum TimelineItemType {
  all('all', 'Todos', Icons.apps_rounded, Colors.grey),
  civilization('civilization', 'Civilização', Icons.account_balance_rounded, Colors.teal),
  historicalCharacter('historical_character', 'Personagem', Icons.person_rounded, Colors.blueAccent),
  historicalEvent('historical_event', 'Evento', Icons.history_edu_rounded, Colors.deepOrange),
  artifact('artifact', 'Artefato', Icons.museum_rounded, Colors.indigo),
  historicalLocation('historical_location', 'Localização', Icons.public_rounded, Colors.green),
  historicalSource('historical_source', 'Fonte', Icons.menu_book_rounded, Colors.amber);

  final String apiValue;
  final String label;
  final IconData icon;
  final Color color;

  const TimelineItemType(this.apiValue, this.label, this.icon, this.color);

  static TimelineItemType fromString(String value) {
    return TimelineItemType.values.firstWhere(
      (e) => e.apiValue == value || e.name == value,
      orElse: () => TimelineItemType.all,
    );
  }
}

/// Item unificado de apresentação para a Timeline do CHRONOS.
class TimelineDisplayItem {
  final String id;
  final String slug;
  final String entityType;
  final String title;
  final String description;
  final String? imageUrl;
  final int year;
  final String? color;

  const TimelineDisplayItem({
    required this.id,
    required this.slug,
    required this.entityType,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.year,
    this.color,
  });

  TimelineItemType get type => TimelineItemType.fromString(entityType);

  String get periodLabel {
    return year < 0 ? '${year.abs()} a.C.' : '$year d.C.';
  }

  factory TimelineDisplayItem.fromJson(Map<String, dynamic> json) {
    return TimelineDisplayItem(
      id: json['id'] as String,
      slug: json['slug'] as String? ?? '',
      entityType: json['entity_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      year: json['year'] as int,
      color: json['color'] as String?,
    );
  }
}
