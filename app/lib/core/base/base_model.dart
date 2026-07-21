import 'base_entity.dart';

/// Classe base abstrata para todos os Modelos de Dados no CHRONOS.
/// Herda de [BaseEntity] para manter integridade com as regras de domínio.
abstract class BaseModel<T extends BaseEntity> extends BaseEntity {
  const BaseModel(super.id);

  /// Converte o modelo atual de volta para sua Entidade de Domínio pura.
  T toEntity();
}
