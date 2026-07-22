import 'package:chronos/core/base/base_use_case.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/civilization.dart';
import '../repositories/civilization_repository.dart';

/// Caso de Uso puro de negócio para recuperar uma Civilização específica por seu slug único.
class GetCivilizationBySlug extends BaseUseCase<Civilization, String> {
  final CivilizationRepository _repository;

  const GetCivilizationBySlug(this._repository);

  @override
  Future<Result<Civilization>> call(String slug) {
    return _repository.getBySlug(slug);
  }
}
