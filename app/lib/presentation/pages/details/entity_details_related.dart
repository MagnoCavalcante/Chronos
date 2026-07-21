import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';

/// Componente de conexões e relações de conteúdo para a tela de detalhes do CHRONOS.
///
/// Prepara a infraestrutura e arquitetura necessárias para renderizar interconexões
/// entre Eventos vinculados, Personagens, Civilizações, Artefatos e Localizações.
/// Utiliza placeholders responsivos e interativos quando não houver dados.
class EntityDetailsRelated extends StatelessWidget {
  final dynamic entity;
  final Color color;

  const EntityDetailsRelated({
    super.key,
    required this.entity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Estrutura arquitetural de conexões e relacionamentos
    final List<Map<String, dynamic>> connections = [
      {
        'title': 'Eventos Vinculados',
        'icon': Icons.auto_stories_rounded,
        'count': 'Conectado',
        'desc': 'Marcos cronológicos na mesma fenda temporal.',
      },
      {
        'title': 'Personagens Históricos',
        'icon': Icons.person_rounded,
        'count': 'Conectado',
        'desc': 'Figuras influentes e agentes do período.',
      },
      {
        'title': 'Civilizações Coexistentes',
        'icon': Icons.fort_rounded,
        'count': 'Conectado',
        'desc': 'Impérios e sociedades que moldaram o contexto.',
      },
      {
        'title': 'Cultura Material & Artefatos',
        'icon': Icons.category_rounded,
        'count': 'Conectado',
        'desc': 'Relíquias, manuscritos e invenções preservadas.',
      },
      {
        'title': 'Georeferenciamento & Locais',
        'icon': Icons.place_rounded,
        'count': 'Conectado',
        'desc': 'Sítios arqueológicos e rotas mapeadas na fenda.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.md, top: ChronosSpacing.sm),
          child: Text(
            'Interconexões Históricas',
            style: ChronosTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
        ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: connections.length,
          itemBuilder: (context, index) {
            final conn = connections[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
              child: ChronosCard(
                borderColor: color.withOpacity(0.12),
                padding: const EdgeInsets.all(ChronosSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ChronosSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(ChronosRadius.sm),
                      ),
                      child: Icon(conn['icon'] as IconData, color: color, size: 20),
                    ),
                    ChronosSpacing.hSizedBoxMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                conn['title'] as String,
                                style: ChronosTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ChronosColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ChronosRadius.xs),
                                ),
                                child: Text(
                                  conn['count'] as String,
                                  style: ChronosTypography.labelSmall.copyWith(
                                    color: color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            conn['desc'] as String,
                            style: ChronosTypography.bodySmall.copyWith(
                              color: ChronosColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ChronosSpacing.vSizedBoxMD,
      ],
    );
  }
}
