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
