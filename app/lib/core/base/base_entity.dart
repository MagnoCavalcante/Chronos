/// Entidade base para todas as entidades de domínio no ecossistema CHRONOS.
///
/// Centraliza os atributos comuns a todas as entidades:
/// - id: Identificador único
/// - active: Status de ativação
/// - createdAt: Timestamp de criação
/// - updatedAt: Timestamp de última atualização
///
/// Fornece igualdade por valor baseada no [id] e imutabilidade.
/// Não possui dependência de Supabase ou JSON.
abstract class BaseEntity {
  /// Identificador único da entidade.
  final String id;

  /// Status de ativação da entidade.
  final bool active;

  /// Timestamp de criação da entidade.
  final DateTime createdAt;

  /// Timestamp da última atualização da entidade.
  final DateTime updatedAt;

  const BaseEntity({
    required this.id,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Implementação de igualdade por valor baseada no [id].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEntity && other.id == id;
  }

  /// Implementação de hashCode baseada no [id].
  @override
  int get hashCode => id.hashCode;

  /// Cria uma cópia desta entidade com as propriedades especificadas alteradas.
  ///
  /// As subclasses devem sobrescrever este método para incluir suas propriedades específicas.
  BaseEntity copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}
