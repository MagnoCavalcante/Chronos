import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/di/service_locator.dart';
import '../../core/navigation/navigation_service.dart';
import '../../core/navigation/route_names.dart';
import '../../core/utils/logger.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  bool _isFlutterInitialized = false;
  bool _isSupabaseInitialized = false;
  String? _errorMessage;
  String _targetUrl = '';

  // Estados adicionais para teste real de conectividade
  bool _isNetworkChecking = false;
  bool _hasNetworkSuccess = false;
  String? _networkErrorType; // 'network_dns' | 'auth_failed' | 'sdk_uninitialized' | null
  String? _networkDetailMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _performNetworkCheck();
  }

  void _checkStatus() {
    // Se o initState foi chamado e este widget foi renderizado, o Flutter iniciou com sucesso.
    _isFlutterInitialized = true;
    _isSupabaseInitialized = SupabaseConfig.isInitialized;
    _errorMessage = SupabaseConfig.initializationError;
    _targetUrl = SupabaseConfig.supabaseUrl;
  }

  Future<void> _performNetworkCheck() async {
    if (!_isSupabaseInitialized) {
      setState(() {
        _networkErrorType = 'sdk_uninitialized';
        _networkDetailMessage = 'O cliente local do Supabase não pôde ser inicializado.';
      });
      return;
    }

    setState(() {
      _isNetworkChecking = true;
      _hasNetworkSuccess = false;
      _networkErrorType = null;
      _networkDetailMessage = null;
    });

    try {
      // Forçamos um round-trip real tentando ler da tabela 'eras'
      await SupabaseConfig.client.from('eras').select().limit(1);
      
      setState(() {
        _isNetworkChecking = false;
        _hasNetworkSuccess = true;
        _networkDetailMessage = 'Conexão estabelecida com sucesso. Resposta recebida do servidor.';
      });
    } on PostgrestException catch (e) {
      setState(() {
        _isNetworkChecking = false;
        final status = int.tryParse(e.code ?? '') ?? 0;
        if (status == 401 || status == 403 || e.message.toLowerCase().contains('jwt') || e.message.toLowerCase().contains('invalid api key')) {
          _networkErrorType = 'auth_failed';
          _networkDetailMessage = 'Erro de Autenticação.\nCódigo de status: ${e.code ?? status}\nMensagem: ${e.message}';
        } else {
          _hasNetworkSuccess = true;
          _networkDetailMessage = 'Autenticação bem-sucedida (Anon Key aceita pelo servidor).\nCódigo de resposta: ${e.code ?? status} (${e.message})';
        }
      });
    } catch (e) {
      setState(() {
        _isNetworkChecking = false;
        _networkErrorType = 'network_dns';
        _networkDetailMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color emeraldGreen = Color(0xFF10B981);
    final navigationService = locate<NavigationService>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Dark cosmic canvas
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minimalist visual logo accent with status halo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _hasNetworkSuccess
                        ? emeraldGreen.withValues(alpha: 0.08)
                        : (_isNetworkChecking
                            ? Colors.cyanAccent.withValues(alpha: 0.08)
                            : Colors.redAccent.withValues(alpha: 0.08)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _hasNetworkSuccess
                          ? emeraldGreen.withValues(alpha: 0.3)
                          : (_isNetworkChecking
                              ? Colors.cyanAccent.withValues(alpha: 0.3)
                              : Colors.redAccent.withValues(alpha: 0.3)),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _hasNetworkSuccess
                        ? Icons.cloud_done_outlined
                        : (_isNetworkChecking
                            ? Icons.swap_calls_rounded
                            : Icons.cloud_off_outlined),
                    size: 64,
                    color: _hasNetworkSuccess
                        ? emeraldGreen
                        : (_isNetworkChecking
                            ? Colors.cyanAccent
                            : Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Typography Pairing
                const Text(
                  'CHRONOS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Validação da Infraestrutura Real',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Connection status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.5), // Slate 800 with transparency
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATUS DA INFRAESTRUTURA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 1. Flutter State
                      Row(
                        children: [
                          Icon(
                            _isFlutterInitialized ? Icons.check_circle : Icons.error,
                            color: _isFlutterInitialized ? emeraldGreen : Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '✅ Flutter iniciado',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 2. Supabase State
                      Row(
                        children: [
                          Icon(
                            _isSupabaseInitialized ? Icons.check_circle : Icons.cancel,
                            color: _isSupabaseInitialized ? emeraldGreen : Colors.redAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isSupabaseInitialized ? '✅ Supabase inicializado' : '❌ Falha na inicialização do Supabase',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 3. Network Connection state
                      Row(
                        children: [
                          if (_isNetworkChecking)
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                              ),
                            )
                          else
                            Icon(
                              _hasNetworkSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                              color: _hasNetworkSuccess
                                  ? emeraldGreen
                                  : (_networkErrorType == 'auth_failed'
                                      ? Colors.orangeAccent
                                      : Colors.redAccent),
                              size: 22,
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isNetworkChecking
                                  ? '⏳ Testando conectividade real...'
                                  : (_hasNetworkSuccess
                                      ? '⚡ Conectividade Real OK (Round-trip ativo)'
                                      : (_networkErrorType == 'auth_failed'
                                          ? '⚠️ Chave Anon inválida/rejeitada'
                                          : '❌ Erro de Rede/DNS ou Servidor offline')),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_errorMessage != null) ...[
                        const Divider(height: 32, color: Colors.white10),
                        const Text(
                          'DETALHES DO ERRO DE INICIALIZAÇÃO:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],

                      if (_networkDetailMessage != null) ...[
                        const Divider(height: 24, color: Colors.white10),
                        Text(
                          _hasNetworkSuccess ? 'DETALHES DE CONECTIVIDADE:' : 'DETALHES DO ERRO DE CONEXÃO:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _hasNetworkSuccess ? emeraldGreen : (_networkErrorType == 'auth_failed' ? Colors.orangeAccent : Colors.redAccent),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_hasNetworkSuccess ? emeraldGreen : (_networkErrorType == 'auth_failed' ? Colors.orangeAccent : Colors.redAccent)).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: (_hasNetworkSuccess ? emeraldGreen : (_networkErrorType == 'auth_failed' ? Colors.orangeAccent : Colors.redAccent)).withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            _networkDetailMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: _hasNetworkSuccess ? emeraldGreen : (_networkErrorType == 'auth_failed' ? Colors.orangeAccent : Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão para re-testar conectividade
                ElevatedButton.icon(
                  onPressed: _isNetworkChecking ? null : _performNetworkCheck,
                  icon: _isNetworkChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Testar Conexão Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ChronosLogger.info('Navegando para o módulo de Eras via NavigationService...', tag: 'Navigation');
                    navigationService.openEra();
                  },
                  icon: const Icon(Icons.explore_outlined, color: Colors.cyanAccent),
                  label: const Text('Visualizar Módulo de Eras'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.cyanAccent, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ChronosLogger.info('Navegando para Eventos Históricos via NavigationService...', tag: 'Navigation');
                    navigationService.openHistoricalEvent();
                  },
                  icon: const Icon(Icons.history_toggle_off_rounded, color: Colors.amberAccent),
                  label: const Text('Visualizar Eventos Históricos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.amberAccent, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ChronosLogger.info('Navegando para Personagens Históricos via NavigationService...', tag: 'Navigation');
                    navigationService.openHistoricalCharacter();
                  },
                  icon: const Icon(Icons.people_alt_outlined, color: Colors.purpleAccent),
                  label: const Text('Visualizar Personagens Históricos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.purpleAccent, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ChronosLogger.info('Navegando para Civilizações via NavigationService...', tag: 'Navigation');
                    navigationService.openCivilization();
                  },
                  icon: const Icon(Icons.gavel_rounded, color: Colors.greenAccent),
                  label: const Text('Visualizar Civilizações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.greenAccent, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Environmental configuration documentation card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.link, color: Colors.blueAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Endpoint de Conexão Ativo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.white10),
                      Text(
                        _targetUrl,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Tech badge footer
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.terminal, color: Colors.grey, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'SUPABASE SPRINT 3.2 ACTIVE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
