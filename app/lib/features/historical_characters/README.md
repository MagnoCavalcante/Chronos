# Módulo de HistoricalCharacters — CHRONOS

Este módulo gerencia a visualização, carregamento e as regras de negócio associadas aos(às) **HistoricalCharacters** dentro do ecossistema CHRONOS.

## Arquitetura e Estrutura de Pastas

Seguindo estritamente as diretrizes oficiais de **Feature-First** combinada com **Clean Architecture**, a feature está estruturada da seguinte forma:

```text
lib/features/historical_characters/
├── data/
│   ├── datasources/
│   │   └── historical_character_remote_datasource.dart       # Conexão direta com SupabaseClient
│   ├── models/
│   │   └── historical_character_model.dart                   # Mapeamento e serialização JSON/Entity
│   └── repositories/
│       └── historical_character_repository_impl.dart         # Implementação concreta de conversões e tratamentos
├── domain/
│   ├── entities/
│   │   └── historical_character.dart                         # Entidade de Domínio imutável e pura
│   ├── repositories/
│   │   └── historical_character_repository.dart              # Interface abstrata do repositório
│   └── usecases/
│       └── get_historical_characters_usecase.dart                 # Caso de uso de responsabilidade única
├── presentation/
│   ├── controllers/
│   │   └── historical_characters_controller.dart                 # Gerenciamento de estado reativo via ChangeNotifier
│   ├── screens/
│   │   └── historical_characters_screen.dart                     # UI construída em Material 3 e ListenableBuilder
│   └── widgets/
│       ├── historical_character_card.dart                    # Cartão visual para listagem
│       ├── historical_characters_empty.dart                      # Renderização do estado vazio
│       ├── historical_characters_error.dart                      # Renderização do estado de erro com Retry
│       └── historical_characters_loading.dart                    # Feedback visual com Skeleton Loading animado
├── di/
│   └── historical_characters_di.dart                             # Módulo isolado de injeção de dependências
├── routes/
│   └── historical_characters_routes.dart                         # Registro isolado de caminhos e rotas nominais
└── tests/                                                # Conjunto de testes unitários
```

## Fluxo de Execução

1. **Inicialização**: A tela `HistoricalCharactersScreen` resolve seu `HistoricalCharactersController` via `ServiceLocator` no `initState`.
2. **Carregamento**: No pós-frame, o método `loadHistoricalCharacters` do controller é acionado.
3. **Casos de Uso**: O controller aciona o `GetHistoricalCharactersUseCase` que solicita dados ao `HistoricalCharacterRepository`.
4. **Infraestrutura**: A implementação concreta `HistoricalCharacterRepositoryImpl` busca dados na fonte remota `HistoricalCharacterRemoteDataSource` usando Supabase.
5. **Reatividade**: O controller recebe o `Result<List<HistoricalCharacter>>`, atualiza o estado interno e emite `notifyListeners()`, re-renderizando os componentes da interface visual.
