import 'package:flutter/material.dart';

/// Telas Compartilhadas (Shared Screens)
/// 
/// Agrupa interfaces completas de telas reutilizáveis de suporte,
/// como telas de erro genérico, telas de carregamento global,
/// modais de onboarding ou manutenção do sistema.
class ChronosErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ChronosErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
