import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';

/// Componente de galeria de imagens e placeholders históricos para a tela de detalhes do CHRONOS.
class EntityDetailsGallery extends StatelessWidget {
  final dynamic entity;
  final Color color;

  const EntityDetailsGallery({
    super.key,
    required this.entity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Tenta obter uma lista de imagens associadas da fenda temporal
    List<String> imageUrls = [];
    try {
      if (entity.images is List) {
        imageUrls = List<String>.from(entity.images);
      }
    } catch (_) {}

    final bool hasRealImages = imageUrls.isNotEmpty;

    // Se não houver imagens reais de acervo, exibe representações históricas estilizadas (placeholders)
    final List<Map<String, dynamic>> galleryItems = hasRealImages
        ? imageUrls.map((url) => {'url': url, 'label': 'Registro'}).toList()
        : [
            {
              'icon': Icons.architecture_rounded,
              'label': 'Cultura Material',
              'desc': 'Vestígios físicos e arquitetônicos associados.',
            },
            {
              'icon': Icons.menu_book_rounded,
              'label': 'Registros Textuais',
              'desc': 'Manuscritos, crônicas e fontes primárias preservadas.',
            },
            {
              'icon': Icons.map_rounded,
              'label': 'Contexto Espacial',
              'desc': 'Fronteiras geopolíticas na fenda temporal.',
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.md, top: ChronosSpacing.sm),
          child: Text(
            'Galeria Visual e Evidências',
            style: ChronosTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: galleryItems.length,
            itemBuilder: (context, index) {
              final item = galleryItems[index];

              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: ChronosSpacing.md),
                child: ChronosCard(
                  borderColor: color.withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ChronosRadius.md),
                    child: hasRealImages
                        ? Image.network(
                            item['url'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(
                              Icons.broken_image_rounded,
                              'Erro de Conexão',
                              'Não foi possível sincronizar o acervo de imagem.',
                            ),
                          )
                        : _buildPlaceholderCard(
                            item['icon'] as IconData,
                            item['label'] as String,
                            item['desc'] as String,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        ChronosSpacing.vSizedBoxLG,
      ],
    );
  }

  Widget _buildPlaceholderCard(IconData icon, String label, String desc) {
    return Container(
      color: ChronosColors.surfaceLight,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          ChronosSpacing.vSizedBoxXS,
          Text(
            label,
            style: ChronosTypography.bodyMedium.copyWith(
              color: ChronosColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          ChronosSpacing.vSizedBoxXXS,
          Text(
            desc,
            style: ChronosTypography.bodySmall.copyWith(
              color: ChronosColors.textSecondary,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
