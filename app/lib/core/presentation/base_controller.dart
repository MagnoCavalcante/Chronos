import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:flutter/foundation.dart';

/// Estados possíveis que uma View pode assumir ao interagir com o [BaseController].
enum ViewState {
  /// Estado inicial, quando nenhuma operação foi executada ainda.
  initial,

  /// Carregamento completo da tela ou busca de dados inicial.
  loading,

  /// Operação concluída com sucesso e dados válidos disponíveis.
  success,

  /// Operação concluída com sucesso, porém o resultado é uma lista/mapa vazia.
  empty,

  /// Erro/falha na execução de alguma regra de negócio.
  error,

  /// Atualização de dados que já existem na tela em segundo plano.
  refreshing,
}

/// Encapsula de forma imutável todo o estado de uma View gerenciada pelo [BaseController].
class ViewStatus<T> {
  /// Estado atual da View.
  final ViewState state;

  /// Dados encapsulados pela View.
  final T? data;

  /// Falha/erro estruturado encapsulado, caso o estado seja [ViewState.error].
  final Failure? error;

  /// Momento de atualização do estado.
  final DateTime timestamp;

  /// Tempo gasto na última operação de carregamento.
  final Duration loadingTime;

  const ViewStatus({
    required this.state,
    this.data,
    this.error,
    required this.timestamp,
    this.loadingTime = Duration.zero,
  });

  /// Retorna se o estado atual é o inicial.
  bool get isInitial => state == ViewState.initial;

  /// Retorna se o estado atual é de carregamento inicial.
  bool get isLoading => state == ViewState.loading;

  /// Retorna se o estado atual é de sucesso.
  bool get isSuccess => state == ViewState.success;

  /// Retorna se o estado atual é vazio.
  bool get isEmpty => state == ViewState.empty;

  /// Retorna se o estado atual possui falha/erro.
  bool get isError => state == ViewState.error;

  /// Retorna se o estado atual é de atualização em segundo plano.
  bool get isRefreshing => state == ViewState.refreshing;

  /// Cria uma cópia deste status permitindo atualizar propriedades seletivamente.
  ViewStatus<T> copyWith({
    ViewState? state,
    T? data,
    Failure? error,
    DateTime? timestamp,
    Duration? loadingTime,
  }) {
    return ViewStatus<T>(
      state: state ?? this.state,
      data: data ?? this.data,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
      loadingTime: loadingTime ?? this.loadingTime,
    );
  }
}

/// Base abstrata para todos os controladores da camada de apresentação (Presentation Layer) do CHRONOS.
///
/// ### Papel na Clean Architecture:
/// Fica localizado na camada de **Presentation**, sendo responsável por interagir diretamente com
/// os Casos de Uso (Domain Layer), gerenciar o estado da UI de forma imutável e avisar os componentes visuais.
///
/// Oferece recursos nativos como:
/// - Gerenciamento robusto e unificado de estados ([ViewState]) e dados reativos ([ViewStatus]).
/// - Execução segura de operações assíncronas ([execute]) com log automático e medição de tempo de performance.
/// - Proteção automática contra vazamento de memória e chamadas a [notifyListeners] após descarte ([dispose]).
/// - Cancelamento de concorrência ou operações antigas quando uma nova operação é iniciada.
abstract class BaseController<T> extends ChangeNotifier {
  late ViewStatus<T> _status;
  bool _isDisposed = false;
  int _operationCount = 0;

  BaseController({T? initialData}) {
    _status = ViewStatus<T>(
      state: ViewState.initial,
      data: initialData,
      timestamp: DateTime.now(),
    );
  }

  /// Retorna o estado completo da View.
  ViewStatus<T> get status => _status;

  /// Retorna o estado simplificado da View.
  ViewState get state => _status.state;

  /// Retorna os dados encapsulados pela View.
  T? get data => _status.data;

  /// Retorna o erro/falha, se houver.
  Failure? get error => _status.error;

  /// Facilitadores de verificação de estado.
  bool get isInitial => _status.isInitial;
  bool get isLoading => _status.isLoading;
  bool get isSuccess => _status.isSuccess;
  bool get isEmpty => _status.isEmpty;
  bool get isError => _status.isError;
  bool get isRefreshing => _status.isRefreshing;

  bool get hasError => error != null;
  bool get hasData => data != null;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _operationCount++; // Desativa e invalida qualquer execução assíncrona pendente
    super.dispose();
  }

  /// Limpa erros ativos e retorna ao estado mais coerente (initial ou success).
  void clearError() {
    if (hasError) {
      _status = _status.copyWith(
        state: _status.data == null ? ViewState.initial : ViewState.success,
        error: null,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Reinicia o estado do controlador.
  void reset({T? initialData}) {
    _operationCount++;
    _status = ViewStatus<T>(
      state: ViewState.initial,
      data: initialData,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  /// Executa uma ação de negócio encapsulando-a sob o ciclo de vida do controlador.
  ///
  /// Gerencia os estados de carregamento iniciais e secundários, mede o tempo de processamento,
  /// trata exceções inesperadas mapeando-as para [UnknownFailure] e loga todas as transições com o [ChronosLogger].
  Future<Result<T>> execute(
    Future<Result<T>> Function() operation, {
    String tag = 'BaseController',
  }) async {
    final operationId = ++_operationCount;
    final isRefresh = state == ViewState.success || state == ViewState.empty;

    _status = _status.copyWith(
      state: isRefresh ? ViewState.refreshing : ViewState.loading,
      error: null,
      timestamp: DateTime.now(),
    );
    notifyListeners();

    ChronosLogger.info(
      'Iniciando execução de operação assíncrona (isRefresh: $isRefresh)...',
      tag: tag,
    );

    final stopwatch = Stopwatch()..start();
    Result<T> result;

    try {
      result = await operation();
    } catch (e, stackTrace) {
      ChronosLogger.error(
        'Exceção inesperada capturada durante a execução da operação: $e',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );
      result = Result.failure(UnknownFailure(
        'Exceção inesperada na camada de apresentação: $e',
        originalError: e,
      ));
    }

    stopwatch.stop();

    // Proteção de concorrência ou destruição de recursos
    if (_isDisposed || operationId != _operationCount) {
      ChronosLogger.info(
        'Operação descartada: controlador descartado ou operação substituída.',
        tag: tag,
      );
      return result;
    }

    final elapsed = stopwatch.elapsed;

    result.fold(
      onSuccess: (value) {
        final isDataEmpty = _isCollectionEmpty(value);
        _status = ViewStatus<T>(
          state: isDataEmpty ? ViewState.empty : ViewState.success,
          data: value,
          timestamp: DateTime.now(),
          loadingTime: elapsed,
        );

        int count = 0;
        if (value is Iterable) {
          count = value.length;
        } else if (value is Map) {
          count = value.length;
        }

        ChronosLogger.info(
          'Operação concluída com sucesso! Estado: ${state.name} | Tempo: ${elapsed.inMilliseconds}ms${count > 0 ? " | Itens: $count" : ""}',
          tag: tag,
        );
      },
      onFailure: (failure) {
        _status = ViewStatus<T>(
          state: ViewState.error,
          data: _status.data, // Mantém dados anteriores para fins de otimismo visual
          error: failure,
          timestamp: DateTime.now(),
          loadingTime: elapsed,
        );

        ChronosLogger.error(
          'Falha na execução da operação: ${failure.message} | Tempo: ${elapsed.inMilliseconds}ms',
          tag: tag,
          error: failure.originalError,
        );
      },
    );

    notifyListeners();
    return result;
  }

  /// Executa novamente a última operação de carregamento.
  /// Deve ser implementado pelas subclasses para orquestrar o comportamento de retry.
  Future<void> retry() async {
    ChronosLogger.info('Método retry acionado no controlador base.', tag: 'BaseController');
  }

  /// Executa um refresh dos dados.
  /// Deve ser implementado pelas subclasses para orquestrar o comportamento de refresh.
  Future<void> refresh() async {
    ChronosLogger.info('Método refresh acionado no controlador base.', tag: 'BaseController');
  }

  bool _isCollectionEmpty(dynamic value) {
    if (value == null) return true;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}
