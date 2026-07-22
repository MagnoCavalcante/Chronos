import '../../core/base/base_entity.dart';
import 'publication_status.dart';

/// Enum fortemente tipado representando os diferentes tipos geográficos e arqueológicos de Localizações Históricas.
enum LocationType {
  continent('continent'),
  country('country'),
  region('region'),
  province('province'),
  city('city'),
  village('village'),
  settlement('settlement'),
  empire('empire'),
  kingdom('kingdom'),
  archaeologicalSite('archaeological_site'),
  battlefield('battlefield'),
  religiousSite('religious_site'),
  monument('monument'),
  naturalLandmark('natural_landmark');

  final String value;

  const LocationType(this.value);

  /// Converte uma string no enum correspondente de forma segura.
  factory LocationType.fromValue(String value) {
    return LocationType.values.firstWhere(
      (type) => type.value == value.toLowerCase() || type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LocationType.settlement,
    );
  }

  @override
  String toString() => value;
}

/// Entidade de Domínio representando uma Localização Histórica no ecossistema CHRONOS.
///
/// Serve como base geográfica pura, imutável e desacoplada para todas as relações históricas do sistema.
class HistoricalLocation extends BaseEntity {
  final String slug;
  final String name;
  final String shortName;
  final String description;
  final String summary;
  final double latitude;
  final double longitude;
  final LocationType locationType;
  final String? parentLocationId;
  final String modernCountry;
  final String modernRegion;
  final int startYear;
  final int? endYear;
  final String coverImageUrl;
  final PublicationStatus publicationStatus;

  const HistoricalLocation({
    required String id,
    required this.slug,
    required this.name,
    required this.shortName,
    required this.description,
    required this.summary,
    required this.latitude,
    required this.longitude,
    required this.locationType,
    this.parentLocationId,
    required this.modernCountry,
    required this.modernRegion,
    required this.startYear,
    this.endYear,
    required this.coverImageUrl,
    required this.publicationStatus,
  }) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is HistoricalLocation &&
          runtimeType == other.runtimeType &&
          slug == other.slug &&
          name == other.name &&
          shortName == other.shortName &&
          description == other.description &&
          summary == other.summary &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          locationType == other.locationType &&
          parentLocationId == other.parentLocationId &&
          modernCountry == other.modernCountry &&
          modernRegion == other.modernRegion &&
          startYear == other.startYear &&
          endYear == other.endYear &&
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
      latitude.hashCode ^
      longitude.hashCode ^
      locationType.hashCode ^
      parentLocationId.hashCode ^
      modernCountry.hashCode ^
      modernRegion.hashCode ^
      startYear.hashCode ^
      endYear.hashCode ^
      coverImageUrl.hashCode ^
      publicationStatus.hashCode;
}
