# CHRONOS — Padrão Oficial de Arquitetura de Features
## Versão 2.0.0 (Sprint 4.2.0 - Core Foundation Refactored)

Este documento define e congela a arquitetura oficial para todas as novas funcionalidades do ecossistema **CHRONOS**. Ele serve como padrão obrigatório e modelo de referência para guiar os engenheiros na expansão do projeto para as próximas entidades (Eventos, Personagens, Civilizações, Artefatos, Fontes, Localizações e Relações).

**Mudanças na v2.0.0**: Introdução da infraestrutura base centralizada (`core/base/`) para eliminar duplicação e consolidar padrões arquiteturais. Todas as novas features devem utilizar as classes base: `BaseEntity`, `BaseModel<T>`, `BaseRepository<T>`, `BaseRemoteDatasource<T>`, `BaseUseCase<Output, Input>`, e `BaseController`.

---

## 1. Estrutura Oficial de Pastas (Padrão de Feature)

Cada nova funcionalidade dentro do ecossistema móvel CHRONOS (baseado em Flutter e Clean Architecture) deve ser dividida em camadas rígidas de isolamento no diretório `lib/`. A feature **Eras** serve como o padrão ouro:

```text
lib/
├── core/                         # Infraestrutura compartilhada transversal
│   ├── base/                     # INFRAESTRUTURA BASE CENTRALIZADA (v2.0.0)
│   │   ├── base_entity.dart      # Entidade base com atributos comuns (id, active, createdAt, updatedAt)
│   │   ├── base_model.dart       # Modelo base com contrato de serialização (fromJson, toJson, toEntity, fromEntity)
│   │   ├── base_repository.dart  # Repositório base com operações CRUD padrão (getAll, getById, delete, save, update)
│   │   ├── base_remote_datasource.dart # DataSource base com tratamento centralizado de erros e logging
│   │   ├── base_usecase.dart     # UseCase base com logging e tratamento de erros centralizado
│   │   └── base_controller.dart  # Re-export do BaseController existente (state management)
│   ├── di/                       # Injeção de dependências e Service Locator
│   │   └── service_locator.dart  # Registro central de Singletons e Factories
│   ├── errors/                   # Tratamento padronizado de erros e falhas
│   │   ├── exceptions.dart       # Exceções técnicas físicas (camada de dados)
│   │   └── failure.dart          # Falhas abstratas de negócio (camada de domínio)
│   ├── presentation/             # Apresentação base
│   │   └── base_controller.dart # Controller base com state management reativo
│   └── utils/                    # Utilitários de sistema puros
│       ├── logger.dart           # Logger centralizado do sistema (ChronosLogger)
│       └── result.dart           # Mônada de controle funcional (Result<T>)
│
├── domain/                       # Camada de Domínio (Pureza total de negócios)
│   ├── entities/                 # Entidades puras (Ex: era.dart, event.dart) - DEVEM EXTENDER BaseEntity
│   ├── repositories/             # Contratos de interfaces abstratas dos repositórios - DEVEM EXTENDER BaseRepository<T>
│   └── usecases/                 # Casos de uso específicos (SRP, Callable Classes) - DEVEM EXTENDER BaseUseCase<Output, Input>
│
├── data/                         # Camada de Dados (Persistência e Infraestrutura física)
│   ├── datasources/              # Pontes de dados (Abstração e Implementação) - DEVEM EXTENDER BaseRemoteDatasource<T>
│   ├── models/                   # Modelos físicos de dados (Ex: era_model.dart) - DEVEM IMPLEMENTAR BaseModel<T>
│   └── repositories/             # Implementações concretas dos repositórios de domínio
│
├── presentation/                 # Camada de Apresentação (Interface visual e reatividade)
│   ├── controllers/              # Gerenciadores de estado reativo (ChangeNotifier/Controller) - DEVEM EXTENDER BaseController
│   └── screens/                  # Widgets e telas completas de UI (Flutter puro)
│
└── main.dart                     # Inicialização do Flutter, Supabase e Service Locator
```

---

## 2. Fluxo de Execução & Regra de Dependências (End-to-End)

O fluxo de dados do ecossistema CHRONOS segue uma estrutura estritamente **unidirecional** e **desacoplada**. Conforme a regra de dependência da Clean Architecture, as camadas externas dependem de abstrações das camadas internas; **a camada de Domínio nunca conhece nada sobre as camadas de Apresentação ou Dados**.

```text
  [ Camada de Apresentação ]
         UI (Screens) <== ListenableBuilder ==> Controller (ChangeNotifier)
                                                       ||
                                                       || (Resolve & Invoca)
                                                       \/
  [ Camada de Domínio ]
                                            UseCase (Caso de Uso puro)
                                                       ||
                                                       || (Depende de)
                                                       \/
                                            Repository (Contrato / Interface)
                                                       ||
                                                       || (Implementado por)
                                                       \/
  [ Camada de Dados ]
                                            RepositoryImpl (Mapeia e Trata)
                                                       ||
                                                       || (Consome)
                                                       \/
                                            RemoteDataSource (Abstração / Implementação)
                                                       ||
                                                       || (Consultas Relacionais)
                                                       \/
                                            Supabase Client / PostgreSQL
```

### Mecanismo de Segurança de Camadas:
1. **Erros**: Se uma falha física de rede/banco acontecer no `RemoteDataSource` (que extende `BaseRemoteDatasource<T>`), ele dispara uma exceção técnica `ServerException` com tratamento centralizado de logging e mapeamento de erros.
2. **Result**: O `RepositoryImpl` intercepta a `ServerException`, faz o logging via `ChronosLogger` (já centralizado no base), mapeia-a para um domínio de erro `Failure` (ex: `NetworkFailure`), e encapsula a resposta na mônada funcional `Result.failure(failure)`.
3. **Sem Exceptions na UI**: O `UseCase` (que extende `BaseUseCase<Output, Input>`) repassa o `Result<T>` intacto com logging centralizado. O `Controller` recebe o `Result` e usa `.fold()` para atualizar reativamente a lista em caso de sucesso, ou exibir uma mensagem limpa amigável ao usuário em caso de falha, sem nunca arriscar travar a aplicação por exceções não tratadas.

---

## 3. Infraestrutura Base Centralizada (v2.0.0)

A versão 2.0.0 introduz classes base em `core/base/` para eliminar duplicação e consolidar padrões arquiteturais. Todas as novas features DEVEM utilizar estas classes base.

### 3.1 BaseEntity
- **Propósito**: Centralizar atributos comuns a todas as entidades de domínio
- **Atributos**: `id` (String), `active` (bool), `createdAt` (DateTime), `updatedAt` (DateTime)
- **Benefícios**: Elimina duplicação de código, garante consistência, fornece igualdade por valor baseada em `id`
- **Uso**: Todas as entidades de domínio devem extender `BaseEntity`

```dart
class Era extends BaseEntity {
  final String nome;
  final String descricao;
  // ... outros atributos específicos

  const Era({
    required super.id,
    required super.active,
    required super.createdAt,
    required super.updatedAt,
    required this.nome,
    required this.descricao,
    // ...
  });
}
```

### 3.2 BaseModel<T>
- **Propósito**: Definir contrato padrão para serialização e conversão de modelos
- **Métodos**: `fromJson()`, `toJson()`, `toEntity()`, `fromEntity()`
- **Benefícios**: Garante consistência na conversão JSON/Entity, elimina duplicação
- **Uso**: Todos os modelos de dados devem implementar `BaseModel<T>`

```dart
class EraModel extends Era implements BaseModel<Era> {
  @override
  factory EraModel.fromJson(Map<String, dynamic> json) {
    return EraModel(
      id: json['id'] as String,
      active: json['ativo'] as bool,
      // ...
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ativo': active,
      // ...
    };
  }

  @override
  Era toEntity() {
    return Era(
      id: id,
      active: active,
      // ...
    );
  }

  @override
  factory EraModel.fromEntity(Era entity) {
    return EraModel(
      id: entity.id,
      active: entity.active,
      // ...
    );
  }
}
```

### 3.3 BaseRepository<T>
- **Propósito**: Definir operações CRUD padrão para repositórios
- **Métodos**: `getAll()`, `getById()`, `delete()`, `save()`, `update()`
- **Benefícios**: Padroniza interface de repositórios, garante consistência
- **Uso**: Todos os contratos de repositório devem extender `BaseRepository<T>`

```dart
abstract class EraRepository extends BaseRepository<Era> {
  Future<Result<List<Era>>> getAllEras();
  // Métodos CRUD padrão já herdados de BaseRepository<Era>
}
```

### 3.4 BaseRemoteDatasource<T>
- **Propósito**: Centralizar tratamento de erros, logging e gerenciamento de Supabase client
- **Funcionalidades**: Tratamento automático de erros de rede, autenticação, banco de dados; logging centralizado; método `executeWithErrorHandling()`
- **Benefícios**: Elimina duplicação de tratamento de erros, garante consistência de logging
- **Uso**: DataSources com operações padrão devem extender `BaseRemoteDatasource<T>` e implementar `fetchData()`

```dart
class EraRemoteDataSourceImpl extends BaseRemoteDatasource<EraModel>
    implements EraRemoteDataSource {
  EraRemoteDataSourceImpl({SupabaseClient? client})
      : super(
          client: client ?? SupabaseConfig.client,
          tag: 'EraRemoteDataSource',
        );

  @override
  Future<List<EraModel>> fetchData() async {
    final response = await client.from('eras').select();
    throwIfEmpty(response, 'Era');
    return response.map((item) => EraModel.fromJson(item)).toList();
  }

  @override
  Future<List<EraModel>> getAllEras() async {
    return executeWithErrorHandling();
  }
}
```

### 3.5 BaseUseCase<Output, Input>
- **Propósito**: Centralizar logging e tratamento de erros em casos de uso
- **Métodos**: `call()` (público), `execute()` (abstrato, implementado por subclasses)
- **Benefícios**: Elimina duplicação de logging e tratamento de erros, garante consistência
- **Uso**: Todos os casos de uso devem extender `BaseUseCase<Output, Input>`

```dart
class GetAllErasUseCase extends BaseUseCase<List<Era>, void> {
  final EraRepository repository;

  GetAllErasUseCase(this.repository);

  @override
  Future<Result<List<Era>>> execute(void input) async {
    return await repository.getAllEras();
  }
}
```

### 3.6 BaseController
- **Propósito**: Fornecer state management reativo com operações assíncronas padronizadas
- **Funcionalidades**: Gerenciamento de estado (`ViewStatus`, `ViewState`), execução de operações assíncronas com logging, proteção contra concorrência, notificação reativa
- **Benefícios**: Elimina duplicação de lógica de state management, garante consistência
- **Uso**: Todos os controllers devem extender `BaseController`

```dart
class ErasController extends BaseController<List<Era>> {
  final GetAllErasUseCase getAllErasUseCase;

  ErasController(this.getAllErasUseCase);

  Future<void> loadEras() async {
    final result = await execute(() => getAllErasUseCase());
    // Tratamento do resultado
  }
}
```

---

## 4. Responsabilidades de Cada Camada

### A. Domínio (Domain) - *O Coração do Aplicativo*
- **Entities**: Objetos puramente lógicos que representam conceitos reais de negócios. **DEVEM EXTENDER `BaseEntity`**. Devem usar `const`, imutabilidade, e não conter referências a bibliotecas, frameworks ou parsers de dados (sem JSON/Supabase). A igualdade estrutural é fornecida por `BaseEntity`.
- **Repositories (Interfaces)**: Declaram as operações que o negócio exige. **DEVEM EXTENDER `BaseRepository<T>`**. Definem o contrato conceitual (o "que" fazer), garantindo que as regras não saibam "como" os dados são armazenados. Operações CRUD padrão são herdadas automaticamente.
- **UseCases**: Classes de finalidade única (SRP) e focadas (Callable Classes com o método `call()`). **DEVEM EXTENDER `BaseUseCase<Output, Input>`**. Contêm as regras de processo do aplicativo. Logging e tratamento de erros são centralizados na classe base.

### B. Dados (Data) - *A Conexão com o Mundo Físico*
- **Models**: Extensões diretas das entidades de domínio. **DEVEM IMPLEMENTAR `BaseModel<T>`**. Responsáveis pela serialização/deserialização (`fromJson`, `toJson`) e conversão segura bidirecional de e para entidades puras de negócio (`toEntity()` e `fromEntity()`). O contrato é garantido pela interface base.
- **DataSources**: Interfaces e implementações que interagem diretamente com drivers externos ou APIs (Supabase). Para operações padrão, **DEVEM EXTENDER `BaseRemoteDatasource<T>`**. Lançam exceções físicas estruturadas (`ServerException`) com tratamento centralizado de logging e mapeamento de erros.
- **Repositories (Implementações)**: Implementam as interfaces de domínio. São os portões de segurança: chamam os DataSources, traduzem modelos físicos para entidades de domínio imutáveis e convertem exceções cruas para `Failure`s seguros encapsulados no tipo `Result<T>`.

### C. Apresentação (Presentation) - *A Experiência Visual Reativa*
- **Controllers**: Classes que mantêm o estado dinâmico da tela e reagem aos inputs do usuário. **DEVEM EXTENDER `BaseController`**. Disparam Casos de Uso e consomem o retorno via padrão `Result<T>`. Logging, tratamento de erros e gerenciamento de estado são centralizados na classe base.
- **Screens**: Widgets de visualização completos de tela. Consomem instâncias de controllers obtidas exclusivamente via `locate<Controller>()` do `ServiceLocator`. Não possuem lógica de tratamento de dados de baixo nível.

---

## 5. Convenções Oficiais de Nomenclatura

Para manter a consistência em um projeto de larga escala com múltiplas entidades futuras, as convenções abaixo de nomenclatura e sintaxe de arquivos são obrigatórias:

| Elemento Arquitetural | Sufixo Recomendado | Exemplo Real (Eras) | Exemplo Futuro (Eventos) |
| :--- | :--- | :--- | :--- |
| **Arquivo de Entidade** | `[nome_singular].dart` | `era.dart` | `event.dart` |
| **Classe de Entidade** | `[NomeCamelCase]` | `class Era` | `class Event` |
| **Arquivo de Modelo** | `[nome_singular]_model.dart` | `era_model.dart` | `event_model.dart` |
| **Classe de Modelo** | `[NomeCamelCase]Model` | `class EraModel` | `class EventModel` |
| **Interface DataSource** | `[nome_singular]_remote_datasource.dart` | `era_remote_datasource.dart` | `event_remote_datasource.dart` |
| **Classe DataSource** | `[NomeCamelCase]RemoteDataSourceImpl` | `class EraRemoteDataSourceImpl` | `class EventRemoteDataSourceImpl` |
| **Contrato Repositório**| `[nome_singular]_repository.dart` | `era_repository.dart` | `event_repository.dart` |
| **Classe Repositório** | `[NomeCamelCase]RepositoryImpl` | `class EraRepositoryImpl` | `class EventRepositoryImpl` |
| **Caso de Uso (Arquivo)**| `[acao]_[entidade_plural]_usecase.dart` | `get_all_eras_usecase.dart` | `get_events_by_era_usecase.dart` |
| **Caso de Uso (Classe)** | `[Acao][EntidadePlural]UseCase` | `class GetAllErasUseCase` | `class GetEventsByEraUseCase` |
| **Controller (Arquivo)** | `[entidade_plural]_controller.dart` | `eras_controller.dart` | `events_controller.dart` |
| **Controller (Classe)** | `[EntidadePlural]Controller` | `class ErasController` | `class EventsController` |
| **Screen (Arquivo)** | `[entidade_plural]_screen.dart` | `eras_screen.dart` | `events_screen.dart` |
| **Screen (Classe)** | `[EntidadePlural]Screen` | `class ErasScreen` | `class EventsScreen` |

---

## 6. Sequência Recomendada de Implementação de uma Feature

Ao expandir o ecossistema CHRONOS com uma nova entidade (ex: **Eventos**), o desenvolvedor deve seguir rigorosamente a sequência de construção de baixo para alto nível de forma a garantir testes constantes e integridade modular:

```text
Passo 1: Banco de Dados ──────> Passo 2: Domínio ─────────> Passo 3: Dados ──────────> Passo 4: Apresentação
(Migration + Seeds SQL)     (Entity + Repository Intf)    (Model + DataSource + Impl)   (Controller + Screens)
```

1. **Camada de Infraestrutura Relacional**:
   - Criar e executar a migração SQL (`/database/migrations/`) definindo tabelas, RLS e índices.
   - Criar os dados iniciais fundamentais via scripts de sementes (`/database/seeds/` ou migrações equivalentes).
2. **Camada de Domínio (Sem Dependências)**:
   - Criar os Enums conceituais e a **Entidade** pura de negócio **EXTENDENDO `BaseEntity`**.
   - Criar o contrato abstrato do **Repository EXTENDENDO `BaseRepository<T>`** contendo os retornos envelopados na mônada `Result<T>`.
   - Implementar os **UseCases EXTENDENDO `BaseUseCase<Output, Input>`** focados herdando a interface do repositório.
3. **Camada de Dados**:
   - Implementar o **Model IMPLEMENTANDO `BaseModel<T>`** de persistência adicionando `fromJson`, `toJson`, `toEntity()` e `fromEntity()`.
   - Definir a interface e implementação concreta do **RemoteDataSource EXTENDENDO `BaseRemoteDatasource<T>`** (para operações padrão) com acesso ao cliente do Supabase.
   - Implementar o **RepositoryImpl**, adicionando conversões de entidades e tratamento seguro de exceções de infraestrutura (usando `ServerException` centralizado).
4. **Camada de Apresentação & Integração**:
   - Implementar o **Controller EXTENDENDO `BaseController`**, orquestrando estados reativos com o uso de `ChronosLogger` e `Result`.
   - Registrar todas as novas classes criadas no método `setupServiceLocator()` do `/lib/core/di/service_locator.dart`.
   - Construir a tela de UI (**Screen**) resolvendo o controller reativo através do atalho global `locate<Controller>()`.

---

## 7. Checklist de Qualidade Obrigatório (DoD - Definition of Done)

Nenhuma feature de entidade do CHRONOS deve ser dada como concluída sem antes certificar a conformidade completa de todos os seguintes itens:

### ☑ Infraestrutura Relacional (Banco de Dados)
- [ ] **Migration**: Tabela criada com chaves primárias UUID geradas automaticamente pelo banco, slugs indexadas de forma única, e triggers automáticas de atualização para `updated_at`.
- [ ] **RLS (Row Level Security)**: Ativado para a nova tabela no Supabase, garantindo que consultas públicas (`SELECT`) sejam liberadas anonimamente, mas operações de escrita sejam restritas a administradores ou vetadas na aplicação móvel padrão.
- [ ] **Seed**: Sementes históricas mínimas oficiais populadas com idempotência (`ON CONFLICT (slug) DO UPDATE`).

### ☑ Camada de Domínio (Business Core)
- [ ] **Entity**: Totalmente imutável, livre de qualquer importação de terceiros, serializadores ou pacotes de dados. **DEVE EXTENDER `BaseEntity`**. Igualdade estrutural por valor fornecida pela classe base.
- [ ] **Repository Interface**: **DEVE EXTENDER `BaseRepository<T>`** para herdar operações CRUD padrão.
- [ ] **UseCase**: Focado em um único propósito comercial, estruturado como callable class (`call()`). **DEVE EXTENDER `BaseUseCase<Output, Input>`** para logging e tratamento de erros centralizados. Retorno encapsulado em `Result<T>`.

### ☑ Camada de Dados (Infrastructure & Persistence)
- [ ] **Model**: Isolado e estendendo a entidade correspondente. **DEVE IMPLEMENTAR `BaseModel<T>`**. Serializadores `fromJson`, `toJson`, `toEntity()` e `fromEntity()` perfeitamente tipados com tratamentos preventivos para valores numéricos e enums de banco de dados.
- [ ] **DataSource**: Abstraído por interface e isolando o acesso direto às chamadas REST ou Supabase SDK. Para operações padrão, **DEVE EXTENDER `BaseRemoteDatasource<T>`**. Captura e dispara unicamente exceções tipadas unificadas (`ServerException`) com tratamento centralizado de logging e mapeamento de erros.
- [ ] **RepositoryImpl**: Atua como o limitador de vazamentos de dados. Captura as exceções do DataSource de forma segura, gera logs explicativos consistentes via `ChronosLogger` e envelopa o retorno para a camada de negócios em objetos limpos de tipo `Result<T>`.

### ☑ Camada de Apresentação (UI & Reatividade)
- [ ] **Controller**: **DEVE EXTENDER `BaseController`**. Utiliza o estado reativo sem re-renderizações cíclicas infinitas. Logging, tratamento de erros e gerenciamento de estado são centralizados na classe base.
- [ ] **Service Locator**: Todas as novas classes estão cadastradas corretamente em `setupServiceLocator()` respeitando seus tempos de vida (`LazySingleton` para fontes e repositórios; `Factory` para controllers e instâncias transitórias).
- [ ] **Screen**: Widget limpo e livre de lógica pesada de controle de rede ou persistência. Resolve suas dependências de forma limpa usando a função atalho `locate<Controller>()` e monitora estados usando `ListenableBuilder` de forma cirúrgica.

### ☑ Qualidade & Compilação Geral
- [ ] **Imports**: Sem caminhos absolutos locais incorretos e sem importações cruzadas inadequadas (camadas internas nunca importam camadas externas).
- [ ] **Linter**: Execução de `flutter analyze` sem nenhum aviso ou erro (requer Flutter/Dart no PATH).
- [ ] **Compilação**: Build de produção limpo obtendo sucesso total.
