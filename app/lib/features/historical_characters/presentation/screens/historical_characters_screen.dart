import 'package:flutter/material.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/navigation/navigation_service.dart';
import 'package:chronos/core/presentation/widgets/chronos_icon_button.dart';
import 'package:chronos/core/presentation/widgets/chronos_page.dart';
import 'package:chronos/core/presentation/widgets/chronos_scaffold.dart';
import 'package:chronos/core/theme/chronos_icons.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/domain/entities/era.dart';
import 'package:chronos/domain/usecases/get_all_eras_usecase.dart';
import '../controllers/historical_characters_controller.dart';
import '../widgets/historical_character_card.dart';
import '../widgets/historical_character_empty.dart';
import '../widgets/historical_character_error.dart';
import '../widgets/historical_character_loading.dart';

/// Tela principal para exibição, busca e navegação de HistoricalCharacters do CHRONOS.
class HistoricalCharactersScreen extends StatefulWidget {
  final HistoricalCharactersController? controller;

  const HistoricalCharactersScreen({
    super.key,
    this.controller,
  });

  @override
  State<HistoricalCharactersScreen> createState() => _HistoricalCharactersScreenState();
}

class _HistoricalCharactersScreenState extends State<HistoricalCharactersScreen> {
  late final HistoricalCharactersController _controller;
  late final NavigationService _navigationService;
  static const String _tag = 'HistoricalCharactersScreen';
  Map<String, Era> _erasMap = const {};

  @override
  void initState() {
    super.initState();
    ChronosLogger.info('Iniciando ciclo de vida da tela de HistoricalCharacters...', tag: _tag);

    _controller = widget.controller ?? locate<HistoricalCharactersController>();
    _navigationService = locate<NavigationService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadHistoricalCharacters();
      _loadEras();
    });
  }

  Future<void> _loadEras() async {
    try {
      final getAllEras = locate<GetAllErasUseCase>();
      final result = await getAllEras();
      if (result.isSuccess && mounted) {
        final eras = result.valueOrNull ?? [];
        setState(() {
          _erasMap = {for (final e in eras) e.id: e};
        });
      }
    } catch (e) {
      ChronosLogger.error('Erro ao carregar Eras contextuais para os Personagens.', tag: _tag, error: e);
    }
  }

  Future<void> _handleRefresh() async {
    ChronosLogger.info('Disparando atualização manual de historicalCharacters...', tag: _tag);
    await _controller.loadHistoricalCharacters();
    await _loadEras();
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'CHRONOS — Personagens',
      actions: [
        ChronosIconButton(
          tooltip: 'Sincronizar',
          icon: ChronosIcons.sync,
          onPressed: _handleRefresh,
        ),
      ],
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return ChronosPage(
            onRefresh: _handleRefresh,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildBodyContent(),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_controller.isLoading) {
      return const HistoricalCharacterLoading();
    }

    if (_controller.hasError) {
      return HistoricalCharacterError(
        failure: _controller.failure!,
        onRetry: _controller.loadHistoricalCharacters,
      );
    }

    if (_controller.isEmpty) {
      return HistoricalCharacterEmpty(
        onRefresh: _controller.loadHistoricalCharacters,
      );
    }

    final itemsList = _controller.items;
    return ListView.separated(
      itemCount: itemsList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final item = itemsList[index];
        final era = _erasMap[item.eraId];
        return HistoricalCharacterCard(
          item: item,
          era: era,
          onTap: () {
            _navigationService.openHistoricalEvent(arguments: item);
          },
        );
      },
    );
  }
}
