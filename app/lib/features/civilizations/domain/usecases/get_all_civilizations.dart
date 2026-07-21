import 'package:chronos/core/base/base_use_case.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/civilization.dart';
import '../repositories/civilization_repository.dart';

/// Caso de Uso puro de negócio para recuperar todas as Civilizações publicadas.
class GetAllCivilizations extends BaseUseCase<List<Civilization>, NoParams> {
  final CivilizationRepository _repository;

  const GetAllCivilizations(this._repository);

  @override
  Future<Result<List<Civilization>>> call(NoParams params) {
    return _repository.getAllPublished();
  }
}
