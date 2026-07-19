import 'package:chronos/domain/entities/publication_status.dart';
import '../../domain/entities/civilization.dart';

/// Modelo de persistência para a feature Civilizations.
///
/// Mantém a separação entre domínio e infraestrutura, encapsulando o mapeamento JSON
/// do Supabase e deixando claro que as relações futuras ainda não foram implementadas.
class CivilizationModel extends Civilization {
  const CivilizationModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.shortName,
    required super.description,
    required super.summary,
    super.startYear,
    super.endYear,
    super.eraId,
    super.primaryEventId,
    super.primaryCharacterId,
    super.primaryArtifactId,
    super.primaryLocationId,
    super.primarySourceId,
    super.relationshipGraphId,
    required super.publicationStatus,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CivilizationModel.fromJson(Map<String, dynamic> json) {
    return CivilizationModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String? ?? json['nome'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      description: json['description'] as String? ?? json['descricao'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      startYear: json['start_year'] as int?,
      endYear: json['end_year'] as int?,
      eraId: json['era_id'] as String?,
      primaryEventId: json['primary_event_id'] as String?,
      primaryCharacterId: json['primary_character_id'] as String?,
      primaryArtifactId: json['primary_artifact_id'] as String?,
      primaryLocationId: json['primary_location_id'] as String?,
      primarySourceId: json['primary_source_id'] as String?,
      relationshipGraphId: json['relationship_graph_id'] as String?,
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String? ?? 'draft'),
      active: json['active'] as bool? ?? json['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'short_name': shortName,
      'description': description,
      'summary': summary,
      'start_year': startYear,
      'end_year': endYear,
      'era_id': eraId,
      'primary_event_id': primaryEventId,
      'primary_character_id': primaryCharacterId,
      'primary_artifact_id': primaryArtifactId,
      'primary_location_id': primaryLocationId,
      'primary_source_id': primarySourceId,
      'relationship_graph_id': relationshipGraphId,
      'publication_status': publicationStatus.value,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CivilizationModel.fromEntity(Civilization entity) {
    if (entity is CivilizationModel) {
      return entity;
    }
    return CivilizationModel(
      id: entity.id,
      slug: entity.slug,
      name: entity.name,
      shortName: entity.shortName,
      description: entity.description,
      summary: entity.summary,
      startYear: entity.startYear,
      endYear: entity.endYear,
      eraId: entity.eraId,
      primaryEventId: entity.primaryEventId,
      primaryCharacterId: entity.primaryCharacterId,
      primaryArtifactId: entity.primaryArtifactId,
      primaryLocationId: entity.primaryLocationId,
      primarySourceId: entity.primarySourceId,
      relationshipGraphId: entity.relationshipGraphId,
      publicationStatus: entity.publicationStatus,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Civilization toEntity() {
    return Civilization(
      id: id,
      slug: slug,
      name: name,
      shortName: shortName,
      description: description,
      summary: summary,
      startYear: startYear,
      endYear: endYear,
      eraId: eraId,
      primaryEventId: primaryEventId,
      primaryCharacterId: primaryCharacterId,
      primaryArtifactId: primaryArtifactId,
      primaryLocationId: primaryLocationId,
      primarySourceId: primarySourceId,
      relationshipGraphId: relationshipGraphId,
      publicationStatus: publicationStatus,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  CivilizationModel copyWith({
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
    return CivilizationModel(
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
}
