import 'package:chronos/core/base/base_repository.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/civilization.dart';

/// Contrato (Interface) de Repositório de Civilization para o ecossistema CHRONOS.
abstract class CivilizationRepository extends BaseRepository {
  const CivilizationRepository();

  /// Recupera todas as Civilizações publicadas e ativas.
  Future<Result<List<Civilization>>> getAllPublished();

  /// Recupera uma Civilização específica por seu identificador único.
  Future<Result<Civilization>> getById(String id);

  /// Recupera uma Civilização específica por seu slug único.
  Future<Result<Civilization>> getBySlug(String slug);
}
