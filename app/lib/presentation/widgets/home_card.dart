import 'package:flutter/material.dart';
import '../../core/home/home_item.dart';
import '../../core/presentation/widgets/chronos_card.dart';
import '../../core/theme/theme.dart';

/// Card horizontal para exibição de entidades na Home e Favoritos.
class HomeCard extends StatelessWidget {
  final HomeItem item;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final double width;
  final double height;

  const HomeCard({
    super.key,
    required this.item,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.width = 160,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ChronosCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          height: 100,
                          width: width,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFavorite,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(ChronosSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.category!,
                      style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
                    ),
                  ],
                  if (item.chronology != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.chronology!,
                      style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.accent),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 100,
      width: width,
      color: ChronosColors.surfaceLight,
      child: const Icon(Icons.image_rounded, color: ChronosColors.textMuted),
    );
  }
}
