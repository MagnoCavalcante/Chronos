import '../../domain/entities/historical_location.dart';
import '../../domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'historical_locations'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class HistoricalLocationModel extends HistoricalLocation {
  const HistoricalLocationModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.shortName,
    required super.description,
    required super.summary,
    required super.latitude,
    required super.longitude,
    required super.locationType,
    super.parentLocationId,
    required super.modernCountry,
    required super.modernRegion,
    required super.startYear,
    super.endYear,
    required super.coverImageUrl,
    required super.publicationStatus,
  });

  /// Reconstrói uma instância de [HistoricalLocationModel] a partir de um registro relacional JSON.
  factory HistoricalLocationModel.fromJson(Map<String, dynamic> json) {
    return HistoricalLocationModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationType: LocationType.fromValue(json['location_type'] as String? ?? 'settlement'),
      parentLocationId: json['parent_location_id'] as String?,
      modernCountry: json['modern_country'] as String? ?? '',
      modernRegion: json['modern_region'] as String? ?? '',
      startYear: (json['start_year'] as num?)?.toInt() ?? 0,
      endYear: (json['end_year'] as num?)?.toInt(),
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String? ?? 'draft'),
    );
  }

  /// Converte a instância atual de [HistoricalLocationModel] em um mapa relacional JSON estrutural.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'short_name': shortName,
      'description': description,
      'summary': summary,
      'latitude': latitude,
      'longitude': longitude,
      'location_type': locationType.value,
      'parent_location_id': parentLocationId,
      'modern_country': modernCountry,
      'modern_region': modernRegion,
      'start_year': startYear,
      'end_year': endYear,
      'cover_image_url': coverImageUrl,
      'publication_status': publicationStatus.value,
    };
  }

  /// Converte uma entidade limpa de domínio [HistoricalLocation] para a representação de dados física [HistoricalLocationModel].
  factory HistoricalLocationModel.fromEntity(HistoricalLocation entity) {
    if (entity is HistoricalLocationModel) {
      return entity;
    }
    return HistoricalLocationModel(
      id: entity.id,
      slug: entity.slug,
      name: entity.name,
      shortName: entity.shortName,
      description: entity.description,
      summary: entity.summary,
      latitude: entity.latitude,
      longitude: entity.longitude,
      locationType: entity.locationType,
      parentLocationId: entity.parentLocationId,
      modernCountry: entity.modernCountry,
      modernRegion: entity.modernRegion,
      startYear: entity.startYear,
      endYear: entity.endYear,
      coverImageUrl: entity.coverImageUrl,
      publicationStatus: entity.publicationStatus,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [HistoricalLocation].
  HistoricalLocation toEntity() {
    return HistoricalLocation(
      id: id,
      slug: slug,
      name: name,
      shortName: shortName,
      description: description,
      summary: summary,
      latitude: latitude,
      longitude: longitude,
      locationType: locationType,
      parentLocationId: parentLocationId,
      modernCountry: modernCountry,
      modernRegion: modernRegion,
      startYear: startYear,
      endYear: endYear,
      coverImageUrl: coverImageUrl,
      publicationStatus: publicationStatus,
    );
  }
}
