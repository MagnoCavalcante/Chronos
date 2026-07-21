import 'package:flutter/material.dart';
import 'entity_renderer.dart';
import 'entity_view.dart';
import 'entity_render_context.dart';
import 'entity_render_pipeline.dart';

/// Fábrica Abstrata de Criação para Renderização de Entidades do CHRONOS.
///
/// Encapsula a descoberta dinâmica, construção de contextos e a geração de widgets
/// seguindo estritamente os princípios SOLID de responsabilidade única e Aberto/Fechado.
/// É proibida a existência de estruturas condicionais ("if/else" ou "switch")
/// verificando classes físicas ou tipos de entidade específicos. Toda a resolução é delegada à Registry.
class EntityFactory {
  const EntityFactory();

  /// Constrói e retorna o widget renderizado final da entidade para a exibição visual especificada.
  Widget create({
    required dynamic entity,
    EntityView? view,
    EntityRenderContext? context,
    EntityRenderPipeline? pipeline,
  }) {
    // Retorna a composição renderizada passando a responsabilidade para a orquestração do EntityRenderer
    return EntityRenderer(
      entity: entity,
      view: view,
      context: context,
      pipeline: pipeline,
    );
  }
}
