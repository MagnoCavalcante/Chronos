# Módulo de Civilizations — CHRONOS

Este módulo gerencia a visualização, carregamento e as regras de negócio associadas aos(às) **Civilizations** dentro do ecossistema CHRONOS.

## Arquitetura e Estrutura de Pastas

Seguindo estritamente as diretrizes oficiais de **Feature-First** combinada com **Clean Architecture**, a feature está estruturada da seguinte forma:

```text
lib/features/civilizations/
├── data/
│   ├── datasources/
│   │   └── civilization_remote_datasource.dart       # Conexão direta com SupabaseClient
│   ├── models/
│   │   └── civilization_model.dart                   # Mapeamento e serialização JSON/Entity
│   └── repositories/
│       └── civilization_repository_impl.dart         # Implementação concreta de conversões e tratamentos
├── domain/
│   ├── entities/
│   │   └── civilization.dart                         # Entidade de Domínio imutável e pura
│   ├── repositories/
│   │   └── civilization_repository.dart              # Interface abstrata do repositório
│   └── usecases/
│       └── get_civilizations_usecase.dart                 # Caso de uso de responsabilidade única
├── presentation/
│   ├── controllers/
│   │   └── civilizations_controller.dart                 # Gerenciamento de estado reativo via ChangeNotifier
│   ├── screens/
│   │   └── civilizations_screen.dart                     # UI construída em Material 3 e ListenableBuilder
│   └── widgets/
│       ├── civilization_card.dart                    # Cartão visual para listagem
│       ├── civilizations_empty.dart                      # Renderização do estado vazio
│       ├── civilizations_error.dart                      # Renderização do estado de erro com Retry
│       └── civilizations_loading.dart                    # Feedback visual com Skeleton Loading animado
├── di/
│   └── civilizations_di.dart                             # Módulo isolado de injeção de dependências
├── routes/
│   └── civilizations_routes.dart                         # Registro isolado de caminhos e rotas nominais
└── tests/                                                # Conjunto de testes unitários
```

## Fluxo de Execução

1. **Inicialização**: A tela `CivilizationsScreen` resolve seu `CivilizationsController` via `ServiceLocator` no `initState`.
2. **Carregamento**: No pós-frame, o método `loadCivilizations` do controller é acionado.
3. **Casos de Uso**: O controller aciona o `GetCivilizationsUseCase` que solicita dados ao `CivilizationRepository`.
4. **Infraestrutura**: A implementação concreta `CivilizationRepositoryImpl` busca dados na fonte remota `CivilizationRemoteDataSource` usando Supabase.
5. **Reatividade**: O controller recebe o `Result<List<Civilization>>`, atualiza o estado interno e emite `notifyListeners()`, re-renderizando os componentes da interface visual.
