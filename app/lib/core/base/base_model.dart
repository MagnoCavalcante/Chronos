/// Modelo base para todos os modelos de persistência no ecossistema CHRONOS.
///
/// Define o contrato padrão para serialização/deserialização e conversão
/// bidirecional entre modelos de dados e entidades de domínio.
///
/// Não utiliza reflection ou dynamic desnecessariamente.
/// As subclasses devem implementar os métodos de conversão de forma tipada.
abstract class BaseModel<T> {
  /// Converte uma instância do modelo para um mapa JSON.
  ///
  /// Deve ser implementado pelas subclasses para mapear campos específicos.
  Map<String, dynamic> toJson();

  /// Reconstrói uma instância do modelo a partir de um mapa JSON.
  ///
  /// Deve ser implementado pelas subclasses para desserializar campos específicos.
  factory BaseModel.fromJson(Map<String, dynamic> json);

  /// Converte o modelo de persistência para uma entidade pura de domínio.
  ///
  /// Deve ser implementado pelas subclasses para realizar o mapeamento
  /// entre o modelo físico e a entidade de negócio.
  T toEntity();

  /// Converte uma entidade de domínio para o modelo de persistência.
  ///
  /// Deve ser implementado pelas subclasses para realizar o mapeamento
  /// entre a entidade de negócio e o modelo físico.
  factory BaseModel.fromEntity(T entity);
}
