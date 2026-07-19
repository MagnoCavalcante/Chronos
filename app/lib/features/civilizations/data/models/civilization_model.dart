import '../../domain/entities/civilization.dart';
import 'package:chronos/domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela 'civilizations'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class CivilizationModel extends Civilization {
  const CivilizationModel({
    required super.id,
    required super.slug,
    required super.nome,
    required super.descricao,
    required super.publicationStatus,
    required super.ativo,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Reconstrói uma instância de [CivilizationModel] a partir de um registro relacional JSON.
  factory CivilizationModel.fromJson(Map<String, dynamic> json) {
    return CivilizationModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      publicationStatus: PublicationStatus.fromValue(json['publication_status'] as String),
      ativo: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância atual de [CivilizationModel] em um mapa relacional JSON estrutural.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'nome': nome,
      'descricao': descricao,
      'publication_status': publicationStatus.value,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converte uma entidade limpa de domínio [Civilization] para a representação de dados física [CivilizationModel].
  factory CivilizationModel.fromEntity(Civilization entity) {
    if (entity is CivilizationModel) {
      return entity;
    }
    return CivilizationModel(
      id: entity.id,
      slug: entity.slug,
      nome: entity.nome,
      descricao: entity.descricao,
      publicationStatus: entity.publicationStatus,
      ativo: entity.ativo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [Civilization].
  Civilization toEntity() {
    return Civilization(
      id: id,
      slug: slug,
      nome: nome,
      descricao: descricao,
      publicationStatus: publicationStatus,
      ativo: ativo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  CivilizationModel copyWith({
    String? id,
    String? slug,
    String? nome,
    String? descricao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CivilizationModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
