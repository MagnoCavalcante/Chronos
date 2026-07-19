import 'package:flutter/foundation.dart';
import 'package:chronos/core/di/service_locator.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/core/utils/logger.dart';
import 'package:chronos/core/utils/result.dart';
import '../../domain/entities/civilization.dart';
import '../../domain/usecases/get_civilizations_usecase.dart';

/// Controller da camada de Apresentação (Presentation Layer) encarregado do
/// gerenciamento de estado e fluxo de dados reativos para Civilizations.
class CivilizationsController extends ChangeNotifier {
  final GetCivilizationsUseCase _getCivilizationsUseCase;

  List<Civilization> _items = const [];
  bool _isLoading = false;
  Failure? _failure;

  CivilizationsController({
    GetCivilizationsUseCase? useCase,
  }) : _getCivilizationsUseCase = useCase ?? locate<GetCivilizationsUseCase>();

  List<Civilization> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  bool get hasError => _failure != null;
  bool get hasData => _items.isNotEmpty && !_isLoading;
  bool get isEmpty => _items.isEmpty && !_isLoading && !hasError;

  Future<void> loadCivilizations() async {
    ChronosLogger.info('Iniciando o carregamento de Civilizations...', tag: 'CivilizationsController');
    _setLoading(true);
    _clearErrorInternal();

    final stopwatch = Stopwatch()..start();
    final result = await _getCivilizationsUseCase();
    stopwatch.stop();

    result.fold(
      onSuccess: (data) {
        _items = List.unmodifiable(data);
        _failure = null;
        ChronosLogger.info(
          'Civilizations carregados(as) com sucesso! Total: ${_items.length}. Tempo: ${stopwatch.elapsedMilliseconds}ms',
          tag: 'CivilizationsController',
        );
      },
      onFailure: (falha) {
        _failure = falha;
        ChronosLogger.error(
          'Falha ao carregar civilizations: ${falha.message}',
          tag: 'CivilizationsController',
          error: falha.originalError,
        );
      },
    );

    _setLoading(false);
  }

  void clearError() {
    if (_failure != null) {
      _clearErrorInternal();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _clearErrorInternal() {
    _failure = null;
  }
}
