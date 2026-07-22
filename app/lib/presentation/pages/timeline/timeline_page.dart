import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../widgets/chronos_loading_view.dart';
import '../../widgets/chronos_empty_view.dart';
import '../../widgets/chronos_error_view.dart';
import 'timeline_controller.dart';
import 'timeline_header.dart';
import 'timeline_list.dart';

/// Página principal da Timeline MVP do CHRONOS.
///
/// Desenvolvida sob as diretrizes estritas da camada Experience Layer.
/// Orquestra a carga unificada de Eras e Eventos Históricos, delega a filtragem
/// e ordenação ao [TimelineController] e renderiza os estados correspondentes
/// utilizando os componentes oficiais do Design System.
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late final TimelineController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimelineController();

    // Dispara a carga inicial assíncrona logo após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.carregarDados();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ChronosPage(
            scrollable: false,
            padding: EdgeInsets.zero,
            onRefresh: _controller.carregarDados,
            child: _buildBodyContent(),
          );
        },
      ),
    );
  }

  /// Resolve o widget de corpo correspondente ao estado reativo do controlador.
  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const ChronosLoadingView(
        message: 'Sincronizando fendas temporais e alinhando eras...',
        icon: Icons.hourglass_empty_rounded,
      );
    }

    if (_controller.hasError) {
      return ChronosErrorView(
        message: _controller.errorMessage,
        onRetry: _controller.carregarDados,
      );
    }

    return Column(
      children: [
        TimelineHeader(controller: _controller),
        Expanded(
          child: _controller.filteredItems.isEmpty
              ? ChronosEmptyView(
                  icon: Icons.search_off_rounded,
                  title: 'Nenhum registro no período',
                  description: 'Tente expandir o intervalo de anos, escolher outra categoria ou limpar a busca.',
                  action: ChronosButton(
                    label: 'Limpar Filtros',
                    onPressed: _controller.resetFilters,
                    variant: ChronosButtonVariant.text,
                  ),
                )
              : TimelineList(controller: _controller),
        ),
      ],
    );
  }
}
