# ARCHITECTURE: Arquitetura Técnica do CHRONOS

Este documento descreve detalhadamente a arquitetura de software do ecossistema CHRONOS. A arquitetura foi concebida para garantir alta performance, isolamento de responsabilidades, previsibilidade e escalabilidade sustentável para a preservação de dados e conexões históricas ao longo de muitos anos.

---

## 1. Visão Geral e Paradigma Arquitetural

O CHRONOS utiliza uma combinação estratégica de **Clean Architecture** (Arquitetura Limpa) e **Feature-Driven Development** (FDD/Desenvolvimento Orientado a Funcionalidades):

*   **Clean Architecture (Camadas Horizontais)**: Organiza as responsabilidades técnicas de forma desacoplada e impermeável, garantindo que as regras de negócio de domínio permaneçam puras, isoladas de detalhes tecnológicos como bancos de dados, frameworks ou interfaces gráficas.
*   **Feature-Driven Development (Fatias Verticais)**: Organiza os módulos por agrupamentos lógicos de funcionalidades de produto (ex: `timeline`, `sources`, `auth`), facilitando a manutenção e permitindo que as equipes colaborem em frentes específicas sem gerar conflitos na base de código global.

---

## 2. Diagrama Geral do Fluxo

Abaixo está representado o fluxo de ponta a ponta que rege a inicialização, autenticação, requisição e entrega de valor visual no ecossistema CHRONOS:

```
+-----------------------------------------------------------------------------------+
|                                     USUÁRIO                                       |
+----------------------------------------+------------------------------------------+
                                         | (Toca em um elemento/Interage)
                                         v
+-----------------------------------------------------------------------------------+
|                                  FLUTTER UI                                       |
|                  (Screens, Widgets & Componentes Visuais)                         |
+----------------------------------------+------------------------------------------+
                                         | (Aciona ação / Lê estado)
                                         v
+-----------------------------------------------------------------------------------+
|                              RIVERPOD (ESTADOS)                                   |
|               (Controllers, Providers & Gerenciadores de Estado)                  |
+----------------------------------------+------------------------------------------+
                                         | (Dispara execução)
                                         v
+-----------------------------------------------------------------------------------+
|                               USE CASES (DOMÍNIO)                                 |
|             (Casos de Uso Conceituais, ex: ObterCausalidadeEventos)               |
+----------------------------------------+------------------------------------------+
                                         | (Invoca contrato abstrato)
                                         v
+-----------------------------------------------------------------------------------+
|                            REPOSITORIES (CONTRATOS)                               |
|               (Interfaces de Repositório do Domínio de Negócio)                   |
+----------------------------------------+------------------------------------------+
                                         | (Implementação física na camada Data)
                                         v
+-----------------------------------------------------------------------------------+
|                         DATA SOURCES (FONTES DE DADOS)                            |
|             (Supabase API Client / Local Cache / SQLite Data Sources)             |
+----------------------------------------+------------------------------------------+
                                         | (Realiza requisição segura)
                                         v
+-----------------------------------------------------------------------------------+
|                                 SUPABASE SDK                                      |
+----------------------------------------+------------------------------------------+
                                         | (Conexão via API Rest / WebSocket)
                                         v
+-----------------------------------------------------------------------------------+
|                        POSTGRESQL (NUVEM DO SUPABASE)                             |
|          (Tabelas Relacionais + Arestas de Grafo / RLS / Auth / Storage)          |
+-----------------------------------------------------------------------------------+
```

---

## 3. O Fluxo de Dados na Prática

Para compreender o ciclo de vida de uma operação, observe o passo a passo de como uma requisição percorre as camadas e retorna ao usuário:

1.  **Interação do Usuário**: O usuário toca em um evento específico ("Queda de Constantinopla") na timeline.
2.  **Encaminhamento na UI**: O Widget intercepta o gesto e aciona o método correspondente no `Controller` (gerenciado via Riverpod).
3.  **Execução do Caso de Uso**: O Controller invoca o Caso de Uso apropriado (`ObterInfluenciaCausalUseCase`), que contém as regras de negócio conceituais sobre como conectar eventos.
4.  **Consulta ao Repositório**: O Caso de Uso solicita os dados ao contrato do Repositório (`EventRepository`). O Caso de Uso não sabe se os dados vêm da internet, de um arquivo local ou de um banco interno.
5.  **Acesso ao DataSource**: A implementação real do repositório (`EventRepositoryImpl`) repassa a demanda para o DataSource físico do Supabase (`EventSupabaseDataSource`).
6.  **Garantia de Segurança (RLS)**: O Supabase recebe a requisição de busca e valida as credenciais através de suas políticas nativas de **Row Level Security (RLS)** diretamente no banco PostgreSQL.
7.  **Processamento no Banco Híbrido**: O banco PostgreSQL executa a query recursiva e retorna as linhas correspondentes ao evento e suas arestas de conexão causal (grafo).
8.  **Conversão de Modelos (Data-to-Domain)**: O DataSource obtém o JSON, converte para o modelo tecnológico de persistência (`EventModel`) e o Repositório o purifica em uma Entidade de Domínio imutável e sem dependências externas (`HistoricalEvent`).
9.  **Retorno e Atualização**: A Entidade de Domínio volta pelo fluxo do Caso de Uso até o Controller, que atualiza o estado reativo no Riverpod.
10. **Renderização Visual**: O widget do Flutter escuta a atualização de estado e redesenha a tela de forma fluida, exibindo o grafo causal com suavidade.

---

## 4. Dependências Oficiais do Ecossistema

| Tecnologia | Finalidade | Responsabilidade |
| :--- | :--- | :--- |
| **Flutter** | SDK Multiplataforma | Renderização de alto desempenho de UI em todas as plataformas (Skia/Impeller). |
| **Dart** | Linguagem de Programação | Codificação de toda a lógica do app e definição de modelos de negócio puros. |
| **Riverpod** | Gerenciador de Estados | Controle de reatividade, injeção de dependências e sincronização de dados de UI. |
| **GoRouter** | Sistema de Roteamento | Navegação declarativa e profunda (deep linking) fluida entre as telas. |
| **Supabase** | Backend as a Service (BaaS) | Provedor de infraestrutura (banco relacional, autenticação segura, RLS e Storage). |
| **PostgreSQL** | Banco de Dados Relacional | Armazenamento persistente de dados históricos e consultas recursivas em grafos. |
| **GitHub** | Versionamento e CI/CD | Fonte da verdade técnica, auditoria acadêmica, revisão de código e automação. |
| **VS Code** | IDE de Codificação | Ambiente unificado e oficial para desenvolvimento local de software. |

---

## 5. Regras Arquiteturais Invioláveis

A integridade estrutural e a sobrevivência do ecossistema a longo prazo dependem do respeito contínuo às seguintes regras de isolamento de código:

*   **Widgets não acessam dados diretamente**: É terminantemente proibido chamar APIs, SDKs do Supabase ou realizar queries de rede dentro de arquivos de UI (Screens e Widgets).
*   **Widgets não conhecem JSON**: A camada de visualização trabalha estritamente com dados tipados e Entidades de Domínio já processadas. Parsers de JSON (`map`, `fromJson`, `toJson`) devem residir apenas nos Models da camada de `Data`.
*   **A camada de Domain não importa Flutter**: O domínio (`domain/`) do CHRONOS deve ser escrito em Dart puro. Ele nunca deve importar `package:flutter/...`, mantendo as regras de negócio limpas e portáveis para execução fora da interface.
*   **A camada de Domain não importa Supabase**: O domínio não conhece o Supabase ou qualquer outro provedor de nuvem. Toda a conexão externa é abstraída por interfaces e resolvida em runtime pela injeção de dependências.
*   **Repositories não contêm lógicas de tela**: Repositórios e fontes de dados lidam unicamente com a recuperação, tratamento e persistência física de informações, desconhecendo rotas, controllers ou estados visuais.
*   **A UI é livre de lógica de negócio**: A interface serve apenas para renderizar dados e delegar ações. Decisões de validação histórica, cruzamento de dados ou causalidade pertencem aos Casos de Uso.

---

## 6. Princípios de Performance e Fluidez Visual

Navegar por grafos históricos e grandes volumes temporais de eras exige cuidados rígidos com a performance em dispositivos móveis e navegadores web:

*   **Lazy Loading e Paginação**: Os dados cronológicos de eras e eventos nunca devem ser carregados todos de uma única vez. O sistema deve carregar os dados conforme a navegação temporal se aproxima de novas faixas ou de acordo com a expansão dinâmica dos cards.
*   **Cache Local Otimizado**: Informações estáticas históricas (que não mudam) devem ser cacheadas localmente após a primeira consulta ao Supabase, reduzindo custos de rede e garantindo visualização offline instantânea.
*   **Índices no PostgreSQL**: As colunas frequentemente utilizadas em filtros (como anos de início/fim, tipos de arestas de causalidade e chaves estrangeiras) devem receber índices de busca otimizados (`B-Tree` ou especializados) diretamente no banco do Supabase para acelerar o tempo de retorno de dados.
*   **Consultas Assíncronas Não Bloqueantes**: Todas as requisições de IO e de rede do Dart devem ser executadas utilizando padrões assíncronos (`Future`, `Stream`), garantindo que a Thread principal de UI permaneça livre de travamentos e rodando a 60 FPS ou superior.
*   **Evitar Rebuilds Desnecessários na UI**: Utilizar componentes estruturados e seletores de estado granulares no Riverpod (`ref.watch(provider.select(...))`) para garantir que apenas os componentes que sofreram alteração real de dados sejam redesenhados em tela.

---

## 7. Estratégia de Migrations e Banco Híbrido

O CHRONOS utiliza o PostgreSQL nativo do Supabase com uma modelagem otimizada para grafos:

1.  **Armazenamento de Entidades**: Eras e eventos históricos são modelados em tabelas puramente relacionais estruturadas clássicas, aplicando constraints rígidas e garantindo a indestrutibilidade e a consistência das informações.
2.  **Mapeamento de Relações**: As teias e conexões (como causalidade histórica ou influência artística) são estabelecidas em tabelas de junção de arestas (ex: `causality_edges`), permitindo o rastreamento profundo de árvores genealógicas ou de causalidades sem sobrecarregar as tabelas principais.
3.  **Migrations Versionadas**: Todas as alterações estruturais de esquemas de tabelas ou políticas de Row Level Security (RLS) são escritas em arquivos de script `.sql` numerados de forma sequencial na pasta `/database/migrations`, de modo que toda modificação estrutural de banco seja revisada no GitHub antes de sua implantação em produção.

---

## 8. Módulos da Camada de Experiência (Epic 3)

### 8.1 Universal Entity Details (Sprint 5.1.1)
Uma das maiores inovações de interface do CHRONOS é o componente universal de visualização rica de entidades (**`EntityDetailsPage`**).
- **Consumo do Entity Rendering Engine**: O detalhamento visual de qualquer entidade (Era, Evento, Personagem, etc.) consome dinamicamente o motor de renderização comum. Isso unifica o visual e evita duplicações.
- **Estruturação Modular**: A visualização de detalhes é segregada em widgets altamente especializados e desacoplados:
  - `EntityDetailsHeader`: Renderização de capas, títulos, anos de vigência e badges rápidos.
  - `EntityDetailsContent`: Corpo principal de texto com descrições detalhadas suportando RichText ou Markdown.
  - `EntityDetailsGallery`: Visualização em grade e carrossel de fotos, gravuras e pinturas históricas.
  - `EntityDetailsMetadata`: Exibição de pares de chaves-valores estruturadas (tipo, material, localizações).
  - `EntityDetailsActions`: Botões para salvar em dossiês, exportar para PDF ou escutar via áudio sintético.
  - `EntityDetailsRelated`: Lista deslizante de relações causais e geográficas descobertas.

### 8.2 Global Search Engine MVP (Sprint 5.2.0)
O mecanismo de navegação unificado do CHRONOS baseia-se no primeiro motor de Busca Global multiplataforma de dados históricos.
- **Agregação de Controladores em Índice Único**: O `ChronosSearchController` consome reativamente os estados carregados de todos os domínios (Eras, Eventos, Personagens, Civilizações, Artefatos, Localizações) para orquestrar as buscas sem acoplamento direto de rede.
- **Incremental Debounce**: Entrada de texto tratada com temporizador assíncrono de **300ms**, minimizando re-indexações e garantindo fluidez perfeita de 60fps/120fps.
- **Algoritmo de Scoring Recontrutivo**: Sistema de relevância com pesos para ranquear resultados (exato no título: +100, parcial no título: +50, subtítulo: +25, descrição: +10).
- **Filtros por Categoria e Ordenações Complexas**: Oferece segmentação ágil de conteúdo e ordenações por Relevância, Ordem Alfabética e Ordem Cronológica (sincronizando anos negativos B.C. e positivos A.D. com perfeição).

---

## 9. Evolução Futura da Arquitetura

O design arquitetural adotado no CHRONOS foi projetado com alta modularidade, permitindo que o sistema cresça e adote novas topologias sem quebras ou necessidade de reescrever o código base existente:

*   **Camada de API Dedicada**: Caso o projeto necessite de processos de segurança avançados ou integrações governamentais de grande escala, um servidor intermediário de API em Go ou Node.js pode ser facilmente adicionado entre o Supabase e o aplicativo, bastando implementar um novo DataSource na camada de dados (`Data`) sem alterar as lógicas de Domínio ou de Apresentação.
*   **Mecanismo Offline-First**: Caso o ecossistema incorpore sincronização bidirecional complexa para tablets e computadores, as interfaces dos Repositórios suportarão a substituição ou combinação do DataSource remoto pelo banco de dados local unificado (como SQLite/Isar), mantendo as regras visuais intactas.
*   **Múltiplas Fontes de Integração**: Novas integrações de dados, como bibliotecas universitárias internacionais e arquivos em formato livre, podem ser conectadas ao CHRONOS adicionando-se novos adaptadores na camada de dados, garantindo que o sistema permaneça agnóstico a fornecedores únicos e pronto para acompanhar as necessidades das próximas décadas.
