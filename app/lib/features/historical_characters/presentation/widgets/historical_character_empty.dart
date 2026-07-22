import 'package:flutter/material.dart';

/// Componente visual dedicado para exibição de estado vazio na listagem de Personagens Históricos.
class HistoricalCharacterEmpty extends StatelessWidget {
  final VoidCallback onRefresh;

  const HistoricalCharacterEmpty({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum registro encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ainda não existem personagens históricos publicados ou ativos neste período ou categoria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
}
