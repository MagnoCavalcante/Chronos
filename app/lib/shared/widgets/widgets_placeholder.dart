import 'package:flutter/material.dart';

/// Componentes de Interface de Usuário Reutilizáveis (Shared Widgets)
/// 
/// Contém componentes visuais globais compartilhados entre diferentes módulos do app.
/// Garante consistência visual no Design System e reaproveitamento de código.
class ChronosButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ChronosButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
