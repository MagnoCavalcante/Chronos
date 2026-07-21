import '../utils/result.dart';

/// Interface/Contrato base abstrato para todos os Casos de Uso (Use Cases) do CHRONOS.
/// Centraliza a assinatura e padroniza a execução por meio do operador funcional `call`.
abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();

  /// Executa a regra de negócio do caso de uso de forma síncrona ou assíncrona.
  Future<Result<Type>> call(Params params);
}

/// Classe utilitária para representar parâmetros nulos ou vazios em Casos de Uso.
class NoParams {
  const NoParams();
}
