import 'package:flutter/material.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/presentation/widgets/chronos_card.dart';
import 'package:chronos/core/presentation/widgets/chronos_chip.dart';
import 'package:chronos/core/presentation/widgets/chronos_icon_button.dart';
import 'package:chronos/core/presentation/widgets/chronos_text_field.dart';
import 'package:chronos/core/theme/chronos_colors.dart';
import 'package:chronos/core/theme/chronos_spacing.dart';
import 'package:chronos/core/theme/chronos_typography.dart';
import 'package:chronos/core/presentation/widgets/chronos_snackbar.dart';
import '../../domain/entities/ai_entities.dart';
import '../controllers/conversation_controller.dart';

/// Tela do assistente inteligente Chronos AI.
///
/// Permite fazer perguntas históricas, escolher modos de resposta,
/// visualizar sugestões, citações e entidades relacionadas.
class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  late final ConversationController _controller;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = locate<ConversationController>();
    _controller.addListener(_onStateChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    FocusScope.of(context).unfocus();
    _controller.ask(text);
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ChronosColors.surface,
        title: Text('Limpar histórico?', style: ChronosTypography.titleLarge),
        content: Text(
          'Todas as perguntas e respostas serão removidas. Favoritos também serão perdidos.',
          style: ChronosTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: AppBar(
        backgroundColor: ChronosColors.surface,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: ChronosColors.border, width: 1.0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chronos AI',
              style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              state.currentMode.label,
              style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ChronosIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Limpar histórico',
            onPressed: _confirmClear,
          ),
          const SizedBox(width: ChronosSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModeSelector(state.currentMode),
            Expanded(
              child: _buildMessages(state),
            ),
            if (state.error != null) _buildError(state.error!),
            _buildSuggestions(state.suggestions),
            _buildInputArea(state.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(AiMode current) {
    return Container(
      color: ChronosColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AiMode.values.map((mode) {
            return Padding(
              padding: const EdgeInsets.only(right: ChronosSpacing.sm),
              child: ChronosChip(
                label: mode.label,
                isSelected: current == mode,
                onTap: () => _controller.setMode(mode),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessages(ConversationState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(ChronosSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_fix_high_rounded, color: ChronosColors.accent, size: 48),
              const SizedBox(height: ChronosSpacing.md),
              Text(
                'Pergunte qualquer coisa sobre História',
                style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ChronosSpacing.sm),
              Text(
                'O Chronos AI busca primeiro no acervo histórico e, quando necessário, complementa com IA.',
                style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.isLoading && index == 0) {
          return _buildLoadingBubble();
        }
        final message = state.messages[state.isLoading ? index - 1 : index];
        return _buildMessagePair(message);
      },
    );
  }

  Widget _buildMessagePair(ConversationMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              margin: const EdgeInsets.only(left: ChronosSpacing.xxl),
              padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.sm),
              decoration: BoxDecoration(
                color: ChronosColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.question,
                style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textOnAccent),
              ),
            ),
          ),
          const SizedBox(height: ChronosSpacing.sm),
          _buildAssistantCard(message.response, message.id),
        ],
      ),
    );
  }

  Widget _buildAssistantCard(AiResponse response, String messageId) {
    return ChronosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                response.usedExternalAi ? Icons.cloud_done_outlined : Icons.storage_rounded,
                color: response.usedExternalAi ? ChronosColors.info : ChronosColors.success,
                size: 16,
              ),
              const SizedBox(width: ChronosSpacing.xs),
              Text(
                response.usedExternalAi ? 'Resposta com IA externa' : 'Resposta do acervo Chronos',
                style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textSecondary),
              ),
              const Spacer(),
              if (response.latency != null)
                Text(
                  '${response.latency!.inMilliseconds}ms',
                  style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: ChronosSpacing.sm),
          Text(
            response.text,
            style: ChronosTypography.bodyMedium.copyWith(height: 1.5),
          ),
          if (response.citations.isNotEmpty) ...[
            const SizedBox(height: ChronosSpacing.md),
            Text('Fontes', style: ChronosTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: ChronosSpacing.xs),
            Wrap(
              spacing: ChronosSpacing.sm,
              runSpacing: ChronosSpacing.xs,
              children: response.citations.map((c) => ChronosChip(
                label: c.title,
                leadingIcon: Icons.menu_book_rounded,
                onTap: () => _showEntityInfo(c.title),
              )).toList(),
            ),
          ],
          if (response.relatedEntities.isNotEmpty) ...[
            const SizedBox(height: ChronosSpacing.md),
            Text('Relacionados', style: ChronosTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: ChronosSpacing.xs),
            Wrap(
              spacing: ChronosSpacing.sm,
              runSpacing: ChronosSpacing.xs,
              children: response.relatedEntities.map((e) => ChronosChip(
                label: e.title,
                leadingIcon: _iconForEntityType(e.entityType),
                onTap: () => _showEntityInfo(e.title),
              )).toList(),
            ),
          ],
          const SizedBox(height: ChronosSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChronosIconButton(
                icon: Icons.star_border_rounded,
                tooltip: 'Favoritar',
                onPressed: () => _controller.toggleFavorite(messageId),
              ),
              const SizedBox(width: ChronosSpacing.xs),
              ChronosIconButton(
                icon: Icons.push_pin_outlined,
                tooltip: 'Fixar',
                onPressed: () => _controller.togglePin(messageId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ChronosCard(
          padding: const EdgeInsets.all(ChronosSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: ChronosColors.accent),
              ),
              const SizedBox(width: ChronosSpacing.sm),
              Text('Consultando acervo...', style: ChronosTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      color: ChronosColors.error.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: ChronosColors.error),
          const SizedBox(width: ChronosSpacing.sm),
          Expanded(
            child: Text(error, style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      color: ChronosColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você também pode perguntar...',
            style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textSecondary),
          ),
          const SizedBox(height: ChronosSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestions.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: ChronosSpacing.sm),
                  child: ChronosChip(
                    label: s,
                    onTap: () => _controller.selectSuggestion(s),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isLoading) {
    return Container(
      color: ChronosColors.surface,
      padding: const EdgeInsets.fromLTRB(
        ChronosSpacing.md,
        ChronosSpacing.sm,
        ChronosSpacing.md,
        ChronosSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: ChronosTextField(
              controller: _textController,
              hintText: 'Pergunte sobre História...',
              prefixIcon: Icons.chat_bubble_outline_rounded,
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: ChronosColors.accent),
                      onPressed: _send,
                    ),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForEntityType(String entityType) {
    switch (entityType) {
      case 'historical_character':
        return Icons.person_rounded;
      case 'historical_event':
        return Icons.history_edu_rounded;
      case 'civilization':
        return Icons.account_balance_rounded;
      case 'artifact':
        return Icons.museum_rounded;
      case 'historical_location':
        return Icons.public_rounded;
      case 'historical_source':
        return Icons.menu_book_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  void _showEntityInfo(String title) {
    ChronosSnackBar.show(context, message: 'Abrir detalhes de "$title" (Sprint futura).');
  }
}
