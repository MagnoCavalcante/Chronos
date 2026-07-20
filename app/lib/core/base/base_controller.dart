/// Re-export do BaseController existente em core/presentation.
///
/// O BaseController está localizado em core/presentation/base_controller.dart
/// e fornece toda a funcionalidade necessária:
/// - Gerenciamento de estados (loading, success, error, empty, refreshing)
/// - Tratamento de Failure
/// - Logger integrado
/// - Result Pattern com fold()
/// - Refresh e Retry
/// - Dispose seguro
///
/// Este re-export mantém a estrutura organizacional de core/base/ enquanto
/// evita duplicação de código.
export '../presentation/base_controller.dart';
