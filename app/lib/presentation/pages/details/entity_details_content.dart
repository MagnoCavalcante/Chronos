import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';

/// Componente para renderizar a descrição, resumo, informações históricas
/// e curiosidades de uma entidade histórica.
class EntityDetailsContent extends StatelessWidget {
  final dynamic entity;
  final Color color;

  const EntityDetailsContent({
    super.key,
    required this.entity,
    required this.color,
  });

  /// Extrai valor do campo de forma dinâmica e reativa.
  dynamic _extractValue(String key) {
    if (entity == null) return null;
    final String type = entity.runtimeType.toString().toLowerCase();
    
    try {
      if (type == 'era') {
        switch (key) {
          case 'resumo': return entity.descricaoResumida;
          case 'descricao': return entity.descricao;
        }
      }
      if (type == 'event' || type == 'historicalevent') {
        switch (key) {
          case 'resumo': return entity.nome;
          case 'descricao': return entity.descricao;
        }
      }
      if (type == 'character' || type == 'historicalcharacter') {
        switch (key) {
          case 'resumo': return entity.titulo;
          case 'descricao': return entity.biografia;
        }
      }
      if (type == 'civilization') {
        switch (key) {
          case 'resumo': return entity.summary;
          case 'descricao': return entity.description;
        }
      }
      if (type == 'artifact') {
        switch (key) {
          case 'resumo': return entity.summary;
          case 'descricao': return entity.description;
        }
      }
      if (type == 'historicallocation') {
        switch (key) {
          case 'resumo': return entity.summary;
          case 'descricao': return entity.description;
        }
      }
    } catch (_) {}

    // Operador colchetes para fallbacks dinâmicos de mapa ou json
    try {
      return entity[key];
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String? resumo = _extractValue('resumo') ?? _extractValue('summary') ?? _extractValue('descricaoResumida');
    final String? descricao = _extractValue('descricao') ?? _extractValue('description') ?? _extractValue('biografia');
    
    // Busca por campos de curiosidades / trivia
    final String? curiosidades = _extractValue('curiosidades') ?? 
                                 _extractValue('curiosidade') ?? 
                                 _extractValue('trivia') ?? 
                                 _extractValue('fatosInteressantes');

    // Busca por campos de informações históricas
    final String? informacoesHistoricas = _extractValue('contextoHistorico') ?? 
                                          _extractValue('historia') ?? 
                                          _extractValue('historicalInfo') ??
                                          _extractValue('infoHistorica');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Resumo Executivo
        if (resumo != null && resumo.isNotEmpty) ...[
          _buildSectionHeader('Resumo Executivo'),
          ChronosCard(
            borderColor: color.withOpacity(0.2),
            padding: const EdgeInsets.all(ChronosSpacing.md),
            child: Text(
              resumo,
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          ChronosSpacing.vSizedBoxMD,
        ],

        // 2. Descrição Detalhada
        if (descricao != null && descricao.isNotEmpty && descricao != resumo) ...[
          _buildSectionHeader('Descrição Detalhada'),
          Text(
            descricao,
            style: ChronosTypography.bodyMedium.copyWith(
              color: ChronosColors.textSecondary,
              height: 1.6,
            ),
          ),
          ChronosSpacing.vSizedBoxMD,
        ],

        // 3. Informações Históricas
        if (informacoesHistoricas != null && informacoesHistoricas.isNotEmpty) ...[
          _buildSectionHeader('Informações Históricas'),
          Text(
            informacoesHistoricas,
            style: ChronosTypography.bodyMedium.copyWith(
              color: ChronosColors.textSecondary,
              height: 1.6,
            ),
          ),
          ChronosSpacing.vSizedBoxMD,
        ],

        // 4. Curiosidades (se existir)
        if (curiosidades != null && curiosidades.isNotEmpty) ...[
          _buildSectionHeader('Curiosidades & Fatos'),
          ChronosCard(
            backgroundColor: color.withOpacity(0.05),
            borderColor: color.withOpacity(0.3),
            padding: const EdgeInsets.all(ChronosSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: color, size: 24),
                ChronosSpacing.hSizedBoxMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Você Sabia?',
                        style: ChronosTypography.titleSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ChronosSpacing.vSizedBoxXS,
                      Text(
                        curiosidades,
                        style: ChronosTypography.bodyMedium.copyWith(
                          color: ChronosColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ChronosSpacing.vSizedBoxMD,
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.xs, top: ChronosSpacing.sm),
      child: Text(
        title,
        style: ChronosTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: ChronosColors.textPrimary,
        ),
      ),
    );
  }
}
