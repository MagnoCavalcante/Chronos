# CHRONOS: Projeto de Modelo Físico do Banco de Dados V1.0 (Sprint 2.2)

Este documento descreve o **Projeto Físico Detalhado** do banco de dados relacional e grafo do **CHRONOS**, otimizado para **PostgreSQL** no ambiente **Supabase**. Ele traduz a modelagem conceitual e o design de domínios em tabelas, tipos de dados, chaves estrangeiras, restrições e planos de indexação.

---

## 🏛️ 1. Camada Relacional (Dados Operacionais e de Apoio)

Essas tabelas gerenciam os usuários da plataforma, seus perfis operacionais, favoritação de conteúdos e fontes imutáveis de referência científica.

### A. Tabela: `users_profiles`
*   **Objetivo:** Armazenar os perfis dos usuários e dados de engajamento do aplicativo móvel, mantendo-os desvinculados dos dados privados de autenticação do Supabase.
*   **Justificativa:** Proteger e expor os atributos públicos dos usuários sob controle estrito de políticas RLS, sem acoplamento com dados sensíveis do `auth.users`.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Sim | **Chave Primária (PK)** (gerado automaticamente via `gen_random_uuid()`) |
| `user_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `auth.users(id)` (Unique, ON DELETE CASCADE) |
| `display_name` | `VARCHAR(100)` | Sim | Nome legível do usuário final. |
| `avatar_url` | `VARCHAR(255)` | Não | Link opcional para imagem do perfil. |
| `streak_days` | `INTEGER` | Sim | Contador de dias consecutivos de uso (Default: `0`). CHECK: `streak_days >= 0` |
| `created_at` | `TIMESTAMPTZ` | Sim | Carimbo de registro da conta (Default: `NOW()`) |
| `updated_at` | `TIMESTAMPTZ` | Sim | Última edição cadastral (Default: `NOW()`) |

*   **Índices Recomendados:**
    *   `idx_users_profiles_user_id` (Unique B-Tree em `user_id`): Acelera a vinculação do usuário autenticado às suas preferências.

---

### B. Tabela: `sources`
*   **Objetivo:** Cadastrar o acervo de referências bibliográficas, achados arqueológicos físicos ou manuscritos clássicos primários.
*   **Justificativa:** Estabelecer uma biblioteca de evidências unificada, permitindo referenciar múltiplos fatos sem duplicar dados bibliográficos.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Sim | **Chave Primária (PK)** (gerado via `gen_random_uuid()`) |
| `title` | `VARCHAR(255)` | Sim | Título do livro, documento ou monumento arqueológico. |
| `author` | `VARCHAR(255)` | Não | Historiador clássico (Heródoto), contemporâneo, ou escavador principal. |
| `category` | `VARCHAR(50)` | Sim | Tipo de fonte. CHECK: `IN ('primary_text', 'epigraphic', 'numismatic', 'contemporary_historiography')` |
| `publication_year`| `INTEGER` | Não | Ano aproximado de edição da tradução ou obra. |
| `reference_url` | `VARCHAR(511)` | Não | Link (URL) opcional para catalogação digital (ex: Perseus Project). |
| `created_at` | `TIMESTAMPTZ` | Sim | Data de cadastro interno no sistema. |

*   **Índices Recomendados:**
    *   `idx_sources_category` (B-Tree em `category`): Filtros de categorização de evidências.

---

### C. Tabela: `timelines`
*   **Objetivo:** Armazenar os eixos narrativos curados pelos editores que agrupam eventos tematicamente para o usuário.
*   **Justificativa:** Fornecer eixos temáticos estruturados aos quais as entidades do grafo podem se acoplar de forma flexível.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Sim | **Chave Primária (PK)** (gerado via `gen_random_uuid()`) |
| `slug` | `VARCHAR(100)` | Sim | Identificador amigável único. **Restrição (Unique)** |
| `priority_level` | `INTEGER` | Sim | Peso de prioridade na interface (Default: `3`). CHECK: `BETWEEN 1 AND 5` |
| `created_at` | `TIMESTAMPTZ` | Sim | Data de inserção da trilha narrativa. |

*   **Índices Recomendados:**
    *   `idx_timelines_slug` (Unique B-Tree em `slug`)
    *   `idx_timelines_priority` (B-Tree em `priority_level`)

---

### D. Tabela: `saved_dossiers`
*   **Objetivo:** Gerenciar as pastas de favoritos, dossiês salvos ou anotações de leitura dos usuários.
*   **Justificativa:** Tabela de ligação convencional N:M ligando usuários às entidades semânticas marcadas.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `user_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `users_profiles(id)` ON DELETE CASCADE |
| `entity_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `entities(id)` ON DELETE CASCADE |
| `saved_at` | `TIMESTAMPTZ` | Sim | Data da marcação (Default: `NOW()`) |

*   **Chave Primária Composta:** `(user_id, entity_id)`
*   **Índices Recomendados:**
    *   `idx_saved_dossiers_entity_id` (B-Tree em `entity_id`): Acelera análises de engajamento reverso (quais dossiês são mais marcados globalmente).

---

## 🔗 2. Camada de Grafo de Conhecimento (Knowledge Graph Core)

Esta camada modela de forma dinâmica o Grafo semântico CHRONOS utilizando o padrão Property Graph, contendo os Nós, as Arestas direcionadas e as traduções que permitem a evolução contínua da base de dados.

### E. Tabela: `entities` (Nós/Nodes)
*   **Objetivo:** Tabela unificada e polimórfica que armazena todas as entidades do Grafo de Conhecimento (Civilização, Personagem, Evento, Local, etc.).
*   **Justificativa:** Centralizar todas as entidades permite realizar buscas lineares rápidas na linha do tempo, aplicar indexação geográfica e busca por similaridade semântica (vetores) em uma tabela única de altíssima performance.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Sim | **Chave Primária (PK)** |
| `slug` | `VARCHAR(100)` | Sim | Identificador amigável e único para navegação de rotas. **Unique** |
| `type` | `VARCHAR(50)` | Sim | Tipo de Entidade. CHECK: `IN ('civilization', 'personage', 'event', 'location', 'technology', 'mythology')` |
| `evidence_level` | `VARCHAR(50)` | Sim | Grau de comprovação científica. CHECK: `IN ('level_1_arch_monumental', 'level_2_arch_movable', 'level_3_epigraphic', 'level_4_textual_primary', 'level_5_textual_secondary', 'level_6_hist_consensus', 'level_7_myth_traditional')` |
| `time_value` | `BIGINT` | Não | Segundos relativos à Epoch 1 d.C. para ordenação linear na Linha do Tempo. |
| `time_display_raw`| `VARCHAR(100)` | Não | String literal exibida para o usuário (ex: `"c. 3400 a.C."`, `"Fim do Século IV a.C."`) |
| `coordinate` | `geometry(Point, 4326)`| Não | Coordenadas GPS de latitude/longitude indexadas (Extensão PostGIS). |
| `properties` | `JSONB` | Sim | Atributos específicos e dinâmicos de cada entidade (Default: `'{}'`) |
| `embedding_vector`| `vector(1536)` | Não | Vetor de embedding para busca semântica e IA (Extensão pgvector). |
| `status` | `VARCHAR(20)` | Sim | Status operacional de publicação. CHECK: `IN ('draft', 'review', 'published')` (Default: `'draft'`) |
| `created_at` | `TIMESTAMPTZ` | Sim | Data de inserção do nó no sistema. |
| `updated_at` | `TIMESTAMPTZ` | Sim | Última revisão editorial do nó. |

*   **Índices Recomendados:**
    *   `idx_entities_slug` (Unique B-Tree em `slug`)
    *   `idx_entities_type_time` (B-Tree em `(type, time_value)`): Acelera filtros da linha do tempo.
    *   `idx_entities_time_value` (B-Tree em `time_value`): Indexação rápida para buscas ordenadas por séculos.
    *   `idx_entities_properties` (GIN em `properties`): Otimização de consultas avançadas em metadados JSONB.
    *   `idx_entities_coordinate` (GIST em `coordinate`): Otimização espacial para buscas de proximidade no mapa.
    *   `idx_entities_embedding` (HNSW/IVFFlat em `embedding_vector`): Busca semântica vetorial rápida por IA.

---

### F. Tabela: `relationships` (Arestas/Edges)
*   **Objetivo:** Mapear as conexões direcionadas, tipadas e mutáveis entre quaisquer duas entidades históricas do sistema.
*   **Justificativa:** É a espinha dorsal do Grafo de Conhecimento, funcionando como uma lista de adjacências de alto desempenho para cruzamento de causalidades históricas.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | Sim | **Chave Primária (PK)** |
| `source_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `entities(id)` ON DELETE CASCADE |
| `target_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `entities(id)` ON DELETE CASCADE |
| `type` | `VARCHAR(50)` | Sim | Tipo de Relacionamento. CHECK: `IN ('ruled', 'allied_with', 'born_in', 'located_in', 'participated_in', 'caused', 'originated_in', 'influenced')` |
| `time_start_value`| `BIGINT` | Não | Data relativa de início da conexão (ex: início de um reinado). |
| `time_end_value` | `BIGINT` | Não | Data relativa de término da conexão (ex: término de um reinado). |
| `metadata` | `JSONB` | Sim | Atributos específicos da aresta (Default: `'{}'`) |
| `created_at` | `TIMESTAMPTZ` | Sim | Data de criação da conexão. |

*   **Índices Recomendados:**
    *   `idx_relationships_source` (B-Tree em `source_id`)
    *   `idx_relationships_target` (B-Tree em `target_id`)
    *   `idx_relationships_compound` (B-Tree composto em `(source_id, target_id, type)`): Otimiza a checagem de conexões redundantes.
*   **Restrições (Constraints):**
    *   `prevent_self_relation`: `CHECK (source_id <> target_id)` (Impede auto-relacionamento de nós).

---

### G. Tabela: `entity_translations` (Internacionalização/i18n)
*   **Objetivo:** Traduzir todos os dados em linguagem natural (nomes, descrições e propriedades textuais) das entidades do Grafo.
*   **Justificativa:** Isolar os campos textuais voláteis de múltiplos idiomas em uma tabela anexa, mantendo as tabelas do Grafo livres de duplicação estrutural de colunas.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `entity_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `entities(id)` ON DELETE CASCADE |
| `locale` | `VARCHAR(10)` | Sim | Tag de idioma padrão ISO (ex: `"pt-BR"`, `"en-US"`, `"es-ES"`). |
| `name` | `VARCHAR(200)` | Sim | Nome de exibição traduzido da entidade. |
| `description` | `TEXT` | Sim | Corpo principal do dossiê ou sumário traduzido. |
| `properties_trans`| `JSONB` | Sim | Tradução de metadados específicos salvos de forma chave-valor. |

*   **Chave Primária Composta:** `(entity_id, locale)`
*   **Índices Recomendados:**
    *   `idx_entity_translations_locale` (B-Tree em `locale`): Acelera o carregamento de idiomas selecionados na interface.

---

### H. Tabela: `entity_sources` (Conexão Fatos-Evidências)
*   **Objetivo:** Associar de forma qualificada as entidades históricas às fontes de provas materiais e literárias que validam sua cientificidade.
*   **Justificativa:** Tabela de ligação N:M detalhada, amparando os princípios de transparência e verificação de fontes científicas da plataforma.
*   **Campos:**

| Campo | Tipo PostgreSQL | Obrigatório? | Detalhes / Chaves / Restrições |
| :--- | :--- | :--- | :--- |
| `entity_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `entities(id)` ON DELETE CASCADE |
| `source_id` | `UUID` | Sim | **Chave Estrangeira (FK)** $\rightarrow$ `sources(id)` ON DELETE CASCADE |
| `pages_referenced`| `VARCHAR(100)`| Não | Página, capítulo ou referência de catálogo arqueológico. |
| `context_quote` | `TEXT` | Não | Fragmento literário ou citação direta traduzida de apoio. |
| `created_at` | `TIMESTAMPTZ` | Sim | Data do vínculo editorial. |

*   **Chave Primária Composta:** `(entity_id, source_id)`

---

## 🛠️ 3. Lista de Tabelas da V1 e Ordem de Criação

Para construir fisicamente o banco de dados sem quebrar regras de restrições e dependências de chaves estrangeiras, as tabelas devem ser geradas estritamente na seguinte sequência lógica:

```
                                  [ auth.users ] (Supabase Core)
                                        │
                                        ▼
   ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
   │    sources      │       │ users_profiles  │       │    timelines    │
   └────────┬────────┘       └────────┬────────┘       └─────────────────┘
            │                         │
            │                         ▼
            │               ┌─────────────────┐
            │               │     entities    │
            │               └─┬─────────────┬─┘
            │                 │             │
            ▼                 ▼             ▼
   ┌─────────────────┐  ┌─────────────┐  ┌─────────────────────┐
   │ entity_sources  │  │relationships│  │ entity_translations │
   └─────────────────┘  └─────────────┘  └─────────────────────┘
                              ▲
                              │
                    ┌─────────┴───────┐
                    │  saved_dossiers │
                    └─────────────────┘
```

1.  **Tabela Mestre Interna (Fornecida pelo Supabase):** `auth.users`
2.  **`users_profiles`** (Depende de `auth.users`)
3.  **`sources`** (Sem dependências externas)
4.  **`timelines`** (Sem dependências externas)
5.  **`entities`** (Sem dependências externas diretas de herança, mas referenciada em sequência)
6.  **`relationships`** (Depende de `entities` para as colunas `source_id` e `target_id`)
7.  **`entity_translations`** (Depende de `entities`)
8.  **`entity_sources`** (Depende de `entities` e `sources`)
9.  **`saved_dossiers`** (Depende de `users_profiles` e `entities`)

---

## 🔬 4. Pontos Críticos de Atenção antes de Gerar as Migrations SQL

Antes de escrever os scripts DDL finais para o Supabase CLI, o time de engenharia de dados do CHRONOS deve certificar-se de:

1.  **Habilitar Extensões de Apoio:**
    *   O script SQL de migração inicial deve declarar de forma explícita a ativação da extensão **PostGIS** (`CREATE EXTENSION IF NOT EXISTS postgis;`) para o tipo `geometry(Point, 4326)`.
    *   Se for utilizar a busca semântica baseada em IA e embeddings do Gemini no banco de dados na V1.0, habilite também a extensão **pgvector** (`CREATE EXTENSION IF NOT EXISTS vector;`).
2.  **Configurar UUID Nativos:**
    *   Garanta que a extensão para chaves UUID automáticas esteja habilitada (`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`), permitindo o uso de `DEFAULT gen_random_uuid()` para todas as chaves primárias físicas.
3.  **Planejar Políticas Row Level Security (RLS) Estratégicas:**
    *   Tabelas de curadoria como `entities`, `relationships` e `entity_translations` devem conter políticas RLS de `SELECT` que permitam leitura pública anônima para registros com `status = 'published'`, e que permitam privilégios completos de escrita (`INSERT/UPDATE/DELETE`) exclusivamente para administradores autenticados (`auth.role() = 'service_role'` ou triggers específicas).
    *   A tabela `users_profiles` e `saved_dossiers` deve impor a restrição RLS estrita de que o usuário autenticado só possa consultar ou editar registros pertencentes ao seu próprio ID de usuário (`auth.uid() = user_id`).
4.  **Sincronização de updated_at por Triggers:**
    *   As tabelas `users_profiles` e `entities` devem possuir triggers de atualização automática do campo `updated_at` acionadas em eventos de modificação, prevenindo dados desatualizados na sincronização offline do aplicativo móvel.
