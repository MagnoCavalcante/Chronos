import '../core/base/base_entity.dart';
import 'publication_status.dart';

/// Entidade de Domínio representando um Evento histórico no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
/// Extende [BaseEntity] para centralizar atributos comuns.
class Event extends BaseEntity {
  final String eraId;
  final String slug;
  final String nome;
  final String descricao;
  final int anoOcorrencia;
  final PublicationStatus publicationStatus;

  const Event({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.eraId,
    required this.slug,
    required this.nome,
    required this.descricao,
    required this.anoOcorrencia,
    required this.publicationStatus,
  });

  @override
  Event copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? eraId,
    String? slug,
    String? nome,
    String? descricao,
    int? anoOcorrencia,
    PublicationStatus? publicationStatus,
  }) {
    return Event(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eraId: eraId ?? this.eraId,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      anoOcorrencia: anoOcorrencia ?? this.anoOcorrencia,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}

/// Typedef para compatibilidade com o domínio CHRONOS de eventos históricos.
typedef HistoricalEvent = Event;

