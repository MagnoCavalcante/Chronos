import 'publication_status.dart';

/// Entidade de Domínio representando um Personagem histórico no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Character {
  final String id;
  final String slug;
  final String nome;
  final String titulo;
  final String biografia;
  final int nascimentoAno;
  final int? morteAno;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.slug,
    required this.nome,
    required this.titulo,
    required this.biografia,
    required this.nascimentoAno,
    this.morteAno,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Character copyWith({
    String? id,
    String? slug,
    String? nome,
    String? titulo,
    String? biografia,
    int? nascimentoAno,
    int? morteAno,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      titulo: titulo ?? this.titulo,
      biografia: biografia ?? this.biografia,
      nascimentoAno: nascimentoAno ?? this.nascimentoAno,
      morteAno: morteAno ?? this.morteAno,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Character &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.titulo == titulo &&
        other.biografia == biografia &&
        other.nascimentoAno == nascimentoAno &&
        other.morteAno == morteAno &&
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
        titulo.hashCode ^
        biografia.hashCode ^
        nascimentoAno.hashCode ^
        morteAno.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
