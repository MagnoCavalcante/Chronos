import 'publication_status.dart';

/// Entidade de Domínio representando um Artefato histórico no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class Artifact {
  final String id;
  final String slug;
  final String nome;
  final String descricao;
  final String localDeDescoberta;
  final int anoEstimado;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Artifact({
    required this.id,
    required this.slug,
    required this.nome,
    required this.descricao,
    required this.localDeDescoberta,
    required this.anoEstimado,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  Artifact copyWith({
    String? id,
    String? slug,
    String? nome,
    String? descricao,
    String? localDeDescoberta,
    int? anoEstimado,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artifact(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      localDeDescoberta: localDeDescoberta ?? this.localDeDescoberta,
      anoEstimado: anoEstimado ?? this.anoEstimado,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artifact &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.localDeDescoberta == localDeDescoberta &&
        other.anoEstimado == anoEstimado &&
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
        localDeDescoberta.hashCode ^
        anoEstimado.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
