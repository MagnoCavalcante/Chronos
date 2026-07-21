import '../../domain/entities/artifact.dart';
import '../../domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'artifacts'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class ArtifactModel extends Artifact {
  const ArtifactModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.shortName,
    required super.description,
    required super.summary,
    required super.artifactType,
    required super.originCivilizationId,
    required super.originLocationId,
    required super.estimatedYear,
    required super.material,
    required super.currentLocation,
    required super.coverImageUrl,
    required super.publicationStatus,
  });

  /// Reconstrói uma instância de [ArtifactModel] a partir de um registro relacional JSON.
  factory ArtifactModel.fromJson(Map<String, dynamic> json) {
    return ArtifactModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String? ?? '',
      description: json['description'] as String,
      summary: json['summary'] as String? ?? '',
      artifactType: json['artifact_type'] as String,
      originCivilizationId: json['origin_civilization_id'] as String? ?? '',
      originLocationId: json['origin_location_id'] as String? ?? '',
      estimatedYear: (json['estimated_year'] as num?)?.toInt() ?? 0,
      material: json['material'] as String? ?? '',
      currentLocation: json['current_location'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String? ?? 'draft'),
    );
  }

  /// Converte a instância atual de [ArtifactModel] em um mapa relacional JSON estrutural.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'short_name': shortName,
      'description': description,
      'summary': summary,
      'artifact_type': artifactType,
      'origin_civilization_id': originCivilizationId,
      'origin_location_id': originLocationId,
      'estimated_year': estimatedYear,
      'material': material,
      'current_location': currentLocation,
      'cover_image_url': coverImageUrl,
      'publication_status': publicationStatus.value,
    };
  }

  /// Converte uma entidade limpa de domínio [Artifact] para a representação de dados física [ArtifactModel].
  factory ArtifactModel.fromEntity(Artifact entity) {
    if (entity is ArtifactModel) {
      return entity;
    }
    return ArtifactModel(
      id: entity.id,
      slug: entity.slug,
      name: entity.name,
      shortName: entity.shortName,
      description: entity.description,
      summary: entity.summary,
      artifactType: entity.artifactType,
      originCivilizationId: entity.originCivilizationId,
      originLocationId: entity.originLocationId,
      estimatedYear: entity.estimatedYear,
      material: entity.material,
      currentLocation: entity.currentLocation,
      coverImageUrl: entity.coverImageUrl,
      publicationStatus: entity.publicationStatus,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [Artifact].
  Artifact toEntity() {
    return Artifact(
      id: id,
      slug: slug,
      name: name,
      shortName: shortName,
      description: description,
      summary: summary,
      artifactType: artifactType,
      originCivilizationId: originCivilizationId,
      originLocationId: originLocationId,
      estimatedYear: estimatedYear,
      material: material,
      currentLocation: currentLocation,
      coverImageUrl: coverImageUrl,
      publicationStatus: publicationStatus,
    );
  }

  @override
  ArtifactModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? shortName,
    String? description,
    String? summary,
    String? artifactType,
    String? originCivilizationId,
    String? originLocationId,
    int? estimatedYear,
    String? material,
    String? currentLocation,
    String? coverImageUrl,
    PublicationStatus? publicationStatus,
  }) {
    return ArtifactModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      artifactType: artifactType ?? this.artifactType,
      originCivilizationId: originCivilizationId ?? this.originCivilizationId,
      originLocationId: originLocationId ?? this.originLocationId,
      estimatedYear: estimatedYear ?? this.estimatedYear,
      material: material ?? this.material,
      currentLocation: currentLocation ?? this.currentLocation,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}
