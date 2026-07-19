/// Sistema centralizado de feature flags do CHRONOS.
class FeatureFlags {
  const FeatureFlags._();

  static const bool timeline3D = true;
  static const bool graphEngine = true;
  static const bool offlineMode = false;
  static const bool academicMode = false;
  static const bool experimentalSearch = false;
  static const bool futureAI = false;

  static bool isEnabled(String key) {
    switch (key) {
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
