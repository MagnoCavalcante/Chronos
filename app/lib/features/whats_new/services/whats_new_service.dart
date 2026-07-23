import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/whats_new_entities.dart';

/// Serviço "Novidades da Versão" do CHRONOS.
///
/// Após atualização, mostra automaticamente novas funcionalidades, melhorias e correções.
/// Permite não exibir novamente.
class WhatsNewService extends ChangeNotifier {
  static const String _tag = 'WhatsNewService';
  static const String _lastSeenKey = 'chronos_whats_new_last_seen';
  static const String _currentVersion = '6.12.0';

  bool _shouldShow = false;

  /// Se o modal de novidades deve ser exibido.
  bool get shouldShow => _shouldShow;

  /// Versão atual do app.
  String get currentVersion => _currentVersion;

  /// Release notes da versão atual.
  ReleaseNotes get currentRelease => _releases.first;

  /// Verifica se há novidades não vistas.
  Future<void> check() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeen = prefs.getString(_lastSeenKey);
      _shouldShow = lastSeen != _currentVersion;
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao verificar novidades: $e', tag: _tag);
    }
  }

  /// Marca as novidades como vistas.
  Future<void> dismiss() async {
    _shouldShow = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSeenKey, _currentVersion);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar dismiss: $e', tag: _tag);
    }
    notifyListeners();
  }

  /// Reseta para mostrar novamente (configurações).
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSeenKey);
      _shouldShow = true;
    } catch (_) {}
    notifyListeners();
  }

  static final List<ReleaseNotes> _releases = [
    ReleaseNotes(
      version: '6.12.0',
      releaseDate: DateTime(2026, 7, 23),
      items: const [
        WhatsNewItem(
          title: 'UX/UI Premium',
          description: 'Revisão completa da interface com microinterações, shimmer loading e animações suaves.',
          type: WhatsNewItemType.improvement,
        ),
        WhatsNewItem(
          title: 'Onboarding',
          description: 'Introdução guiada ao aplicativo para novos usuários.',
          type: WhatsNewItemType.feature,
        ),
        WhatsNewItem(
          title: 'Dicas Contextuais',
          description: 'Tooltips inteligentes que aparecem na primeira utilização.',
          type: WhatsNewItemType.feature,
        ),
        WhatsNewItem(
          title: 'Design System',
          description: 'Tokens padronizados de elevação, animação e responsividade.',
          type: WhatsNewItemType.improvement,
        ),
        WhatsNewItem(
          title: 'Acessibilidade',
          description: 'Melhorias de contraste, feedback tátil e navegação acessível.',
          type: WhatsNewItemType.improvement,
        ),
      ],
    ),
  ];
}
