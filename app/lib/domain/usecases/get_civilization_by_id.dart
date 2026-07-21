import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/civilization.dart';
import '../../features/civilizations/domain/repositories/civilization_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar uma civilização pelo ID único.
class GetCivilizationById extends BaseUseCase<Civilization, String> {
  final CivilizationRepository _repository;

  const GetCivilizationById(this._repository);

  @override
  Future<Result<Civilization>> call(String id) async {
    return _repository.getById(id);
  }
}
