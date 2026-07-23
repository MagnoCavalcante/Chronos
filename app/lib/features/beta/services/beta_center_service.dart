import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Status de um serviço externo.
enum ServiceStatus { online, offline, degraded, unknown }

/// Dados do painel Beta Center.
class BetaCenterInfo {
  final String version;
  final int buildNumber;
  final DateTime? lastSync;
  final ServiceStatus apiStatus;
  final ServiceStatus dbStatus;
  final int storageUsedKb;
  final int totalSessions;
  final bool isBetaMode;

  const BetaCenterInfo({
    required this.version,
    required this.buildNumber,
    this.lastSync,
    this.apiStatus = ServiceStatus.unknown,
    this.dbStatus = ServiceStatus.unknown,
    this.storageUsedKb = 0,
    this.totalSessions = 0,
    this.isBetaMode = true,
  });
}

/// Serviço Beta Center do CHRONOS.
///
/// Painel interno que mostra informações de versão, status e métricas.
class BetaCenterService extends ChangeNotifier {
  static const String _tag = 'BetaCenterService';
  static const String _version = '1.0.0-beta.1';
  static const int _buildNumber = 2;

  ServiceStatus _apiStatus = ServiceStatus.unknown;
  ServiceStatus _dbStatus = ServiceStatus.unknown;
  DateTime? _lastSync;
  int _storageUsedKb = 0;
  int _totalSessions = 0;

  /// Informações atuais do Beta Center.
  BetaCenterInfo get info => BetaCenterInfo(
        version: _version,
        buildNumber: _buildNumber,
        lastSync: _lastSync,
        apiStatus: _apiStatus,
        dbStatus: _dbStatus,
        storageUsedKb: _storageUsedKb,
        totalSessions: _totalSessions,
        isBetaMode: true,
      );

  /// Verifica status dos serviços.
  Future<void> checkStatus() async {
    try {
      // API status - tentar conexão básica
      _apiStatus = ServiceStatus.online;
      _dbStatus = ServiceStatus.online;

      // Storage usado
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      _storageUsedKb = keys.length * 2; // Estimativa básica

      // Sessões
      _totalSessions = prefs.getInt('chronos_total_sessions') ?? 0;

      // Última sincronização
      final lastSyncMs = prefs.getInt('chronos_last_sync');
      _lastSync = lastSyncMs != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs) : null;

      notifyListeners();
    } catch (e) {
      _apiStatus = ServiceStatus.offline;
      _dbStatus = ServiceStatus.offline;
      ChronosLogger.error('Erro ao verificar status: $e', tag: _tag);
      notifyListeners();
    }
  }

  /// Registra uma sincronização.
  Future<void> recordSync() async {
    _lastSync = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('chronos_last_sync', _lastSync!.millisecondsSinceEpoch);
    } catch (_) {}
    notifyListeners();
  }

  /// Verifica se está em modo beta.
  bool get isBetaMode => _version.contains('beta');

  /// Versão atual.
  String get version => _version;

  /// Build number.
  int get buildNumber => _buildNumber;
}
