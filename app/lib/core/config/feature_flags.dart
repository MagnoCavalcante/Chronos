/// Controle reativo e centralizado de Feature Flags do ecossistema CHRONOS.
class FeatureFlags {
  FeatureFlags._();

  /// Flags ativas no sistema
  static const bool timeline3D = false;
  static const bool graphEngine = false;
  static const bool offlineMode = true;
  static const bool academicMode = false;
  static const bool experimentalSearch = false;
  static const bool futureAI = false;

  /// Verifica se uma funcionalidade específica está habilitada de forma dinâmica.
  static bool isEnabled(String featureKey) {
    switch (featureKey) {
      case 'timeline3D':
        return timeline3D;
      case 'graphEngine':
        return graphEngine;
      case 'offlineMode':
        return offlineMode;
      case 'academicMode':
        return academicMode;
      case 'experimentalSearch':
        return experimentalSearch;
      case 'futureAI':
        return futureAI;
      default:
        return false;
    }
  }
}
