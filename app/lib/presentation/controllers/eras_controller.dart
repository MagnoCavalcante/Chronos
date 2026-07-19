import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/era.dart';
import '../../domain/usecases/get_all_eras_usecase.dart';

/// Controller da camada de Apresentação (Presentation Layer) responsável pelo
/// gerenciamento de estado e fluxo de dados relacionados à listagem de Eras históricas.
///
/// ### Papel na Clean Architecture:
/// Fica localizado na fronteira da camada de **Presentation**. É o componente que
/// adapta os fluxos de negócios (representados pelos Casos de Uso) para as necessidades
/// específicas da interface gráfica de usuário (UI).
///
/// - **Independência Tecnológica**: Não possui qualquer acoplamento com persistência (Supabase, SQL),
///   modelos físicos (EraModel), fontes de dados ou serializadores (JSON).
/// - **Princípio de Inversão de Dependência (DIP)**: Depende unicamente do caso de uso abstrato
///   [GetAllErasUseCase] injetado externamente, facilitando testes unitários e mocks.
/// - **Gerenciamento de Estado Reativo**: Utiliza o [ChangeNotifier] nativo do Flutter para
///   sinalizar alterações de estado de forma performática e previsível para os ouvintes (Widgets).
class ErasController extends ChangeNotifier {
  final GetAllErasUseCase _getAllErasUseCase;

  List<Era> _eras = const [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Inicializa o [ErasController] injetando de forma obrigatória as suas dependências comerciais.
  ErasController({
    required GetAllErasUseCase getAllErasUseCase,
  }) : _getAllErasUseCase = getAllErasUseCase;

  /// Retorna a lista imutável das Eras carregadas atualmente no estado do controller.
  ///
  /// Garante que nenhuma camada visual externa consiga corromper a coleção interna de dados.
  List<Era> get eras => List.unmodifiable(_eras);

  /// Retorna o estado atual de carregamento do controller.
  bool get isLoading => _isLoading;

  /// Retorna a última mensagem de erro capturada, caso ocorra alguma falha.
  String? get errorMessage => _errorMessage;

  /// Indica se o controller possui algum erro registrado no momento.
  bool get hasError => _errorMessage != null;

  /// Executa a orquestração para recuperar todas as Eras publicadas no ecossistema CHRONOS.
  ///
  /// Modifica reativamente o estado interno de carregamento, erros e dados, emitindo
  /// notificações periódicas para manter a UI sincronizada.
  Future<void> carregarEras() async {
    ChronosLogger.info('Iniciando o carregamento de todas as Eras...', tag: 'ErasController');
    _setLoading(true);
    _clearErrorInternal();

    // Invoca a regra de negócio central através do Caso de Uso obtendo uma mônada Result
    final resultado = await _getAllErasUseCase();
    
    resultado.fold(
      onSuccess: (dados) {
        _eras = List.unmodifiable(dados);
        ChronosLogger.info('Eras carregadas com sucesso! Total: ${_eras.length}', tag: 'ErasController');
      },
      onFailure: (falha) {
        _errorMessage = falha.message;
        ChronosLogger.error('Falha ao obter eras: ${falha.message}', tag: 'ErasController', error: falha.originalError);
      },
    );

    _setLoading(false);
  }

  /// Limpa explicitamente qualquer estado de erro remanescente no controller.
  void clearError() {
    if (_errorMessage != null) {
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
    _errorMessage = null;
  }
}

