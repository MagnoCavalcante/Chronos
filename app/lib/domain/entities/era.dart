import 'publication_status.dart';

/// Entidade de Domínio que representa uma Era histórica no ecossistema CHRONOS.
///
/// Totalmente pura e livre de qualquer dependência de frameworks ou de persistência.
/// Implementa igualdade estrutural por valor e suporte a atualizações imutáveis.
class Era {
  final String id;
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
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Era({
    required this.id,
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
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia desta Era com as propriedades especificadas alteradas (Padrão Prototype).
  Era copyWith({
    String? id,
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
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Era(
      id: id ?? this.id,
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
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Era &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.tituloCurto == tituloCurto &&
        other.descricao == descricao &&
        other.descricaoResumida == descricaoResumida &&
        other.inicioAno == inicioAno &&
        other.fimAno == fimAno &&
        other.ordemCronologica == ordemCronologica &&
        other.corHex == corHex &&
        other.iconKey == iconKey &&
        other.coverImageUrl == coverImageUrl &&
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
        tituloCurto.hashCode ^
        descricao.hashCode ^
        descricaoResumida.hashCode ^
        inicioAno.hashCode ^
        fimAno.hashCode ^
        ordemCronologica.hashCode ^
        corHex.hashCode ^
        iconKey.hashCode ^
        coverImageUrl.hashCode ^
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
