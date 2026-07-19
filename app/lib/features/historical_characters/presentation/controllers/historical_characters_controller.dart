import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/historical_character.dart';
import '../../domain/usecases/get_all_historical_characters.dart';
import '../../domain/usecases/get_historical_character_by_id.dart';
import '../../domain/usecases/get_historical_character_by_slug.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para HistoricalCharacters.
///
/// Herda de [BaseController<List<HistoricalCharacter>>] delegando todo o gerenciamento de
/// estados de infraestrutura (loading, error, empty, refreshing) e medição automática de performance.
class HistoricalCharactersController extends BaseController<List<HistoricalCharacter>> {
  final GetAllHistoricalCharacters _getAllHistoricalCharacters;
  final GetHistoricalCharacterById _getHistoricalCharacterById;
  final GetHistoricalCharacterBySlug _getHistoricalCharacterBySlug;

  HistoricalCharactersController({
    GetAllHistoricalCharacters? useCase,
    GetHistoricalCharacterById? getByIdUseCase,
    GetHistoricalCharacterBySlug? getBySlugUseCase,
  })  : _getAllHistoricalCharacters = useCase ?? locate<GetAllHistoricalCharacters>(),
        _getHistoricalCharacterById = getByIdUseCase ?? locate<GetHistoricalCharacterById>(),
        _getHistoricalCharacterBySlug = getBySlugUseCase ?? locate<GetHistoricalCharacterBySlug>(),
        super(initialData: const []);

  /// Getter para manter compatibilidade com a UI e testes existentes.
  List<HistoricalCharacter> get items => data ?? const [];

  /// Getter alternativo mapeando [error] para [failure] mantendo compatibilidade de nomenclatura.
  Failure? get failure => error;

  /// Método principal para carregar todos os personagens históricos de forma reativa.
  Future<void> loadHistoricalCharacters() async {
    await execute(
      () => _getAllHistoricalCharacters(),
      tag: 'HistoricalCharactersController',
    );
  }

  /// Busca um personagem histórico específico pelo seu identificador único.
  Future<Result<HistoricalCharacter>> getCharacterById(String id) async {
    return await _getHistoricalCharacterById(id);
  }

  /// Busca um personagem histórico específico pelo seu slug único.
  Future<Result<HistoricalCharacter>> getCharacterBySlug(String slug) async {
    return await _getHistoricalCharacterBySlug(slug);
  }

  @override
  Future<void> retry() async {
    await loadHistoricalCharacters();
  }

  @override
  Future<void> refresh() async {
    await loadHistoricalCharacters();
  }
}
