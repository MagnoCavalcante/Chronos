import '../../core/utils/result.dart';
import '../entities/era.dart';
import '../repositories/era_repository.dart';

/// Caso de Uso (Use Case) responsável por orquestrar a recuperação de todas as Eras históricas publicadas.
///
/// ### Papel na Clean Architecture:
/// O Caso de Uso (Use Case) representa as regras de negócio de aplicação (Application Business Rules).
/// Ele fica na camada de **Domain**, atuando como o núcleo lógico da aplicação.
///
/// De acordo com a Regra de Dependência (Dependency Rule) da Clean Architecture:
/// - **Independência Total**: Não conhece detalhes de infraestrutura, bancos de dados (Supabase),
///   frameworks visuais (Flutter), serialização ou formatos de trânsito (JSON).
/// - **Inversão de Dependências (DIP)**: Depende exclusivamente da interface abstrata [EraRepository]
///   definida também na camada de Domínio, garantindo desacoplamento completo.
/// - **Responsabilidade Única (SRP)**: Possui uma única e exclusiva intenção de negócio: buscar a
///   lista de todas as Eras ativas e publicadas.
class GetAllErasUseCase {
  /// O contrato do repositório injetado externamente, seguindo o padrão de Inversão de Dependência.
  final EraRepository repository;

  /// Inicializa o caso de uso injetando de forma explícita a interface abstrata do repositório de Eras.
  const GetAllErasUseCase(this.repository);

  /// Executa a regra de negócio do caso de uso, delegando a recuperação das entidades para o repositório.
  ///
  /// Retorna uma coleção de entidades puras de negócio [Era] envelopadas em [Result].
  Future<Result<List<Era>>> call() async {
    return repository.getAllEras();
  }
}

