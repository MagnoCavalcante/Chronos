import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// Contrato de abstração da Camada de Navegação do CHRONOS.
///
/// Permite que Controllers e UseCases invoquem transições de fluxo de forma desacoplada,
/// sem conhecerem contextos do Flutter (BuildContext) ou a classe Navigator diretamente.
abstract class NavigationService {
  /// Retorna a chave global do navegador para controle extracorporal (GlobalKey).
  GlobalKey<NavigatorState> get navigatorKey;

  /// Transiciona para uma nova rota empilhando-a no topo da pilha.
  Future<T?> goTo<T>(String routeName, {Object? arguments});

  /// Substitui a tela atual na pilha por uma nova rota.
  Future<T?> replace<T, TO>(String routeName, {Object? arguments, TO? result});

  /// Remove todas as telas anteriores da pilha e estabelece uma nova rota raiz.
  Future<T?> replaceAll<T>(String routeName, {Object? arguments});

  /// Retorna para a tela anterior desempilhando o topo atual.
  void back<T>([T? result]);

  /// Retorna na pilha até que o predicado fornecido seja satisfeito.
  void popUntil(bool Function(Route<dynamic>) predicate);

  /// Retorna ou navega diretamente para a página inicial (Home) limpando a pilha.
  void goHome();

  /// Abre a tela de Personagens Históricos de forma padronizada.
  void openHistoricalCharacter({Object? arguments});

  /// Abre a tela de Eventos Históricos de forma padronizada.
  void openHistoricalEvent({Object? arguments});

  /// Abre a tela de Eras Históricas de forma padronizada.
  void openEra({Object? arguments});

  /// Abre a tela de Civilizações (Sprint futura) de forma padronizada.
  void openCivilization({Object? arguments});

  /// Abre a tela de Artefatos (Sprint futura) de forma padronizada.
  void openArtifact({Object? arguments});

  /// Abre a tela de Localizações Geográficas (Sprint futura) de forma padronizada.
  void openLocation({Object? arguments});
}

/// Implementação oficial do [NavigationService] usando NavigatorState nativo do Flutter.
class NavigationServiceImpl implements NavigationService {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Dicionário de guardas de rota vinculados por nome de rota.
  final Map<String, List<RouteGuard>> _routeGuards = {};

  /// Registra um conjunto de guardas de verificação para uma determinada rota nominal.
  void registerGuards(String routeName, List<RouteGuard> guards) {
    _routeGuards[routeName] = guards;
    ChronosLogger.info(
      'Registrados ${guards.length} guarda(s) de rota para "$routeName".',
      tag: 'NavigationService',
    );
  }

  /// Avalia a sequência de guardas de segurança associada à rota destino.
  Future<bool> _evaluateGuards(String routeName, {Object? arguments}) async {
    final context = navigatorKey.currentContext;
    if (context == null) return true; // Se o contexto ainda não está pronto, prossegue.

    final guards = _routeGuards[routeName];
    if (guards == null || guards.isEmpty) return true;

    for (final guard in guards) {
      final isAllowed = await guard.canNavigate(context, routeName, arguments: arguments);
      if (!isAllowed) {
        final redirect = guard.redirectRoute;
        if (redirect != null && redirect != routeName) {
          ChronosLogger.warning(
            'Acesso negado para a rota "$routeName" pelo guarda ${guard.runtimeType}. Redirecionando para "$redirect"...',
            tag: 'NavigationService',
          );
          // Redireciona de forma assíncrona desacoplada
          unawaited(replace(redirect, arguments: arguments));
        } else {
          ChronosLogger.warning(
            'Acesso negado para a rota "$routeName" pelo guarda ${guard.runtimeType}. Transição cancelada.',
            tag: 'NavigationService',
          );
        }
        return false;
      }
    }
    return true;
  }

  @override
  Future<T?> goTo<T>(String routeName, {Object? arguments}) async {
    ChronosLogger.info('goTo -> Rota: "$routeName" | Args: $arguments', tag: 'NavigationService');
    final isAllowed = await _evaluateGuards(routeName, arguments: arguments);
    if (!isAllowed) return null;

    return navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  }

  @override
  Future<T?> replace<T, TO>(String routeName, {Object? arguments, TO? result}) async {
    ChronosLogger.info('replace -> Rota: "$routeName" | Args: $arguments', tag: 'NavigationService');
    final isAllowed = await _evaluateGuards(routeName, arguments: arguments);
    if (!isAllowed) return null;

    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  @override
  Future<T?> replaceAll<T>(String routeName, {Object? arguments}) async {
    ChronosLogger.info('replaceAll -> Rota: "$routeName" | Args: $arguments', tag: 'NavigationService');
    final isAllowed = await _evaluateGuards(routeName, arguments: arguments);
    if (!isAllowed) return null;

    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  @override
  void back<T>([T? result]) {
    ChronosLogger.info('back() chamado.', tag: 'NavigationService');
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop<T>(result);
    } else {
      ChronosLogger.warning('back() abortado: Nenhuma rota anterior na pilha para desempilhar.', tag: 'NavigationService');
    }
  }

  @override
  void popUntil(bool Function(Route<dynamic>) predicate) {
    ChronosLogger.info('popUntil chamado com predicado customizado.', tag: 'NavigationService');
    navigatorKey.currentState?.popUntil(predicate);
  }

  @override
  void goHome() {
    replaceAll(RouteNames.home);
  }

  @override
  void openHistoricalCharacter({Object? arguments}) {
    goTo(RouteNames.historicalCharacters, arguments: arguments);
  }

  @override
  void openHistoricalEvent({Object? arguments}) {
    goTo(RouteNames.events, arguments: arguments);
  }

  @override
  void openEra({Object? arguments}) {
    goTo(RouteNames.eras, arguments: arguments);
  }

  @override
  void openCivilization({Object? arguments}) {
    goTo(RouteNames.civilizations, arguments: arguments);
  }

  @override
  void openArtifact({Object? arguments}) {
    goTo(RouteNames.artifacts, arguments: arguments);
  }

  @override
  void openLocation({Object? arguments}) {
    goTo(RouteNames.locations, arguments: arguments);
  }
}
