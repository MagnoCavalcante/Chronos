import '../feature_context.dart';
import 'template_builder.dart';

class ReadmeTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''# Módulo de ${context.featurePascal} — CHRONOS

Este módulo gerencia a visualização, carregamento e as regras de negócio associadas aos(às) **${context.featurePascal}** dentro do ecossistema CHRONOS.

## Arquitetura e Estrutura de Pastas

Seguindo estritamente as diretrizes oficiais de **Feature-First** combinada com **Clean Architecture**, a feature está estruturada da seguinte forma:

```text
lib/features/${context.featureName}/
├── data/
│   ├── datasources/
│   │   └── ${context.singularSnake}_remote_datasource.dart       # Conexão direta com SupabaseClient
│   ├── models/
│   │   └── ${context.singularSnake}_model.dart                   # Mapeamento e serialização JSON/Entity
│   └── repositories/
│       └── ${context.singularSnake}_repository_impl.dart         # Implementação concreta de conversões e tratamentos
├── domain/
│   ├── entities/
│   │   └── ${context.singularSnake}.dart                         # Entidade de Domínio imutável e pura
│   ├── repositories/
│   │   └── ${context.singularSnake}_repository.dart              # Interface abstrata do repositório
│   └── usecases/
│       └── get_${context.featureName}_usecase.dart                 # Caso de uso de responsabilidade única
├── presentation/
│   ├── controllers/
│   │   └── ${context.featureName}_controller.dart                 # Gerenciamento de estado reativo via ChangeNotifier
│   ├── screens/
│   │   └── ${context.featureName}_screen.dart                     # UI construída em Material 3 e ListenableBuilder
│   └── widgets/
│       ├── ${context.singularSnake}_card.dart                    # Cartão visual para listagem
│       ├── ${context.featureName}_empty.dart                      # Renderização do estado vazio
│       ├── ${context.featureName}_error.dart                      # Renderização do estado de erro com Retry
│       └── ${context.featureName}_loading.dart                    # Feedback visual com Skeleton Loading animado
├── di/
│   └── ${context.featureName}_di.dart                             # Módulo isolado de injeção de dependências
├── routes/
│   └── ${context.featureName}_routes.dart                         # Registro isolado de caminhos e rotas nominais
└── tests/                                                # Conjunto de testes unitários
```

## Fluxo de Execução

1. **Inicialização**: A tela `${context.featurePascal}Screen` resolve seu `${context.featurePascal}Controller` via `ServiceLocator` no `initState`.
2. **Carregamento**: No pós-frame, o método `load${context.featurePascal}` do controller é acionado.
3. **Casos de Uso**: O controller aciona o `Get${context.featurePascal}UseCase` que solicita dados ao `${context.singularPascal}Repository`.
4. **Infraestrutura**: A implementação concreta `${context.singularPascal}RepositoryImpl` busca dados na fonte remota `${context.singularPascal}RemoteDataSource` usando Supabase.
5. **Reatividade**: O controller recebe o `Result<List<${context.singularPascal}>>`, atualiza o estado interno e emite `notifyListeners()`, re-renderizando os componentes da interface visual.
''';
  }
}
