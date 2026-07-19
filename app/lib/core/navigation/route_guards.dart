import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'route_names.dart';

/// Contrato abstrato e padronizado para os Guardas de Rota do CHRONOS.
///
/// Permite validar permissões, status de autenticação ou chaves de flag de recurso
/// de forma reativa e desacoplada antes de efetivar transições de tela.
abstract class RouteGuard {
  const RouteGuard();

  /// Avalia se a navegação para a rota especificada é permitida.
  ///
  /// Retorna `true` se o acesso estiver liberado, ou `false` se for bloqueado.
  FutureOr<bool> canNavigate(BuildContext context, String routeName, {Object? arguments});

  /// Define a rota de fallback para onde o usuário deve ser redirecionado caso falhe na validação.
  ///
  /// Se retornar `null`, a navegação será cancelada silenciosamente sem redirecionamento.
  String? get redirectRoute;
}

/// Guarda de Autenticação para garantir que apenas usuários logados acessem certas rotas.
class AuthGuard extends RouteGuard {
  final bool Function()? _isAuthenticatedProvider;

  const AuthGuard({bool Function()? isAuthenticatedProvider})
      : _isAuthenticatedProvider = isAuthenticatedProvider;

  @override
  FutureOr<bool> canNavigate(BuildContext context, String routeName, {Object? arguments}) {
    final isAuthenticated = _isAuthenticatedProvider?.call() ?? true; // Default true para não bloquear fluxo atual
    
    ChronosLogger.info(
      'AuthGuard avaliando rota "$routeName". Autenticado: $isAuthenticated',
      tag: 'NavigationGuard',
    );

    return isAuthenticated;
  }

  @override
  String? get redirectRoute => RouteNames.home;
}

/// Guarda de Permissões para controle fino de acessos baseado em perfis/roles.
class PermissionGuard extends RouteGuard {
  final List<String> requiredPermissions;
  final bool Function(List<String>)? _hasPermissionsProvider;

  const PermissionGuard({
    required this.requiredPermissions,
    bool Function(List<String>)? hasPermissionsProvider,
  }) : _hasPermissionsProvider = hasPermissionsProvider;

  @override
  FutureOr<bool> canNavigate(BuildContext context, String routeName, {Object? arguments}) {
    if (requiredPermissions.isEmpty) return true;

    final hasPermission = _hasPermissionsProvider?.call(requiredPermissions) ?? true;
    
    ChronosLogger.info(
      'PermissionGuard avaliando rota "$routeName". Permissões requeridas: $requiredPermissions. Autorizado: $hasPermission',
      tag: 'NavigationGuard',
    );

    return hasPermission;
  }

  @override
  String? get redirectRoute => RouteNames.home;
}

/// Guarda de Feature Flags para controle dinâmico de novos recursos na plataforma.
class FeatureFlagGuard extends RouteGuard {
  final String featureKey;
  final bool Function(String)? _isFeatureEnabledProvider;

  const FeatureFlagGuard({
    required this.featureKey,
    bool Function(String)? isFeatureEnabledProvider,
  }) : _isFeatureEnabledProvider = isFeatureEnabledProvider;

  @override
  FutureOr<bool> canNavigate(BuildContext context, String routeName, {Object? arguments}) {
    final isEnabled = _isFeatureEnabledProvider?.call(featureKey) ?? true;
    
    ChronosLogger.info(
      'FeatureFlagGuard avaliando rota "$routeName". Feature: "$featureKey". Ativo: $isEnabled',
      tag: 'NavigationGuard',
    );

    return isEnabled;
  }

  @override
  String? get redirectRoute => RouteNames.home;
}

/// Guarda de Rotas Experimentais para permitir acesso seletivo a módulos em desenvolvimento (Sprints futuras).
class ExperimentalRouteGuard extends RouteGuard {
  final bool isExperimentalAllowed;

  const ExperimentalRouteGuard({this.isExperimentalAllowed = false});

  @override
  FutureOr<bool> canNavigate(BuildContext context, String routeName, {Object? arguments}) {
    ChronosLogger.info(
      'ExperimentalRouteGuard avaliando rota "$routeName". Permitir experimental: $isExperimentalAllowed',
      tag: 'NavigationGuard',
    );

    return isExperimentalAllowed;
  }

  @override
  String? get redirectRoute => RouteNames.home;
}
