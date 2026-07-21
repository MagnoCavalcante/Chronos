import '../../core/base/base_use_case.dart';
import '../../core/utils/result.dart';
import '../entities/civilization.dart';
import '../../features/civilizations/domain/repositories/civilization_repository.dart';

/// Caso de Uso (Use Case) de negócio responsável por buscar uma civilização pelo Slug único.
class GetCivilizationBySlug extends BaseUseCase<Civilization, String> {
  final CivilizationRepository _repository;

  const GetCivilizationBySlug(this._repository);

  @override
  Future<Result<Civilization>> call(String slug) async {
    return _repository.getBySlug(slug);
  }
}
