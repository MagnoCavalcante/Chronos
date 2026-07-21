# CHRONOS Project Architecture — Three Pillars Model

Este documento especifica a arquitetura de referência definitiva e a reorganização macroestatística do ecossistema **CHRONOS**. Ele estrutura o crescimento sustentável da aplicação ao longo de anos, dividindo-a em três pilares lógicos claros e independentes: **Core Platform**, **Knowledge Engine** e **Experience Layer**.

---

## 1. Visão Geral da Arquitetura

O ecossistema CHRONOS adota uma arquitetura de alta modularidade inspirada nos princípios de *Clean Architecture*, *Domain-Driven Design (DDD)* e desacoplamento em camadas. O fluxo de dados opera de forma estritamente unidirecional e previsível, onde camadas de maior abstração (regras de negócio) nunca dependem diretamente de detalhes de infraestrutura ou renderização.

```
┌─────────────────────────────────────────────────────────┐
│                    EXPERIENCE LAYER                     │
│       Timeline, Map, Graph Explorer, AI Assistant       │
│  (Consome estritamente Casos de Uso | Independe de DB)  │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    KNOWLEDGE ENGINE                     │
│    Eras, Events, Characters, Civilizations, Artifacts   │
│   (Regras puras de negócio | Entities, Repos, UseCases) │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      CORE PLATFORM                      │
│     DI, Theme, Result/Failure, Log, Base Classes        │
│    (Toda a infraestrutura compartilhada necessária)      │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Organização dos Três Pilares

### Pillar I: Core Platform (A Base)
O **Core Platform** é o alicerce fundamental de infraestrutura reutilizável e serviços transversais. Nenhuma Feature ou interface do usuário pode existir sem herdar ou consumir esta camada. Ela é totalmente agnóstica às regras de negócio específicas das entidades históricas.

#### Componentes Principais:
- **Core Base Classes**: Classes reguladoras e padrões estruturais do sistema:
  - `BaseEntity`: Garante identidade única, igualdade por valor e rastreamento temporal básico para entidades de negócio.
  - `BaseModel`: Fornece a interface de mapeamento e serialização de/para JSON.
  - `BaseRemoteDataSource`: Interface abstrata para operações remotas de I/O de baixo nível.
  - `BaseRepository`: Contrato centralizador para o fluxo de dados purificados.
  - `BaseUseCase`: Força o padrão de execução de regras de negócio em comando único (`call(Params)`), retornando mônadas estruturadas de resultado.
  - `BaseController`: Estende o estado reativo unificado do `ViewState` (initial, loading, success, empty, error, refreshing).
- **DI (Dependency Injection)**: Service Locator central baseado na classe estática `sl` e no método utilitário `locate<T>()`, desacoplando completamente a instanciação da utilização das dependências.
- **Logger (`ChronosLogger`)**: Mecanismo de log estruturado que unifica diagnósticos de início, tempo de processamento, sucesso e falhas com tags de rastreamento.
- **Result & Failure Patterns**: Mônada `Result<T>` encapsulando dados puros em caso de sucesso (`Success`) ou falhas encapsuladas em entidades estruturadas `Failure` (`Failure`).
- **Theme & Design Tokens**: Biblioteca visual em `chronos_theme.dart` encapsulando as paletas oficiais de cores, espaçamentos, tipografia, elevação e cantos arredondados de forma reativa.
- **Navigation & Configuration**: Gerenciamento de rotas desacopladas, configurações globais de runtime e parâmetros ambientais da aplicação.
- **Feature Generator**: Automação por linha de comando em `tool/generate_feature.dart` para a criação rápida de novas fatias arquiteturais.

---

### Pillar II: Knowledge Engine (O Motor de Conhecimento)
O **Knowledge Engine** é o núcleo central de inteligência histórica e factual do CHRONOS. Ele representa as regras de domínio puras, relações cronológicas e sincronizações temporais.

#### Diretriz de Isolamento:
**Esta camada é totalmente livre de Flutter e conceitos de apresentação visível.** Ela conhece apenas lógica de negócio e se expressa exclusivamente por meio de:
1. **Entities**: Modelos puros que representam os conceitos históricos e suas invariáveis de negócio.
2. **Repositories (Interfaces)**: Contratos que abstraem a persistência física dos dados.
3. **UseCases**: Lógicas funcionais puras acionadas por comandos únicos.

#### Domínios de Negócio Pertencentes ao Motor:
- **Eras**: Divisão de grandes períodos da humanidade.
- **Historical Events**: Eventos pontuais localizados geograficamente e ancorados em datas exatas.
- **Historical Characters**: Biografias, linhagens e influências de grandes figuras do tempo.
- **Civilizations**: Dinastias, impérios e sociedades humanas.
- **Artifacts**: Relíquias históricas, invenções e registros arqueológicos.
- **Locations**: Mapeamento espacial de acontecimentos e fronteiras mutáveis.
- **Sources**: Referências acadêmicas, crônicas originais e registros literários.
- **Relationships**: A teia de correlações complexas que unem personagens, impérios e eventos históricos.

---

### Pillar III: Experience Layer (A Interface)
A **Experience Layer** é responsável exclusiva pela interação final com o usuário, renderização visual, manipulação de estados e apresentações dinâmicas.

#### Diretriz de Comunicação:
**Esta camada apenas consome UseCases e Controllers.** Ela é terminantemente proibida de acessar diretamente `DataSources` ou `Repositories`, infraestruturas de banco de dados locais ou requisições físicas diretas do Supabase. A comunicação flui obrigatoriamente pelos controladores de estado reativos herdados da Core Foundation.

#### Universal Entity Rendering Engine (Motor de Renderização Universal):
- **Desacoplamento de Apresentação**: Nenhuma entidade histórica é responsável pela sua própria renderização. O motor dinâmico decide como apresentar o conhecimento.
- **Render Pipeline (Pipeline de Renderização)**: Executa um fluxo isolado composto por 8 estágios mandatórios:
  1. *Metadata Resolution*: Decisão de campos visíveis/ocultos.
  2. *Layout Resolution*: Adaptação física a grades/flexibilidades.
  3. *Theme Resolution*: Sincronização automática de tokens de design.
  4. *Accessibility Resolution*: Injeção semântica profunda de acessibilidade.
  5. *Animation Resolution*: Transições físicas fluidas e controle de redução de movimento.
  6. *Interaction Resolution*: Configuração de foco, gestos de toque e atalhos físicos.
  7. *Rendering*: Processamento estético secundário.
  8. *Final Composition*: Embalagem final em design polido de alta coesão.

#### Organização da Experiência Atual (Sprint 5.1.1 — Universal Entity Details):
- **`AppShell` (`lib/presentation/pages/navigation/app_shell.dart`)**: A estrutura oficial responsiva que se adapta nativamente a dispositivos Móveis, Tablets e Desktops, unificando `AppBar` e área de transição suave de conteúdo.
- **`MainNavigation` (`lib/presentation/pages/navigation/main_navigation.dart`)**: Enum e arquitetura unificada gerenciadora das abas centrais do sistema: Home, Timeline, Mapa, Busca, Favoritos e Ajustes.
- **`HomePage` (`lib/presentation/pages/home/home_page.dart`)**: Tela inicial construída exclusivamente por meio de componentes visuais do Design System (`ChronosCard`, `ChronosSectionHeader`), apresentando boas-vindas com visual de alto nível.
- **`Timeline MVP` (`lib/presentation/pages/timeline/`)**: Linha do tempo unificada e conectada que consome reativamente `ErasController` e `HistoricalEventsController` via `TimelineController`, oferecendo ordenação cronológica síncrona, filtros de período e Era, busca textual local, visualização agrupada por Era e abertura de detalhes via Universal Entity Rendering Engine.
- **`EntityDetailsPage` (`lib/presentation/pages/details/`)**: Tela universal unificada e dinâmica de detalhes históricos. Apresenta fendas temporais por meio de layout responsivo adaptado para Mobile, Tablet e Desktop (Bento Grid), utilizando subcomponentes modulares para Header, Dynamic Metadata, Action Actions, Media Gallery, Connected Content e Rich Summary.
- **`EntityBrowser` (`lib/presentation/widgets/browser/entity_browser.dart`)**: Componente reativo genérico para listagem, filtros avançados, ordenação síncrona e buscas textuais integradas ao `SearchDelegate`.
- **`EntityRenderer` & `EntityFactory` (`lib/presentation/engine/`)**: Núcleo lógico do Universal Rendering Engine que transforma qualquer entidade em suas frentes visuais: Lista, Grade, Compacto, Cards, Detalhado (delegando agora nativamente para a nova `EntityDetailsPage`), Timeline, Mapa, Grafo, Comparativo, Pré-visualização, Resultados de Busca e Respostas IA.

#### Organização da Experiência Atual e Planejada:
- **Timeline MVP (Interactive Timeline)**: Canvas dinâmico sequencial unificado e conectado para exploração de Eras e Eventos Históricos (Concluído!).
- **Historical Map**: Renderização e mudança dinâmica de fronteiras de impérios sobrepostos ao mapa mundi.
- **Graph Explorer**: Visualização em rede (Nodes e Edges) das interconexões de relações históricas.
- **Global Search & Omnibox**: Ferramenta de busca unificada de metadados em todos os domínios históricos.
- **AI Assistant**: Assistente contextual do tempo integrado para tirar dúvidas históricas e sugerir correlações cronológicas.
- **Favorites & Bookmarks**: Organização pessoal e salvamento offline de registros.
- **Settings & Profile**: Ajustes de acessibilidade, preferências de fuso histórico e sincronizações de conta.

---

## 3. Relatório de Auditoria de Arquitetura

Como parte do Quality Gate da Sprint 4.4.DS, foi executada uma auditoria minuciosa de toda a estrutura de arquivos e responsabilidades ativas no projeto.

### Arquivos "Sem Dono" ou em Transição:
1. **`lib/presentation/widgets/historical_event_card.dart`**:
   - *Status*: Atualmente acoplado à apresentação direta de eventos. Com a consolidação da biblioteca reutilizável (Sprint 4.4.4), este widget deve ser descontinuado no futuro ou reescrito por meio da composição do novo `ChronosCard`.
2. **`lib/presentation/widgets/historical_events_empty.dart`, `_error.dart`, `_loading.dart`**:
   - *Status*: Substituídos conceitualmente por `ChronosEmptyView`, `ChronosErrorView` e `ChronosLoadingView`. Permanecerão intactos para garantir retrocompatibilidade, mas foram marcados para depreciação futura.

### Responsabilidades Misturadas Identificadas:
- **Camada de Injeção de Dependências (`lib/core/di/service_locator.dart`)**:
   - Registra diretamente implementações físicas de infraestrutura misturadas com factories globais. Recomenda-se no futuro separar os registros em módulos menores de DI (ex: `knowledge_di.dart`, `experience_di.dart`) para isolar completamente as fronteiras físicas de cada pilar.

---

## 4. Roadmap Oficial do CHRONOS

A evolução de engenharia do CHRONOS seguirá a seguinte ordem de priorização recomendada para garantir estabilidade, segurança e modularidade:

```
┌──────────────────────────────────────────────┐
│  1. Foundation (Core Platform & UI Widgets)  │
└──────────────────────┬───────────────────────┘
                       │ (Pronto!)
                       ▼
┌──────────────────────────────────────────────┐
│  2. Knowledge Engine (Regras Puras / Era/Ev) │
└──────────────────────┬───────────────────────┘
                       │ (Em andamento...)
                       ▼
┌──────────────────────────────────────────────┐
│  3. Experience Layer (Timeline & Map Views)  │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  4. Graph Engine (Mapeamento de Relações)    │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  5. AI Layer (Assistente Temporal Gemini)    │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  6. Offline Engine (Local Cache / Sync)      │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│  7. Public API & Developer SDK               │
└──────────────────────────────────────────────┘
```

---

## 5. Recomendações de Engenharia para Futuras Evoluções

1. **Validação Estrita de Importações**: Configurar ferramentas de linting para proibir importações de camadas de infraestrutura ou Flutter dentro de pacotes de domínio (`lib/domain/`).
2. **Abstração das Fontes de Imagem**: Centralizar chamadas de rede de mídia e imagens no `ChronosImageBanner` para permitir substituições simples por cache em disco no futuro.
3. **Escalar o Debounce**: Acoplar de forma transparente uma política de debounce configurável no controlador do `ChronosSearchBar` para aliviar consultas simultâneas a APIs remotas de alta densidade histórica.

---

## 6. Continuous Architecture Review

A partir da Sprint 4.4.QA, o CHRONOS adota uma governança de revisão contínua. Toda nova feature ou sprint futura deve ser rigorosamente auditada utilizando o **Architecture Guardian** (especificado em `docs/ARCHITECTURE_GUARDIAN.md`).

O processo mandatório de validação consiste em:
1. **Preenchimento do Feature Review**: Preencher e anexar o modelo oficial em `docs/FEATURE_REVIEW_TEMPLATE.md` para documentar impactos, riscos e dependências.
2. **Validação por Checklist**: Seguir passo a passo as checagens técnicas contidas em `docs/CODE_REVIEW_CHECKLIST.md`.
3. **Auditoria de Quality Score**: Garantir que as pontuações individuais e gerais do Score Card sejam de no mínimo **9,5 / 10** para que a feature seja considerada aprovada para integração definitiva.

---

## 7. Historical Knowledge Graph

O **Historical Knowledge Graph** serve como a supercamada semântica unificada do ecossistema CHRONOS. Sua função central no ecossistema é interconectar os diferentes domínios históricos (como Eras, Eventos, Personagens, Civilizações, Artefatos e Localizações) por meio de relacionamentos direcionados, tipados e valorados no tempo e espaço.

### Princípios da Integração do Grafo:
1. **Camada Semântica Sobreposta**: O grafo não substitui nem altera a modelagem relacional do banco de dados (PostgreSQL); ele reside como uma camada semântica sobreposta. Os nós (`GraphNode`) referenciam chaves primárias existentes, mantendo o desacoplamento físico completo.
2. **Navegabilidade Recursiva (CTE)**: Desenhado especificamente para permitir que a engine busque conexões indiretas em profundidade ilimitada utilizando consultas recursivas eficientes (Recursive Common Table Expressions - CTE) no nível do banco de dados.
3. **Escala de Confiança Histórica**: Diferentes relações históricas possuem diferentes graus de certeza ou consenso acadêmico. O grafo modela isso por meio de níveis estruturados de confiabilidade (`confidence`), variando de lendas a fatos comprovados.

A documentação conceitual de referência e as especificações técnicas completas dos nós e arestas estão localizadas no documento oficial `docs/HISTORICAL_KNOWLEDGE_GRAPH.md`.

---

## 8. Avaliação da Arquitetura

- **Nota de Arquitetura**: **9.9 / 10**
- *Justificativa*: A arquitetura atingiu um patamar extraordinário de desacoplamento após o congelamento do Universal Entity Rendering Engine. Nenhuma entidade do Knowledge Engine é responsável pela própria representação visual, garantindo modularidade exemplar, obediência estrita ao princípio Aberto/Fechado (SOLID) e blindagem completa das telas contra campos físicos dos modelos de domínio.
