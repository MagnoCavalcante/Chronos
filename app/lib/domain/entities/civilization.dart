import 'publication_status.dart';

/// Entidade de Domínio representando uma Civilização histórica no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Civilization {
  final String id;
  final String slug;
  final String nome;
  final String descricao;
  final int inicioAno;
  final int? fimAno;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Civilization({
    required this.id,
    required this.slug,
    required this.nome,
    required this.descricao,
    required this.inicioAno,
    this.fimAno,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Civilization copyWith({
    String? id,
    String? slug,
    String? nome,
    String? descricao,
    int? inicioAno,
    int? fimAno,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Civilization(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      inicioAno: inicioAno ?? this.inicioAno,
      fimAno: fimAno ?? this.fimAno,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Civilization &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.inicioAno == inicioAno &&
        other.fimAno == fimAno &&
        other.publicationStatus == publicationStatus &&
        other.ativo == ativo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        slug.hashCode ^
        nome.hashCode ^
        descricao.hashCode ^
        inicioAno.hashCode ^
        fimAno.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
