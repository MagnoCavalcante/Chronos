/// Ambientes oficiais suportados pelo ecossistema CHRONOS.
enum ChronosEnvironment {
  development,
  staging,
  production,
}

extension ChronosEnvironmentX on ChronosEnvironment {
  /// Nome legível usado na UI e em logs.
  String get displayName {
    switch (this) {
      case ChronosEnvironment.development:
        return 'Development';
      case ChronosEnvironment.staging:
        return 'Staging';
      case ChronosEnvironment.production:
        return 'Production';
    }
  }

  /// Nome de identificação usado em variáveis e ambientes de build.
  String get value {
    switch (this) {
      case ChronosEnvironment.development:
        return 'development';
      case ChronosEnvironment.staging:
        return 'staging';
      case ChronosEnvironment.production:
        return 'production';
    }
  }

  /// Define se o ambiente atual é de produção.
  bool get isProduction => this == ChronosEnvironment.production;
}

extension ChronosEnvironmentParser on String {
  ChronosEnvironment toChronosEnvironment() {
    switch (toLowerCase()) {
      case 'staging':
        return ChronosEnvironment.staging;
      case 'production':
        return ChronosEnvironment.production;
      case 'development':
      default:
        return ChronosEnvironment.development;
    }
  }
}
