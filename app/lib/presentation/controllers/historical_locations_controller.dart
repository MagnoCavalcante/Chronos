import 'package:chronos/core/base/base_use_case.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import 'package:chronos/domain/entities/historical_location.dart';
import '../../domain/usecases/get_all_locations.dart';
import '../../domain/usecases/get_location_by_id.dart';
import '../../domain/usecases/get_location_by_slug.dart';
import '../../domain/usecases/get_locations_by_parent.dart';
import '../../domain/usecases/get_locations_by_type.dart';
import '../../domain/usecases/get_locations_within_bounds.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para Localizações Históricas (Historical Locations).
///
/// Herda de [BaseController] para orquestrar de forma estruturada e unificada
/// os estados de [ViewState] (initial, loading, success, empty, error, refreshing).
class HistoricalLocationsController extends BaseController<List<HistoricalLocation>> {
  final GetAllLocations _getAllLocations;
  final GetLocationById _getLocationById;
  final GetLocationBySlug _getLocationBySlug;
  final GetLocationsByParent _getLocationsByParent;
  final GetLocationsByType _getLocationsByType;
  final GetLocationsWithinBounds _getLocationsWithinBounds;

  HistoricalLocation? _selectedLocation;

  /// Inicializa o [HistoricalLocationsController] injetando de forma obrigatória ou externa as suas dependências comerciais.
  HistoricalLocationsController({
    GetAllLocations? getAllLocations,
    GetLocationById? getLocationById,
    GetLocationBySlug? getLocationBySlug,
    GetLocationsByParent? getLocationsByParent,
    GetLocationsByType? getLocationsByType,
    GetLocationsWithinBounds? getLocationsWithinBounds,
  })  : _getAllLocations = getAllLocations ?? locate<GetAllLocations>(),
        _getLocationById = getLocationById ?? locate<GetLocationById>(),
        _getLocationBySlug = getLocationBySlug ?? locate<GetLocationBySlug>(),
        _getLocationsByParent = getLocationsByParent ?? locate<GetLocationsByParent>(),
        _getLocationsByType = getLocationsByType ?? locate<GetLocationsByType>(),
        _getLocationsWithinBounds = getLocationsWithinBounds ?? locate<GetLocationsWithinBounds>(),
        super(initialData: const []);

  /// Retorna a lista imutável dos itens carregados atualmente no estado do controller.
  List<HistoricalLocation> get items => List.unmodifiable(data ?? const []);

  /// Retorna a localização selecionada/carregada individualmente se houver.
  HistoricalLocation? get selectedLocation => _selectedLocation;

  /// Retorna a falha/erro estruturado ativo no controlador.
  Failure? get failure => error;

  /// Executa o carregamento de todas as localizações históricas cadastradas no CHRONOS.
  Future<void> loadLocations() async {
    ChronosLogger.info('Iniciando o carregamento de todas as Localizações...', tag: 'HistoricalLocationsController');

    await execute(
      () async {
        return await _getAllLocations(const NoParams());
      },
      tag: 'HistoricalLocationsController',
    );
  }

  /// Executa o carregamento de uma localização pelo ID único.
  Future<void> loadLocation(String id) async {
    ChronosLogger.info('Iniciando o carregamento da Localização por ID: $id...', tag: 'HistoricalLocationsController');

    final result = await execute(
      () async {
        final usecaseResult = await _getLocationById(id);
        return usecaseResult.fold(
          onSuccess: (location) {
            _selectedLocation = location;
            return Result.success([location]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'HistoricalLocationsController',
    );

    if (result.isFailure) {
      _selectedLocation = null;
    }
  }

  /// Executa o carregamento de uma localização pelo slug único.
  Future<void> loadLocationBySlug(String slug) async {
    ChronosLogger.info('Iniciando o carregamento da Localização por Slug: $slug...', tag: 'HistoricalLocationsController');

    final result = await execute(
      () async {
        final usecaseResult = await _getLocationBySlug(slug);
        return usecaseResult.fold(
          onSuccess: (location) {
            _selectedLocation = location;
            return Result.success([location]);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      tag: 'HistoricalLocationsController',
    );

    if (result.isFailure) {
      _selectedLocation = null;
    }
  }

  /// Executa o carregamento de todas as localizações pertencentes a uma Localização pai específica.
  Future<void> loadLocationsByParent(String parentId) async {
    ChronosLogger.info('Iniciando o carregamento de Localizações por Pai ID: $parentId...', tag: 'HistoricalLocationsController');

    await execute(
      () async {
        return await _getLocationsByParent(parentId);
      },
      tag: 'HistoricalLocationsController',
    );
  }

  /// Executa o carregamento de todas as localizações pertencentes a um Tipo específico.
  Future<void> loadLocationsByType(LocationType type) async {
    ChronosLogger.info('Iniciando o carregamento de Localizações por Tipo: ${type.value}...', tag: 'HistoricalLocationsController');

    await execute(
      () async {
        return await _getLocationsByType(type);
      },
      tag: 'HistoricalLocationsController',
    );
  }

  /// Executa o carregamento de todas as localizações pertencentes aos Limites geográficos (Bounding Box).
  Future<void> loadLocationsWithinBounds(GetLocationsWithinBoundsParams bounds) async {
    ChronosLogger.info(
      'Iniciando o carregamento de Localizações dentro dos limites Lat: [${bounds.minLat}, ${bounds.maxLat}], Lng: [${bounds.minLng}, ${bounds.maxLng}]...',
      tag: 'HistoricalLocationsController',
    );

    await execute(
      () async {
        return await _getLocationsWithinBounds(bounds);
      },
      tag: 'HistoricalLocationsController',
    );
  }

  /// Reinicia ou atualiza o estado atual do controlador limpando seleções anteriores.
  @override
  Future<void> refresh() async {
    ChronosLogger.info('Atualizando controlador de Localizações...', tag: 'HistoricalLocationsController');
    _selectedLocation = null;
    await loadLocations();
  }

  /// Tenta recarregar a operação que falhou.
  @override
  Future<void> retry() async {
    ChronosLogger.info('Retentando operação no controlador de Localizações...', tag: 'HistoricalLocationsController');
    if (_selectedLocation == null && (data == null || data!.isEmpty)) {
      await loadLocations();
    } else if (_selectedLocation != null) {
      await loadLocation(_selectedLocation!.id);
    }
  }
}
