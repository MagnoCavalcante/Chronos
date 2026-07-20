import '../core/base/base_entity.dart';
import 'publication_status.dart';

/// Entidade de Domínio representando um Personagem histórico no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
/// Extende [BaseEntity] para centralizar atributos comuns.
class Character extends BaseEntity {
  final String slug;
  final String nome;
  final String titulo;
  final String biografia;
  final int nascimentoAno;
  final int? morteAno;
  final PublicationStatus publicationStatus;

  const Character({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.slug,
    required this.nome,
    required this.titulo,
    required this.biografia,
    required this.nascimentoAno,
    this.morteAno,
    required this.publicationStatus,
  });

  @override
  Character copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? slug,
    String? nome,
    String? titulo,
    String? biografia,
    int? nascimentoAno,
    int? morteAno,
    PublicationStatus? publicationStatus,
  }) {
    return Character(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      titulo: titulo ?? this.titulo,
      biografia: biografia ?? this.biografia,
      nascimentoAno: nascimentoAno ?? this.nascimentoAno,
      morteAno: morteAno ?? this.morteAno,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}
