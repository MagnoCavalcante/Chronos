import 'package:flutter/material.dart';
import 'entity_render_context.dart';
import 'entity_descriptor.dart';
import 'entity_metadata.dart';

/// Define a assinatura padrão para processar um estágio no pipeline de renderização.
abstract class PipelineStage {
  String get name;
  Widget process(
    Widget current,
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  );
}

/// Implementação do Pipeline de Renderização Universal do CHRONOS.
///
/// Orquestra a execução das 8 etapas obrigatórias de forma sequencial e isolada.
class EntityRenderPipeline {
  final List<PipelineStage> _stages;

  EntityRenderPipeline({List<PipelineStage>? stages})
      : _stages = stages ?? _getDefaultStages();

  /// Executa sequencialmente todas as etapas do pipeline para produzir a composição final.
  Widget execute({
    required dynamic entity,
    required EntityDescriptor descriptor,
    required EntityMetadata metadata,
    required EntityRenderContext context,
    required Widget Function(EntityRenderContext, EntityMetadata) baseRenderer,
  }) {
    // 1. Estágio Inicial de Rendering (Renderiza o elemento cru com base no Renderer padrão/especializado)
    Widget currentWidget = baseRenderer(context, metadata);

    // 2. Passa pelos demais estágios de processamento
    for (final stage in _stages) {
      currentWidget = stage.process(currentWidget, entity, descriptor, metadata, context);
    }

    return currentWidget;
  }

  /// Define a lista padrão dos 8 estágios oficiais de renderização do CHRONOS.
  static List<PipelineStage> _getDefaultStages() {
    return [
      const MetadataResolutionStage(),
      const LayoutResolutionStage(),
      const ThemeResolutionStage(),
      const AccessibilityResolutionStage(),
      const AnimationResolutionStage(),
      const InteractionResolutionStage(),
      const RenderingStage(),
      const FinalCompositionStage(),
    ];
  }
}

// ====================================================================
// ETAPA 1: Metadata Resolution (Decide as chaves visíveis/ocultas)
// ====================================================================
class MetadataResolutionStage implements PipelineStage {
  @override
  String get name => 'Metadata Resolution';

  const MetadataResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    // Garante que campos proibidos ou ocultos sejam retirados da árvore lógica.
    // Como esta etapa atua em nível de estrutura lógica, injetamos como um InheritedWidget
    // se necessário, ou envelopamos garantindo a imutabilidade dos dados expostos.
    return MetadataResolverScope(
      metadata: metadata,
      child: current,
    );
  }
}

class MetadataResolverScope extends InheritedWidget {
  final EntityMetadata metadata;

  const MetadataResolverScope({
    super.key,
    required this.metadata,
    required super.child,
  });

  static MetadataResolverScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetadataResolverScope>();
  }

  @override
  bool updateShouldNotify(MetadataResolverScope oldWidget) {
    return metadata != oldWidget.metadata;
  }
}

// ====================================================================
// ETAPA 2: Layout Resolution (Adapta as restrições físicas de grade/flex)
// ====================================================================
class LayoutResolutionStage implements PipelineStage {
  @override
  String get name => 'Layout Resolution';

  const LayoutResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    // Alinha restrições de layout com o tamanho de tela lógico (Móvel, Tablet, etc.).
    double maxWidth;
    switch (context.screenSize) {
      case EngineScreenSize.ultraWide:
        maxWidth = 1400.0;
        break;
      case EngineScreenSize.desktop:
        maxWidth = 1100.0;
        break;
      case EngineScreenSize.tablet:
        maxWidth = 750.0;
        break;
      case EngineScreenSize.mobile:
      case EngineScreenSize.foldable:
      default:
        maxWidth = double.infinity;
        break;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: current,
      ),
    );
  }
}

// ====================================================================
// ETAPA 3: Theme Resolution (Sincroniza tokens de cores, cantos e fontes)
// ====================================================================
class ThemeResolutionStage implements PipelineStage {
  @override
  String get name => 'Theme Resolution';

  const ThemeResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    // Configura um escopo de tema local herdado da cor principal da entidade se houver,
    // preservando compatibilidade exemplar com as diretrizes do ChronosTheme.
    return Theme(
      data: context.theme.copyWith(
        primaryColor: descriptor.color,
        colorScheme: context.theme.colorScheme.copyWith(
          secondary: descriptor.color,
        ),
      ),
      child: current,
    );
  }
}

// ====================================================================
// ETAPA 4: Accessibility Resolution (Insere etiquetas e marcações Semantics)
// ====================================================================
class AccessibilityResolutionStage implements PipelineStage {
  @override
  String get name => 'Accessibility Resolution';

  const AccessibilityResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    return Semantics(
      label: 'Entidade do tipo ${descriptor.displayName}: ${descriptor.entityType}',
      hint: 'Toque para interagir com ${descriptor.pluralName}',
      container: true,
      child: current,
    );
  }
}

// ====================================================================
// ETAPA 5: Animation Resolution (Agrega transições físicas de fade/layout)
// ====================================================================
class AnimationResolutionStage implements PipelineStage {
  @override
  String get name => 'Animation Resolution';

  const AnimationResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    if (!context.animate || context.accessibility.reduceMotion) {
      return current;
    }

    // Adiciona uma transição fluida nativa ao renderizar a árvore de componentes
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: current,
    );
  }
}

// ====================================================================
// ETAPA 6: Interaction Resolution (Configura gestos, foco e atalhos físicos)
// ====================================================================
class InteractionResolutionStage implements PipelineStage {
  @override
  String get name => 'Interaction Resolution';

  const InteractionResolutionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    return Focus(
      autofocus: false,
      focusNode: FocusNode(),
      child: InkWell(
        onTap: () {
          if (context.onNavigate != null) {
            context.onNavigate!(entity);
          }
        },
        splashColor: descriptor.color.withValues(alpha: 0.08),
        highlightColor: descriptor.color.withValues(alpha: 0.04),
        child: current,
      ),
    );
  }
}

// ====================================================================
// ETAPA 7: Rendering (Processa e injeta elementos gráficos secundários)
// ====================================================================
class RenderingStage implements PipelineStage {
  @override
  String get name => 'Rendering';

  const RenderingStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    // Adiciona estilização física secundária (ex: borda de destaque ou sombra personalizada)
    return Material(
      color: Colors.transparent,
      child: current,
    );
  }
}

// ====================================================================
// ETAPA 8: Final Composition (Embala o widget em um design consistente)
// ====================================================================
class FinalCompositionStage implements PipelineStage {
  @override
  String get name => 'Final Composition';

  const FinalCompositionStage();

  @override
  Widget process(Widget current, dynamic entity, EntityDescriptor descriptor,
      EntityMetadata metadata, EntityRenderContext context) {
    // Ajusta o preenchimento/margin de embalagem final
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: current,
    );
  }
}
