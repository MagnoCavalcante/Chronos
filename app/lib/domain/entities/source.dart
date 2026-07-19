import 'publication_status.dart';

/// Entidade de Domínio representando uma Fonte (referência histórica) no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Source {
  final String id;
  final String titulo;
  final String autor;
  final String? url;
  final String descricao;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Source({
    required this.id,
    required this.titulo,
    required this.autor,
    this.url,
    required this.descricao,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Source copyWith({
    String? id,
    String? titulo,
    String? autor,
    String? url,
    String? descricao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Source(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      url: url ?? this.url,
      descricao: descricao ?? this.descricao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Source &&
        other.id == id &&
        other.titulo == titulo &&
        other.autor == autor &&
        other.url == url &&
        other.descricao == descricao &&
        other.publicationStatus == publicationStatus &&
        other.ativo == ativo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        autor.hashCode ^
        url.hashCode ^
        descricao.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
