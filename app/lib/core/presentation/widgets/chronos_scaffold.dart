import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';

/// Scaffold unificado oficial do ecossistema CHRONOS.
///
/// Encapsula a lógica de Scaffold do Material, garantindo AppBar e background unificados
/// e alinhados aos Design Tokens do projeto.
class ChronosScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;

  const ChronosScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final bool displayBackButton = showBackButton && canPop;

    PreferredSizeWidget? appBar;
    if (title != null || titleWidget != null) {
      appBar = AppBar(
        title: titleWidget ?? Text(title!),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: displayBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
      );
    }

    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }
}
