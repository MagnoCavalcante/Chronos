import 'package:flutter/material.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/utils/logger.dart';
import '../../domain/entities/civilization.dart';
import '../controllers/civilizations_controller.dart';
import '../widgets/civilization_card.dart';
import '../widgets/civilizations_empty.dart';
import '../widgets/civilizations_error.dart';
import '../widgets/civilizations_loading.dart';

/// Tela principal para exibição, busca e navegação de Civilizations do CHRONOS.
class CivilizationsScreen extends StatefulWidget {
  final CivilizationsController? controller;

  const CivilizationsScreen({
    super.key,
    this.controller,
  });

  @override
  State<CivilizationsScreen> createState() => _CivilizationsScreenState();
}

class _CivilizationsScreenState extends State<CivilizationsScreen> {
  late final CivilizationsController _controller;
  static const String _tag = 'CivilizationsScreen';

  @override
  void initState() {
    super.initState();
    ChronosLogger.info('Iniciando ciclo de vida da tela de Civilizations...', tag: _tag);

    _controller = widget.controller ?? locate<CivilizationsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadCivilizations();
    });
  }

  @override
  void dispose() {
    ChronosLogger.info('Liberando recursos e saindo da tela de Civilizations.', tag: _tag);
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ChronosLogger.info('Disparando atualização manual de civilizations...', tag: _tag);
    final stopwatch = Stopwatch()..start();
    await _controller.loadCivilizations();
    stopwatch.stop();
    ChronosLogger.info('Atualização manual de civilizations finalizada em ${stopwatch.elapsedMilliseconds}ms.', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHRONOS — Civilizations',
          style: const TextStyle(
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
      return const CivilizationsLoading();
    }

    if (_controller.hasError) {
      return CivilizationsError(
        failure: _controller.failure!,
        onRetry: _controller.loadCivilizations,
      );
    }

    if (_controller.isEmpty) {
      return CivilizationsEmpty(
        onRefresh: _controller.loadCivilizations,
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
          final Civilization item = itemsList[index];
          return CivilizationCard(
            item: item,
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
