import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/civilization.dart';
import '../../features/civilizations/domain/repositories/civilization_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por retornar todas as civilizações publicadas.
class GetAllCivilizations extends BaseUseCase<List<Civilization>, NoParams> {
  final CivilizationRepository _repository;

  const GetAllCivilizations(this._repository);

  @override
  Future<Result<List<Civilization>>> call(NoParams params) async {
    return _repository.getAllPublished();
  }
}
