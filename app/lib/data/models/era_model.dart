import '../../core/base/base_model.dart';
import '../../domain/entities/era.dart';
import '../../domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'eras'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
/// Implementa [BaseModel] para padronizar conversão JSON/Entity.
class EraModel extends Era implements BaseModel<Era> {
  const EraModel({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required super.slug,
    required super.nome,
    required super.tituloCurto,
    required super.descricao,
    required super.descricaoResumida,
    required super.inicioAno,
    required super.fimAno,
    required super.ordemCronologica,
    required super.corHex,
    super.iconKey,
    super.coverImageUrl,
    required super.publicationStatus,
  });

  /// Reconstrói uma instância de [EraModel] a partir de um registro relacional JSON.
  @override
  factory EraModel.fromJson(Map<String, dynamic> json) {
    return EraModel(
      id: json['id'] as String,
      active: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      slug: json['slug'] as String,
      nome: json['nome'] as String,
      tituloCurto: json['titulo_curto'] as String,
      descricao: json['descricao'] as String,
      descricaoResumida: json['descricao_resumida'] as String,
      inicioAno: (json['inicio_ano'] as num).toInt(),
      fimAno: (json['fim_ano'] as num).toInt(),
      ordemCronologica: (json['ordem_cronologica'] as num).toInt(),
      corHex: json['cor_hex'] as String,
      iconKey: json['icon_key'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String),
    );
  }

  /// Converte a instância atual de [EraModel] em um mapa relacional JSON estrutural.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ativo': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'slug': slug,
      'nome': nome,
      'titulo_curto': tituloCurto,
      'descricao': descricao,
      'descricao_resumida': descricaoResumida,
      'inicio_ano': inicioAno,
      'fim_ano': fimAno,
      'ordem_cronologica': ordemCronologica,
      'cor_hex': corHex,
      'icon_key': iconKey,
      'cover_image_url': coverImageUrl,
      'publication_status': publicationStatus.value,
    };
  }

  /// Converte uma entidade limpa de domínio [Era] para a representação de dados física [EraModel].
  @override
  factory EraModel.fromEntity(Era entity) {
    return EraModel(
      id: entity.id,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      slug: entity.slug,
      nome: entity.nome,
      tituloCurto: entity.tituloCurto,
      descricao: entity.descricao,
      descricaoResumida: entity.descricaoResumida,
      inicioAno: entity.inicioAno,
      fimAno: entity.fimAno,
      ordemCronologica: entity.ordemCronologica,
      corHex: entity.corHex,
      iconKey: entity.iconKey,
      coverImageUrl: entity.coverImageUrl,
      publicationStatus: entity.publicationStatus,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [Era].
  @override
  Era toEntity() {
    return Era(
      id: id,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      slug: slug,
      nome: nome,
      tituloCurto: tituloCurto,
      descricao: descricao,
      descricaoResumida: descricaoResumida,
      inicioAno: inicioAno,
      fimAno: fimAno,
      ordemCronologica: ordemCronologica,
      corHex: corHex,
      iconKey: iconKey,
      coverImageUrl: coverImageUrl,
      publicationStatus: publicationStatus,
    );
  }

  @override
  EraModel copyWith({
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
    return EraModel(
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
