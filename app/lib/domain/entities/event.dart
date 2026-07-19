import 'publication_status.dart';

/// Entidade de Domínio representando um Evento histórico no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Event {
  final String id;
  final String eraId;
  final String slug;
  final String nome;
  final String descricao;
  final int anoOcorrencia;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.eraId,
    required this.slug,
    required this.nome,
    required this.descricao,
    required this.anoOcorrencia,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? eraId,
    String? slug,
    String? nome,
    String? descricao,
    int? anoOcorrencia,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      eraId: eraId ?? this.eraId,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      anoOcorrencia: anoOcorrencia ?? this.anoOcorrencia,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.eraId == eraId &&
        other.slug == slug &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.anoOcorrencia == anoOcorrencia &&
        other.publicationStatus == publicationStatus &&
        other.ativo == ativo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        eraId.hashCode ^
        slug.hashCode ^
        nome.hashCode ^
        descricao.hashCode ^
        anoOcorrencia.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// Typedef para compatibilidade com o domínio CHRONOS de eventos históricos.
typedef HistoricalEvent = Event;

