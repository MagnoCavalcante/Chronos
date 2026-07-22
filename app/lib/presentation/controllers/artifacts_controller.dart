import 'package:chronos/core/base/base_use_case.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import 'package:chronos/domain/entities/artifact.dart';
import '../../domain/usecases/get_all_artifacts.dart';
import '../../domain/usecases/get_artifact_by_id.dart';
import '../../domain/usecases/get_artifact_by_slug.dart';
import '../../domain/usecases/get_artifacts_by_civilization.dart';
import '../../domain/usecases/get_artifacts_by_location.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para Artefatos (Artifacts).
///
/// Herda de [BaseController] para orquestrar de forma estruturada e unificada
/// os estados de [ViewState] (initial, loading, success, empty, error, refreshing).
class ArtifactsController extends BaseController<List<Artifact>> {
  final GetAllArtifacts _getAllArtifacts;
  final GetArtifactById _getArtifactById;
  final GetArtifactBySlug _getArtifactBySlug;
  final GetArtifactsByCivilization _getArtifactsByCivilization;
  final GetArtifactsByLocation _getArtifactsByLocation;

  Artifact? _selectedArtifact;

  /// Inicializa o [ArtifactsController] injetando de forma obrigatória ou externa as suas dependências comerciais.
  ArtifactsController({
    GetAllArtifacts? getAllArtifacts,
    GetArtifactById? getArtifactById,
    GetArtifactBySlug? getArtifactBySlug,
    GetArtifactsByCivilization? getArtifactsByCivilization,
    GetArtifactsByLocation? getArtifactsByLocation,
  })  : _getAllArtifacts = getAllArtifacts ?? locate<GetAllArtifacts>(),
        _getArtifactById = getArtifactById ?? locate<GetArtifactById>(),
        _getArtifactBySlug = getArtifactBySlug ?? locate<GetArtifactBySlug>(),
        _getArtifactsByCivilization = getArtifactsByCivilization ?? locate<GetArtifactsByCivilization>(),
        _getArtifactsByLocation = getArtifactsByLocation ?? locate<GetArtifactsByLocation>(),
        super(initialData: const []);

  /// Retorna a lista imutável dos itens carregados atualmente no estado do controller.
  List<Artifact> get items => List.unmodifiable(data ?? const []);

  /// Retorna o artefato selecionado/carregado individualmente se houver.
  Artifact? get selectedArtifact => _selectedArtifact;

  /// Retorna a falha/erro estruturado ativo no controlador.
  Failure? get failure => error;

  /// Executa o carregamento de todos os artefatos históricos no CHRONOS.
  Future<void> loadArtifacts() async {
    ChronosLogger.info('Iniciando o carregamento de todos os Artefatos...', tag: 'ArtifactsController');
    
    await execute(
      () async {
        return await _getAllArtifacts(const NoParams());
      },
      tag: 'ArtifactsController',
    );
  }

  /// Executa o carregamento de um artefato pelo ID único.
  Future<void> loadArtifact(String id) async {
    ChronosLogger.info('Iniciando o carregamento do Artefato por ID: $id...', tag: 'ArtifactsController');

    final result = await execute(
      () async {
        final usecaseResult = await _getArtifactById(id);
        return usecaseResult.fold(
          onSuccess: (artifact) {
            _selectedArtifact = artifact;
            return Result.success([artifact]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'ArtifactsController',
    );

    if (result.isFailure) {
      _selectedArtifact = null;
    }
  }

  /// Executa o carregamento de um artefato pelo slug único.
  Future<void> loadArtifactBySlug(String slug) async {
    ChronosLogger.info('Iniciando o carregamento do Artefato por Slug: $slug...', tag: 'ArtifactsController');

    final result = await execute(
      () async {
        final usecaseResult = await _getArtifactBySlug(slug);
        return usecaseResult.fold(
          onSuccess: (artifact) {
            _selectedArtifact = artifact;
            return Result.success([artifact]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'ArtifactsController',
    );

    if (result.isFailure) {
      _selectedArtifact = null;
    }
  }

  /// Executa o carregamento de todos os artefatos pertencentes a uma Civilização específica.
  Future<void> loadArtifactsByCivilization(String civilizationId) async {
    ChronosLogger.info('Iniciando o carregamento de Artefatos por Civilização ID: $civilizationId...', tag: 'ArtifactsController');
    
    await execute(
      () async {
        return await _getArtifactsByCivilization(civilizationId);
      },
      tag: 'ArtifactsController',
    );
  }

  /// Executa o carregamento de todos os artefatos pertencentes a uma Localização específica.
  Future<void> loadArtifactsByLocation(String locationId) async {
    ChronosLogger.info('Iniciando o carregamento de Artefatos por Localização ID: $locationId...', tag: 'ArtifactsController');
    
    await execute(
      () async {
        return await _getArtifactsByLocation(locationId);
      },
      tag: 'ArtifactsController',
    );
  }

  /// Reinicia ou atualiza o estado atual do controlador limpando seleções anteriores.
  @override
  Future<void> refresh() async {
    ChronosLogger.info('Atualizando controlador de Artefatos...', tag: 'ArtifactsController');
    _selectedArtifact = null;
    await loadArtifacts();
  }

  /// Tenta recarregar a operação que falhou.
  @override
  Future<void> retry() async {
    ChronosLogger.info('Retentando operação no controlador de Artefatos...', tag: 'ArtifactsController');
    if (_selectedArtifact == null && (data == null || data!.isEmpty)) {
      await loadArtifacts();
    } else if (_selectedArtifact != null) {
      await loadArtifact(_selectedArtifact!.id);
    }
  }
}
