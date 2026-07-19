import 'publication_status.dart';

/// Entidade de Domínio representando uma Relação semântica entre duas entidades no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Relation {
  final String id;
  final String origemId;
  final String origemTipo; // ex: 'era', 'event', 'character'
  final String destinoId;
  final String destinoTipo; // ex: 'event', 'character', 'artifact'
  final String tipoRelacao; // ex: 'contemporâneo', 'criador_de', 'sucedido_por'
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Relation({
    required this.id,
    required this.origemId,
    required this.origemTipo,
    required this.destinoId,
    required this.destinoTipo,
    required this.tipoRelacao,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Relation copyWith({
    String? id,
    String? origemId,
    String? origemTipo,
    String? destinoId,
    String? destinoTipo,
    String? tipoRelacao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Relation(
      id: id ?? this.id,
      origemId: origemId ?? this.origemId,
      origemTipo: origemTipo ?? this.origemTipo,
      destinoId: destinoId ?? this.destinoId,
      destinoTipo: destinoTipo ?? this.destinoTipo,
      tipoRelacao: tipoRelacao ?? this.tipoRelacao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Relation &&
        other.id == id &&
        other.origemId == origemId &&
        other.origemTipo == origemTipo &&
        other.destinoId == destinoId &&
        other.destinoTipo == destinoTipo &&
        other.tipoRelacao == tipoRelacao &&
        other.publicationStatus == publicationStatus &&
        other.ativo == ativo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        origemId.hashCode ^
        origemTipo.hashCode ^
        destinoId.hashCode ^
        destinoTipo.hashCode ^
        tipoRelacao.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
