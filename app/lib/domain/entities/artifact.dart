import '../../core/base/base_entity.dart';
import 'publication_status.dart';

/// Entidade de Domínio representando um Artefato histórico no ecossistema CHRONOS.
///
/// Totalmente pura, imutável e desacoplada de frameworks ou bancos de dados físicos.
class Artifact extends BaseEntity {
  final String slug;
  final String name;
  final String shortName;
  final String description;
  final String summary;
  final String artifactType;
  final String originCivilizationId;
  final String originLocationId;
  final int estimatedYear;
  final String material;
  final String currentLocation;
  final String coverImageUrl;
  final PublicationStatus publicationStatus;

  const Artifact({
    required String id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.description,
    required this.summary,
    required this.artifactType,
    required this.originCivilizationId,
    required this.originLocationId,
    required this.estimatedYear,
    required this.material,
    required this.currentLocation,
    required this.coverImageUrl,
    required this.publicationStatus,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Artifact &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          name == other.name &&
          shortName == other.shortName &&
          description == other.description &&
          summary == other.summary &&
          artifactType == other.artifactType &&
          originCivilizationId == other.originCivilizationId &&
          originLocationId == other.originLocationId &&
          estimatedYear == other.estimatedYear &&
          material == other.material &&
          currentLocation == other.currentLocation &&
          coverImageUrl == other.coverImageUrl &&
          publicationStatus == other.publicationStatus;

  @override
  int get hashCode =>
      super.hashCode ^
      slug.hashCode ^
      name.hashCode ^
      shortName.hashCode ^
      description.hashCode ^
      summary.hashCode ^
      artifactType.hashCode ^
      originCivilizationId.hashCode ^
      originLocationId.hashCode ^
      estimatedYear.hashCode ^
      material.hashCode ^
      currentLocation.hashCode ^
      coverImageUrl.hashCode ^
      publicationStatus.hashCode;
}
