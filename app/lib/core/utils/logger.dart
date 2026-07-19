import 'dart:developer' as developer;

/// Sistema oficial e centralizado de Logging para o ecossistema CHRONOS.
/// 
/// Garante que todos os logs de depuração e de erro do aplicativo sejam gerados
/// com formatação consistente, tags apropriadas e de forma segura para produção.
class ChronosLogger {
  ChronosLogger._();

  /// Logs informativos sobre o fluxo normal do app ou ciclo de vida.
  static void info(String message, {String tag = 'CHRONOS'}) {
    developer.log('💡 [INFO] $message', name: tag, time: DateTime.now());
  }

  /// Logs de depuração (debug) úteis apenas para desenvolvimento.
  /// 
  /// Estes logs são compilados de forma otimizada e executados apenas em modo debug.
  static void debug(String message, {String tag = 'CHRONOS'}) {
    assert(() {
      developer.log('🛠️ [DEBUG] $message', name: tag, time: DateTime.now());
      return true;
    }());
  }

  /// Logs de aviso (warning) para alertar sobre comportamentos anômalos, mas não fatais.
  static void warn(String message, {String tag = 'CHRONOS', Object? error, StackTrace? stackTrace}) {
    developer.log(
      '⚠️ [WARN] $message',
      name: tag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs de erro crítico que interrompem ou falham uma operação de negócio.
  static void error(String message, {String tag = 'CHRONOS', Object? error, StackTrace? stackTrace}) {
    developer.log(
      '❌ [ERROR] $message',
      name: tag,
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}
