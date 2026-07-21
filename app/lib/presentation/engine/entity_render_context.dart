import 'package:flutter/material.dart';
import 'entity_view.dart';

/// Define o tamanho/breakpoint lógico de tela no contexto do Render Engine.
enum EngineScreenSize {
  mobile,
  tablet,
  desktop,
  ultraWide,
  foldable,
}

/// Propriedades de acessibilidade agregadas para customização de renders.
class EngineAccessibility {
  final bool screenReaderEnabled;
  final bool highContrast;
  final double textScaleFactor;
  final bool reduceMotion;

  const EngineAccessibility({
    this.screenReaderEnabled = false,
    this.highContrast = false,
    this.textScaleFactor = 1.0,
    this.reduceMotion = false,
  });
}

/// Contexto unificado e compartilhado que guia todo o pipeline de renderização de entidades.
class EntityRenderContext {
  final BuildContext? buildContext;
  final ThemeData theme;
  final EngineScreenSize screenSize;
  final EngineAccessibility accessibility;
  final EntityView currentView;
  final bool selectionMode;
  final Set<String> selectedIds;
  final Map<String, dynamic> filters;
  final String sorting;
  final Function(dynamic)? onNavigate;
  final bool animate;
  final String locale;
  final List<String> permissions;

  const EntityRenderContext({
    this.buildContext,
    required this.theme,
    required this.screenSize,
    required this.accessibility,
    required this.currentView,
    this.selectionMode = false,
    this.selectedIds = const {},
    this.filters = const {},
    this.sorting = 'nameAsc',
    this.onNavigate,
    this.animate = true,
    this.locale = 'pt_BR',
    this.permissions = const [],
  });

  /// Método utilitário para derivar o EngineScreenSize a partir de largura em pixels.
  static EngineScreenSize getScreenSize(double width) {
    if (width >= 1920) return EngineScreenSize.ultraWide;
    if (width >= 1200) return EngineScreenSize.desktop;
    if (width >= 768) return EngineScreenSize.tablet;
    // Dispositivos dobráveis geralmente possuem comportamentos específicos,
    // mas podem ser mapeados por detecção física futura.
    return EngineScreenSize.mobile;
  }

  EntityRenderContext copyWith({
    BuildContext? buildContext,
    ThemeData? theme,
    EngineScreenSize? screenSize,
    EngineAccessibility? accessibility,
    EntityView? currentView,
    bool? selectionMode,
    Set<String>? selectedIds,
    Map<String, dynamic>? filters,
    String? sorting,
    Function(dynamic)? onNavigate,
    bool? animate,
    String? locale,
    List<String>? permissions,
  }) {
    return EntityRenderContext(
      buildContext: buildContext ?? this.buildContext,
      theme: theme ?? this.theme,
      screenSize: screenSize ?? this.screenSize,
      accessibility: accessibility ?? this.accessibility,
      currentView: currentView ?? this.currentView,
      selectionMode: selectionMode ?? this.selectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
      filters: filters ?? this.filters,
      sorting: sorting ?? this.sorting,
      onNavigate: onNavigate ?? this.onNavigate,
      animate: animate ?? this.animate,
      locale: locale ?? this.locale,
      permissions: permissions ?? this.permissions,
    );
  }
}
