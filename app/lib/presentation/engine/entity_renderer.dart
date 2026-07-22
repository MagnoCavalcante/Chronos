import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/chronos_card.dart';
import '../widgets/browser/entity_card.dart';
import 'entity_descriptor.dart';
import 'entity_metadata.dart';
import 'entity_render_context.dart';
import 'entity_render_pipeline.dart';
import 'entity_view.dart';
import 'entity_registry.dart';
import 'entity_view_registry.dart';
import '../pages/details/entity_details_page.dart';

/// O Renderizador Universal de Entidades do CHRONOS.
///
/// Este widget recebe qualquer entidade de domínio e resolve dinamicamente
/// seu descritor, metadados e renderizadores via pipeline.
class EntityRenderer extends StatelessWidget {
  final dynamic entity;
  final EntityView? view;
  final EntityRenderContext? context;
  final EntityRenderPipeline? pipeline;

  const EntityRenderer({
    super.key,
    required this.entity,
    this.view,
    this.context,
    this.pipeline,
  });

  @override
  Widget build(BuildContext context) {
    final registry = EntityRegistry();
    final String entityType = registry.resolveEntityType(entity);

    // 1. Resolve o descritor e metadados
    final descriptor = registry.getDescriptor(entityType) ??
        EntityDescriptor(
          entityType: entityType,
          displayName: 'Entidade Genérica',
          pluralName: 'Entidades Genéricas',
          icon: Icons.layers_outlined,
          color: ChronosColors.textPrimary,
          searchFields: const [],
          category: 'Geral',
        );

    final metadata = registry.getMetadata(entityType) ??
        EntityMetadata(
          entityType: entityType,
          fields: const [],
        );

    // 2. Resolve o contexto de renderização
    final resolvedContext = this.context ??
        EntityRenderContext(
          theme: Theme.of(context),
          screenSize: EntityRenderContext.getScreenSize(MediaQuery.of(context).size.width),
          accessibility: EngineAccessibility(
            screenReaderEnabled: MediaQuery.of(context).accessibleNavigation,
            highContrast: MediaQuery.of(context).highContrast,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
          ),
          currentView: view ?? descriptor.defaultView,
        );

    // 3. Resolve o pipeline de renderização
    final resolvedPipeline = pipeline ?? EntityRenderPipeline();

    // 4. Executa a renderização passando pelo pipeline
    return resolvedPipeline.execute(
      entity: entity,
      descriptor: descriptor,
      metadata: metadata,
      context: resolvedContext,
      baseRenderer: (ctx, meta) {
        // Verifica se existe um renderizador especializado ou genérico registrado no View Registry
        final viewRegistry = EntityViewRegistry();
        final specializedFn = viewRegistry.getRenderer(descriptor.entityType, ctx.currentView);

        if (specializedFn != null) {
          return specializedFn(entity, descriptor, meta, ctx);
        }

        // Fallback para renderização nativa embutida na Engine
        return _renderDefaultView(entity, descriptor, meta, ctx);
      },
    );
  }

  /// Renderizador padrão embutido na Engine para cada uma das modalidades visuais do CHRONOS.
  Widget _renderDefaultView(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    final display = mapToDisplay(entity, descriptor, metadata);

    switch (context.currentView) {
      case EntityView.compact:
        return EntityCard(display: display, viewMode: EntityViewMode.compact);
      case EntityView.grid:
        return EntityCard(display: display, viewMode: EntityViewMode.grid);
      case EntityView.cards:
        return EntityCard(display: display, viewMode: EntityViewMode.large);
      case EntityView.list:
        return EntityCard(display: display, viewMode: EntityViewMode.list);
      case EntityView.details:
        return _renderDetailsView(entity, descriptor, metadata, context);
      case EntityView.timeline:
        return _renderTimelinePlaceholder(entity, descriptor, metadata, context);
      case EntityView.map:
        return _renderMapPlaceholder(entity, descriptor, metadata, context);
      case EntityView.graph:
        return _renderGraphPlaceholder(entity, descriptor, metadata, context);
      case EntityView.comparison:
        return _renderComparisonPlaceholder(entity, descriptor, metadata, context);
      case EntityView.preview:
        return _renderPreviewView(entity, descriptor, metadata, context, display);
      case EntityView.searchResult:
        return _renderSearchResultView(entity, descriptor, metadata, context, display);
      case EntityView.aiResult:
        return _renderAiResultView(entity, descriptor, metadata, context, display);
    }
  }

  /// Mapeador dinâmico universal que traduz qualquer entidade cadastrada em ChronosEntityDisplay de forma automatizada.
  static ChronosEntityDisplay mapToDisplay(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
  ) {
    final String id = _extractValue(entity, 'id')?.toString() ?? '';
    final String title = _extractValue(entity, 'nome')?.toString() ??
        _extractValue(entity, 'name')?.toString() ??
        _extractValue(entity, 'titulo')?.toString() ??
        'Sem título';

    final String subtitle = _extractValue(entity, 'titulo')?.toString() ??
        _extractValue(entity, 'shortName')?.toString() ??
        _extractValue(entity, 'autor')?.toString() ??
        'Registro Histórico';

    final String? description = _extractValue(entity, 'descricao')?.toString() ??
        _extractValue(entity, 'descricaoResumida')?.toString() ??
        _extractValue(entity, 'biografia')?.toString() ??
        _extractValue(entity, 'description')?.toString() ??
        _extractValue(entity, 'summary')?.toString();

    final String? imageUrl = _extractValue(entity, 'coverImageUrl')?.toString() ??
        _extractValue(entity, 'coverUrl')?.toString();

    // Extração temporal automática com base em metadados cronológicos
    int? chronologyValue;
    String? chronologyString;
    final timelineFields = metadata.timelineFields;
    if (timelineFields.isNotEmpty) {
      final firstVal = _extractValue(entity, timelineFields.first.key);
      if (firstVal is int) {
        chronologyValue = firstVal;
        if (timelineFields.length > 1) {
          final secondVal = _extractValue(entity, timelineFields[1].key);
          if (secondVal is int) {
            final suffixA = firstVal < 0 ? ' a.C.' : ' d.C.';
            final suffixB = secondVal < 0 ? ' a.C.' : ' d.C.';
            chronologyString = '${firstVal.abs()}$suffixA — ${secondVal.abs()}$suffixB';
          } else {
            final suffix = firstVal < 0 ? ' a.C.' : ' d.C.';
            chronologyString = '${firstVal.abs()}$suffix';
          }
        } else {
          final suffix = firstVal < 0 ? ' a.C.' : ' d.C.';
          chronologyString = '${firstVal.abs()}$suffix';
        }
      }
    }

    return ChronosEntityDisplay(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      imageUrl: imageUrl,
      icon: descriptor.icon,
      color: descriptor.color,
      chronology: chronologyString,
      chronologyValue: chronologyValue,
      category: descriptor.category,
      type: descriptor.displayName,
    );
  }

  /// Extrai reflexivamente o valor de um campo de qualquer classe do CHRONOS de forma síncrona.
  static dynamic _extractValue(dynamic entity, String fieldKey) {
    if (entity == null) return null;
    final String typeString = entity.runtimeType.toString().toLowerCase();

    try {
      if (typeString == 'era') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'nome': return entity.nome;
          case 'descricaoResumida': return entity.descricaoResumida;
          case 'inicioAno': return entity.inicioAno;
          case 'fimAno': return entity.fimAno;
          case 'corHex': return entity.corHex;
        }
      }
      if (typeString == 'event' || typeString == 'historicalevent') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'eraId': return entity.eraId;
          case 'nome': return entity.nome;
          case 'descricao': return entity.descricao;
          case 'anoOcorrencia': return entity.anoOcorrencia;
        }
      }
      if (typeString == 'character' || typeString == 'historicalcharacter') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'nome': return entity.nome;
          case 'titulo': return entity.titulo;
          case 'biografia': return entity.biografia;
          case 'nascimentoAno': return entity.nascimentoAno;
          case 'morteAno': return entity.morteAno;
        }
      }
      if (typeString == 'civilization') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'name': return entity.name;
          case 'shortName': return entity.shortName;
          case 'description': return entity.description;
          case 'summary': return entity.summary;
          case 'startYear': return entity.startYear;
          case 'endYear': return entity.endYear;
        }
      }
      if (typeString == 'artifact') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'name': return entity.name;
          case 'shortName': return entity.shortName;
          case 'description': return entity.description;
          case 'summary': return entity.summary;
          case 'artifactType': return entity.artifactType;
          case 'originCivilizationId': return entity.originCivilizationId;
          case 'originLocationId': return entity.originLocationId;
          case 'estimatedYear': return entity.estimatedYear;
          case 'material': return entity.material;
          case 'currentLocation': return entity.currentLocation;
          case 'coverImageUrl': return entity.coverImageUrl;
        }
      }
      if (typeString == 'historicallocation') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'name': return entity.name;
          case 'shortName': return entity.shortName;
          case 'description': return entity.description;
          case 'summary': return entity.summary;
          case 'latitude': return entity.latitude;
          case 'longitude': return entity.longitude;
          case 'parentLocationId': return entity.parentLocationId;
          case 'modernCountry': return entity.modernCountry;
          case 'modernRegion': return entity.modernRegion;
          case 'startYear': return entity.startYear;
          case 'endYear': return entity.endYear;
          case 'coverImageUrl': return entity.coverImageUrl;
        }
      }
      if (typeString == 'source' || typeString == 'historicalsource') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'titulo': return entity.titulo;
          case 'autor': return entity.autor;
          case 'url': return entity.url;
          case 'descricao': return entity.descricao;
        }
      }
      if (typeString == 'relation' || typeString == 'relationship') {
        switch (fieldKey) {
          case 'id': return entity.id;
          case 'origemId': return entity.origemId;
          case 'origemTipo': return entity.origemTipo;
          case 'destinoId': return entity.destinoId;
          case 'destinoTipo': return entity.destinoTipo;
          case 'tipoRelacao': return entity.tipoRelacao;
        }
      }
    } catch (_) {}

    // Fallback dinâmico para mapas ou objetos que implementam o operador colchetes
    try {
      return entity[fieldKey];
    } catch (_) {}

    return null;
  }

  /// Renderiza uma visualização rica e detalhada baseada em metadados.
  Widget _renderDetailsView(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    return EntityDetailsPage(
      entity: entity,
      descriptor: descriptor,
    );
  }

  /// Renderiza o container de preparação para a Timeline Engine.
  Widget _renderTimelinePlaceholder(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    final tFields = metadata.timelineFields;
    final firstVal = tFields.isNotEmpty ? _extractValue(entity, tFields.first.key) : 'Indeterminado';

    return ChronosCard(
      borderColor: descriptor.color.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.timeline_rounded, color: ChronosColors.textSecondary),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timeline Anchor', style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                Text('Coordenada temporal associada: $firstVal', style: ChronosTypography.codeSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ChronosColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Timeline Engine Ready',
              style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Renderiza o container de preparação para a Map Engine.
  Widget _renderMapPlaceholder(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    final mFields = metadata.mapFields;
    final lat = mFields.length > 0 ? _extractValue(entity, 'latitude') : null;
    final lng = mFields.length > 1 ? _extractValue(entity, 'longitude') : null;

    return ChronosCard(
      borderColor: Colors.green.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.map_rounded, color: Colors.green),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Georreferenciamento', style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                Text(lat != null && lng != null ? 'Coordenadas: $lat, $lng' : 'Coordenadas geográficas herdadas', style: ChronosTypography.codeSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ChronosColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Map Engine Ready',
              style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Renderiza o container de preparação para a Graph Engine.
  Widget _renderGraphPlaceholder(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    return ChronosCard(
      borderColor: Colors.purple.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.bubble_chart_rounded, color: Colors.purple),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Graph Connection Point', style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                Text('Mapeando nós e adjacências semânticas no CHRONOS', style: ChronosTypography.codeSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ChronosColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Graph Engine Ready',
              style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Renderiza o container de preparação para o Comparador Histórico.
  Widget _renderComparisonPlaceholder(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
  ) {
    final compFields = metadata.comparableFields;

    return ChronosCard(
      borderColor: descriptor.color.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: ChronosColors.textSecondary),
              ChronosSpacing.hSizedBoxMD,
              Text('Comparador de Métricas', style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          ChronosSpacing.vSizedBoxSM,
          Text(
            'Campos comparáveis suportados: ${compFields.map((f) => f.label).join(", ")}',
            style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Renderiza uma pré-visualização elegante e minimalista.
  Widget _renderPreviewView(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
    ChronosEntityDisplay display,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      decoration: BoxDecoration(
        color: ChronosColors.surface,
        borderRadius: BorderRadius.circular(ChronosRadius.sm),
        border: Border.all(color: descriptor.color.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4.0, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(descriptor.icon, color: descriptor.color, size: 16),
              ChronosSpacing.hSizedBoxSM,
              Expanded(
                child: Text(
                  display.title,
                  style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ChronosSpacing.vSizedBoxSM,
          Text(
            display.subtitle,
            style: ChronosTypography.codeSmall.copyWith(color: descriptor.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (display.description != null) ...[
            ChronosSpacing.vSizedBoxSM,
            Text(
              display.description!,
              style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Renderiza o resultado de uma pesquisa otimizada para texto.
  Widget _renderSearchResultView(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
    ChronosEntityDisplay display,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(ChronosSpacing.xs),
        decoration: BoxDecoration(
          color: descriptor.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ChronosRadius.xs),
        ),
        child: Icon(descriptor.icon, color: descriptor.color, size: 18),
      ),
      title: Text(display.title, style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(display.subtitle, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary)),
      trailing: display.chronology != null
          ? Text(display.chronology!, style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted))
          : null,
    );
  }

  /// Renderiza a visualização rica decorada com visual temático synthwave/AI.
  Widget _renderAiResultView(
    dynamic entity,
    EntityDescriptor descriptor,
    EntityMetadata metadata,
    EntityRenderContext context,
    ChronosEntityDisplay display,
  ) {
    final aiFields = metadata.aiFields;
    final highlightText = aiFields.isNotEmpty
        ? _extractValue(entity, aiFields.first.key)?.toString()
        : display.description;

    return Container(
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChronosColors.surface,
            descriptor.color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ChronosRadius.md),
        border: Border.all(color: descriptor.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: ChronosColors.accent, size: 20),
              ChronosSpacing.hSizedBoxSM,
              Text(
                'Análise Inteligente CHRONOS',
                style: ChronosTypography.codeSmall.copyWith(
                  color: ChronosColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ChronosColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ChronosRadius.xs),
                ),
                child: Text(
                  'IA Core',
                  style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.accent, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          ChronosSpacing.vSizedBoxMD,
          Text(display.title, style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ChronosSpacing.vSizedBoxXS,
          Text(display.subtitle, style: ChronosTypography.bodySmall.copyWith(color: descriptor.color, fontWeight: FontWeight.bold)),
          if (highlightText != null && highlightText.isNotEmpty) ...[
            ChronosSpacing.vSizedBoxMD,
            Container(
              padding: const EdgeInsets.all(ChronosSpacing.md),
              decoration: BoxDecoration(
                color: ChronosColors.surfaceLight,
                borderRadius: BorderRadius.circular(ChronosRadius.xs),
                border: Border.all(color: ChronosColors.border, width: 0.5),
              ),
              child: Text(
                highlightText,
                style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textPrimary, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
