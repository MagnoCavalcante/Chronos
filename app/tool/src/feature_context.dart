class FeatureContext {
  final String featureName; // e.g., civilizations or historical_characters
  late final String featurePascal;
  late final String featureCamel;
  late final String singularSnake;
  late final String singularPascal;
  late final String singularCamel;

  FeatureContext(this.featureName) {
    // Singularize featureName
    String singular = featureName;
    if (featureName.endsWith('ies')) {
      singular = featureName.substring(0, featureName.length - 3) + 'y';
    } else if (featureName.endsWith('s') && !featureName.endsWith('ss')) {
      singular = featureName.substring(0, featureName.length - 1);
    }

    singularSnake = singular;
    singularPascal = _toPascalCase(singular);
    singularCamel = _toCamelCase(singular);

    featurePascal = _toPascalCase(featureName);
    featureCamel = _toCamelCase(featureName);
  }

  static String _toPascalCase(String text) {
    return text.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join('');
  }

  static String _toCamelCase(String text) {
    final pascal = _toPascalCase(text);
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
