import 'package:flutter/material.dart';
import 'entity_descriptor.dart';
import 'entity_metadata.dart';
import 'entity_render_context.dart';
import 'entity_view.dart';

/// Assinatura padrão para funções renderizadoras registradas no View Registry.
typedef ViewRendererFn = Widget Function(
  dynamic entity,
  EntityDescriptor descriptor,
  EntityMetadata metadata,
  EntityRenderContext context,
);

/// Registro independente de visualizações de entidades do CHRONOS.
///
/// Permite o cadastro e substituição dinâmica de renderizadores visuais sob demanda,
/// viabilizando a injeção futura de plug-ins específicos (como timelines, grafos ou mapas)
/// de forma totalmente desacoplada.
class EntityViewRegistry {
  static final EntityViewRegistry _instance = EntityViewRegistry._internal();

  factory EntityViewRegistry() => _instance;

  EntityViewRegistry._internal();

  // Chave interna baseada em: "entityType:entityView"
  final Map<String, ViewRendererFn> _renderers = {};

  // Renderizadores genéricos que servem para qualquer entidade quando não há especialização registrada
  final Map<EntityView, ViewRendererFn> _genericRenderers = {};

  /// Limpa todos os renderizadores registrados.
  void clear() {
    _renderers.clear();
    _genericRenderers.clear();
  }

  /// Registra um renderizador especializado para uma combinação exata de tipo de entidade e modo visual.
  void registerSpecialized({
    required String entityType,
    required EntityView view,
    required ViewRendererFn renderer,
  }) {
    final String key = _buildKey(entityType, view);
    _renderers[key] = renderer;
  }

  /// Registra um renderizador genérico para um modo visual, servindo como fallback para qualquer entidade.
  void registerGeneric({
    required EntityView view,
    required ViewRendererFn renderer,
  }) {
    _genericRenderers[view] = renderer;
  }

  /// Resolve o renderizador adequado para a entidade e modo visual solicitados.
  ///
  /// Primeiro busca especializações por tipo de entidade. Caso não encontre, recorre
  /// ao renderizador genérico do modo visual correspondente.
  ViewRendererFn? getRenderer(String entityType, EntityView view) {
    final String key = _buildKey(entityType, view);

    // 1. Tenta especialização direta da entidade
    if (_renderers.containsKey(key)) {
      return _renderers[key];
    }

    // 2. Recorre ao renderizador genérico se cadastrado
    if (_genericRenderers.containsKey(view)) {
      return _genericRenderers[view];
    }

    return null;
  }

  String _buildKey(String entityType, EntityView view) => '$entityType:${view.name}';
}
