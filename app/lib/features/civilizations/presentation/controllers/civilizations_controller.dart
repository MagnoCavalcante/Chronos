import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/base_controller.dart';
import '../../domain/entities/civilization.dart';
import '../../domain/usecases/get_civilizations_usecase.dart';

/// Controller da camada de apresentação para Civilizations.
///
/// Mantém a lógica de estado dentro do padrão BaseController do CHRONOS e deixa a UI
/// responsiva a estados de initial/loading/success/empty/error/refreshing.
class CivilizationsController extends BaseController<List<Civilization>> {
  final GetCivilizationsUseCase _getCivilizationsUseCase;

  CivilizationsController({GetCivilizationsUseCase? useCase})
      : _getCivilizationsUseCase = useCase ?? locate<GetCivilizationsUseCase>(),
        super(initialData: const []);

  List<Civilization> get items => data ?? const [];

  Failure? get failure => error;

  Future<void> loadCivilizations() async {
    await execute(
      () => _getCivilizationsUseCase(),
      tag: 'CivilizationsController',
    );
  }

  @override
  Future<void> retry() async {
    await loadCivilizations();
  }

  @override
  Future<void> refresh() async {
    await loadCivilizations();
  }
}
