import '../feature_context.dart';
import 'template_builder.dart';

class ModelTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import '../../domain/entities/${context.singularSnake}.dart';
import 'package:chronos/domain/entities/publication_status.dart';

/// Modelo de Persistência (Data Model) que mapeia a estrutura física da tabela '${context.featureName}'.
///
/// Responsável exclusivo pela serialização/deserialização de JSON, comunicação
/// com as camadas de entrada/saída, mapeamento estrutural e isolamento
/// de detalhes do banco de dados (ex: Supabase).
class ${context.singularPascal}Model extends ${context.singularPascal} {
  const ${context.singularPascal}Model({
    required super.id,
    required super.slug,
    required super.nome,
    required super.descricao,
    required super.publicationStatus,
    required super.ativo,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Reconstrói uma instância de [${context.singularPascal}Model] a partir de um registro relacional JSON.
  factory ${context.singularPascal}Model.fromJson(Map<String, dynamic> json) {
    return ${context.singularPascal}Model(
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

  /// Converte a instância atual de [${context.singularPascal}Model] em um mapa relacional JSON estrutural.
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

  /// Converte uma entidade limpa de domínio [${context.singularPascal}] para a representação de dados física [${context.singularPascal}Model].
  factory ${context.singularPascal}Model.fromEntity(${context.singularPascal} entity) {
    if (entity is ${context.singularPascal}Model) {
      return entity;
    }
    return ${context.singularPascal}Model(
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

  /// Converte o modelo de persistência de dados para uma entidade pura do Domínio [${context.singularPascal}].
  ${context.singularPascal} toEntity() {
    return ${context.singularPascal}(
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
  ${context.singularPascal}Model copyWith({
    String? id,
    String? slug,
    String? nome,
    String? descricao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${context.singularPascal}Model(
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
''';
  }
}
