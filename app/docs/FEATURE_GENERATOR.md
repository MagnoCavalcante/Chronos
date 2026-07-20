# CHRONOS — Feature Generator
## Version 2.0.0 (Sprint 4.2.0 - Core Foundation Integration)

Este documento descreve a arquitetura, utilização, extensibilidade e diretrizes de manutenção do **CHRONOS Feature Generator**, uma ferramenta oficial de engenharia de software interna projetada para acelerar a inicialização de novas frentes de produto, garantindo 100% de conformidade com os padrões arquiteturais congelados do ecossistema.

**Mudanças na v2.0.0**: O gerador agora gera features que utilizam a infraestrutura base centralizada (`core/base/`), incluindo BaseEntity, BaseModel<T>, BaseRepository<T>, BaseRemoteDatasource<T>, BaseUseCase<Output, Input>, e BaseController.

---

## 1. Fluxo Completo de Execução

O gerador segue uma sequência rígida e previsível para garantir a integridade da arquitetura da aplicação:

1. **Validação de Entrada**: O script principal verifica a presença do nome da feature em formato snake_case como argumento da linha de comando.
2. **Análise de Contexto Semântico (`FeatureContext`)**: O nome fornecido é processado para derivar termos singulares/plurais em formatos Camel, Pascal e Snake case.
3. **Criação da Árvore de Diretórios**: Todas as subpastas da feature (`data`, `domain`, `presentation`, `di`, `routes`, `tests`, etc.) são criadas recursivamente.
4. **Construção de Templates**: Instâncias do `TemplateBuilder` geram o boilerplate do código de cada camada com as substituições semânticas necessárias.
5. **Gravação dos Arquivos**: Os arquivos de código Dart, scripts SQL de migração e sementes (seed), testes automatizados e o README local são escritos em disco.
6. **Injeção de Código Cirúrgica (Surgical Injection)**: 
   - Insere a importação e registra as dependências da nova feature em `lib/core/di/service_locator.dart`.
   - Insere a importação e registra as rotas no mapa central em `lib/core/navigation/app_routes.dart`.
7. **Confirmação Visual**: Exibe o log consolidado com os arquivos gerados e as confirmações de injeção estática.

---

## 2. Estrutura de Diretórios e Arquivos Gerados

Cada execução do gerador produz uma estrutura de pastas e arquivos estritamente acoplada aos princípios de Feature-Driven Development (FDD) e Clean Architecture:

```text
lib/features/<nome_da_feature>/
├── README.md                       # Documentação local da feature e do caso de uso
├── di/
│   └── <nome_da_feature>_di.dart   # Injeção e ServiceLocator local do módulo
├── routes/
│   └── <nome_da_feature>_routes.dart # Catálogo de rotas e mapeamento nominal local
├── domain/
│   ├── entities/
│   │   └── <singular_snake>.dart   # Entidades puras e imutáveis EXTENDENDO BaseEntity
│   ├── repositories/
│   │   └── <singular_snake>_repository.dart # Interface abstrata EXTENDENDO BaseRepository<T>
│   └── usecases/
│       └── get_<nome_da_feature>_usecase.dart # Casos de uso EXTENDENDO BaseUseCase<Output, Input>
├── data/
│   ├── datasources/
│   │   └── <singular_snake>_remote_datasource.dart # Contrato de infraestrutura externa EXTENDENDO BaseRemoteDatasource<T>
│   ├── models/
│   │   └── <singular_snake>_model.dart # Serialização JSON IMPLEMENTANDO BaseModel<T>
│   ├── repositories/
│   │   └── <singular_snake>_repository_impl.dart # Implementação concreta com tratamento de Result<T>
│   ├── migrations/
│   │   └── migration.sql           # Template DDL SQL para criação de tabela
│   └── seeds/
│       └── seed.sql                # Template DML SQL para alimentação da tabela
├── presentation/
│   ├── controllers/
│   │   └── <nome_da_feature>_controller.dart # Gerenciamento de estado reativo EXTENDENDO BaseController
│   ├── screens/
│   │   └── <nome_da_feature>_screen.dart # Interface em conformidade com Material 3
│   └── widgets/
│       ├── <singular_snake>_card.dart # Exibição individual do registro
│       ├── <nome_da_feature>_loading.dart # Componente visual de esqueleto de carregamento
│       ├── <nome_da_feature>_error.dart # Componente visual para tratamento amigável de falhas
│       └── <nome_da_feature>_empty.dart # Componente visual para estado sem dados
└── tests/
    ├── <singular_snake>_entity_test.dart # Testes de cópia, imutabilidade e igualdade
    ├── <singular_snake>_model_test.dart # Testes de serialização e desserialização JSON
    ├── <singular_snake>_repository_test.dart # Testes de comportamento do repositório sob Result<T>
    └── <nome_da_feature>_controller_test.dart # Testes de comportamento do controle reativo
```

---

## 3. Como Utilizar e Regenerar

Para inicializar ou atualizar uma feature existente, execute o comando de execução na raiz do diretório `app`:

```bash
# Executar a partir de `/app/applet/app`
dart run tool/generate_feature.dart <nome_da_feature>
```

### Exemplos:
```bash
dart run tool/generate_feature.dart historical_characters
```

### Instruções de Regeneração:
- **Sobrescrita Segura**: O gerador foi projetado de forma idempotente para arquivos de template de código; se você modificar os templates base e executar o gerador novamente, ele irá reescrever os arquivos sob a feature.
- **Detecção de Duplicados**: Para as injeções estáticas em `service_locator.dart` e `app_routes.dart`, o gerador faz uma verificação estática. Se a chamada de registro (ex: `HistoricalCharactersDI.register();`) ou o spread de rotas (ex: `...HistoricalCharactersRoutes.routes`) já estiverem presentes nos arquivos centrais, o gerador os ignora, evitando duplicidade e mantendo a formatação intacta.
- **Limpeza de Recursos**: Se uma feature precisa ser descontinuada ou completamente redefinida de forma limpa, remova a pasta física da feature sob `lib/features/` e as chamadas correspondentes inseridas nos arquivos centrais antes de executar a nova geração.

---

## 4. Templates e Classes Base (v2.0.0)

O gerador v2.0.0 gera templates que utilizam automaticamente as classes base do `core/base/`. A seguir estão os padrões de geração para cada camada:

### 4.1 Template de Entidade (Entity)
As entidades geradas automaticamente extendem `BaseEntity` e incluem os atributos comuns (`id`, `active`, `createdAt`, `updatedAt`):

```dart
import 'package:chronos/core/base/base_entity.dart';

class {{singularPascal}} extends BaseEntity {
  final String nome;

  const {{singularPascal}}({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.nome,
  });

  @override
  {{singularPascal}} copyWith({
    String? id,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nome,
  }) {
    return {{singularPascal}}(
      id: id ?? this.id,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nome: nome ?? this.nome,
    );
  }
}
```

### 4.2 Template de Modelo (Model)
Os modelos gerados implementam `BaseModel<T>` e incluem todos os métodos de serialização:

```dart
import 'package:chronos/core/base/base_model.dart';
import '../entities/{{singularSnake}}.dart';

class {{singularPascal}}Model extends {{singularPascal}} implements BaseModel<{{singularPascal}}> {
  @override
  factory {{singularPascal}}Model.fromJson(Map<String, dynamic> json) {
    return {{singularPascal}}Model(
      id: json['id'] as String,
      active: json['ativo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nome: json['nome'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ativo': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nome': nome,
    };
  }

  @override
  {{singularPascal}} toEntity() {
    return {{singularPascal}}(
      id: id,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nome: nome,
    );
  }

  @override
  factory {{singularPascal}}Model.fromEntity({{singularPascal}} entity) {
    if (entity is {{singularPascal}}Model) return entity;
    return {{singularPascal}}Model(
      id: entity.id,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nome: entity.nome,
    );
  }
}
```

### 4.3 Template de Repositório (Repository Interface)
As interfaces de repositório extendem `BaseRepository<T>` para herdar operações CRUD padrão:

```dart
import 'package:chronos/core/base/base_repository.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/{{singularSnake}}.dart';

abstract class {{singularPascal}}Repository extends BaseRepository<{{singularPascal}}> {
  Future<Result<List<{{singularPascal}}>>> getAll{{pluralPascal}}();
}
```

### 4.4 Template de Remote DataSource
Os remote datasources extendem `BaseRemoteDatasource<T>` para tratamento centralizado de erros:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chronos/core/config/supabase_config.dart';
import 'package:chronos/core/base/base_remote_datasource.dart';
import '../models/{{singularSnake}}_model.dart';

class {{singularPascal}}RemoteDataSourceImpl extends BaseRemoteDatasource<{{singularPascal}}Model>
    implements {{singularPascal}}RemoteDataSource {
  {{singularPascal}}RemoteDataSourceImpl({SupabaseClient? client})
      : super(
          client: client ?? SupabaseConfig.client,
          tag: '{{singularPascal}}RemoteDataSource',
        );

  @override
  Future<List<{{singularPascal}}Model>> fetchData() async {
    final response = await client
        .from('{{pluralSnake}}')
        .select()
        .eq('ativo', true);

    throwIfEmpty(response, '{{singularPascal}}');

    return response
        .map((item) => {{singularPascal}}Model.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override'
  Future<List<{{singularPascal}}Model>> getAll{{pluralPascal}}() async {
    return executeWithErrorHandling();
  }
}
```

### 4.5 Template de Use Case
Os casos de uso extendem `BaseUseCase<Output, Input>` para logging centralizado:

```dart
import 'package:chronos/core/base/base_usecase.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/{{singularSnake}}.dart';
import '../repositories/{{singularSnake}}_repository.dart';

class GetAll{{pluralPascal}}UseCase extends BaseUseCase<List<{{singularPascal}}>, void> {
  final {{singularPascal}}Repository repository;

  GetAll{{pluralPascal}}UseCase(this.repository);

  @override
  Future<Result<List<{{singularPascal}}>>> execute(void input) async {
    return await repository.getAll{{pluralPascal}}();
  }
}
```

### 4.6 Template de Controller
Os controllers extendem `BaseController` para state management padronizado:

```dart
import 'package:chronos/core/base/base_controller.dart';
import 'package:chronos/core/utils/result.dart';
import '../entities/{{singularSnake}}.dart';
import '../usecases/get_{{pluralSnake}}_usecase.dart';

class {{pluralPascal}}Controller extends BaseController<List<{{singularPascal}}>> {
  final GetAll{{pluralPascal}}UseCase getAll{{pluralPascal}}UseCase;

  {{pluralPascal}}Controller(this.getAll{{pluralPascal}}UseCase);

  Future<void> load{{pluralPascal}}() async {
    final result = await execute(() => getAll{{pluralPascal}}UseCase());
    result.fold(
      ({{pluralSnake}}) => updateState(ViewState.data({{pluralSnake}})),
      (failure) => updateState(ViewState.error(failure.message)),
    );
  }
}
```

---

## 5. Como Adicionar e Modificar Templates (Manutenção)

O gerador segue rigorosamente o princípio Aberto/Fechado (OCP). Para estender os templates ou criar novas camadas:

1. **Criar um Builder dedicado**: Adicione um arquivo sob `tool/src/template_builders/` estendendo a interface `TemplateBuilder`.
   
   *Exemplo (`tool/src/template_builders/my_custom_builder.dart`)*:
   ```dart
   import '../feature_context.dart';
   import 'template_builder.dart';

   class MyCustomBuilder implements TemplateBuilder {
     @override
     String build(FeatureContext context) {
       return '''// Template customizado para ${context.singularPascal}
// Criado em conformidade com o ecossistema CHRONOS.
// Utiliza classes base do core/base/ conforme v2.0.0
''';
     }
   }
   ```

2. **Expor o Builder**: Registre a exportação do novo arquivo no agregador de exportações `tool/src/template_builders/builders.dart`.

3. **Adicionar ao Sequenciador**: Adicione a gravação do arquivo correspondente dentro do método principal `main` em `/app/tool/generate_feature.dart`:
   ```dart
   _writeFile(
     '$basePath/custom_layer/${context.singularSnake}_custom.dart',
     MyCustomBuilder().build(context),
   );
   ```

4. **Utilizar Classes Base**: Ao criar novos templates, sempre utilize as classes base apropriadas:
   - Entidades: `extends BaseEntity`
   - Modelos: `implements BaseModel<T>`
   - Repositórios: `extends BaseRepository<T>`
   - DataSources: `extends BaseRemoteDatasource<T>` (quando aplicável)
   - UseCases: `extends BaseUseCase<Output, Input>`
   - Controllers: `extends BaseController`

---

## 6. Diretrizes Rigorosas de Desenvolvimento

- **Sintaxe Result<T>**: Todos os métodos expostos na camada de domínio e repositórios devem sempre retornar a estrutura funcional unificada `Result<T>`. O uso de lançamentos de exceção diretos para fora de repositórios ou contratos de interface é estritamente proibido.
- **ChronosLogger**: Os controladores e serviços reativos de apresentação devem encapsular seus registros utilizando a chamada estática `ChronosLogger.info` and `ChronosLogger.error`, garantindo rastreabilidade estruturada. Nas classes base, o logging já é centralizado.
- **Imports Absolutos vs. Relativos**: Em todos os templates, use imports absolutos (`package:chronos/...`) para se referir ao núcleo comum (`core`, `shared`, etc.). Use imports relativos apenas para dependências que estão no mesmo escopo local da feature (dentro de `lib/features/<nome_da_feature>/`).
- **Classes Base Obrigatórias**: Todos os templates DEVEM utilizar as classes base do `core/base/` conforme especificado na seção 4. Não é permitido criar features sem utilizar a infraestrutura base centralizada.
- **ServerException Centralizado**: DataSources devem usar `ServerException` em vez de exceções customizadas. O tratamento de erros é centralizado em `BaseRemoteDatasource<T>`.
