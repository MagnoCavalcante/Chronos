import '../../core/base/base_model.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'historical_events'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
/// Implementa [BaseModel] para padronizar conversão JSON/Entity.
class HistoricalEventModel extends Event implements BaseModel<Event> {
  /// Título resumido para exibições em espaços densos.
  final String tituloCurto;

  /// Descrição concisa para listagens rápidas e tooltips.
  final String descricaoResumida;

  /// Classificação temática do evento (political, military, social, etc.).
  final String eventType;

  /// Nível de precisão temporal (exact, year, approximate, etc.).
  final String datePrecision;

  /// Ano de encerramento do acontecimento (opcional/nulo para pontuais).
  final int? endYear;

  /// Latitude geográfica decimal para mapas.
  final double? latitude;

  /// Longitude geográfica decimal para mapas.
  final double? longitude;

  /// Pontuação de relevância do evento de 1 a 5.
  final int importanceScore;

  const HistoricalEventModel({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required super.eraId,
    required super.slug,
    required String titulo, // Mapeia para super.nome da entidade Event
    required super.descricao,
    required int startYear, // Mapeia para super.anoOcorrencia da entidade Event
    required super.publicationStatus,
    required this.tituloCurto,
    required this.descricaoResumida,
    required this.eventType,
    required this.datePrecision,
    this.endYear,
    this.latitude,
    this.longitude,
    required this.importanceScore,
  }) : super(
          nome: titulo,
          anoOcorrencia: startYear,
        );

  /// Reconstrói uma instância de [HistoricalEventModel] a partir de um registro relacional JSON.
  @override
  factory HistoricalEventModel.fromJson(Map<String, dynamic> json) {
    return HistoricalEventModel(
      id: json['id'] as String,
      active: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      eraId: json['era_id'] as String,
      slug: json['slug'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      startYear: (json['start_year'] as num).toInt(),
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String),
      tituloCurto: json['titulo_curto'] as String,
      descricaoResumida: json['descricao_resumida'] as String,
      eventType: json['event_type'] as String,
      datePrecision: json['date_precision'] as String,
      endYear: json['end_year'] != null ? (json['end_year'] as num).toInt() : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      importanceScore: (json['importance_score'] as num).toInt(),
    );
  }

  /// Converte a instância atual de [HistoricalEventModel] em um mapa relacional JSON estrutural.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ativo': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'era_id': eraId,
      'slug': slug,
      'titulo': nome, // Mapeia para o nome (titulo) da entidade
      'descricao': descricao,
      'start_year': anoOcorrencia, // Mapeia para o anoOcorrencia da entidade
      'publication_status': publicationStatus.value,
      'titulo_curto': tituloCurto,
      'descricao_resumida': descricaoResumida,
      'event_type': eventType,
      'date_precision': datePrecision,
      'end_year': endYear,
      'latitude': latitude,
      'longitude': longitude,
      'importance_score': importanceScore,
    };
  }

  /// Converte uma entidade limpa de domínio [Event] para a representação de dados física [HistoricalEventModel].
  ///
  /// Como a entidade [Event] é simplificada, campos adicionais recebem valores padrão coerentes.
  @override
  factory HistoricalEventModel.fromEntity(Event entity) {
    if (entity is HistoricalEventModel) {
      return entity;
    }
    return HistoricalEventModel(
      id: entity.id,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      eraId: entity.eraId,
      slug: entity.slug,
      titulo: entity.nome,
      descricao: entity.descricao,
      startYear: entity.anoOcorrencia,
      publicationStatus: entity.publicationStatus,
      tituloCurto: entity.nome,
      descricaoResumida: '',
      eventType: 'other',
      datePrecision: 'year',
      importanceScore: 3,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [Event].
  @override
  Event toEntity() {
    return Event(
      id: id,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      eraId: eraId,
      slug: slug,
      nome: nome,
      descricao: descricao,
      anoOcorrencia: anoOcorrencia,
      publicationStatus: publicationStatus,
    );
  }

  @override
  HistoricalEventModel copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? eraId,
    String? slug,
    String? nome, // Alinhado com a super classe Event
    String? descricao,
    int? anoOcorrencia, // Alinhado com a super classe Event
    PublicationStatus? publicationStatus,
    String? tituloCurto,
    String? descricaoResumida,
    String? eventType,
    String? datePrecision,
    int? endYear,
    double? latitude,
    double? longitude,
    int? importanceScore,
  }) {
    return HistoricalEventModel(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eraId: eraId ?? this.eraId,
      slug: slug ?? this.slug,
      titulo: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      startYear: anoOcorrencia ?? this.anoOcorrencia,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      tituloCurto: tituloCurto ?? this.tituloCurto,
      descricaoResumida: descricaoResumida ?? this.descricaoResumida,
      eventType: eventType ?? this.eventType,
      datePrecision: datePrecision ?? this.datePrecision,
      endYear: endYear ?? this.endYear,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      importanceScore: importanceScore ?? this.importanceScore,
    );
  }
}
