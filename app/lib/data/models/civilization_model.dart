import '../../domain/entities/civilization.dart';
import '../../domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'civilizations'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class CivilizationModel extends Civilization {
  const CivilizationModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.shortName,
    required super.description,
    required super.summary,
    required super.startYear,
    super.endYear,
    required super.publicationStatus,
  });

  /// Reconstrói uma instância de [CivilizationModel] a partir de um registro relacional JSON.
  factory CivilizationModel.fromJson(Map<String, dynamic> json) {
    return CivilizationModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String? ?? '',
      description: json['description'] as String,
      summary: json['summary'] as String? ?? '',
      startYear: (json['start_year'] as num?)?.toInt() ?? 0,
      endYear: (json['end_year'] as num?)?.toInt(),
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String? ?? 'draft'),
    );
  }

  /// Converte a instância atual de [CivilizationModel] em um mapa relacional JSON estrutural.
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
      'publication_status': publicationStatus.value,
    };
  }

  /// Converte uma entidade limpa de domínio [Civilization] para a representação de dados física [CivilizationModel].
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
      publicationStatus: entity.publicationStatus,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [Civilization].
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
      publicationStatus: publicationStatus,
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
    PublicationStatus? publicationStatus,
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
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}
