import 'package:chronos/core/utils/result.dart';
import '../entities/civilization.dart';

/// Contrato (Interface) de Repositório de Civilization para o ecossistema CHRONOS.
abstract class CivilizationRepository {
  /// Recupera todos(as) os(as) Civilizations publicados(as) e ativos(as).
  Future<Result<List<Civilization>>> getAllCivilizations();
}
