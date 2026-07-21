# Historical Knowledge Graph Architecture

Este documento especifica a fundação conceitual e a arquitetura oficial do **Historical Knowledge Graph** do ecossistema **CHRONOS**. Esta estrutura serve como uma camada de abstração semântica projetada para interconectar as entidades históricas do sistema de maneira escalável, performática e flexível.

---

## 1. Visão Geral

O **Historical Knowledge Graph** é responsável por modelar e representar relacionamentos semânticos e temporais complexos entre diferentes entidades históricas. 

### Diretrizes de Projeto:
* **Camada Semântica Sobreposta**: As entidades históricas (como Eras, Eventos, Personagens, Civilizações, Artefatos e Localizações) continuam existindo de forma independente no modelo relacional tradicional. O grafo funciona como uma camada semântica sobreposta que correlaciona estes registros.
* **Preservação do Modelo Relacional**: Nenhuma entidade existente precisa ser alterada ou ter suas tabelas originais reestruturadas. O grafo consome chaves primárias e metadados para construir conexões semânticas.
* **Alta Compatibilidade**: Desenhado sob medida para compatibilidade total com bancos de dados relacionais (**PostgreSQL**), permitindo travessias rápidas de relacionamentos recursivos usando cláusulas **Recursive CTE (Common Table Expressions)**.

---

## 2. Entidades Participantes do Grafo

Qualquer entidade histórica atual ou futura do ecossistema CHRONOS pode ser representada como um nó (`GraphNode`) no grafo de conhecimento. Isso inclui, mas não se limita a:

* **Era** (Períodos cronológicos)
* **HistoricalEvent** (Eventos e marcos temporais)
* **HistoricalCharacter** (Figuras históricas e personalidades)
* **Civilization** (Impérios, dinastias e sociedades)
* **Artifact** (Relíquias, invenções e registros arqueológicos)
* **HistoricalLocation** (Base geográfica e espacial oficial)
* **HistoricalSource** (Fontes acadêmicas e bibliografia)
* **Future Entities** (Quaisquer novos domínios acoplados futuramente)

---

## 3. Modelo Conceitual do Grafo

A modelagem do grafo é composta estritamente por dois elementos conceituais fundamentais: **Nós (Nodes)** e **Arestas (Edges)**.

### A. GraphNode (Nó do Grafo)
Representa de forma genérica e agnóstica qualquer entidade do sistema CHRONOS participando da rede de conhecimento.

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | UUID | Identificador exclusivo do nó no grafo. |
| `entityType` | String / Enum | O domínio da entidade de origem (ex: `character`, `event`, `civilization`). |
| `entityId` | UUID | Identificador físico da entidade na tabela relacional de origem. |
| `title` | String | Nome ou título humanizado do nó para renderização simplificada. |
| `slug` | String | Slug único para resolução de URLs amigáveis. |
| `publicationStatus` | Enum | Estado de publicação do nó (`draft`, `published`, `archived`). |

### B. GraphEdge (Aresta do Grafo)
Define uma relação direcionada, valorada e semanticamente rica ligando um nó de origem a um nó de destino.

| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | UUID | Identificador exclusivo do relacionamento. |
| `sourceNodeId` | UUID | Identificador do nó de origem (`GraphNode`). |
| `targetNodeId` | UUID | Identificador do nó de destino (`GraphNode`). |
| `relationshipType` | Enum | O classificador semântico exato da relação. |
| `weight` | Double | Intensidade histórica do relacionamento (escala quantitativa). |
| `confidence` | Enum | Nível de confiabilidade histórica da informação. |
| `startYear` | Integer (opcional) | Ano de início em que a relação se tornou ativa no tempo. |
| `endYear` | Integer (opcional) | Ano de término da relação se aplicável. |
| `historicalSourceId` | UUID (opcional) | Referência para a fonte histórica original que valida a relação. |
| `notes` | String (opcional) | Notas acadêmicas ou observações adicionais sobre o relacionamento. |

---

## 4. Tipos de Relacionamento (Relationship Types)

A semântica das arestas é altamente expressiva e tipada, cobrindo interações políticas, geográficas, dinásticas, cronológicas e de impacto tecnológico:

* **participated_in**: Julius Caesar participou da Guerra das Gálias.
* **occurred_in**: A Guerra das Gálias ocorreu na região da Gália.
* **created**: Uma civilização ou figura gerou uma obra, tratado ou instituição.
* **invented**: Johannes Gutenberg inventou a prensa de tipos móveis.
* **governed**: Imperadores governando seus impérios.
* **founded**: Rômulo fundando a cidade de Roma.
* **destroyed**: A queda ou destruição de uma cidade por invasores.
* **influenced**: O Império Romano influenciou o Império Bizantino.
* **allied_with**: Alianças diplomáticas e tratados militares entre nações.
* **enemy_of**: Relações oficiais de conflito armado ou rivalidade.
* **ancestor_of**: Relações de ancestralidade biológica ou dinástica.
* **successor_of**: Sucessão direta ao trono ou cargo de liderança.
* **predecessor_of**: Cargo ou estrutura anterior que deu origem ao novo.
* **located_in**: Localização de um monumento, artefato ou batalha dentro de um ponto geográfico.
* **capital_of**: A cidade servindo como capital oficial de um império ou reino.
* **member_of**: Indivíduos participantes de uma escola filosófica, conselho ou grupo.
* **traded_with**: Rotas comerciais de comércio frequente entre civilizações.
* **discovered**: Descobrimento geográfico ou arqueológico.
* **built**: Edificação de monumentos, estradas ou muralhas.
* **used**: Utilização frequente de artefatos por determinados povos.
* **mentioned_by**: Citações em fontes bibliográficas e literaturas antigas.
* **inspired**: Impacto estético ou conceitual que inspirou movimentos posteriores.

---

## 5. Escala de Confiabilidade (Confidence)

Dado que a pesquisa histórica trabalha frequentemente com fontes incompletas, controversas ou parciais, as arestas contêm uma classificação de confiança baseada no nível de consenso acadêmico e integridade das fontes:

* **very_low**: Evidência puramente lendária, mítica ou de tradição oral tardia sem suporte arqueológico direto.
* **low**: Informação debatida, com forte discordância entre historiadores ou baseada em fontes secundárias únicas e fragmentadas.
* **medium**: Consenso histórico razoável apoiado em fontes escritas correlacionadas, porém sem ricas confirmações arqueológicas.
* **high**: Consenso amplamente estabelecido na historiografia moderna com farta documentação cruzada.
* **verified**: Fato material incontestável com farta documentação contemporânea coerente e evidências arqueológicas diretas irrefutáveis.

---

## 6. Peso Histórico (Weight)

O peso (`weight`) representa a intensidade ou impacto histórico da relação. Ele quantifica de forma abstrata quão crucial é aquela aresta na teia histórica, permitindo que algoritmos de recomendação ou renderização visual destaquem conexões principais:

* **Pequena Influência** ($w < 0.3$): Interação diplomática secundária, trocas comerciais ocasionais ou encontros esporádicos.
* **Forte Influência** ($0.3 \le w < 0.8$): Relação de vassalagem, influências artísticas marcantes, alianças duradouras ou campanhas militares prolongadas.
* **Causalidade Direta / Impacto Crucial** ($w \ge 0.8$): O evento de origem determina diretamente a existência ou colapso do destino (ex: assassinato de um monarca iniciando uma guerra, invenção de Gutenberg estruturando a circulação de conhecimento).

---

## 7. Exemplos Práticos de Representação Semântica

Abaixo estão descritos graficamente os fluxos estruturados de conhecimento que o grafo modela de forma semântica pura:

### Exemplo A: Participação em Evento Militar e Localização Geográfica
```
[Julius Caesar] (entityType: character)
     │
     └───► (relationshipType: participated_in | confidence: verified | weight: 0.95)
              │
              ▼
     [Gallic Wars] (entityType: event)
              │
              └───► (relationshipType: occurred_in | confidence: high | weight: 0.8)
                       │
                       ▼
              [Gaul] (entityType: location)
```

### Exemplo B: Influência Histórica entre Civilizações e Impérios
```
[Roman Empire] (entityType: civilization)
     │
     └───► (relationshipType: influenced | confidence: verified | weight: 0.85)
              │
              ▼
     [Byzantine Empire] (entityType: civilization)
```

### Exemplo C: Invenção de Tecnologia e Atribuição de Autoria
```
[Printing Press] (entityType: artifact)
     │
     └───► (relationshipType: invented_by | confidence: verified | weight: 1.0)
              │
              ▼
     [Johannes Gutenberg] (entityType: character)
```

---

## 8. Compatibilidade de Engenharia (Quality Gate)

O design conceitual do Historical Knowledge Graph foi rigorosamente projetado para garantir máxima compatibilidade técnica nas futuras etapas de desenvolvimento:

1. **Clean Architecture & Domain Isolation**: O modelo conceitual preserva o domínio do CHRONOS totalmente puro. Os nós referenciam entidades externas por identificadores agnósticos (`entityId`, `entityType`), evitando acoplamento físico bidirecional indesejado na camada de domínio.
2. **PostgreSQL Relational Mapping**: As tabelas de `graph_nodes` e `graph_edges` podem ser criadas como tabelas normais no PostgreSQL, conectadas por restrições de chave estrangeira polimórficas ou integridade referencial lógica em nível de aplicação.
3. **Recursive CTE Compatibility**: A estrutura direcionada de arestas (`sourceNodeId` -> `targetNodeId`) permite travessia recursiva de profundidade arbitrária no banco de dados com desempenho linear, ideal para descobrir caminhos históricos entre duas personalidades distintas.
4. **Futura API Pública**: Facilidade de conversão direta para formatos padrão de mercado como JSON-LD, GeoJSON (com a integração das coordenadas de nós geográficos) ou serializadores prontos para bibliotecas visuais de rede (ex: D3.js, Vis.js).

---

## 9. Roadmap Conceitual (Graph Engine)

A implementação técnica do motor do grafo está prevista para as próximas Sprints da seguinte maneira:

```
┌─────────────────────────────────────────────────────────┐
│ SPRINT 4.6.KG: Definição Arquitetural do Grafo (Atual) │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│ SPRINT 4.7.1 : Criação das Tabelas de Nós/Arestas no DB │
│                e Migrações de Estrutura Relacional      │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│ SPRINT 4.7.2 : Camada de Domínio e Dados do GraphEngine │
│                (Repositories, UseCases, Recursive CTEs) │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│ SPRINT 4.8.1 : Visualizador Interativo na Experience    │
│                (Gráficos em Teia com D3.js no Web App)  │
└─────────────────────────────────────────────────────────┘
```
