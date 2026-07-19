import '../feature_context.dart';

class WidgetTemplateBuilder {
  String buildCard(FeatureContext context) {
    return '''import 'package:flutter/material.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';
import '../../domain/entities/${context.singularSnake}.dart';

class ${context.singularPascal}Card extends StatelessWidget {
  final ${context.singularPascal} item;
  final VoidCallback? onTap;

  const ${context.singularPascal}Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosCard(
      margin: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          ChronosAvatar(
            name: item.nome,
            fallbackIcon: ChronosIcons.hourglass,
            size: 44.0,
          ),
          const SizedBox(width: ChronosSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nome,
                  style: ChronosTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: ChronosSpacing.xs),
                Text(
                  item.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ChronosTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
''';
  }

  String buildLoading(FeatureContext context) {
    return '''import 'package:flutter/material.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';

class ${context.singularPascal}Loading extends StatelessWidget {
  const ${context.singularPascal}Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.md,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ChronosCard(
          margin: EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
          child: Row(
            children: [
              ChronosSkeleton(
                width: 44.0,
                height: 44.0,
                isCircular: true,
              ),
              SizedBox(width: ChronosSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChronosSkeleton(width: 140.0, height: 16.0),
                    SizedBox(height: ChronosSpacing.sm),
                    ChronosSkeleton(width: double.infinity, height: 12.0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
''';
  }

  String buildError(FeatureContext context) {
    return '''import 'package:flutter/material.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';

class ${context.singularPascal}Error extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const ${context.singularPascal}Error({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosErrorState(
      errorMessage: failure.message,
      onRetry: onRetry,
    );
  }
}
''';
  }

  String buildEmpty(FeatureContext context) {
    return '''import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';

class ${context.singularPascal}Empty extends StatelessWidget {
  final VoidCallback onRefresh;

  const ${context.singularPascal}Empty({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosEmptyState(
      title: 'Nenhum registro encontrado',
      description: 'Ainda não existem itens publicados ou ativos nesta categoria.',
      actionLabel: 'Sincronizar',
      onActionPressed: onRefresh,
    );
  }
}
''';
  }
}
