import 'package:flutter/material.dart';
import 'chronos_button.dart';
import 'chronos_dialog.dart';

/// Diálogo de Confirmação padronizado do CHRONOS.
///
/// Apresenta uma pergunta simples ao usuário com botões claros de confirmação e cancelamento,
/// retornando um [bool] assíncrono para a tela invocadora.
abstract class ChronosConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await ChronosDialog.show<bool>(
      context,
      title: title,
      content: Text(message),
      actions: [
        ChronosButton(
          label: cancelLabel,
          variant: ChronosButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ChronosButton(
          label: confirmLabel,
          variant: ChronosButtonVariant.primary,
          customColor: isDestructive ? Theme.of(context).colorScheme.error : null,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    return result ?? false;
  }
}
