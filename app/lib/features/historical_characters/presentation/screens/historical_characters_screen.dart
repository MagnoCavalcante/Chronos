import 'package:flutter/material.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/domain/entities/era.dart';
import 'package:chronos/domain/usecases/get_all_eras_usecase.dart';
import '../../domain/entities/historical_character.dart';
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
  static const String _tag = 'HistoricalCharactersScreen';
  Map<String, Era> _erasMap = const {};

  @override
  void initState() {
    super.initState();
    ChronosLogger.info('Iniciando ciclo de vida da tela de HistoricalCharacters...', tag: _tag);

    _controller = widget.controller ?? locate<HistoricalCharactersController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadHistoricalCharacters();
      _loadEras();
    });
  }

  @override
  void dispose() {
    ChronosLogger.info('Liberando recursos e saindo da tela de HistoricalCharacters.', tag: _tag);
    super.dispose();
  }

  Future<void> _loadEras() async {
    try {
      final getAllEras = locate<GetAllErasUseCase>();
      final result = await getAllEras();
      if (result.isSuccess) {
        final eras = result.valueOrNull ?? [];
        if (mounted) {
          setState(() {
            _erasMap = {for (final e in eras) e.id: e};
          });
        }
      }
    } catch (e) {
      ChronosLogger.error('Erro ao carregar Eras contextuais para os Personagens.', tag: _tag, error: e);
    }
  }

  Future<void> _handleRefresh() async {
    ChronosLogger.info('Disparando atualização manual de historicalCharacters...', tag: _tag);
    final stopwatch = Stopwatch()..start();
    await _controller.loadHistoricalCharacters();
    await _loadEras();
    stopwatch.stop();
    ChronosLogger.info('Atualização manual de historicalCharacters finalizada em ${stopwatch.elapsedMilliseconds}ms.', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHRONOS — Personagens',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            icon: const Icon(Icons.sync_rounded),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBodyContent(),
              ),
            ],
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
    return RefreshIndicator(
      color: Colors.amberAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        itemCount: itemsList.length,
        itemBuilder: (context, index) {
          final HistoricalCharacter item = itemsList[index];
          final era = _erasMap[item.eraId];
          return HistoricalCharacterCard(
            item: item,
            era: era,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Visualizando detalhes do item "${item.nome}".'),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
