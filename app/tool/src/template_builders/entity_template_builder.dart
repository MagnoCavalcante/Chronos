import '../feature_context.dart';
import 'template_builder.dart';

class EntityTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''import 'package:chronos/domain/entities/publication_status.dart';

/// Entidade de Domínio representando um(a) ${context.singularPascal} no ecossistema CHRONOS.
///
/// Totalmente pura e desacoplada de frameworks ou bancos de dados físicos.
class ${context.singularPascal} {
  final String id;
  final String slug;
  final String nome;
  final String descricao;
  final PublicationStatus publicationStatus;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ${context.singularPascal}({
    required this.id,
    required this.slug,
    required this.nome,
    required this.descricao,
    required this.publicationStatus,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
  });

  ${context.singularPascal} copyWith({
    String? id,
    String? slug,
    String? nome,
    String? descricao,
    PublicationStatus? publicationStatus,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${context.singularPascal}(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${context.singularPascal} &&
        other.id == id &&
        other.slug == slug &&
        other.nome == nome &&
        other.descricao == descricao &&
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
        publicationStatus.hashCode ^
        ativo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
''';
  }
}
