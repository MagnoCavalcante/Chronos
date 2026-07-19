import 'package:flutter/material.dart';
import '../../theme/chronos_spacing.dart';

/// Componente de Página (Page Wrapper) oficial do CHRONOS.
///
/// Encapsula área de segurança (SafeArea), espaçamentos de margem consistentes,
/// suporte embutido para Pull-to-Refresh (recarregar) e uma transição suave de exibição.
class ChronosPage extends StatefulWidget {
  final Widget child;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final Future<void> Function()? onRefresh;

  const ChronosPage({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: ChronosSpacing.lg,
      vertical: ChronosSpacing.md,
    ),
    this.scrollable = false,
    this.onRefresh,
  });

  @override
  State<ChronosPage> createState() => _ChronosPageState();
}

class _ChronosPageState extends State<ChronosPage> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent = widget.child;

    if (widget.padding != null) {
      pageContent = Padding(
        padding: widget.padding!,
        child: pageContent,
      );
    }

    if (widget.scrollable) {
      pageContent = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: pageContent,
      );
    }

    if (widget.onRefresh != null) {
      pageContent = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).cardColor,
        child: widget.scrollable
            ? pageContent
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: pageContent,
                  ),
                ],
              ),
      );
    }

    if (widget.useSafeArea) {
      pageContent = SafeArea(child: pageContent);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: pageContent,
    );
  }
}
