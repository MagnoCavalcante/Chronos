import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/widgets.dart';
import '../controllers/eras_controller.dart';
import '../../domain/entities/era.dart';

/// Tela de validação de fluxo técnico para o módulo de Eras no ecossistema CHRONOS.
class ErasScreen extends StatefulWidget {
  final ErasController? controller;

  const ErasScreen({
    super.key,
    this.controller,
  });

  @override
  State<ErasScreen> createState() => _ErasScreenState();
}

class _ErasScreenState extends State<ErasScreen> {
  late final ErasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? locate<ErasController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.carregarEras();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'CHRONOS — Eras Históricas',
      actions: [
        ChronosIconButton(
          icon: ChronosIcons.sync,
          tooltip: 'Sincronizar',
          onPressed: _controller.carregarEras,
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ChronosPage(
            onRefresh: _controller.carregarEras,
            scrollable: false,
            child: _buildBodyContent(),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const ChronosLoading(
        description: 'Carregando Eras do CHRONOS...',
      );
    }

    if (_controller.hasError) {
      return ChronosErrorState(
        errorMessage: _controller.errorMessage ?? 'Ocorreu um erro desconhecido.',
        onRetry: _controller.carregarEras,
      );
    }

    if (_controller.eras.isEmpty) {
      return ChronosEmptyState(
        title: 'Nenhuma Era encontrada',
        description: 'Ainda não existem eras ativas e publicadas publicadas no sistema.',
        actionLabel: 'Sincronizar',
        onActionPressed: _controller.carregarEras,
      );
    }

    return ChronosList<Era>(
      items: _controller.eras,
      showSeparator: false,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.xs),
      itemBuilder: (context, era, index) {
        return _EraValidationCard(era: era);
      },
    );
  }
}

/// Card de exibição simplificado de uma Era.
class _EraValidationCard extends StatelessWidget {
  final Era era;

  const _EraValidationCard({required this.era});

  @override
  Widget build(BuildContext context) {
    Color? borderAccentColor;
    try {
      final cleanHex = era.corHex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        borderAccentColor = Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        borderAccentColor = Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {
      // Ignora e utiliza cor padrão em caso de string hexadecimal inválida
    }

    final accentColor = borderAccentColor ?? ChronosColors.accent;

    final String labelInicio = era.inicioAno < 0 ? '${era.inicioAno.abs()} a.C.' : '${era.inicioAno} d.C.';
    final String labelFim = era.fimAno < 0 ? '${era.fimAno.abs()} a.C.' : '${era.fimAno} d.C.';

    return ChronosCard(
      margin: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
      borderColor: accentColor.withOpacity(0.4),
      borderWidth: 1.5,
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(era.iconKey),
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: ChronosSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        era.nome,
                        style: ChronosTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: ChronosSpacing.xs),
                    StatusBadge(status: era.publicationStatus.value),
                  ],
                ),
                const SizedBox(height: ChronosSpacing.xs),
                Text(
                  era.tituloCurto,
                  style: ChronosTypography.bodyMedium,
                ),
                const SizedBox(height: ChronosSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: ChronosColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '$labelInicio — $labelFim',
                      style: ChronosTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: ChronosSpacing.xxs),
                Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: ChronosColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Slug: ${era.slug}',
                      style: ChronosTypography.codeSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? key) {
    switch (key?.toLowerCase()) {
      case 'castle':
        return Icons.fort_rounded;
      case 'history':
        return Icons.auto_stories_rounded;
      case 'temple':
        return Icons.gavel_rounded;
      case 'hourglass':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.public_rounded;
    }
  }
}
