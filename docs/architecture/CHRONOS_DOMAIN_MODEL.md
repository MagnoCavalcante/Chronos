# CHRONOS: Modelagem de Domínio e Engenharia de Grafo (Sprint 2.1)

Este documento apresenta a especificação conceitual do domínio do sistema **CHRONOS**, aplicando princípios de **Domain-Driven Design (DDD)** e arquitetura de Grafos de Conhecimento para mapear as interações e fronteiras conceituais do projeto.

---

## 🧭 1. Grandes Domínios do Sistema (Bounded Contexts)

Para gerenciar a complexidade do universo histórico e mitológico do CHRONOS, dividimos o sistema em **cinco grandes domínios de contexto**, cada um responsável por uma faceta lógica e de dados do ecossistema:

```
                  ┌──────────────────────────────────────────────┐
                  │            CHRONOS CORE ENGINE               │
                  └──────────────────────┬───────────────────────┘
                                         │
       ┌──────────────────┬──────────────┴──────┬──────────────────┬─────────────────┐
       ▼                  ▼                     ▼                  ▼                 ▼
┌──────────────┐   ┌──────────────┐      ┌──────────────┐   ┌──────────────┐  ┌──────────────┐
│  Espaço-Tempo │   │  Científico  │      │ Sociopolítico│   │ Intelectual  │  │ Mitologia e  │
│  e Cronologia│   │ e Histórico  │      │   e Humano   │   │ e Cultural   │  │   Crenças    │
└──────────────┘   └──────────────┘      └──────────────┘   └──────────────┘  └──────────────┘
```

1.  **Domínio de Espaço-Tempo e Cronologia (Time-Space Engine):**
    *   *Propósito:* Gerenciar a ancoragem temporal, os eixos de transição linear, os recortes cartográficos e a mutabilidade das fronteiras territoriais.
2.  **Domínio Científico-Historiográfico (Scientific & Evidence Core):**
    *   *Propósito:* Validar as afirmações históricas contra evidências materiais de escavação, epigrafias ou manuscritos primários, graduando o nível de certeza científica.
3.  **Domínio Sociopolítico e Humano (Humanities Domain):**
    *   *Propósito:* Modelar os atores históricos individuais, a ascensão e queda de civilizações unificadas, tratados de paz e dinâmicas de conflitos bélicos.
4.  **Domínio Intelectual e Cultural (Cultural & Thought Core):**
    *   *Propósito:* Mapear a transmissão do conhecimento abstrato humano, incluindo o progresso tecnológico material, as escolas de filosofia e as manifestações artísticas/literárias.
5.  **Domínio de Mitologia e Crenças (Myth & Lore Domain):**
    *   *Propósito:* Catalogar as religiões históricas, as cosmologias tradicionais de povos antigos, seus panteões de divindades e narrativas lendárias.

---

## 🗂️ 2. Lista de Entidades por Domínio

Abaixo estão descritas todas as entidades centrais do CHRONOS. Cada entidade é especificada pela sua responsabilidade, informações intrínsecas e relacionamentos típicos no Grafo.

---

### A. Domínio de Espaço-Tempo e Cronologia

#### 1. Linha do Tempo (`Timeline`)
*   **O que representa:** Um eixo cronológico linear de eventos coordenados de forma sequencial de acordo com um contexto (ex: "História de Atenas", "Grandes Batalhas de Roma").
*   **Responsabilidade:** Agrupar e ordenar sequências de acontecimentos para renderização dinâmica na tela do usuário.
*   **Informações que deve conter:** ID único, Título Comercial, Descrição Temática, Escopo Temporal (Ano de Início e Fim), Prioridade Visual de Exibição.
*   **Relaciona-se com:** `Era` (N:M), `Event` (1:N), `Civilization` (N:1).

#### 2. Era (`Era`)
*   **O que representa:** Grandes divisões históricas ou de eixos de transição macro com características sociais ou geográficas homogêneas (ex: "Período Helenístico", "República Romana").
*   **Responsabilidade:** Segmentar a macro-história para navegação conceitual.
*   **Informações que deve conter:** ID, Nome, Descrição de Características da Era, Ano de Transição Inicial, Ano de Transição Final.
*   **Relaciona-se com:** `Timeline` (N:M), `Civilization` (1:N), `Event` (1:N).

#### 3. Evento (`Event`)
*   **O que representa:** Um acontecimento pontual ou de curta duração ancorado no tempo linear (ex: "Assassinato de Júlio César", "Inauguração do Coliseu").
*   **Responsabilidade:** Servir como o nó mestre de causalidade histórica.
*   **Informações que deve conter:** ID, Título, Descrição, Data Relativa Inteira (`time_value`), Data de Exibição Literal, Tipo de Precisão Temporal, Impacto de Causalidade.
*   **Relaciona-se com:** `Location` (N:1), `Personage` (N:M), `Civilization` (N:M), `Source` (N:M).

#### 4. Local (`Location`)
*   **O que representa:** Coordenadas GPS e dados espaciais correspondentes a sítios do passado (ex: "Fórum de Pompeia", "Pólis de Esparta").
*   **Responsabilidade:** Georreferenciar nós no mapa histórico global.
*   **Informações que deve conter:** ID, Nome Histórico, Nome Geográfico Moderno, Coordenadas Geográficas (Latitude/Longitude), Tipo de Local (Sítio Arqueológico, Fortaleza, Porto, Templo).
*   **Relaciona-se com:** `Event` (1:N), `Artefact` (1:N), `Civilization` (N:M).

---

### B. Domínio Científico-Historiográfico

#### 5. Documento (`Document`)
*   **O que representa:** Manuscritos, rolos de papiro ou inscrições antigas sobreviventes que carregam dados de escrita direta (ex: "Código de Hamurabi", "Manuscritos do Mar Morto").
*   **Responsabilidade:** Servir como registro material textual primário.
*   **Informações que deve conter:** ID, Nome Catalogado, Idioma Original, Escrita Utilizada, Suporte de Gravação (Argila, Bronze, Pergaminho), Estado de Conservação.
*   **Relaciona-se com:** `Location` (N:1), `Artefact` (1:1), `Source` (1:N).

#### 6. Fonte (`Source`)
*   **O que representa:** O lastro literário ou historiográfico que embasa um fato específico. Pode ser uma fonte antiga (ex: passagens de Tácito) ou de historiografia moderna.
*   **Responsabilidade:** Fornecer rastreabilidade e verificabilidade para as afirmações do CHRONOS.
*   **Informações que deve conter:** ID, Título da Obra, Autor, Categoria (Primária Clássica, Arqueológica, Secundária Contemporânea), Citação Exata Associada (Context Quote).
*   **Relaciona-se com:** `Event` (N:M), `Personage` (N:M), `Document` (N:1), `Bibliography` (N:1).

#### 7. Artefato (`Artefact`)
*   **O que representa:** Qualquer objeto físico de cultura material recuperado pela arqueologia (ex: "Busto de Júlio César", "Biga Etíope", "Moeda de Cleópatra").
*   **Responsabilidade:** Fornecer suporte empírico e ilustrativo para as narrativas da plataforma.
*   **Informações que deve conter:** ID, Nome do Objeto, Material (Bronze, Ouro, Mármore), Dimensões, Museu de Conservação Atual, Ano de Descoberta.
*   **Relaciona-se com:** `Location` (N:1), `Civilization` (N:1), `Document` (1:1).

---

### C. Domínio Sociopolítico e Humano

#### 8. Personagem (`Personage`)
*   **O que representa:** Indivíduos reais e marcantes da história da humanidade (ex: "Alexandre o Grande", "Cícero").
*   **Responsabilidade:** Humanizar a história e concentrar as biografias e decisões de liderança.
*   **Informações que deve conter:** ID, Nome Histórico Completo, Cognome, Data de Nascimento e Morte, Biografia Estruturada, Nível de Evidência Científica.
*   **Relaciona-se com:** `Civilization` (N:M), `Event` (N:M), `Source` (N:M), `Religion` (N:1).

#### 9. Civilização (`Civilization`)
*   **O que representa:** Estados organizados, impérios, confederações ou tribos com identidade cultural e política comum (ex: "Império Selêucida", "Cartago").
*   **Responsabilidade:** Unificar o escopo macro de cultura, fronteiras e eras de domínio.
*   **Informações que deve conter:** ID, Nome Comercial, Período de Apogeu, Capital de Referência, Idioma Oficial de Administração, Religião de Estado Principal.
*   **Relaciona-se com:** `Era` (N:M), `Personage` (N:M), `Location` (N:M), `Technology` (N:M).

#### 10. Guerra (`War`)
*   **O que representa:** Conflito bélico organizado prolongado entre duas ou mais potências do passado (ex: "Guerra do Peloponeso", "Segunda Guerra Púnica").
*   **Responsabilidade:** Contextualizar e agrupar conjuntos de batalhas, causas políticas e alterações territoriais drásticas.
*   **Informações que deve conter:** ID, Nome do Conflito, Causas Principais declaradas, Anos de Início e Término, Beligerantes (Atacantes e Defensores), Baixas Estimadas.
*   **Relaciona-se com:** `Civilization` (N:M), `Battle` (1:N), `Treaty` (1:1).

#### 11. Batalha (`Battle`)
*   **O que representa:** Confronto físico militar pontual ocorrido em coordenadas espaciais e temporais específicas (ex: "Batalha de Farsalos", "Batalha de Termópilas").
*   **Responsabilidade:** Fornecer táticas, perfis de comandantes militares e desfechos heróicos ou táticos.
*   **Informações que deve conter:** ID, Nome, Táticas Empregadas, Comandantes Envolvidos, Vencedor Formal, Baixas Detalhadas.
*   **Relaciona-se com:** `War` (N:1), `Location` (N:1), `Personage` (N:M).

#### 12. Tratado (`Treaty`)
*   **O que representa:** Acordos diplomáticos, pactos de não agressão ou alianças formais firmadas (ex: "Tratado de Paz de Cades").
*   **Responsabilidade:** Modelar o desfecho diplomático de guerras e as dinâmicas de equilíbrio de poder.
*   **Informações que deve conter:** ID, Nome do Pacto, Cláusulas Principais, Consequências de Longo Prazo, Signatários Representantes.
*   **Relaciona-se com:** `War` (1:1), `Civilization` (N:M), `Personage` (N:M).

---

### D. Domínio Intelectual e Cultural

#### 13. Tecnologia (`Technology`)
*   **O que representa:** Invenções técnicas, avanços agrícolas, metalúrgicos, táticos ou marítimos (ex: "Astrolábio", "Arado de Ferro", "Falange Macedônica").
*   **Responsabilidade:** Ilustrar a evolução técnico-científica de cada sociedade.
*   **Informações que deve conter:** ID, Nome Técnico, Setor de Impacto (Militar, Agrícola, Comercial, Náutico), Predecessor Técnico, Impacto no Rendimento Econômico.
*   **Relaciona-se com:** `Civilization` (N:M), `Personage` (N:M), `Artefact` (N:1).

#### 14. Filosofia (`Philosophy`)
*   **O que representa:** Escolas de pensamento ou correntes éticas e intelectuais (ex: "Estoicismo", "Epicurismo", "Platonismo").
*   **Responsabilidade:** Estruturar a história das ideias abstratas e conceitos de vida.
*   **Informações que deve conter:** ID, Nome da Corrente, Escola Fundadora, Conceitos Centrais de Filosofia (ex: *ataraxia*, *razão natural*), Atitude Ética Recomendada.
*   **Relaciona-se com:** `Personage` (N:M), `Civilization` (N:M), `Work` (N:M).

#### 15. Obra (`Work`)
*   **O que representa:** Manifestações artísticas intelectuais específicas legadas à humanidade, sejam livros, estátuas, monumentos ou poemas (ex: "Eneida" de Virgílio, "Metafísica" de Aristóteles).
*   **Responsabilidade:** Catalogar a produção literária e artística do passado.
*   **Informações que deve conter:** ID, Título, Autor original, Gênero da Obra (Épico, Historiográfico, Filosófico), Ano Estimado de Escrita/Criação.
*   **Relaciona-se com:** `Personage` (N:1), `Civilization` (N:1), `Document` (1:1).

---

### E. Domínio de Mitologia e Crenças

#### 16. Religião (`Religion`)
*   **O que representa:** Sistemas coletivos de cultos, rituais clericais e panteões que coordenaram a vida cívica e espiritual das civilizações (ex: "Religião Romana de Estado", "Zoroatrismo").
*   **Responsabilidade:** Modelar o pano de fundo metafísico em que os atores históricos operaram.
*   **Informações que deve conter:** ID, Nome do Sistema de Crença, Livros/Tradições Sagradas, Práticas de Culto Principais, Estrutura Sacerdotal (ex: *Pontífices*).
*   **Relaciona-se com:** `Civilization` (N:M), `Location` (N:M), `Personage` (N:M), `Mythology` (1:1).

#### 17. Mitologia (`Mythology`)
*   **O que representa:** O corpus de narrativas lendárias, sagradas e teogônicas de uma civilização, diferenciando-se da história material baseada em evidências.
*   **Responsabilidade:** Catalogar o folclore e o fantástico conceitual de cada sociedade.
*   **Informações que deve conter:** ID, Nome da Mitologia, Cosmologia Base (Origem do Mundo), Nível de Sincretismo Cultural.
*   **Relaciona-se com:** `Religion` (1:1), `Civilization` (N:1).

---

## 🏛️ 3. Avaliação das Duas Abordagens Arquiteturais

Para materializar este vasto e interconectado domínio no banco de dados, avaliamos duas correntes de modelagem no PostgreSQL/Supabase:

### Abordagem 1: Banco de Dados Relacional Tradicional (TPT - Table Per Type)
*   **Conceito:** Cada uma das 17 entidades descritas acima possui uma tabela física própria com colunas estritas e específicas (`personages`, `battles`, `technologies`, etc.). Relacionamentos são construídos por dezenas de tabelas de associação intermediárias (N:M) (ex: `personage_battles`, `civilization_technologies`).

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   personages    │◄─────►│personage_battles│◄─────►│    battles      │
└─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Abordagem 2: Modelo Híbrido Relacional-Grafo (Property Graph sobre Postgres)
*   **Conceito:** Unificação conceitual. Criamos duas tabelas estruturais centrais: `entities` (Nós) e `relationships` (Arestas direcionadas e tipadas). Atributos específicos e mutáveis de cada entidade são salvos em colunas semi-estruturadas de alta performance (`JSONB`), enquanto propriedades fixas de sistema (ID, slug, nível de evidência e coordenadas geográficas) possuem colunas nativas indexadas.

```
┌────────────────────────────────────────────────────────┐
│                        entities                        │
├────────────────────────────────────────────────────────┤
│ PK id  │  type (personage)  │  properties (JSONB)      │
└────┬───────────────────────────────────────────────▲───┘
     │                                               │
     │                 ┌───────────────┐             │
     └────────────────►│ relationships │─────────────┘
                       ├───────────────┤
                       │ FK source_id  │
                       │ FK target_id  │
                       │ type (ruled)  │
                       └───────────────┘
```

---

## ⚖️ 4. Comparativo de Vantagens e Desvantagens

| Critério de Comparação | Abordagem 1: Relacional Tradicional (TPT) | Abordagem 2: Híbrido Relacional-Grafo (CKE) |
| :--- | :--- | :--- |
| **Integridade de Dados** | **Altíssima:** Chaves estrangeiras estritas e restrições de tipo de coluna evitam inconsistências de dados. | **Alta:** Garantida por validações de esquema JSONB em nível de aplicação e triggers PL/pgSQL no banco. |
| **Facilidade de Escrita de Queries (SQL)** | **Complexa (Múltiplos JOINs):** Cruzar dados de 4 entidades exige encadear múltiplos `JOINs`, impactando performance de escrita de queries complexas. | **Simples (Navegação de Nós):** Consultar qualquer conexão exige selecionar apenas as tabelas `entities` e `relationships`. |
| **Flexibilidade de Evolução do Esquema** | **Baixa:** Adicionar novas entidades ou propriedades exige a alteração física de tabelas (`ALTER TABLE`), migrações DDL e downtime potencial. | **Altíssima:** Novos tipos de entidades e propriedades adicionais são inseridos instantaneamente no campo JSONB sem alterar o banco de dados físico. |
| **Desempenho de Leitura (Timelines e Mapas)** | **Médio-Baixo:** Fazer varreduras gerais na linha do tempo varrendo 10 tabelas diferentes e ordenando datas é extremamente custoso. | **Excelente:** Uma única varredura em `entities` indexada por `time_value` (BIGINT) retorna todos os eventos, personagens e batalhas ordenados em milissegundos. |
| **Adequação para Busca Semântica (Embeddings)** | **Moderada:** Exige espalhar campos vetoriais de embeddings por 15 tabelas separadas, dificultando buscas gerais. | **Nativa e Centralizada:** O campo de embedding reside de forma única na tabela `entities`, permitindo busca semântica em todo o Grafo de uma só vez. |
| **Complexidade de Implementação Inicial** | **Baixa:** Segue os preceitos de modelagem relacional ensinados convencionalmente na academia. | **Média-Alta:** Exige projetar um motor de navegação de grafos e triggers robustas de segurança e integridade de dados. |

---

## 🎯 5. Recomendação e Justificativa Arquitetural

**Recomendação Técnica: Abordagem 2 - Modelo Híbrido Relacional-Grafo (CKE)**

Para as ambições de longo prazo do **CHRONOS**, a **Abordagem 2 (Híbrida)** é a única capaz de sustentar o crescimento e mutabilidade de dados necessários para uma plataforma interativa de exploração temporal por muitos anos, pelas seguintes razões técnicas:

1.  **Uniformidade da Linha do Tempo e Mapas:** No CHRONOS, a interface móvel renderiza na linha do tempo, de forma unificada, nascimentos de personagens, guerras, eventos civis e invenções tecnológicas de forma concorrente. Na abordagem tradicional, o banco realizaria múltiplos `SELECT UNION` em 10 tabelas com estruturas e índices diferentes. No modelo híbrido, a busca de intervalo (`BETWEEN`) ocorre em uma única tabela (`entities`) filtrada pela coluna de indexação inteira linear `time_value` (B-Tree index), garantindo rolagem fluida de tela a 120fps no Flutter.
2.  **Razoabilidade do Grafo de Conhecimento:** Novas descobertas arqueológicas alteram a forma como entendemos relacionamentos históricos. No modelo relacional, criar uma nova conexão inesperada (ex: conectar uma *Religião* diretamente a uma *Tecnologia*) exigiria a criação de uma tabela de ligação física. No modelo híbrido, basta registrar uma nova linha na tabela `relationships` especificando `source_id`, `target_id` e o tipo `INFLUENCED_BY`.
3.  **Performance Centralizada de Inteligência Artificial (AI Grounding):** Para alimentar os agentes especialistas do Google AI Studio (Gemini) com contexto de dados confiáveis via Retrieval-Augmented Generation (RAG), necessitaremos calcular e armazenar embeddings vetoriais de similaridade semântica. Manter um índice de embedding centralizado na tabela `entities` permite que o sistema busque e recupere informações de toda a plataforma instantaneamente com uma única query `pgvector`.

---

## 🔬 6. Crítica de Risco e Próximos Passos (Mitigações)

Apesar de ser a recomendação superior, a arquitetura híbrida relacional-grafo introduz riscos específicos que o time de arquitetura do CHRONOS deve mitigar logo no início do desenvolvimento físico no Supabase:

*   **Risco 1: Perda de Restrições Estritas de Integridade Referencial no campo `properties` (JSONB):**
    *   *Mitigação:* Criaremos Triggers em PL/pgSQL na fase física que validam a estrutura do JSONB contra um esquema definido baseado no `entity_type` do nó, disparando rejeição automática de inserção caso propriedades obrigatórias estejam ausentes ou incorretamente tipadas.
*   **Risco 2: Gargalos em Consultas Recursivas no Postgres:**
    *   *Mitigação:* Limitaremos a profundidade de recursão das queries do grafo nas Stored Procedures no banco de dados e usaremos cache de memória local no aplicativo Flutter para armazenar nós já consultados, evitando requisições redundantes ao Supabase.
