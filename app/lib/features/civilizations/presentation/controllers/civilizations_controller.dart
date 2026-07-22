import 'package:chronos/core/base/base_use_case.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import '../../domain/entities/civilization.dart';
import '../../domain/usecases/get_all_civilizations.dart';
import '../../domain/usecases/get_civilization_by_id.dart';
import '../../domain/usecases/get_civilization_by_slug.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para Civilizations.
///
/// Herda de [BaseController] para orquestrar de forma estruturada e unificada
/// os estados de [ViewState] (initial, loading, success, empty, error, refreshing).
class CivilizationsController extends BaseController<List<Civilization>> {
  final GetAllCivilizations _getAllCivilizations;
  final GetCivilizationById _getCivilizationById;
  final GetCivilizationBySlug _getCivilizationBySlug;

  Civilization? _selectedCivilization;

  /// Inicializa o [CivilizationsController] injetando de forma obrigatória ou externa as suas dependências comerciais.
  CivilizationsController({
    GetAllCivilizations? getAllCivilizations,
    GetCivilizationById? getCivilizationById,
    GetCivilizationBySlug? getCivilizationBySlug,
  })  : _getAllCivilizations = getAllCivilizations ?? locate<GetAllCivilizations>(),
        _getCivilizationById = getCivilizationById ?? locate<GetCivilizationById>(),
        _getCivilizationBySlug = getCivilizationBySlug ?? locate<GetCivilizationBySlug>(),
        super(initialData: const []);

  /// Retorna a lista imutável dos itens carregados atualmente no estado do controller.
  List<Civilization> get items => List.unmodifiable(data ?? const []);

  /// Retorna a civilização selecionada/carregada individualmente se houver.
  Civilization? get selectedCivilization => _selectedCivilization;

  /// Retorna a falha/erro estruturado ativo no controlador.
  Failure? get failure => error;

  /// Executa o carregamento de todas as civilizações publicadas no CHRONOS.
  Future<void> loadCivilizations() async {
    ChronosLogger.info('Iniciando o carregamento de todas as Civilizações...', tag: 'CivilizationsController');
    
    await execute(
      () async {
        return await _getAllCivilizations(const NoParams());
      },
      tag: 'CivilizationsController',
    );
  }

  /// Executa o carregamento de uma civilização pelo ID único.
  Future<void> loadCivilization(String id) async {
    ChronosLogger.info('Iniciando o carregamento da Civilização por ID: $id...', tag: 'CivilizationsController');
    
    final result = await execute(
      () async {
        final usecaseResult = await _getCivilizationById(id);
        return usecaseResult.fold(
          onSuccess: (civilization) {
            _selectedCivilization = civilization;
            return Result.success([civilization]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'CivilizationsController',
    );

    if (result.isFailure) {
      _selectedCivilization = null;
    }
  }

  /// Executa o carregamento de uma civilização pelo slug único.
  Future<void> loadCivilizationBySlug(String slug) async {
    ChronosLogger.info('Iniciando o carregamento da Civilização por Slug: $slug...', tag: 'CivilizationsController');
    
    final result = await execute(
      () async {
        final usecaseResult = await _getCivilizationBySlug(slug);
        return usecaseResult.fold(
          onSuccess: (civilization) {
            _selectedCivilization = civilization;
            return Result.success([civilization]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'CivilizationsController',
    );

    if (result.isFailure) {
      _selectedCivilization = null;
    }
  }

  /// Reinicia ou atualiza o estado atual do controlador limpando seleções anteriores.
  @override
  Future<void> refresh() async {
    ChronosLogger.info('Atualizando controlador de Civilizações...', tag: 'CivilizationsController');
    _selectedCivilization = null;
    await loadCivilizations();
  }

  /// Tenta recarregar a operação que falhou.
  @override
  Future<void> retry() async {
    ChronosLogger.info('Retentando operação no controlador de Civilizações...', tag: 'CivilizationsController');
    if (_selectedCivilization == null && (data == null || data!.isEmpty)) {
      await loadCivilizations();
    } else if (_selectedCivilization != null) {
      await loadCivilization(_selectedCivilization!.id);
    }
  }
}
