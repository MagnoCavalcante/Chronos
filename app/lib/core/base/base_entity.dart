/// Classe base abstrata para todas as Entidades de Domínio do CHRONOS.
/// Garante que todas as entidades possuam identificador único e suporte a comparação por igualdade.
abstract class BaseEntity {
  final String id;

  const BaseEntity(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
