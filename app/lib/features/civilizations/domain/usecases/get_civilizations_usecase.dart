import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/civilization.dart';
import '../repositories/civilization_repository.dart';

/// Caso de Uso (UseCase) com responsabilidade única de recuperar Civilizations ativos(as).
class GetCivilizationsUseCase {
  final CivilizationRepository _repository;

  GetCivilizationsUseCase({CivilizationRepository? repository})
      : _repository = repository ?? locate<CivilizationRepository>();

  Future<Result<List<Civilization>>> call() async {
    return await _repository.getAllCivilizations();
  }
}
