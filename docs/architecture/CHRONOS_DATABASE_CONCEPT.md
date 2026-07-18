# CHRONOS: Projeto Conceitual de Banco de Dados (Grafo de Conhecimento Semântico)

Este documento apresenta o **Projeto Conceitual de Banco de Dados** para o ecossistema CHRONOS, correspondente aos objetivos de arquitetura de dados da **Sprint 2**. 

---

## 🧭 1. Modelo Conceitual: Abordagem Híbrida Relacional-Grafo

Para satisfazer o requisito de que o CHRONOS funcione como um **Knowledge Graph** dinâmico e expansível, mas mantendo a integridade referencial, a performance de indexação e a facilidade de integração oferecidas pelo **PostgreSQL** no **Supabase**, adotamos uma **Arquitetura Híbrida de Grafo Relacional** baseada no modelo de **Property Graph (Grafo de Propriedades)**.

### A Estrutura Lógica (Nós e Arestas)
Em vez de criarmos dezenas de tabelas isoladas que exigiriam múltiplos `JOINs` complexos para conectar diferentes esferas do conhecimento (por exemplo, relacionar uma *Tecnologia* a uma *Mitologia*), a base do banco é unificada em torno de dois conceitos primitivos de grafos:

1.  **Nós (Entities):** Representam os elementos concretos ou abstratos da História e Mitologia. Todas as entidades herdam de uma estrutura base comum e possuem propriedades específicas.
2.  **Arestas (Edges/Relationships):** Representam as conexões direcionadas e tipadas entre dois nós quaisquer, contendo seus próprios atributos (como força do vínculo, período temporal e referências científicas).

---

## 🗂️ 2. Lista de Entidades (Entity Types)

Todas as entidades mapeadas no ecossistema CHRONOS são categorizadas sob o tipo genérico `entity_type`. Elas residem conceitualmente na tabela unificada de entidades (`entities`), diferenciando-se através de metadados específicos e esquemas semânticos flexíveis:

| Tipo de Entidade (`entity_type`) | Descrição Semântica | Atributos Específicos Comuns (JSONB) |
| :--- | :--- | :--- |
| **Civilização** | Impérios, pólis, reinos ou confederações tribais do passado. | Período de apogeu, capital de referência, sistema de governo. |
| **Personagem** | Indivíduos históricos, governantes, generais, filósofos ou plebeus. | Gênero, linhagem dinástica, local de nascimento/morte. |
| **Evento** | Acontecimentos datáveis pontuais ou de curta duração. | Duração estimada, impacto geopolítico direto. |
| **Guerra** | Conflitos armados de larga escala ou campanhas militares continuadas. | Causas formais, baixas estimadas, vencedor formal. |
| **Batalha** | Confronte armado individual inserido ou não em uma Guerra. | Táticas utilizadas, comandantes de campo, relevo geográfico. |
| **Tratado** | Acordos diplomáticos, pactos comerciais ou alianças políticas. | Signatários, cláusulas principais, duração da paz obtida. |
| **Local** | Coordenadas geográficas, sítios arqueológicos, cidades antigas ou acidentes geográficos. | Tipo de sítio (porto, fortificação, santuário), status arqueológico. |
| **Artefato** | Objetos físicos descobertos pela arqueologia (moedas, estátuas, armas). | Material de fabricação, museu de conservação atual, dimensões. |
| **Tecnologia** | Invenções materiais, avanços agrícolas, metalúrgicos ou arquitetônicos. | Setor de impacto (militar, agrário, náutico), predecessor técnico. |
| **Filosofia** | Escolas de pensamento, correntes intelectuais ou visões de mundo. | Fundador, conceitos centrais (ex: *ataraxia*, *logos*). |
| **Religião** | Sistemas de crença coletivos, rituais e estruturas clericais históricas. | Panteão principal, livros ou tradições sagradas, locais de culto. |
| **Mitologia** | Narrativas míticas, cosmologias, contos de fundação e genealogia divina. | Sistema de crença de origem, nível de sincretismo. |
| **Obra** | Tratados literários, poemas épicos, esculturas ou monumentos arquitetônicos. | Autor/Escultor, idioma original de redação, estado de conservação. |
| **Documento** | Fontes documentais primárias textuais (papiros, epigrafias). | Suporte original (argila, bronze, pergaminho), escrita utilizada (ex: uncial). |

---

## 🔗 3. Tipos de Relacionamentos (Edges/Relationships)

As arestas conectam de forma direcionada dois nós da tabela `entities` (`source_id` $\rightarrow$ `target_id`). Elas possuem semântica estrita, permitindo que o algoritmo de busca e navegação entenda o contexto da conexão.

### Principais Tipos de Relacionamentos (`relationship_type`):

*   `FOUNDED` (ex: *Personagem* $\rightarrow$ fundou $\rightarrow$ *Civilização*)
*   `RULED` (ex: *Personagem* $\rightarrow$ governou $\rightarrow$ *Civilização*)
*   `PARTICIPATED_IN` (ex: *Personagem* ou *Civilização* $\rightarrow$ participou de $\rightarrow$ *Batalha*)
*   `KILLED_BY` (ex: *Personagem A* $\rightarrow$ foi morto por $\rightarrow$ *Personagem B*)
*   `INVENTED` (ex: *Civilização* ou *Personagem* $\rightarrow$ inventou $\rightarrow$ *Tecnologia*)
*   `LOCATED_IN` (ex: *Batalha* ou *Artefato* $\rightarrow$ localizado geograficamente em $\rightarrow$ *Local*)
*   `DESCRIBES` (ex: *Documento* ou *Obra* $\rightarrow$ descreve $\rightarrow$ *Personagem*, *Batalha* ou *Evento*)
*   `INFLUENCED` (ex: *Filosofia A* $\rightarrow$ influenciou $\rightarrow$ *Filosofia B* ou *Personagem*)
*   `BELONGS_TO` (ex: *Deus Mítico* $\rightarrow$ pertence à $\rightarrow$ *Mitologia*)
*   `CHILD_OF` (ex: *Personagem A* $\rightarrow$ filho de $\rightarrow$ *Personagem B*)
*   `ALLIED_WITH` (ex: *Civilização A* $\rightarrow$ aliada de $\rightarrow$ *Civilização B*)

---

## 📐 4. Diagrama Entidade-Relacionamento (ER) Conceitual

Abaixo está a representação conceitual do grafo estruturado sobre o PostgreSQL em formato de diagrama de texto (Mermaid):

```mermaid
graph TD
    %% Tabela Principal de Nós (Entities)
    Entities["entities (Nós/Entities)<br/>--<br/>PK id (UUID)<br/>slug (VARCHAR)<br/>type (entity_type)<br/>evidence_level (evidence_level)<br/>dynamic_properties (JSONB)"]

    %% Tabela Principal de Conexões (Relationships)
    Relationships["relationships (Arestas/Edges)<br/>--<br/>PK id (UUID)<br/>FK source_id (UUID -> entities)<br/>FK target_id (UUID -> entities)<br/>type (relationship_type)<br/>time_start_raw (VARCHAR)<br/>time_start_val (BIGINT)<br/>metadata (JSONB)"]

    %% Estruturas Auxiliares para Fontes, Evidências e i18n
    Sources["sources (Fontes Primárias & Secundárias)<br/>--<br/>PK id (UUID)<br/>title (VARCHAR)<br/>author (VARCHAR)<br/>category (source_category)<br/>reference_url (VARCHAR)"]

    EntitySources["entity_sources (Associação N:M)<br/>--<br/>PK (entity_id, source_id)<br/>FK entity_id (-> entities)<br/>FK source_id (-> sources)<br/>context_quote (TEXT)<br/>pages_referenced (VARCHAR)"]

    Translations["entity_translations (Internacionalização)<br/>--<br/>PK (entity_id, locale)<br/>FK entity_id (-> entities)<br/>locale (VARCHAR/ISO)<br/>name (VARCHAR)<br/>description (TEXT)<br/>dynamic_properties_trans (JSONB)"]

    %% Relacionamentos do Banco de Dados
    Entities -->|1 : N| Relationships : "source_id"
    Entities -->|1 : N| Relationships : "target_id"
    Entities -->|1 : N| EntitySources
    Sources -->|1 : N| EntitySources
    Entities -->|1 : N| Translations
```

---

## ⏱️ 5. Estratégia para Representar a "Corrente do Tempo"

Representar o tempo histórico no PostgreSQL de forma linear contínua impõe desafios, pois o tipo nativo `DATE` ou `TIMESTAMP` do SQL não suporta de forma nativa anos anteriores a 4713 a.C. (limite do calendário Juliano Proléptico) e não lida com frações temporais imprecisas.

### A Solução CHRONOS: **Mapeamento Centesimal de Segundos Relativos (MSR)**
Para garantir linearidade matemática absoluta e indexação de performance, criamos uma coluna calculada indexada baseada em **BIGINT** denominada `time_value`.

*   **Ponto de Referência Zero (Epoch CHRONOS):** O início do ano **1 d.C.** às 00:00:00.
*   **Fórmula de Conversão:** Armazenamos a data expressa em um número inteiro correspondente a **segundos acumulados ou estimados em relação à Epoch 1 d.C.**
    *   Anos d.C. representam inteiros positivos.
    *   Anos a.C. representam inteiros negativos.
*   **Cálculo Simplificado para Busca por Séculos/Anos:**
    *   $1 \text{ ano} \approx 31.536.000 \text{ segundos}$.
    *   Se um evento ocorre no ano **100 a.C.**, seu `time_val` aproximado será de $-100 \times 31.536.000 = -3.153.600.000$.
*   **Vantagem:** Permite o uso de operadores relacionais matemáticos rápidos (`<`, `>`, `BETWEEN`, `ORDER BY`) que funcionam perfeitamente na escala de milhões de anos a.C. e d.C., permitindo a criação de **B-Tree indexes** para buscas de intervalo ultrarápidas na Linha do Tempo.

---

## 💬 6. Estratégia para Armazenar Datas Aproximadas

A precisão arqueológica exige tolerância a datas aproximadas. O CHRONOS resolve isso por meio de uma coluna de **Armazenamento de Incerteza Estruturada** na tabela `entities` e `relationships`:

```json
{
  "time_display_raw": "c. 3400 a.C.",
  "time_precision": "century",
  "time_margin_of_error_years": 100,
  "time_is_approximate": true
}
```

### Abordagem de Colunas Gêmeas:
Para cada campo temporal de início e fim, o banco armazena três colunas complementares:

1.  `time_start_val` (BIGINT, Obrigatório para ordenação): O valor numérico médio estimado em segundos em relação ao Epoch. Utilizado para posicionamento na linha do tempo.
2.  `time_start_raw` (VARCHAR, Obrigatório para exibição): A string exata fornecida pelos editores ou historiadores (ex: `"c. 3400 a.C."`, `"Fim do Século IV a.C."`, `"Idos de Março de 44 a.C."`). O aplicativo renderiza diretamente esta string para o usuário final, preservando o rigor literário.
3.  `time_precision_type` (ENUM): Define a granularidade do dado cronológico (`exact`, `decade`, `century`, `millennium`, `approximate`, `unknown`). O motor de renderização da linha do tempo usa isso para desenhar barras de incerteza visual ao redor do evento.

---

## 📚 7. Estratégia para Múltiplas Fontes por Conteúdo

O rigor científico do CHRONOS exige que cada fato afirmado seja amparado por uma ou mais fontes verificáveis. 

### Tabela de Associação N:M (`entity_sources`):
Implementamos um modelo de junção altamente qualificado que não apenas vincula uma entidade a um documento, mas também contextualiza a prova arqueológica ou historiográfica:

*   `entities` (1) $\rightarrow$ (N) `entity_sources` (N) $\rightarrow$ (1) `sources`

### Atributos da Tabela Intermediária `entity_sources`:
*   `context_quote` (TEXT): A citação exata (em latim, grego ou tradução consagrada) que confirma o fato narrado no dossiê.
*   `pages_referenced` (VARCHAR): Página, capítulo, livro ou número do fórum onde a inscrição ou fragmento pode ser localizado.
*   `evidence_confidence` (ENUM): Grau de aceitação da fonte pela comunidade acadêmica contemporânea (`consensus`, `disputed`, `minority_hypothesis`).

---

## 🔬 8. Estratégia para Níveis de Evidência

Conforme estabelecido nas premissas editoriais do projeto, o CHRONOS repudia o dogmatismo e expõe de forma transparente a qualidade material de suas asserções. Cada nó da tabela `entities` carrega uma coluna estruturada com o seu respectivo nível de evidência científica.

### Escala de Evidência (`evidence_level` ENUM):
1.  **`level_1_archaeological_monumental`:** Sítios, fortificações ou edifícios físicos escavados e preservados (ex: *Coliseu*, *Teatro de Pompeu*).
2.  **`level_2_archaeological_movable`:** Objetos de cultura material descobertos in situ (ex: *Moedas, Armas, Cerâmicas*).
3.  **`level_3_epigraphic`:** Inscrições permanentes gravadas em pedra, bronze ou argila (ex: *Res Gestae*, *Estela de Hamurabi*).
4.  **`level_4_textual_primary`:** Textos literários contemporâneos ou quase contemporâneos aos fatos narrados (ex: *Anais* de Tácito).
5.  **`level_5_textual_secondary`:** Cópias tardias, compilações bizantinas ou crônicas medievais de obras antigas perdidas.
6.  **`level_6_historiographical_consensus`:** Conclusões e sínteses analíticas amplamente consensuais de pesquisadores modernos.
7.  **`level_7_mythological_traditional`:** Tradições míticas e teogônicas sem correlação empírica material demonstrável (ex: *Teogonia* de Hesíodo).

### Uso Visual no App:
Esta classificação alimentará diretamente uma insígnia (badge) interativa na UI do aplicativo Flutter, educando o usuário sobre a confiabilidade científica do dossiê que ele está consumindo.

---

## 🌐 9. Estratégia para Internacionalização Futura (i18n)

Para permitir a expansão internacional do CHRONOS sem inflar a tabela principal de entidades com colunas duplicadas (`name_pt`, `name_en`, `description_pt`, etc.), adotamos o padrão de **Tabela de Tradução de Atributos Locais** (`entity_translations`).

### Funcionamento do Modelo:
A tabela `entities` contém apenas identificadores de sistema (como ID, slug, coordenadas e tipo de evidência). Todos os textos em linguagem natural legíveis por humanos são migrados para a tabela `entity_translations`:

*   **Chave Primária Composta:** `(entity_id, locale)` onde `locale` é a tag de idioma ISO (ex: `"pt-BR"`, `"en-US"`, `"es-ES"`).
*   **Propriedades Dinâmicas Traduzidas (`dynamic_properties_trans` JSONB):** Permite traduzir campos de propriedades que variam de acordo com o tipo de entidade, mantendo flexibilidade total no Grafo.

---

## ⚖️ 10. Justificativa das Decisões Arquiteturais

1.  **Por que PostgreSQL/Supabase em vez de um Graph Database Nativo (Neo4j)?**
    *   *Redução de Custo e Complexidade:* O Supabase oferece uma infraestrutura de backend pronta, autenticação nativa (Supabase Auth), storage e escalabilidade sem a necessidade de manter e gerenciar um banco de dados NoSQL de grafos separado.
    *   *Consultas Híbridas:* O CHRONOS exige buscas relacionais padrão (como perfis de usuários, logs de leitura, favoritos) que são complexas e ineficientes em bancos de grafos nativos.
    *   *pgvector:* O PostgreSQL possui suporte avançado a busca semântica e IA por meio do vetor `pgvector`, que usaremos extensivamente no mecanismo CKE.
2.  **Por que uma tabela unificada `entities` com JSONB em vez de Table Per Type (TPT)?**
    *   A herança clássica de tabelas em bancos relacionais gera excesso de `JOINs` que degradam a performance de renderização em tempo real de mapas e linhas do tempo.
    *   A coluna `dynamic_properties` (JSONB) permite que novas propriedades de entidades (como "táticas militares" para batalhas) sejam criadas pelos editores sem a necessidade de realizar migrações de DDL físicas no banco de dados.
3.  **Por que converter datas em BIGINT (`time_value`)?**
    *   Sistemas operacionais e bancos de dados falham em ordenar datas negativas complexas a.C. O mapeamento matemático de segundos relativos permite indexação **B-Tree** nativa de alta performance, garantindo que a rolagem da linha do tempo ocorra a 60/120fps sem engasgos de processamento.

---

## 🔍 Crítica ao Modelo e Sugestões de Melhorias Técnicas

Antes de prosseguirmos para o desenvolvimento físico do banco de dados no Supabase, é fundamental analisar os pontos de vulnerabilidade deste modelo e planejar as mitigações correspondentes:

### 1. Desafio de Desempenho em Consultas Recursivas do Grafo (Graph Traversals)
*   *Crítica:* Em um modelo unificado de arestas (`relationships`), consultas recursivas profundas (ex: *"Encontre todas as tecnologias influenciadas indiretamente pelos filósofos contemporâneos a Júlio César"*) podem se tornar lentas à medida que a base cresce para centenas de milhares de nós.
*   *Melhoria Proposta:* Implementar **Common Table Expressions (CTEs) Recursivos** no PostgreSQL encapsulados em **Stored Procedures (Functions)** do Postgres, garantindo que o processamento do grafo ocorra diretamente na memória RAM do banco, retornando apenas o payload final otimizado via JSON para o Flutter.

### 2. Validação de Integridade do campo JSONB `dynamic_properties`
*   *Crítica:* A flexibilidade do JSONB pode levar a inconsistências se um editor cadastrar por engano o atributo `"area_km2"` como string (`"dez mil"`) em vez de inteiro (`10000`).
*   *Melhoria Proposta:* Implementar triggers em PL/pgSQL que validem o schema JSONB (utilizando validação regex ou extensões de validação JSON do Postgres) sempre que uma linha da tabela `entities` for inserida ou modificada.

### 3. Densidade de Nós em Civilizações Centrais
*   *Crítica:* Civilizações massivas como "Império Romano" possuirão dezenas de milhares de arestas conectadas. Fazer o carregamento inicial de todas as arestas de um único nó causará estouro de memória no aplicativo Flutter.
*   *Melhoria Proposta:* Adotar **Paginamento de Arestas** e filtros por relevância/prioridade (`priority_level` de 1 a 5 nas entidades) para carregar inicialmente apenas os nós estruturais de maior impacto visual, expandindo os detalhes conforme o usuário dá zoom na tela.
