import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/era.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_all_eras_usecase.dart';
import '../../domain/usecases/get_historical_events_usecase.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para a listagem de Eventos Históricos.
///
/// ### Papel na Clean Architecture:
/// Localizado exclusivamente na camada de **Presentation**, o controller atua adaptando
/// as respostas dos Casos de Uso ([GetHistoricalEventsUseCase]) do domínio para o estado
/// visual que os Widgets consomem.
///
/// - **Isolamento de Infraestrutura**: Não possui acoplamentos com detalhes físicos (como Supabase, SQL, JSON ou Models).
/// - **Princípio de Inversão de Dependência (DIP)**: Depende unicamente do caso de uso abstrato injetado no construtor.
/// - **Gerenciamento de Estado Reativo**: Estende [ChangeNotifier], notificando a interface gráfica de usuário (UI)
///   apenas quando mudanças reais de estado ocorrem, otimizando renderizações.
class HistoricalEventsController extends ChangeNotifier {
  final GetHistoricalEventsUseCase _getHistoricalEventsUseCase;
  final GetAllErasUseCase _getAllErasUseCase;

  List<HistoricalEvent> _events = const [];
  Map<String, Era> _erasMap = const {};
  bool _isLoading = false;
  Failure? _failure;

  /// Inicializa o [HistoricalEventsController] injetando opcionalmente o Caso de Uso correspondente.
  ///
  /// Caso nenhuma dependência de UseCase seja fornecida, utiliza o [ServiceLocator] para resolução.
  HistoricalEventsController({
    GetHistoricalEventsUseCase? useCase,
    GetAllErasUseCase? getAllErasUseCase,
  })  : _getHistoricalEventsUseCase = useCase ?? locate<GetHistoricalEventsUseCase>(),
        _getAllErasUseCase = getAllErasUseCase ?? locate<GetAllErasUseCase>();

  /// Retorna a lista imutável dos Eventos Históricos carregados atualmente no estado.
  List<HistoricalEvent> get events => List.unmodifiable(_events);

  /// Retorna o mapa imutável de ID de Era para a entidade [Era].
  Map<String, Era> get erasMap => Map.unmodifiable(_erasMap);

  /// Retorna o estado atual de carregamento do controller.
  bool get isLoading => _isLoading;

  /// Retorna a última falha comercial capturada, caso ocorra alguma.
  Failure? get failure => _failure;

  /// Indica se o controller possui algum erro registrado no momento.
  bool get hasError => _failure != null;

  /// Indica se o estado atual possui dados de eventos válidos e não está em carregamento.
  bool get hasData => _events.isNotEmpty && !_isLoading;

  /// Indica se a lista está vazia, o carregamento terminou e não há erros.
  bool get isEmpty => _events.isEmpty && !_isLoading && !hasError;

  /// Executa a busca reativa de todos os Eventos Históricos publicados e ativos.
  ///
  /// Modifica reativamente o estado interno de carregamento, erros e dados, emitindo
  /// notificações cirúrgicas para sincronizar com a árvore de componentes da UI.
  Future<void> loadEvents() async {
    ChronosLogger.info('Iniciando o carregamento de todos os Eventos Históricos...', tag: 'HistoricalEventsController');
    _setLoading(true);
    _clearErrorInternal();

    final stopwatch = Stopwatch()..start();

    // Primeiro carrega as Eras de forma paralela ou sequencial para poder resolver relacionamentos
    final erasResult = await _getAllErasUseCase();
    if (erasResult.isSuccess) {
      final eras = erasResult.valueOrNull ?? [];
      final tempErasMap = <String, Era>{};
      for (final era in eras) {
        tempErasMap[era.id] = era;
      }
      _erasMap = tempErasMap;
    }

    final result = await _getHistoricalEventsUseCase();
    stopwatch.stop();

    result.fold(
      onSuccess: (data) {
        _events = List.unmodifiable(data);
        _failure = null;
        ChronosLogger.info(
          'Eventos históricos carregados com sucesso! Total: ${_events.length}. Tempo: ${stopwatch.elapsedMilliseconds}ms',
          tag: 'HistoricalEventsController',
        );
      },
      onFailure: (falha) {
        _failure = falha;
        ChronosLogger.error(
          'Falha ao carregar eventos históricos: ${falha.message}',
          tag: 'HistoricalEventsController',
          error: falha.originalError,
        );
      },
    );

    _setLoading(false);
  }

  /// Limpa explicitamente qualquer estado de erro remanescente no controller.
  void clearError() {
    if (_failure != null) {
      _clearErrorInternal();
      notifyListeners();
    }
  }

  /// Define o estado de carregamento de forma limpa e notifica os ouvintes da UI.
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Limpa o erro interno sem emitir notificação imediata de forma concorrente.
  void _clearErrorInternal() {
    _failure = null;
  }
}
