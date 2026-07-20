import '../core/base/base_entity.dart';
import 'publication_status.dart';

/// Entidade de Domínio que representa uma Era histórica no ecossistema CHRONOS.
///
/// Totalmente pura e livre de qualquer dependência de frameworks ou de persistência.
/// Implementa igualdade estrutural por valor e suporte a atualizações imutáveis.
/// Extende [BaseEntity] para centralizar atributos comuns.
class Era extends BaseEntity {
  final String slug;
  final String nome;
  final String tituloCurto;
  final String descricao;
  final String descricaoResumida;
  final int inicioAno;
  final int fimAno;
  final int ordemCronologica;
  final String corHex;
  final String? iconKey;
  final String? coverImageUrl;
  final PublicationStatus publicationStatus;

  const Era({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.slug,
    required this.nome,
    required this.tituloCurto,
    required this.descricao,
    required this.descricaoResumida,
    required this.inicioAno,
    required this.fimAno,
    required this.ordemCronologica,
    required this.corHex,
    this.iconKey,
    this.coverImageUrl,
    required this.publicationStatus,
  });

  @override
  Era copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? slug,
    String? nome,
    String? tituloCurto,
    String? descricao,
    String? descricaoResumida,
    int? inicioAno,
    int? fimAno,
    int? ordemCronologica,
    String? corHex,
    String? iconKey,
    String? coverImageUrl,
    PublicationStatus? publicationStatus,
  }) {
    return Era(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      tituloCurto: tituloCurto ?? this.tituloCurto,
      descricao: descricao ?? this.descricao,
      descricaoResumida: descricaoResumida ?? this.descricaoResumida,
      inicioAno: inicioAno ?? this.inicioAno,
      fimAno: fimAno ?? this.fimAno,
      ordemCronologica: ordemCronologica ?? this.ordemCronologica,
      corHex: corHex ?? this.corHex,
      iconKey: iconKey ?? this.iconKey,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      publicationStatus: publicationStatus ?? this.publicationStatus,
    );
  }
}
