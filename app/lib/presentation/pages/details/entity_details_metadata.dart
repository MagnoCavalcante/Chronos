import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../engine/entity_metadata.dart';

/// Componente que consome dinamicamente o modelo de metadados da entidade histórica.
///
/// Apresenta campos como Datas, Localização, Civilização, Personagens, Artefatos, etc.,
/// de forma síncrona, robusta e abstrata, sem conhecer propriedades físicas estáticas das classes.
class EntityDetailsMetadata extends StatelessWidget {
  final dynamic entity;
  final EntityMetadata metadata;
  final Color color;

  const EntityDetailsMetadata({
    super.key,
    required this.entity,
    required this.metadata,
    required this.color,
  });

  /// Extrai reflexivamente o valor de um campo de qualquer classe do CHRONOS de forma síncrona.
  dynamic _extractValue(dynamic entity, String fieldKey) {
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
    } catch (_) {}

    try {
      return entity[fieldKey];
    } catch (_) {}

    return null;
  }

  String _formatYearValue(dynamic value) {
    if (value is int) {
      final int yr = value;
      return yr < 0 ? '${yr.abs()} a.C.' : '$yr d.C.';
    }
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> metadataWidgets = [];

    for (final field in metadata.fields) {
      if (field.isHidden) continue;

      final val = _extractValue(entity, field.key);
      if (val == null || val.toString().trim().isEmpty) continue;

      // Classifica e escolhe o ícone ideal para o metadado
      IconData icon = Icons.info_outline_rounded;
      String label = field.label;
      String displayValue = val.toString();

      final String key = field.key.toLowerCase();

      // Datas
      if (field.isTimelineField || key.contains('ano') || key.contains('data') || key.contains('year') || key.contains('nascimento') || key.contains('morte')) {
        icon = Icons.calendar_today_rounded;
        displayValue = _formatYearValue(val);
      }
      // Localizações
      else if (field.isMapField || key.contains('local') || key.contains('latitude') || key.contains('longitude') || key.contains('country') || key.contains('region')) {
        icon = Icons.place_rounded;
      }
      // Civilizações
      else if (key.contains('civilizacao') || key.contains('civilization')) {
        icon = Icons.fort_rounded;
      }
      // Personagens / Agentes
      else if (key.contains('character') || key.contains('personagem') || key.contains('autor')) {
        icon = Icons.person_rounded;
      }
      // Artefatos / Cultura Material
      else if (key.contains('artifact') || key.contains('artefato') || key.contains('material') || key.contains('objeto')) {
        icon = Icons.category_rounded;
      }
      // Relacionados / Conectores
      else if (key.contains('id') || key.contains('relacao') || key.contains('parent')) {
        icon = Icons.hub_rounded;
      }

      metadataWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              ChronosSpacing.hSizedBoxSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: ChronosTypography.labelSmall.copyWith(
                        color: ChronosColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayValue,
                      style: ChronosTypography.bodyMedium.copyWith(
                        color: ChronosColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (metadataWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.sm, top: ChronosSpacing.sm),
          child: Text(
            'Ficha de Metadados',
            style: ChronosTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
        ),
        ChronosCard(
          borderColor: color.withOpacity(0.15),
          padding: const EdgeInsets.all(ChronosSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metadataWidgets,
          ),
        ),
        ChronosSpacing.vSizedBoxLG,
      ],
    );
  }
}
