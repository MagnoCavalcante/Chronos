import 'package:flutter/material.dart';

class CivilizationsEmpty extends StatelessWidget {
  final VoidCallback onRefresh;

  const CivilizationsEmpty({
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
            const Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum registro encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ainda não existem itens publicados ou ativos nesta categoria.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Sincronizar'),
            ),
          ],
        ),
      ),
    );
  }
}
