import '../../domain/entities/historical_character.dart';
import 'package:chronos/domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'historical_characters'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class HistoricalCharacterModel extends HistoricalCharacter {
  const HistoricalCharacterModel({
    required super.id,
    required super.slug,
    required super.nome,
    super.nomeOriginal,
    super.nomeAlternativo,
    super.titulo,
    super.epiteto,
    required super.descricao,
    required super.descricaoResumida,
    required super.dataNascimento,
    super.dataMorte,
    required super.eraId,
    super.localNascimentoId,
    super.localMorteId,
    required super.sexo,
    super.ocupacaoPrincipal,
    super.civilizacaoPrincipalId,
    super.imagemPrincipal,
    super.corIdentificacao,
    required super.publicationStatus,
    required super.ativo,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Reconstrói uma instância de [HistoricalCharacterModel] a partir de um registro relacional JSON.
  factory HistoricalCharacterModel.fromJson(Map<String, dynamic> json) {
    return HistoricalCharacterModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nome: json['nome'] as String,
      nomeOriginal: json['nome_original'] as String?,
      nomeAlternativo: json['nome_alternativo'] as String?,
      titulo: json['titulo'] as String?,
      epiteto: json['epiteto'] as String?,
      descricao: json['descricao'] as String,
      descricaoResumida: json['descricao_resumida'] as String,
      dataNascimento: DateTime.parse(json['data_nascimento'] as String),
      dataMorte: json['data_morte'] != null ? DateTime.parse(json['data_morte'] as String) : null,
      eraId: json['era_id'] as String,
      localNascimentoId: json['local_nascimento_id'] as String?,
      localMorteId: json['local_morte_id'] as String?,
      sexo: json['sexo'] as String,
      ocupacaoPrincipal: json['ocupacao_principal'] as String?,
      civilizacaoPrincipalId: json['civilizacao_principal_id'] as String?,
      imagemPrincipal: json['imagem_principal'] as String?,
      corIdentificacao: json['cor_identificacao'] as String?,
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String),
      ativo: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância atual de [HistoricalCharacterModel] em um mapa relacional JSON estrutural.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'nome': nome,
      'nome_original': nomeOriginal,
      'nome_alternativo': nomeAlternativo,
      'titulo': titulo,
      'epiteto': epiteto,
      'descricao': descricao,
      'descricao_resumida': descricaoResumida,
      'data_nascimento': dataNascimento.toIso8601String(),
      'data_morte': dataMorte?.toIso8601String(),
      'era_id': eraId,
      'local_nascimento_id': localNascimentoId,
      'local_morte_id': localMorteId,
      'sexo': sexo,
      'ocupacao_principal': ocupacaoPrincipal,
      'civilizacao_principal_id': civilizacaoPrincipalId,
      'imagem_principal': imagemPrincipal,
      'cor_identificacao': corIdentificacao,
      'publication_status': publicationStatus.value,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converte uma entidade limpa de domínio [HistoricalCharacter] para a representação de dados física [HistoricalCharacterModel].
  factory HistoricalCharacterModel.fromEntity(HistoricalCharacter entity) {
    if (entity is HistoricalCharacterModel) {
      return entity;
    }
    return HistoricalCharacterModel(
      id: entity.id,
      slug: entity.slug,
      nome: entity.nome,
      nomeOriginal: entity.nomeOriginal,
      nomeAlternativo: entity.nomeAlternativo,
      titulo: entity.titulo,
      epiteto: entity.epiteto,
      descricao: entity.descricao,
      descricaoResumida: entity.descricaoResumida,
      dataNascimento: entity.dataNascimento,
      dataMorte: entity.dataMorte,
      eraId: entity.eraId,
      localNascimentoId: entity.localNascimentoId,
      localMorteId: entity.localMorteId,
      sexo: entity.sexo,
      ocupacaoPrincipal: entity.ocupacaoPrincipal,
      civilizacaoPrincipalId: entity.civilizacaoPrincipalId,
      imagemPrincipal: entity.imagemPrincipal,
      corIdentificacao: entity.corIdentificacao,
      publicationStatus: entity.publicationStatus,
      ativo: entity.ativo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [HistoricalCharacter].
  HistoricalCharacter toEntity() {
    return HistoricalCharacter(
      id: id,
      slug: slug,
      nome: nome,
      nomeOriginal: nomeOriginal,
      nomeAlternativo: nomeAlternativo,
      titulo: titulo,
      epiteto: epiteto,
      descricao: descricao,
      descricaoResumida: descricaoResumida,
      dataNascimento: dataNascimento,
      dataMorte: dataMorte,
      eraId: eraId,
      localNascimentoId: localNascimentoId,
      localMorteId: localMorteId,
      sexo: sexo,
      ocupacaoPrincipal: ocupacaoPrincipal,
      civilizacaoPrincipalId: civilizacaoPrincipalId,
      imagemPrincipal: imagemPrincipal,
      corIdentificacao: corIdentificacao,
      publicationStatus: publicationStatus,
      ativo: ativo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  HistoricalCharacterModel copyWith({
    String? id,
    String? slug,
    String? nome,
    String? nomeOriginal,
    String? nomeAlternativo,
    String? titulo,
    String? epiteto,
    String? descricao,
    String? descricaoResumida,
    DateTime? dataNascimento,
    DateTime? dataMorte,
    String? eraId,
    String? localNascimentoId,
    String? localMorteId,
    String? sexo,
    String? ocupacaoPrincipal,
    String? civilizacaoPrincipalId,
    String? imagemPrincipal,
    String? corIdentificacao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoricalCharacterModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      nomeOriginal: nomeOriginal ?? this.nomeOriginal,
      nomeAlternativo: nomeAlternativo ?? this.nomeAlternativo,
      titulo: titulo ?? this.titulo,
      epiteto: epiteto ?? this.epiteto,
      descricao: descricao ?? this.descricao,
      descricaoResumida: descricaoResumida ?? this.descricaoResumida,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      dataMorte: dataMorte ?? this.dataMorte,
      eraId: eraId ?? this.eraId,
      localNascimentoId: localNascimentoId ?? this.localNascimentoId,
      localMorteId: localMorteId ?? this.localMorteId,
      sexo: sexo ?? this.sexo,
      ocupacaoPrincipal: ocupacaoPrincipal ?? this.ocupacaoPrincipal,
      civilizacaoPrincipalId: civilizacaoPrincipalId ?? this.civilizacaoPrincipalId,
      imagemPrincipal: imagemPrincipal ?? this.imagemPrincipal,
      corIdentificacao: corIdentificacao ?? this.corIdentificacao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
