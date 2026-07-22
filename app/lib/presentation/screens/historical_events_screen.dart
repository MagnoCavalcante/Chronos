import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/widgets.dart';
import '../../domain/entities/era.dart';
import '../../domain/entities/event.dart';
import '../controllers/historical_events_controller.dart';
import '../widgets/historical_event_card.dart';
import '../widgets/historical_events_empty.dart';
import '../widgets/historical_events_error.dart';
import '../widgets/historical_events_loading.dart';

/// Tela principal para exibição, busca e navegação de Eventos Históricos do CHRONOS.
class HistoricalEventsScreen extends StatefulWidget {
  final HistoricalEventsController? controller;

  const HistoricalEventsScreen({
    super.key,
    this.controller,
  });

  @override
  State<HistoricalEventsScreen> createState() => _HistoricalEventsScreenState();
}

class _ErasTimelinePlaceholderSheet extends StatelessWidget {
  const _ErasTimelinePlaceholderSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(ChronosIcons.event, size: 54, color: ChronosColors.textMuted),
        const SizedBox(height: ChronosSpacing.md),
        Text(
          'Visualização em Linha do Tempo',
          style: ChronosTypography.titleLarge,
        ),
        const SizedBox(height: ChronosSpacing.sm),
        Text(
          'A apresentação encadeada e sequencial dos acontecimentos históricos por Eras será disponibilizada na próxima Sprint de entrega (Sprint 5.0).',
          textAlign: TextAlign.center,
          style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
        ),
        const SizedBox(height: ChronosSpacing.xl),
      ],
    );
  }
}

class _ErasMapPlaceholderSheet extends StatelessWidget {
  const _ErasMapPlaceholderSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(ChronosIcons.location, size: 54, color: ChronosColors.textMuted),
        const SizedBox(height: ChronosSpacing.md),
        Text(
          'Visualização em Mapa Geográfico',
          style: ChronosTypography.titleLarge,
        ),
        const SizedBox(height: ChronosSpacing.sm),
        Text(
          'O mapeamento geográfico interativo de coordenadas decimais de latitude e longitude dos eventos será introduzido no módulo de navegação da Sprint 5.1.',
          textAlign: TextAlign.center,
          style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
        ),
        const SizedBox(height: ChronosSpacing.xl),
      ],
    );
  }
}

class _HistoricalEventsScreenState extends State<HistoricalEventsScreen> {
  late final HistoricalEventsController _controller;
  static const String _tag = 'HistoricalEventsScreen';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? locate<HistoricalEventsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadEvents();
    });
  }

  Future<void> _handleRefresh() async {
    await _controller.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'CHRONOS — Eventos Históricos',
      actions: [
        ChronosIconButton(
          tooltip: 'Sincronizar Banco Remoto',
          icon: ChronosIcons.sync,
          onPressed: _handleRefresh,
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlaceholderControlBar(context),
              Expanded(
                child: ChronosPage(
                  onRefresh: _handleRefresh,
                  scrollable: false,
                  child: _buildBodyContent(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderControlBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ChronosColors.background,
      padding: const EdgeInsets.fromLTRB(
        ChronosSpacing.lg,
        ChronosSpacing.sm,
        ChronosSpacing.lg,
        ChronosSpacing.md,
      ),
      child: Column(
        children: [
          const ChronosSearchBar(
            hintText: 'Buscar eventos por termo ou época...',
          ),
          const SizedBox(height: ChronosSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChronosChip(
                  label: 'Linha do Tempo',
                  leadingIcon: ChronosIcons.event,
                  onTap: () {
                    ChronosBottomSheet.show(
                      context,
                      child: const _ErasTimelinePlaceholderSheet(),
                    );
                  },
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: 'Visualizar no Mapa',
                  leadingIcon: ChronosIcons.location,
                  onTap: () {
                    ChronosBottomSheet.show(
                      context,
                      child: const _ErasMapPlaceholderSheet(),
                    );
                  },
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: 'Filtro: Tipo (Em breve)',
                  leadingIcon: Icons.filter_list_rounded,
                  onTap: () {
                    ChronosSnackBar.show(
                      context,
                      message: 'A funcionalidade "Filtro: Tipo" será entregue no módulo de refinamento cronológico.',
                    );
                  },
                ),
                const SizedBox(width: ChronosSpacing.sm),
                ChronosChip(
                  label: 'Filtro: Era (Em breve)',
                  leadingIcon: Icons.history_toggle_off_rounded,
                  onTap: () {
                    ChronosSnackBar.show(
                      context,
                      message: 'A funcionalidade "Filtro: Era" será entregue no módulo de refinamento cronológico.',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: ChronosSpacing.md),
          const ChronosDivider(),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const HistoricalEventsLoading();
    }

    if (_controller.hasError) {
      return HistoricalEventsError(
        failure: _controller.failure!,
        onRetry: _controller.loadEvents,
      );
    }

    if (_controller.isEmpty) {
      return HistoricalEventsEmpty(
        onRefresh: _controller.loadEvents,
      );
    }

    final eventsList = _controller.events;
    return ChronosList<HistoricalEvent>(
      items: eventsList,
      showSeparator: false,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.xs),
      itemBuilder: (context, event, index) {
        return HistoricalEventCard(
          event: event,
          erasMap: _controller.erasMap,
          onTap: () {
            ChronosSnackBar.show(
              context,
              message: 'Navegação para detalhes do evento "${event.nome}" (Sprint futura).',
            );
          },
        );
      },
    );
  }
}
