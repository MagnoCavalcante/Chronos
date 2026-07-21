# CHRONOS — Padrão de Arquitetura de Features (STANDARD_FEATURE_ARCHITECTURE)

Este documento estabelece o padrão arquitetural oficial para todas as novas funcionalidades (features) integradas ao ecossistema **CHRONOS**. A feature **Historical Events (Eventos Históricos)** foi selecionada e congelada como a nossa **Implementação de Referência (Reference Implementation)**.

Qualquer nova funcionalidade introduzida no projeto deve aderir estritamente a estas convenções para garantir integridade, testabilidade e desacoplamento absoluto.

---

## 1. Fluxo de Dados e Camadas (Clean Architecture)

O fluxo de dados da feature de referência segue rigorosamente o princípio unidirecional e a inversão de dependência:

```text
========================================================================================
                                CAMADA DE APRESENTAÇÃO (UI)
========================================================================================
[ HistoricalEventsScreen ] (Widget) <---> [ HistoricalEventCard / Loading / Empty / Error ]
          │
          │ (Escuta e consome estado)
          ▼
[ HistoricalEventsController ] (ChangeNotifier - Gerenciador de Estado Reativo)
          │
          │ (Invoca)
          ▼
========================================================================================
                                CAMADA DE DOMÍNIO (Pure Dart)
========================================================================================
[ GetHistoricalEventsUseCase ] (Caso de Uso puro de negócio)
          │
          │ (Depende da interface abstrata)
          ▼
[ HistoricalEventRepository ] (Contrato / Interface)
          │
          ▲ (Inversão de Dependência)
          │
========================================================================================
                                CAMADA DE DADOS (Infraestrutura)
========================================================================================
[ HistoricalEventRepositoryImpl ] (Implementação concreta)
          │
          │ (Consome dados físicos)
          ▼
[ HistoricalEventRemoteDataSource ] (Interface do DataSource)
          │
          ▲ (Implementado por)
          │
[ HistoricalEventRemoteDataSourceImpl ] (Acesso físico ao SupabaseClient)
          │
          │ (Chamada remota via Postgrest)
          ▼
[ Supabase / Banco de Dados ] (Camada Física Externa)
```

---

## 2. Exemplo Oficial: Historical Events

Abaixo detalha-se o papel de cada arquivo na nossa implementação de referência:

### A. Domínio (Domain Layer)
1. **Entidade (`Event`)** em `lib/domain/entities/event.dart`:
   - Representação imutável e pura de um evento histórico.
   - Sem acoplamento com dependências do Flutter ou do Supabase.
   - Contém um `typedef HistoricalEvent = Event;` para manter consistência semântica.
2. **Caso de Uso (`GetHistoricalEventsUseCase`)** em `lib/domain/usecases/get_historical_events_usecase.dart`:
   - Coordena a execução da regra de negócio de busca.
   - Invoca a abstração do repositório e retorna um `Result<List<HistoricalEvent>>`.
3. **Contrato do Repositório (`HistoricalEventRepository`)** em `lib/domain/repositories/historical_event_repository.dart`:
   - Interface abstrata definindo a assinatura de busca.

### B. Dados (Data Layer)
1. **Modelo de Persistência (`HistoricalEventModel`)** em `lib/data/models/historical_event_model.dart`:
   - Estende a classe base `Event` do domínio.
   - Responsável único pelas funções `fromJson`, `toJson`, `fromEntity` e `toEntity`.
   - Adiciona propriedades ricas de infraestrutura como `endYear`, `importanceScore`, `eventType` e coordenadas geográficas (`latitude`, `longitude`).
2. **Interface e Implementação do DataSource** em `lib/data/datasources/historical_event_remote_datasource.dart`:
   - `HistoricalEventRemoteDataSource`: Interface contendo a assinatura do método de consulta.
   - `HistoricalEventRemoteDataSourceImpl`: Implementação concreta consumindo `SupabaseClient`. Converte exceções físicas (`PostgrestException`) para a exceção tipada `HistoricalEventDataSourceException`.
3. **Implementação do Repositório (`HistoricalEventRepositoryImpl`)** em `lib/data/repositories/historical_event_repository_impl.dart`:
   - Implementa a interface do domínio.
   - Trata exceções do DataSource e mapeia-as para falhas comerciais puras (`Failure`), encapsulando tudo sob a mônada `Result`.

### C. Apresentação (Presentation Layer)
1. **Controller (`HistoricalEventsController`)** em `lib/presentation/controllers/historical_events_controller.dart`:
   - Gerencia de forma reativa o estado utilizando `ChangeNotifier` e expondo estados granulares (`isLoading`, `failure`, `events`, `erasMap`, `hasError`, `isEmpty`).
   - Evita rebuilds desnecessários através de validações internas.
2. **Telas e Componentes Visuais**:
   - `HistoricalEventsScreen` (`lib/presentation/screens/historical_events_screen.dart`): Tela principal que resolve seu estado no `initState` e renderiza os estados da UI usando `ListenableBuilder`.
   - `HistoricalEventCard` (`lib/presentation/widgets/historical_event_card.dart`): Cartão visual altamente polido que lê metadados temáticos para renderizar cores e ícones dinâmicos.
   - `HistoricalEventsLoading` / `Empty` / `Error` em `lib/presentation/widgets/`: Componentes modulares dedicados à representação visual de cada estado de carregamento, sucesso, erro ou dados vazios.

### D. Exemplo de Referência de Domínio Puro (Civilizations)
Implementado na Sprint 4.4.1 como a nossa arquitetura oficial definitiva para a camada de Domínio baseada na Core Foundation:

1. **Entidade Pura (`Civilization`)** em `lib/features/civilizations/domain/entities/civilization.dart`:
   - Representação puramente Dart, herda de `BaseEntity` (que fornece a propriedade `id`).
   - Imutável (`const`) com comparador de igualdade estrutural baseado em `==` e `hashCode`.
   - Livre de qualquer acoplamento técnico com Flutter, Supabase ou bibliotecas JSON.
   - Atributos próprios: `slug`, `name`, `shortName`, `description`, `summary`, `startYear`, `endYear` e `publicationStatus`.

2. **Contrato de Repositório (`CivilizationRepository`)** em `lib/features/civilizations/domain/repositories/civilization_repository.dart`:
   - Estende a classe `BaseRepository`.
   - Define os métodos puramente de domínio: `getAllPublished()`, `getById(String id)` e `getBySlug(String slug)`.

3. **Casos de Uso Granulares (Use Cases)** em `lib/features/civilizations/domain/usecases/`:
   - Cada caso de uso estende a classe abstrata `BaseUseCase` para garantir responsabilidade única.
   - **`GetAllCivilizations`**: Recupera todas as civilizações publicadas. Usa `NoParams`.
   - **`GetCivilizationById`**: Recupera uma civilização específica pelo ID. Usa `String`.
   - **`GetCivilizationBySlug`**: Recupera uma civilização específica pelo Slug. Usa `String`.

### E. Exemplo de Referência da Camada de Dados (Civilizations)
Implementado na Sprint 4.4.2 como a nossa arquitetura oficial definitiva para a camada de Dados (Data Layer) baseada na Core Foundation:

1. **Modelo de Dados (`CivilizationModel`)** em `lib/data/models/civilization_model.dart`:
   - Herda diretamente de `Civilization` da camada de Domínio.
   - Fornece construtores e métodos puramente técnicos: `fromJson()`, `toJson()`, `fromEntity()` e `toEntity()`.
   - Utiliza exclusivamente os campos existentes na entidade de Domínio para garantir total aderência e desacoplamento de regras de negócio.

2. **Fonte de Dados Remota (`CivilizationRemoteDataSource`)** em `lib/data/datasources/civilization_remote_datasource.dart`:
   - Classe abstrata de contrato estendendo `BaseRemoteDataSource`.
   - Implementação concreta `CivilizationRemoteDataSourceImpl` herdando o contrato e injetando opcionalmente o `SupabaseClient`.
   - Comunica diretamente com o Supabase utilizando exclusivamente o cliente oficial configurado no projeto.
   - Métodos implementados: `getAllPublished()`, `getById()` e `getBySlug()`.
   - Tratamento centralizado de erros em bloco try-catch mapeando erros físicos/específicos para `ServerException` (network, authentication, database, emptyResponse, unknown) e registrando-os por meio do `ChronosLogger`.

3. **Implementação do Repositório (`CivilizationRepositoryImpl`)** em `lib/data/repositories/civilization_repository_impl.dart`:
   - Implementa a interface `CivilizationRepository` de Domínio e estende a classe abstrata `BaseRepository`.
   - Consome a fonte de dados remota de forma totalmente isolada.
   - Converte modelos físicos (`CivilizationModel`) em entidades imutáveis de domínio (`Civilization`), garantindo que nenhum Model vaze para as camadas superiores.
   - Encapsula todas as operações de dados em `safeCall` de `BaseRepository`, convertendo as exceções técnicas (`ServerException`) do nível mais baixo em failures limpas de domínio (`Failure` / `NetworkFailure` / `DatabaseFailure` / etc.), nunca propagando exceções para a apresentação.
   - Retorna os dados encapsulados de forma unificada em mônadas `Result<T>`.

---

### F. Exemplo de Referência da Camada de Aplicação/Apresentação (Civilizations)
Implementado na Sprint 4.4.3 como a nossa arquitetura de referência definitiva para Casos de Uso e Controladores da camada de Aplicação/Apresentação baseada na Core Foundation:

1. **Casos de Uso Granulares (`GetAllCivilizations`, `GetCivilizationById`, `GetCivilizationBySlug`)** em `lib/domain/usecases/`:
   - Herdam a classe abstrata reguladora `BaseUseCase<Type, Params>` da Core Foundation.
   - Dependem exclusivamente da interface abstrata `CivilizationRepository` de Domínio por meio do Princípio de Inversão de Dependências (DIP).
   - Não conhecem nada sobre Supabase, Datasources, Flutter, serialização ou o próprio Controller (Isolamento completo).
   - Retornam de forma limpa as mônadas estruturadas de resultado `Result<T>` contendo dados purificados de negócio.

2. **Controlador de Apresentação (`CivilizationsController`)** em `lib/presentation/controllers/`:
   - Herda diretamente de `BaseController<List<Civilization>>` estendendo a infraestrutura reativa da Core Foundation.
   - Gerencia com exclusividade o estado do fluxo visível utilizando `ViewState` (initial, loading, success, empty, error, refreshing).
   - Executa as regras através das chamadas assíncronas encapsuladas no método reativo `execute(...)` do controlador base.
   - Expõe coleções e dados estritamente imutáveis para a interface (`List.unmodifiable(...)`).
   - Registra logs funcionais de início, progresso, sucesso, tempo de processamento e falhas comerciais exclusivamente com o `ChronosLogger`.

### G. Exemplo de Referência de Domínio de Artefatos (Artifacts)
Implementado na Sprint 4.5.1 como a nossa arquitetura oficial definitiva para o Domínio da feature de Artefatos:

1. **Entidade Pura (`Artifact`)** em `lib/domain/entities/artifact.dart`:
   - Herda diretamente de `BaseEntity` (que fornece a propriedade `id`).
   - Totalmente pura, imutável, com construtor `const` e livre de acoplamento técnico.
   - Atributos próprios mapeados: `slug`, `name`, `shortName`, `description`, `summary`, `artifactType`, `originCivilizationId`, `originLocationId`, `estimatedYear`, `material`, `currentLocation`, `coverImageUrl` e `publicationStatus`.

2. **Contrato de Repositório (`ArtifactRepository`)** em `lib/domain/repositories/artifact_repository.dart`:
   - Interface abstrata limpa de domínio, que não conhece nada sobre bancos de dados ou conexões físicas.
   - Métodos declarados: `getAll()`, `getById()`, `getBySlug()`, `getByCivilization()`, `getByLocation()` e `getPublished()`.

3. **Casos de Uso Granulares (Use Cases)** em `lib/domain/usecases/`:
   - Cada caso de uso herda de `BaseUseCase` para garantir responsabilidade única.
   - **`GetAllArtifacts`**: Recupera todos os artefatos cadastrados.
   - **`GetArtifactById`**: Busca um artefato específico pelo seu identificador único.
   - **`GetArtifactBySlug`**: Busca um artefato específico por meio de seu slug único.

### H. Exemplo de Referência da Camada Data de Artefatos (Artifacts)
Implementado na Sprint 4.5.2 como a nossa arquitetura oficial definitiva para a camada Data de novas features:

1. **Modelo de Dados (`ArtifactModel`)** em `lib/data/models/artifact_model.dart`:
   - Estende a entidade de domínio `Artifact`.
   - Implementa conversores `fromJson` e `toJson` para persistência relacional.
   - Implementa `fromEntity` e `toEntity` para mapeamento bidirecional desacoplado.
   - Fornece imutabilidade por meio de métodos de clonagem (`copyWith`).

2. **Fonte de Dados Remota (`ArtifactRemoteDataSource`)** em `lib/data/datasources/artifact_remote_datasource.dart`:
   - Contrato e implementação concreta (`ArtifactRemoteDataSourceImpl`) que herdam de `BaseRemoteDataSource`.
   - Utiliza exclusivamente o cliente oficial do Supabase para realizar consultas.
   - Implementa as operações `getAllPublished`, `getById`, `getBySlug`, `getByCivilization` e `getByLocation`.
   - Trata exceções nativas (`PostgrestException`) e de rede, convertendo-as na taxonomia unificada de `ServerException`.
   - Enforca imutabilidade estrutural de coleções por meio de `List.unmodifiable(...)`.
   - Logs funcionais em todas as transições de estado via `ChronosLogger`.

3. **Repositório Concreto (`ArtifactRepositoryImpl`)** em `lib/data/repositories/artifact_repository_impl.dart`:
   - Estende `BaseRepository` para usufruir de utilitários como `safeCall`.
   - Implementa o contrato abstrato `ArtifactRepository` pertencente ao domínio.
   - Coordena as chamadas assíncronas do `ArtifactRemoteDataSource`.
   - Mapeia com total isolamento as exceções de infraestrutura (`ServerException`) em mônadas puras `Result<T>` contendo `Failure` correspondentes (`NetworkFailure`, `AuthenticationFailure`, `DatabaseFailure`, `ValidationFailure`, `UnknownFailure`).
   - Garante que dados retornados ao domínio sejam estritamente em formato de entidades puras e coleções imutáveis.

### I. Exemplo de Referência da Camada Application de Artefatos (Artifacts)
Implementado na Sprint 4.5.3 como a nossa arquitetura de referência completa para a camada de aplicação:

1. **Casos de Uso Completos (Domain Layer / Use Cases)** em `lib/domain/usecases/`:
   - **`GetAllArtifacts`**: Retorna todos os artefatos históricos.
   - **`GetArtifactById`**: Recupera um artefato específico por ID.
   - **`GetArtifactBySlug`**: Busca um artefato específico por seu slug de URL.
   - **`GetArtifactsByCivilization`**: Filtra artefatos associados a uma Civilização específica.
   - **`GetArtifactsByLocation`**: Filtra artefatos associados a uma Localização específica.
   - Todos herdam de `BaseUseCase` para isolar responsabilidades e operam estritamente sobre entidades e contratos, retornando `Result<T>`.

2. **Controlador Unificado (`ArtifactsController`)** em `lib/presentation/controllers/artifacts_controller.dart`:
   - Herda diretamente de `BaseController<List<Artifact>>`.
   - Gerencia de forma limpa e imutável os dados de UI e os estados reativos de `ViewState` (`loading`, `success`, `error`, `empty`, `refreshing`).
   - Expõe métodos públicos: `loadArtifacts()`, `loadArtifact(id)`, `loadArtifactBySlug(slug)`, `loadArtifactsByCivilization(id)`, `loadArtifactsByLocation(id)`, `refresh()`, e `retry()`.
   - Utiliza exclusivamente o `ChronosLogger` para relatar o ciclo de vida operacional, tempos de execução e volumetria de dados de forma transparente.

3. **Injeção de Dependências e Registro (Dependency Injection)** em `lib/core/di/service_locator.dart`:
   - Registrado de forma centralizada e sem acoplamentos físicos diretos no `ServiceLocator` (`sl`), assegurando alta testabilidade com suporte a dublês de teste:
     ```dart
     sl.registerLazySingleton<ArtifactRemoteDataSource>(() => ArtifactRemoteDataSourceImpl());
     sl.registerLazySingleton<ArtifactRepository>(() => ArtifactRepositoryImpl(sl.get<ArtifactRemoteDataSource>()));
     sl.registerLazySingleton<GetAllArtifacts>(() => GetAllArtifacts(sl.get<ArtifactRepository>()));
     sl.registerLazySingleton<GetArtifactById>(() => GetArtifactById(sl.get<ArtifactRepository>()));
     ...
     sl.registerFactory<ArtifactsController>(() => ArtifactsController(...));
     ```

### J. Exemplo de Referência da Camada Domain de Localizações Históricas (Historical Locations)
Implementado na Sprint 4.6.1 como a arquitetura conceitual e geográfica de referência para todo o ecossistema CHRONOS:

1. **Entidade de Domínio Pura (`HistoricalLocation`)** em `lib/domain/entities/historical_location.dart`:
   - Estende a classe `BaseEntity`.
   - É totalmente imutável, possui construtor `const` e é livre de importações de frameworks, JSON, Flutter ou bancos de dados.
   - Fornece suporte geográfico completo com atributos estruturados de localização: `latitude`, `longitude`, `locationType`, `modernCountry`, `modernRegion`, `startYear` e `endYear`.
   - Utiliza o enum fortemente tipado `LocationType` para categorizar o perfil de ponto geográfico ou arqueológico (ex: `archaeological_site`, `empire`, `city`).

2. **Contrato de Repositório de Domínio (`HistoricalLocationRepository`)** em `lib/domain/repositories/historical_location_repository.dart`:
   - Define a interface abstrata que as futuras camadas físicas implementarão, estendendo `BaseRepository`.
   - Expõe operações com mônadas `Result<T>` puras para blindar regras de negócio superiores: `getAll()`, `getById()`, `getBySlug()`, `getByParent()`, `getByType()`, `getWithinBounds()` e `getPublished()`.

3. **Casos de Uso Granulares (Use Cases)** em `lib/domain/usecases/`:
   - **`GetAllLocations`**: Recupera todas as localizações cadastradas utilizando `NoParams`.
   - **`GetLocationById`**: Recupera uma localização específica utilizando o ID como parâmetro.
   - **`GetLocationBySlug`**: Recupera uma localização específica utilizando o slug de busca como parâmetro.
   - Todos herdam de `BaseUseCase` garantindo que regras de negócio dependam unicamente de abstrações.

### K. Exemplo de Referência da Camada de Dados de Localizações Históricas (Historical Locations)
Implementado na Sprint 4.6.2 como a arquitetura de persistência e persistência oficial geográfica para o ecossistema CHRONOS:

1. **Modelo de Dados (`HistoricalLocationModel`)** em `lib/data/models/historical_location_model.dart`:
   - Herda diretamente de `HistoricalLocation` da camada de Domínio.
   - Fornece construtores e métodos puramente de infraestrutura física: `fromJson()`, `toJson()`, `fromEntity()` e `toEntity()`.
   - Isolado de qualquer regra de negócio, garantindo a perfeita representação relacional para serialização.

2. **Fonte de Dados Remota (`HistoricalLocationRemoteDataSource`)** em `lib/data/datasources/historical_location_remote_datasource.dart`:
   - Define a interface do contrato e sua respectiva implementação concreta `HistoricalLocationRemoteDataSourceImpl`.
   - Utiliza diretamente `SupabaseClient` e herda de `BaseRemoteDataSource`.
   - Trata erros de requisição física, como indisponibilidades de rede, acessos RLS e constraints de banco de dados, mapeando-os unificadamente para `ServerException`.
   - Enforca o retorno de coleções estruturalmente imutáveis por meio do uso de `List.unmodifiable(...)`.

3. **Implementação do Repositório (`HistoricalLocationRepositoryImpl`)** em `lib/data/repositories/historical_location_repository_impl.dart`:
   - Estende `BaseRepository` para usufruir da segurança de tratamento com `safeCall`.
   - Implementa a interface do domínio `HistoricalLocationRepository`.
   - Converte todos os resultados de `HistoricalLocationModel` retornados pelo DataSource em entidades puras `HistoricalLocation`, impedindo o vazamento de infraestrutura física.
   - Captura exceções técnicas do tipo `ServerException` e remapeia-as para falhas de domínio estruturadas: `NetworkFailure`, `AuthenticationFailure`, `DatabaseFailure`, `EmptyResultFailure` e `UnexpectedFailure`.

### L. Exemplo de Referência da Camada de Aplicação de Localizações Históricas (Historical Locations)
Implementado na Sprint 4.6.3 como a arquitetura oficial de aplicação e controle de apresentação para o ecossistema CHRONOS:

1. **Casos de Uso Completos (Use Cases)** em `lib/domain/usecases/`:
   - **`GetAllLocations`**: Obtém todas as localizações cadastradas utilizando `NoParams`.
   - **`GetLocationById`**: Busca uma localização por ID único.
   - **`GetLocationBySlug`**: Busca uma localização por slug de URL amigável.
   - **`GetLocationsByParent`**: Busca localizações filhas sob uma localização pai específica.
   - **`GetLocationsByType`**: Filtra localizações baseadas no enum fortemente tipado `LocationType`.
   - **`GetLocationsWithinBounds`**: Realiza pesquisas geográficas delimitadas por limites de latitude/longitude (`GetLocationsWithinBoundsParams`).
   - Todos herdam rigorosamente de `BaseUseCase` para garantir o desacoplamento comercial total e retornam `Result<T>`.

2. **Controlador de Estado Reativo (`HistoricalLocationsController`)** em `lib/presentation/controllers/historical_locations_controller.dart`:
   - Estende o `BaseController<List<HistoricalLocation>>` fornecendo uma máquina de estados robusta (`ViewState`) e controle de concorrência reativo automático de forma assíncrona.
   - Expõe métodos comerciais limpos: `loadLocations()`, `loadLocation()`, `loadLocationBySlug()`, `loadLocationsByParent()`, `loadLocationsByType()`, `loadLocationsWithinBounds()`, e `refresh()`.
   - Realiza registros detalhados das transições de estado, volumetria de dados e tempo de performance consumido utilizando o `ChronosLogger`.
   - Mantém a seleção local `selectedLocation` sem poluir as entidades de domínio com lógica temporária de visualização.

3. **Injeção de Dependências Oficial (DI)** em `lib/core/di/service_locator.dart`:
   - Registra de forma limpa e unificada as fontes de dados, repositórios, use cases granulares e controladores, permitindo a perfeita substituição por dublês de teste e desacoplamento absoluto.

---

## 3. Convenções Adotadas

Para manter o ecossistema CHRONOS uniforme, as seguintes diretrizes são obrigatórias:

- **Nomenclatura de Arquivos**: Usar `snake_case` com sufixos explícitos (ex: `historical_event_model.dart`, `historical_event_repository_impl.dart`).
- **Nomenclatura de Classes**: Usar `PascalCase` com sufixos correspondentes à camada (ex: `HistoricalEventRemoteDataSourceImpl`, `GetHistoricalEventsUseCase`).
- **Nomenclatura de Variáveis**: Usar `camelCase`. Constantes de classe ou tags de log devem ser privadas ou com prefixo claro (ex: `static const String _tag = 'HistoricalEventsController';`).
- **Imutabilidade**: Coleções retornadas por repositórios ou expostas por controladores devem ser encapsuladas em coleções imutáveis utilizando `List.unmodifiable(...)` ou `Map.unmodifiable(...)`.
- **Inversão de Controle**: Sempre registrar as dependências no `ServiceLocator` (`lib/core/di/service_locator.dart`) e consumi-las por lá. Nunca instanciar dependências físicas diretamente dentro dos componentes visuais ou de negócio.

---

## 4. Lições Aprendidas

- **Resolução de Relacionamentos**: Carregar dados dependentes (como resolver a `Era` associada a cada `Event`) de forma paralela ou coordenada dentro do `Controller` é muito mais eficiente do que realizar joins caros no banco ou buscar a Era individualmente sob demanda para cada card de UI.
- **Isolamento de Exceções**: O mapeamento de exceções no nível mais baixo (DataSource) para exceções tipadas de infraestrutura (`HistoricalEventDataSourceException`), seguido do re-mapeamento para `Failure` puras no repositório, impede o vazamento de detalhes técnicos de banco de dados para a UI, garantindo a robustez do aplicativo.
- **Feedback Visual de Esqueleto (Skeletons)**: Skeletons animados fornecem uma experiência de uso infinitamente superior ao usuário final quando comparados a simples indicadores circulares de progresso, evitando saltos visuais de layout bruscos.

---

## 5. Checklist de Arquitetura Oficial (Reutilizável)

Toda nova feature inserida no ecossistema CHRONOS deve obrigatoriamente preencher os requisitos do checklist abaixo:

### [ ] 1. Migration & Banco de Dados
- [ ] Schema físico de tabela criado e auditado no banco de dados.
- [ ] Segurança de Linhas (RLS) habilitada e configurada com políticas adequadas.
- [ ] Índices de desempenho criados para chaves estrangeiras e campos de busca frequentes.

### [ ] 2. Seed & Massa de Dados
- [ ] Massa de dados mínimos inserida para visualização em desenvolvimento.
- [ ] Status de publicação (`publication_status`) e flags de atividade (`ativo`) validados.

### [ ] 3. Entity (Domínio)
- [ ] Entidade criada de forma pura em `lib/domain/entities/`.
- [ ] Sem qualquer importação externa de frameworks, infraestrutura de banco ou Flutter.
- [ ] Operadores de igualdade (`==`) e `hashCode` devidamente implementados.

### [ ] 4. Model (Dados)
- [ ] Classe que estende a entidade criada sob `lib/data/models/`.
- [ ] Métodos `fromJson(...)` e `toJson()` implementados e blindados de nulos.
- [ ] Métodos conversores `fromEntity(...)` e `toEntity()` integrados de forma limpa.

### [ ] 5. DataSource (Dados)
- [ ] Interface e implementação remota criadas de forma assíncrona.
- [ ] Exceções do provedor externo (ex: `PostgrestException`) devidamente tratadas.
- [ ] Lançamento consistente de exceções customizadas de infraestrutura da feature.

### [ ] 6. Repository (Dados / Domínio)
- [ ] Interface abstrata criada na camada de Domínio.
- [ ] Implementação física construída na camada de Dados.
- [ ] Interceptação de exceções técnicas e conversão para objetos puros `Failure`.
- [ ] Retorno encapsulado de forma segura e elegante na mônada `Result<T>`.

### [ ] 7. UseCase (Domínio)
- [ ] Caso de uso simples e de responsabilidade única estrita criado no Domínio.
- [ ] Invocação via método `call()` retornando `Future<Result<T>>`.
- [ ] Dependência exclusiva do repositório abstrato, resolvida via `ServiceLocator`.

### [ ] 8. Controller (Apresentação)
- [ ] Gerenciador de estado baseado em `ChangeNotifier` estendendo reatividade.
- [ ] Estados de carregamento, erros e dados bem delimitados.
- [ ] Notificação de ouvintes (`notifyListeners()`) efetuada apenas em transições válidas de estado.
- [ ] Descarte correto de memória e liberação de recursos implementados.

### [ ] 9. Screen (Apresentação)
- [ ] Tela construída com suporte ao Material 3 e sem acoplamento de negócios diretos.
- [ ] Inicialização pós-renderização (`WidgetsBinding.instance.addPostFrameCallback`) executada com segurança.
- [ ] Consumo de dados estruturado via `ListenableBuilder`.

### [ ] 10. Widgets Modulares
- [ ] Componente visual de Card independente criado para encapsular listagem.
- [ ] Estado de carregamento com esqueletos (Skeletons) fluidos e dinâmicos.
- [ ] Tratamento elegante para listas vazias (`EmptyState`) e falhas de rede (`ErrorState`) com botão de re-execução.

### [ ] 11. Service Locator & DI
- [ ] Registro limpo e sequenciado de DataSources, Repositories, UseCases e Controllers.
- [ ] Resolução de dependências efetuada de forma limpa pelo `ServiceLocator`.
- [ ] Prevenção absoluta de duplicidades e loops de dependências.

### [ ] 12. Rotas & Navegação
- [ ] Rota nominal registrada centralmente na estrutura de navegação do aplicativo.
- [ ] Uso consistente de navegações nomeadas nativas do Flutter (`Navigator`).

### [ ] 13. Logger & Rastreamento
- [ ] Chamadas do `ChronosLogger` registradas em todas as transições cruciais (Init, Load, Sucesso, Erro, Refresh e Dispose).

### [ ] 14. Análise Estática & Compilação
- [ ] Execução completa do Linter (`npm run lint` ou `flutter analyze`) sem nenhum aviso ou erro.
- [ ] Compilação completa do aplicativo bem-sucedida.
