# CHRONOS: Arquitetura de Banco de Dados V1.0 (Sprint 2.2)

Este documento especifica a **Arquitetura Conceitual de Banco de Dados** para a versão 1.0 (MVP) do ecossistema CHRONOS. Ele detalha a divisão híbrida entre dados relacionais estruturados e a camada de Grafo de Conhecimento Semântico (CKE), otimizada para o Supabase (PostgreSQL).

---

## 🧭 1. Entidades Principais da Versão 1.0 (MVP)

Para garantir um lançamento estável, focado em alta fidelidade e de rápido desenvolvimento, o escopo da **V1.0** restringe-se a **seis entidades fundamentais**. Estas entidades servem de base para estruturar a experiência do "GPS do Tempo" e a exploração da linha do tempo:

```
 ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
 │  Civilization   │◄─────►│    Personage    │◄─────►│      Event      │
 └────────┬────────┘       └─────────────────┘       └────────┬────────┘
          │                                                   │
          ▼                                                   ▼
 ┌─────────────────┐                                 ┌─────────────────┐
 │    Location     │                                 │     Source      │
 └─────────────────┘                                 └─────────────────┘
          ▲                                                   ▲
          └─────────────────── [ Timeline ] ──────────────────┘
```

1.  **Civilização (`Civilization`):**
    *   *Responsabilidade:* Representar o macro-contexto histórico-cultural e geopolítico (ex: "Império Romano", "Grécia Antiga"). Fornecer a identidade coletiva, capitais móveis de governo, moedas e eixos geográficos principais.
2.  **Personagem (`Personage`):**
    *   *Responsabilidade:* Representar as figuras históricas centrais de impacto direto nas narrativas da V1.0 (ex: "Júlio César", "Cleópatra VII", "Augusto"). Centralizar as biografias de liderança, linhagens familiares e cargos exercidos.
3.  **Evento (`Event`):**
    *   *Responsabilidade:* Representar os acontecimentos cronológicos pontuais ou contínuos que impulsionam a história (ex: "Travessia do Rubicão", "Idos de Março", "Batalha de Actium"). Servir como o elo de conexão na linha do tempo.
4.  **Local (`Location`):**
    *   *Responsabilidade:* Fornecer coordenadas espaciais precisas para situar cidades, batalhas, monumentos ou descobertas arqueológicas no mapa dinâmico do aplicativo (ex: "Alexandria", "Roma", "Teatro de Pompeu").
5.  **Fonte (`Source`):**
    *   *Responsabilidade:* Registrar as referências e provas materiais (inscrições epigráficas, fragmentos de textos de historiadores antigos) que amparam cientificamente os dossiês históricos e biográficos do app.
6.  **Linha do Tempo (`Timeline` / `Era`):**
    *   *Responsabilidade:* Estruturar e encadear sequencialmente os fatos por filtros ou temas (ex: "A Queda da República Romana", "Império Ptolemaico no Egito").

---

## 🔗 2. Catálogo de Relacionamentos para a V1.0

Na V1.0, as arestas do Grafo de Conhecimento Semântico conectam as seis entidades centrais através de relacionamentos direcionados e tipados de forma estrita:

| Entidade de Origem (`source`) | Tipo de Relacionamento (`edge`) | Entidade de Destino (`target`) | Significado Semântico na V1.0 |
| :--- | :--- | :--- | :--- |
| **Personage** | `RULED` | **Civilization** | Indica que o personagem governou ou administrou aquela civilização. |
| **Personage** | `BORN_IN` | **Location** | Associa o nascimento do personagem a uma coordenada geográfica exata. |
| **Personage** | `ALLIED_WITH` | **Personage** | Representa pactos pessoais, casamentos dinásticos ou acordos políticos. |
| **Personage** | `PARTICIPATED_IN` | **Event** | Conecta o personagem às suas ações diretas registradas na história. |
| **Event** | `LOCATED_IN` | **Location** | Posiciona geograficamente o acontecimento no mapa temporal. |
| **Event** | `CAUSED` | **Event** | Estabelece um elo lógico de causa e efeito direto entre dois eventos cronológicos. |
| **Civilization** | `ORIGINATED` | **Event** / **Location** | Associa as origens de um evento ou local ao território da civilização. |
| **Entity (Qualquer)** | `EVIDENCED_BY` | **Source** | Vincula uma informação histórica ou mitológica ao seu lastro de prova científica. |

---

## 🏛️ 3. Arquitetura Híbrida de Dados (Divisão de Camadas)

Para extrair o máximo de desempenho do **PostgreSQL** no **Supabase**, dividimos os dados em duas camadas arquiteturais distintas de acordo com a sua mutabilidade, requisitos de integridade e uso operacional:

```
                       ┌───────────────────────────────┐
                       │   PROJETO CHRONOS V1.0 DATA   │
                       └───────────────┬───────────────┘
                                       │
            ┌──────────────────────────┴──────────────────────────┐
            ▼                                                     ▼
┌──────────────────────────────┐                      ┌──────────────────────────────┐
│  A. CAMADA RELACIONAL FISICA │                      │ B. CAMADA DE GRAFO SEMÂNTICO │
├──────────────────────────────┤                      ├──────────────────────────────┤
│ - Cadastro e Autenticação    │                      │ - Nós do Conhecimento (Nodes)│
│ - Perfis de Usuário          │                      │ - Conexões Direcionadas      │
│ - Favoritos e Marcadores     │                      │ - Atributos Flexíveis (JSONB)│
│ - Logs de Navegação          │                      │ - Traduções (i18n Locales)   │
│ - Controle Operacional e RLS │                      │ - Busca Semântica (pgvector) │
└──────────────────────────────┘                      └──────────────────────────────┘
```

### A. Camada Relacional Física (Dados Estruturados e Operacionais)
Responsável pelas regras de integridade referencial rígidas, controle de acesso do Supabase (RLS), segurança e transações financeiras ou de perfil de usuário.

*   **Tabelas Físicas Típicas nesta Camada:**
    *   `users_profiles` (UUID, FK para `auth.users` do Supabase): Armazena dados cadastrais do usuário final (nome, e-mail, data de registro, avatar, conquistas).
    *   `saved_dossiers` (Associação N:M entre Usuário e Entidade): Guarda os artigos favoritos do usuário para leitura offline.
    *   `reading_history` (Logs operacionais): Histórico de navegação cronológica e interações do usuário com o aplicativo para análises de engajamento.
    *   `sources` (Camada mestre de evidência): IDs de referências bibliográficas estruturadas que necessitam de campos imutáveis e padronizados.

### B. Camada de Grafo de Conhecimento (Dados Semânticos e Flexíveis)
Responsável por modelar as conexões dinâmicas do "GPS do Tempo". Ela unifica todas as entidades históricas em um esquema unificado baseado em tabelas de Nós (`entities`), Arestas (`relationships`) e Traduções (`entity_translations`), permitindo que as conexões cresçam horizontalmente sem a necessidade de novos scripts de migração de banco de dados.

*   **Atributos Fixos Relacionais na Camada de Grafo (Colunas do Banco de Dados):**
    *   `id` (UUID, PK): Identificador único universal do nó.
    *   `slug` (VARCHAR, Unique): Identificador amigável para URLs e carregamento de rotas de navegação.
    *   `type` (ENUM): O tipo de nó (`civilization`, `personage`, `event`, `location`, `source`).
    *   `evidence_level` (ENUM): Grau de robustez científica da entidade histórica.
    *   `time_value` (BIGINT, Indexado): Valor numérico representativo de segundos relativos em relação à Epoch 1 d.C., permitindo indexação B-Tree ultra-veloz para ordenar as linhas do tempo.
    *   `coordinate` (GEOMETRY/Point ou JSONB de coordenadas): Coordenada GPS de latitude e longitude de indexação geográfica rápida.
    *   `embedding_vector` (VECTOR 1536): Embedding vetorial das informações do artigo para busca semântica por similaridade de inteligência artificial (pgvector).
*   **Atributos Flexíveis de Grafo (Armazenados na coluna `properties` JSONB):**
    *   *Para `Civilization`:* `{"capital": "Roma", "government": "República", "apogee_century": "I a.C."}`
    *   *Para `Personage`:* `{"lineage": "Julio-Claudiana", "birth_place_literal": "Roma", "cognomen": "Pater Patriae"}`
    *   *Para `Event`:* `{"impact_level": "global", "military_tactics": "cercamento duplo"}`
    *   *Para `Location`:* `{"elevation_meters": 35, "archeological_status": "active_excavation"}`

---

## 📐 4. Diagrama de Conexão Conceitual da V1.0

O diagrama abaixo ilustra como as tabelas relacionais operacionais e as tabelas híbridas do Grafo de Conhecimento se fundem no banco de dados para entregar a experiência unificada do CHRONOS:

```mermaid
graph TD
    %% Subgrafo da Camada Relacional Operacional (Supabase Auth & Perfis)
    subgraph Operational_Layer ["Camada Relacional Física (Operacional)"]
        Users["auth.users (Supabase)<br/>--<br/>PK id (UUID)<br/>email (VARCHAR)"]
        Profiles["users_profiles<br/>--<br/>PK id (UUID)<br/>FK user_id (-> auth.users)<br/>display_name (VARCHAR)<br/>streak_days (INT)"]
        Saved["saved_dossiers<br/>--<br/>PK (user_id, entity_id)<br/>FK user_id (-> users_profiles)<br/>FK entity_id (-> entities)<br/>saved_at (TIMESTAMP)"]
    end

    %% Subgrafo do Grafo de Conhecimento (CKE)
    subgraph Knowledge_Graph_Layer ["Camada de Grafo de Conhecimento (CKE)"]
        Entities["entities (Nós do Grafo)<br/>--<br/>PK id (UUID)<br/>slug (VARCHAR)<br/>type (entity_type_enum)<br/>evidence_level (evidence_level_enum)<br/>time_value (BIGINT)<br/>coordinate (JSONB/POINT)<br/>properties (JSONB)<br/>embedding (VECTOR)"]
        
        Relationships["relationships (Arestas do Grafo)<br/>--<br/>PK id (UUID)<br/>FK source_id (-> entities)<br/>FK target_id (-> entities)<br/>type (relationship_type_enum)<br/>time_start_value (BIGINT)<br/>metadata (JSONB)"]
        
        Translations["entity_translations (Internacionalização)<br/>--<br/>PK (entity_id, locale)<br/>FK entity_id (-> entities)<br/>locale (VARCHAR)<br/>name (VARCHAR)<br/>description (TEXT)<br/>properties_trans (JSONB)"]
    end

    %% Ligações entre as Camadas
    Users -->|1 : 1| Profiles
    Profiles -->|1 : N| Saved
    Saved -->|N : 1| Entities
    Entities -->|1 : N| Relationships : "source_id"
    Entities -->|1 : N| Relationships : "target_id"
    Entities -->|1 : N| Translations
```

---

## 🔬 5. Análise Crítica e Mitigações para a Fase Física

Antes de efetuarmos a criação das tabelas e políticas de Row Level Security (RLS) no Supabase, mapeamos as principais vulnerabilidades da arquitetura proposta para a V1.0 e estabelecemos suas mitigações estruturais:

### A. Validação de Integridade na Escrita de JSONB
*   **Problema:** Sendo as propriedades específicas (`properties` JSONB) desprovidas de tipos nativos SQL no nível de coluna, há risco de dados corrompidos ou chaves ausentes inseridos via scripts automatizados ou painel administrativo.
*   **Melhoria Proposta:** Implementação de triggers de validação PL/pgSQL na tabela `entities` acionadas em eventos de `INSERT` ou `UPDATE`. Estas triggers validarão a estrutura do campo `properties` contra um schema JSON correspondente ao `type` da entidade (ex: se `type = 'location'`, a trigger rejeitará registros onde falte a propriedade `"archeological_status"`).

### B. Indexação Temporal Complexa para Gráficos
*   **Problema:** A navegação por linha do tempo exige buscas frequentes de intervalos ordenados baseados em datas de início e fim. O uso de `ORDER BY time_value` em queries de grafo pode exigir ordenações em arquivos temporários de disco à medida que a base cresce.
*   **Melhoria Proposta:** Criação de índices compostos B-Tree combinando `(type, time_value)` e `(time_value, id)`. Isto permite que o motor de busca do Supabase resolva a ordenação e paginação diretamente pelas árvores de índice de forma extremamente rápida, sem processar varreduras completas em disco.

### C. Segurança e Vazamento de Dados via RLS (Row Level Security)
*   **Problema:** Como o aplicativo Flutter acessará a tabela `entities` diretamente pelas credenciais de anonimato do Supabase (`anon_key`), um usuário mal-intencionado poderia extrair em massa dados privados de desenvolvimento, rascunhos de dossiês não publicados ou logs do sistema.
*   **Melhoria Proposta:** Toda entidade e relacionamento possuirá uma coluna de estado de publicação (`status` ENUM com valores `draft`, `review`, `published`). A política de segurança RLS garantirá que apenas administradores autenticados tenham acesso a nós e arestas cujo status seja diferente de `published`.

### D. Armazenamento Georreferenciado Nativo
*   **Problema:** A busca de nós baseada em coordenadas geográficas retas por raio de distância (ex: *"Encontre todos os locais históricos num raio de 50km de Alexandria"*) usando funções matemáticas nativas de JSONB é computacionalmente ineficiente.
*   **Melhoria Proposta:** Habilitar a extensão **PostGIS** no PostgreSQL do Supabase, definindo a coluna `coordinate` utilizando o tipo nativo `GEOMETRY(Point, 4326)` com indexação espacial **GIST**. Isto acelera as buscas geográficas de raio de distância em tempo real para milissegundos.
