import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/study/study_models.dart';

/// Card de coleção com capa, título e contador de itens.
class CollectionCard extends StatelessWidget {
  final Collection collection;
  final int itemCount;
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    this.itemCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: collection.coverUrl != null ? null : ChronosColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ChronosRadius.sm),
              image: collection.coverUrl != null
                  ? DecorationImage(image: NetworkImage(collection.coverUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: collection.coverUrl == null
                ? const Icon(Icons.collections_bookmark_rounded, color: ChronosColors.accent)
                : null,
          ),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.title,
                  style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (collection.description?.isNotEmpty == true)
                  Text(
                    collection.description!,
                    style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'}',
                  style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: ChronosColors.textMuted),
        ],
      ),
    );
  }
}
