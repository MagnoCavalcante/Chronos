import 'package:chronos/domain/entities/publication_status.dart';

/// Entidade de domínio para Civilizations.
///
/// Esta primeira versão representa a fundação estratégica da feature e já prepara o modelo
/// para futuras relações com Eras, Historical Events, Historical Characters, Artifacts,
/// Sources, Locations e Relationship Graph, sem implementar essas relações ainda.
class Civilization {
  /// Dados próprios
  final String id;
  final String slug;
  final String name;
  final String shortName;
  final String description;
  final String summary;
  final int? startYear;
  final int? endYear;

  /// Relacionamentos futuros (reservados)
  ///
  /// Estes campos não são usados ainda, mas servem como pontos de extensão futuros.
  final String? eraId;
  final String? primaryEventId;
  final String? primaryCharacterId;
  final String? primaryArtifactId;
  final String? primaryLocationId;
  final String? primarySourceId;
  final String? relationshipGraphId;

  /// Metadados editoriais
  final PublicationStatus publicationStatus;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Civilization({
    required this.id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.description,
    required this.summary,
    this.startYear,
    this.endYear,
    this.eraId,
    this.primaryEventId,
    this.primaryCharacterId,
    this.primaryArtifactId,
    this.primaryLocationId,
    this.primarySourceId,
    this.relationshipGraphId,
    required this.publicationStatus,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  Civilization copyWith({
    String? id,
    String? slug,
    String? name,
    String? shortName,
    String? description,
    String? summary,
    int? startYear,
    int? endYear,
    String? eraId,
    String? primaryEventId,
    String? primaryCharacterId,
    String? primaryArtifactId,
    String? primaryLocationId,
    String? primarySourceId,
    String? relationshipGraphId,
    PublicationStatus? publicationStatus,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Civilization(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      eraId: eraId ?? this.eraId,
      primaryEventId: primaryEventId ?? this.primaryEventId,
      primaryCharacterId: primaryCharacterId ?? this.primaryCharacterId,
      primaryArtifactId: primaryArtifactId ?? this.primaryArtifactId,
      primaryLocationId: primaryLocationId ?? this.primaryLocationId,
      primarySourceId: primarySourceId ?? this.primarySourceId,
      relationshipGraphId: relationshipGraphId ?? this.relationshipGraphId,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Civilization &&
        other.id == id &&
        other.slug == slug &&
        other.name == name &&
        other.shortName == shortName &&
        other.description == description &&
        other.summary == summary &&
        other.startYear == startYear &&
        other.endYear == endYear &&
        other.eraId == eraId &&
        other.primaryEventId == primaryEventId &&
        other.primaryCharacterId == primaryCharacterId &&
        other.primaryArtifactId == primaryArtifactId &&
        other.primaryLocationId == primaryLocationId &&
        other.primarySourceId == primarySourceId &&
        other.relationshipGraphId == relationshipGraphId &&
        other.publicationStatus == publicationStatus &&
        other.active == active &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        slug.hashCode ^
        name.hashCode ^
        shortName.hashCode ^
        description.hashCode ^
        summary.hashCode ^
        startYear.hashCode ^
        endYear.hashCode ^
        eraId.hashCode ^
        primaryEventId.hashCode ^
        primaryCharacterId.hashCode ^
        primaryArtifactId.hashCode ^
        primaryLocationId.hashCode ^
        primarySourceId.hashCode ^
        relationshipGraphId.hashCode ^
        publicationStatus.hashCode ^
        active.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
