import 'package:chronos/core/base/base_entity.dart';
import 'package:chronos/domain/entities/publication_status.dart';

/// Entidade de Domínio representando uma Civilização no ecossistema CHRONOS.
/// Herda de [BaseEntity] para manter a integridade com as regras de domínio.
class Civilization extends BaseEntity {
  final String slug;
  final String name;
  final String shortName;
  final String description;
  final String summary;
  final int startYear;
  final int? endYear;
  final PublicationStatus publicationStatus;

  const Civilization({
    required String id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.description,
    required this.summary,
    required this.startYear,
    this.endYear,
    required this.publicationStatus,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Civilization &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          name == other.name &&
          shortName == other.shortName &&
          description == other.description &&
          summary == other.summary &&
          startYear == other.startYear &&
          endYear == other.endYear &&
          publicationStatus == other.publicationStatus;

  @override
  int get hashCode =>
      super.hashCode ^
      slug.hashCode ^
      name.hashCode ^
      shortName.hashCode ^
      description.hashCode ^
      summary.hashCode ^
      startYear.hashCode ^
      endYear.hashCode ^
      publicationStatus.hashCode;
}
