import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../widgets/chronos_loading_view.dart';
import '../../widgets/chronos_empty_view.dart';
import '../../widgets/chronos_error_view.dart';
import '../../engine/entity_descriptor.dart';
import '../../engine/entity_metadata.dart';
import '../../engine/entity_registry.dart';
import '../../engine/entity_renderer.dart';
import '../../widgets/browser/entity_card.dart';
import 'entity_details_header.dart';
import 'entity_details_content.dart';
import 'entity_details_gallery.dart';
import 'entity_details_metadata.dart';
import 'entity_details_actions.dart';
import 'entity_details_related.dart';
import '../../widgets/discovery_line.dart';

/// Tela unificada e dinâmica de detalhes de entidades históricas do CHRONOS.
///
/// Desenvolvida para orquestrar e renderizar qualquer registro histórico do sistema
/// de forma rica, modular e responsiva, consumindo o Entity Rendering Engine para mapeamento.
class EntityDetailsPage extends StatelessWidget {
  final dynamic entity;
  final EntityDescriptor? descriptor;
  final dynamic controller;

  const EntityDetailsPage({
    super.key,
    required this.entity,
    this.descriptor,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (entity == null) {
      return const Scaffold(
        backgroundColor: ChronosColors.background,
        body: ChronosEmptyView(
          icon: Icons.error_outline_rounded,
          title: 'Entidade não encontrada',
          description: 'A fenda temporal solicitada parece estar inacessível ou vazia.',
        ),
      );
    }

    // 1. Resolve tipo, descritor e metadados via Entity Engine Registry
    final registry = EntityRegistry();
    final String entityType = registry.resolveEntityType(entity);
    final resolvedDescriptor = descriptor ??
        registry.getDescriptor(entityType) ??
        EntityDescriptor(
          entityType: entityType,
          displayName: 'Entidade Histórica',
          pluralName: 'Entidades Históricas',
          icon: Icons.layers_outlined,
          color: ChronosColors.accent,
          category: 'Geral',
          searchFields: const [],
        );

    final metadata = registry.getMetadata(entityType) ??
        EntityMetadata(
          entityType: entityType,
          fields: const [],
        );

    // 2. Transforma usando o mapeador universal do Entity Rendering Engine para evitar duplicação de dados
    final display = EntityRenderer.mapToDisplay(entity, resolvedDescriptor, metadata);
    final Color eraColor = display.color ?? ChronosColors.accent;

    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ChronosColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          resolvedDescriptor.displayName,
          style: ChronosTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: ChronosColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isLargeScreen = constraints.maxWidth >= 800;

                if (isLargeScreen) {
                  return _buildTwoColumnLayout(context, display, metadata, eraColor);
                } else {
                  return _buildSingleColumnLayout(context, display, metadata, eraColor);
                }
              },
            ),
          ),
          _DiscoveryTracker(entity: entity, display: display),
        ],
      ),
    );
  }

  /// Layout de coluna única adaptado para mobile
  Widget _buildSingleColumnLayout(
    BuildContext context,
    ChronosEntityDisplay display,
    EntityMetadata metadata,
    Color eraColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntityDetailsHeader(display: display),
          const ChronosDivider(),
          EntityDetailsActions(entity: entity, color: eraColor),
          const ChronosDivider(),
          EntityDetailsContent(entity: entity, color: eraColor),
          EntityDetailsGallery(entity: entity, color: eraColor),
          EntityDetailsMetadata(entity: entity, metadata: metadata, color: eraColor),
          EntityDetailsRelated(entity: entity, display: display, color: eraColor),
          ChronosSpacing.vSizedBoxLG,
          const DiscoveryLine(),
        ],
      ),
    );
  }

  /// Layout bento-grid em duas colunas otimizado para tablets e desktops
  Widget _buildTwoColumnLayout(
    BuildContext context,
    ChronosEntityDisplay display,
    EntityMetadata metadata,
    Color eraColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coluna Principal (Esquerda - Foco no Conteúdo e Mídias)
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(ChronosSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EntityDetailsHeader(display: display),
                const ChronosDivider(),
                EntityDetailsContent(entity: entity, color: eraColor),
                EntityDetailsGallery(entity: entity, color: eraColor),
                EntityDetailsRelated(entity: entity, display: display, color: eraColor),
                ChronosSpacing.vSizedBoxLG,
                const DiscoveryLine(),
              ],
            ),
          ),
        ),

        // Divisor vertical
        Container(
          width: 1,
          height: double.infinity,
          color: ChronosColors.border,
        ),

        // Coluna Lateral (Direita - Foco em Metadados e Ações Rápidas)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(ChronosSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EntityDetailsActions(entity: entity, color: eraColor),
                const ChronosDivider(),
                EntityDetailsMetadata(entity: entity, metadata: metadata, color: eraColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget invisível que registra o passo atual na Linha de Descoberta.
class _DiscoveryTracker extends StatefulWidget {
  final dynamic entity;
  final ChronosEntityDisplay display;

  const _DiscoveryTracker({required this.entity, required this.display});

  @override
  State<_DiscoveryTracker> createState() => _DiscoveryTrackerState();
}

class _DiscoveryTrackerState extends State<_DiscoveryTracker> {
  @override
  void initState() {
    super.initState();
    _track();
  }

  Future<void> _track() async {
    final id = _resolveId(widget.entity);
    final type = _resolveType(widget.entity);
    if (id == null || type == null) return;

    await DiscoveryLineService().add(DiscoveryStep(
      entityType: type,
      entityId: id,
      title: widget.display.title,
      imageUrl: widget.display.imageUrl,
      color: _toHex(widget.display.color),
    ));
  }

  String? _resolveId(dynamic entity) {
    if (entity is Map<String, dynamic>) return entity['id'] as String?;
    try { return entity.id as String?; } catch (_) {}
    return null;
  }

  String? _resolveType(dynamic entity) {
    String? type;
    if (entity is Map<String, dynamic>) {
      type = entity['entity_type'] as String?;
    }
    try { type ??= entity.entityType as String?; } catch (_) {}
    try { type ??= EntityRegistry().resolveEntityType(entity); } catch (_) {}
    if (type == null) return null;
    return _toSnakeCase(type);
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')
        .toLowerCase();
  }

  String? _toHex(Color? color) {
    if (color == null) return null;
    final value = color.value;
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
