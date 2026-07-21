import 'package:flutter/material.dart';
import 'entity_view.dart';

/// Classe de dados estruturada que descreve as propriedades de comportamento,
/// aparência e recursos suportados por um determinado Tipo de Entidade no CHRONOS.
class EntityDescriptor {
  final String entityType;
  final String displayName;
  final String pluralName;
  final IconData icon;
  final Color color;
  final String coverStrategy; // Estratégia de resolução de imagem (ex: 'network', 'placeholder_color', 'asset')
  final EntityView defaultView;
  final String defaultSort;
  final Map<String, dynamic> defaultFilter;
  final List<String> searchFields;
  final bool timelineSupport;
  final bool mapSupport;
  final bool graphSupport;
  final bool comparisonSupport;
  final bool aiSupport;
  final int priority;
  final String category;

  const EntityDescriptor({
    required this.entityType,
    required this.displayName,
    required this.pluralName,
    required this.icon,
    required this.color,
    this.coverStrategy = 'placeholder_color',
    this.defaultView = EntityView.list,
    this.defaultSort = 'nameAsc',
    this.defaultFilter = const {},
    required this.searchFields,
    this.timelineSupport = false,
    this.mapSupport = false,
    this.graphSupport = false,
    this.comparisonSupport = false,
    this.aiSupport = false,
    this.priority = 100,
    required this.category,
  });
}
