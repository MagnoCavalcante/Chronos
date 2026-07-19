import 'package:flutter/material.dart';
import 'app_router.dart';
import 'route_names.dart';

/// Camada de compatibilidade e mapeamento legado para o ecossistema CHRONOS.
///
/// Encapsula e direciona as definições legadas de rotas para o novo [AppRouter] centralizado,
/// garantindo transição transparente e impedindo quebras de compilação em dependências do MaterialApp.
class AppRoutes {
  AppRoutes._();

  /// Rota para a tela de conexão inicial.
  static const String home = RouteNames.home;

  /// Rota para o módulo de Eras.
  static const String eras = RouteNames.eras;

  /// Rota para o módulo de Eventos Históricos.
  static const String historicalEvents = RouteNames.events;

  /// Rota para o módulo de Personagens Históricos.
  static const String historicalCharacters = RouteNames.historicalCharacters;

  /// Retorna o mapa completo das rotas oficiais de aplicação unificado pelo [AppRouter].
  static Map<String, WidgetBuilder> get routes => AppRouter.routes;
}
