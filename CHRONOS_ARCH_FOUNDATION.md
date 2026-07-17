# CHRONOS Knowledge Engine (CKE)
## Documento de Fundação Arquitetural e Ontologia Semântica
**Versão:** 1.0.0  
**Status:** Aprovado para Implementação Futura  
**Autor:** Arquiteto de Conhecimento CHRONOS  

---

## 1. Introdução e Visão Geral

O **CHRONOS Knowledge Engine (CKE)** é o coração computacional e conceitual da plataforma CHRONOS. Ele foi projetado não como um banco de dados tradicional estruturado em tabelas isoladas ou documentos estáticos, mas como um **Grafo de Conhecimento Semântico (Semantic Knowledge Graph)** de altíssima fidelidade.

Na filosofia do CHRONOS, **a informação histórica é uma rede viva de causalidades**. Nenhum personagem existe no vácuo; nenhuma batalha ocorreu sem um tratado político que a precedesse ou uma crise econômica que a catalisasse; nenhum mito surgiu sem uma civilização que expressasse suas angústias e rituais por meio dele. 

Ao modelar a história humana como um grafo direcionado e rotulado, o CKE garante que:
1. **Unicidade de Dados:** Cada entidade (ex: *Júlio César*) é registrada uma única vez.
2. **Reutilização Multitela:** O mesmo nó do grafo alimenta a visualização de biografia, mapas interativos, linhas do tempo e cartões de estudo.
3. **Descoberta de Conexões:** Algoritmos de busca em profundidade (como o BFS implementado no motor) revelam rotas de influência indireta entre entidades distantes em segundos.
4. **Prontidão para Inteligência Artificial:** Modelos de linguagem (LLMs) podem usar o grafo como uma base de conhecimento ancorada em evidências (RAG - Retrieval-Augmented Generation), eliminando alucinações e fornecendo respostas 100% embasadas cientificamente.

---

## 2. Ontologia de Entidades (Nós do Grafo)

Cada nó no Grafo de Conhecimento representa uma unidade conceitual discreta e pertence a uma das seguintes categorias ontológicas:

### 2.1. Dimensão Humana e Social
*   **Personagens:** Indivíduos históricos documentados cujas ações influenciaram o curso dos acontecimentos (ex: *Cleópatra*, *Aristóteles*).
*   **Autores:** Escritores, cronistas, filósofos ou historiadores (antigos ou contemporâneos) responsáveis por registrar ou analisar os dados (ex: *Heródoto*, *Suetônio*, *Marc Bloch*).
*   **Civilizações:** Culturas e sociedades caracterizadas por uma matriz linguística, religiosa ou tecnológica compartilhada (ex: *Civilização Maia*, *Suméria*).
*   **Impérios:** Estruturas políticas expansionistas e centralizadas que exerceram controle sobre múltiplos povos (ex: *Império Aquemênida*, *Império Carolíngio*).
*   **Países:** Divisões territoriais e políticas modernas ou históricas dotadas de fronteiras administrativas (ex: *República Romana*, *Egito Ptolemaico*).
*   **Regiões:** Delimitações geográficas ou ecológicas que condicionaram o desenvolvimento histórico (ex: *Mesopotâmia*, *Gália*, *Crescente Fértil*).
*   **Cidades:** Centros urbanos, pólis ou assentamentos de relevância política, comercial ou militar (ex: *Babilônia*, *Alexandria*, *Cartago*).

### 2.2. Dimensão de Conflitos e Diplomacia
*   **Guerras:** Conflitos armados de grande escala que se estendem no tempo, envolvendo múltiplos atores e estados (ex: *Guerras Púnicas*, *Guerra dos Cem Anos*).
*   **Batalhas:** Confrontos armados pontuais, táticos e localizados em uma coordenada geográfica e data específica (ex: *Batalha de Gaugamela*, *Batalha de Farsalos*).
*   **Tratados:** Acordos formais, pactos, armistícios ou resoluções diplomáticas que encerram conflitos ou estabelecem fronteiras (ex: *Tratado de Tordesilhas*, *Paz de Westfália*).

### 2.3. Dimensão de Ideias e Cultura
*   **Movimentos:** Correntes intelectuais, artísticas, sociais ou políticas que mobilizaram sociedades (ex: *Iluminismo*, *Renascimento*, *Reforma Protestante*).
*   **Ideologias:** Sistemas estruturados de pensamento sobre organização social e econômica (ex: *Absolutismo*, *Liberalismo Clássico*).
*   **Religiões:** Sistemas institucionalizados de crenças, rituais, dogmas e cultos divinos (ex: *Zoroatrismo*, *Religião de Estado Romana*, *Budismo Teravada*).
*   **Filosofias:** Escolas de pensamento e matrizes reflexivas sobre a existência, ética e lógica (ex: *Estoicismo*, *Epicurismo*, *Escolástica*).

### 2.4. Dimensão de Evidências e Registro Científico
*   **Obras:** Livros literários, poemas épicos ou peças teatrais de relevância cultural (ex: *Ilíada*, *Eneida*, *A República*).
*   **Livros:** Tratados historiográficos, crônicas históricas ou publicações acadêmicas (ex: *Ab Urbe Condita* de Tito Lívio).
*   **Documentos:** Registros textuais oficiais, decretos, leis ou cartas reais (ex: *Código de Hamurabi*, *Carta Magna*, *Decreto de Rosetta*).
*   **Fontes:** Unidade elementar de análise que abriga a evidência material ou literária.
*   **Achados Arqueológicos:** Evidências materiais descobertas em escavações científicas (ex: *Ruínas de Pompeia*, *Túmulo de Tutancâmon*).
*   **Objetos Históricos:** Artefatos móveis criados pela ação humana (ex: *Mecanismo de Anticítera*, *Pedra de Rosetta*, *Moedas de Denário*).
*   **Construções:** Obras de arquitetura ou engenharia monumental que sobrevivem no espaço (ex: *Coliseu*, *Farol de Alexandria*, *Zigurate de Ur*).
*   **Museus:** Instituições modernas que guardam, preservam e exibem artefatos originais e evidências físicas (ex: *Museu do Louvre*, *Museu Britânico*).
*   **Mapas:** Representações cartográficas (antigas ou modernas) que dão o contorno territorial às rotas de comércio ou conquistas.

### 2.5. Dimensão Cronológica e de Escala
*   **Datas:** Âncoras temporais pontuais no calendário linear (ex: *15 de Março de 44 a.C.*).
*   **Períodos:** Intervalos de tempo estruturados e delimitados historicamente (ex: *Antiguidade Tardia*, *Idade do Bronze*, *Período Helenístico*).
*   **Linhas do Tempo:** Estrutura ordenada sequencial que encadeia eventos de um mesmo tema ou território.

### 2.6. Dimensão de Tradições Culturais e Mitológicas (Espaço Especial do Conhecimento)
*   **Mitologias:** Conjunto sistêmico de crenças e narrativas sobrenaturais de um povo (ex: *Mitologia Nórdica*, *Mitologia Egípcia*).
*   **Deuses:** Divindades cultuadas, seus atributos, domínios sagrados e representações rituais (ex: *Odin*, *Ísis*, *Apolo*).
*   **Heróis:** Personagens semidivinos ou figuras mitológicas celebradas em epopeias (ex: *Hércules*, *Aquiles*, *Gilgamesh*).
*   **Criaturas:** Seres fantásticos, monstros, quimeras ou guardiões espirituais (ex: *Esfinge*, *Fenrir*, *Minotauro*).
*   **Artefatos:** Objetos lendários e armas divinas citadas nas narrativas míticas (ex: *Mjölnir*, *Santo Graal*, *Excalibur*).
*   **Símbolos:** Representações icônicas de relevância mágica ou ritualística (ex: *Olho de Hórus*, *Triscele*, *Martelo de Thor*).

---

## 3. Ontologia de Relacionamentos (Arestas Semânticas)

Uma aresta no CKE é sempre direcionada (`Nó Origem` $\xrightarrow{\text{Aresta}}$ `Nó Destino`) e tipada para estabelecer uma relação lógica precisa. Abaixo estão as conexões formais suportadas pela nossa ontologia de dados:

| Nó de Origem (Tipo) | Tipo de Relacionamento (Edge) | Nó de Destino (Tipo) | Descrição Semântica / Exemplo |
| :--- | :--- | :--- | :--- |
| **Personagem** | `PARTICIPATED_IN` | **Evento** | Júlio César liderou a passagem militar do Rubicão. |
| **Evento** | `OCCURRED_IN` | **Cidade** / **Região** | A travessia ocorreu nas margens do Rio Rubicão. |
| **Cidade** | `BELONGS_TO` | **País** | Pompeia pertencia ao território da República Romana. |
| **País** / **Império** | `PART_OF_CIVILIZATION` | **Civilização** | O Império Bizantino faz parte da Civilização Romana. |
| **Guerra** | `HAS_BATTLE` | **Batalha** | A Segunda Guerra Púnica possui a Batalha de Canas. |
| **Documento** | `PROVES_EVENT` | **Evento** | A tábula de bronze do Tratado de Kadesh prova a paz militar. |
| **Livro** / **Obra** | `CITES_DOCUMENT` | **Documento** | O historiador Tácito cita as Atas do Senado. |
| **Autor** | `WROTE_BOOK` | **Livro** | Heródoto escreveu a obra clássica "Histórias". |
| **Filósofo** / **Personagem** | `INFLUENCED` | **Personagem** | Sócrates influenciou a teoria e vida de Platão. |
| **Movimento** | `INFLUENCED` | **Movimento** | O Iluminismo influenciou a Revolução Francesa. |
| **Personagem** | `RULED_EMPIRE` | **Império** | Augusto governou o Império Romano como primeiro imperador. |
| **Civilização** | `CREATED_TECH` | **Tecnologia** | A Civilização Suméria desenvolveu a Escrita Cuneiforme. |
| **Construção** | `CONSTRUCTED_BY` | **Civilização** | O Partenon foi erguido pela Civilização Grega Ateniense. |
| **Construção** | `LOCATED_AT` | **Cidade** | O Coliseu está localizado na cidade de Roma. |
| **Deus** / **Criatura** | `BELONGS_TO_MYTHOLOGY`| **Mitologia** | Thor pertence à Mitologia Nórdica. |
| **Herói** | `COMBATED` | **Criatura** | Teseu combateu e derrotou o Minotauro. |
| **Qualquer Nó** | `TEMPORAL_ANCHOR` | **Período** / **Data** | O Estoicismo está ancorado no Período Helenístico. |
| **Qualquer Nó** | `ASSOCIATED_WITH` | **Qualquer Nó** | Associação genérica conceitual de apoio à navegação. |

---

## 4. O Sistema de Níveis de Evidência Científica

Uma das inovações pioneiras do CKE é a **atribuição de pesos e categorias de certeza acadêmica** para todas as entidades e conexões de dados. Isso estabelece um filtro de honestidade intelectual e transparência inédito em plataformas de conhecimento.

### 4.1. Escala de Rigor Científico
Cada nó de fato histórico possui uma propriedade obrigatória de `EvidenceLevel`:

1.  **Alto Consenso (High Consensus):** Fatos documentados por múltiplas fontes primárias cruzadas, sem divergências substanciais na arqueologia ou historiografia moderna (ex: *Assassinato de Júlio César*, *Fundações do Coliseu*).
2.  **Bom Nível de Evidência (Good Evidence):** Acontecimentos amplamente aceitos e amparados por registros arqueológicos ou literários sólidos, mas com pequenos debates marginais sobre datas precisas ou motivações subjetivas (ex: *Campanhas de Alexandre, o Grande, na Ásia*).
3.  **Tema Debatido (Debated Topic):** Eventos sobre os quais a academia historiográfica possui visões conflitantes ou divididas, frequentemente devido à escassez de registros originais não-tendenciosos (ex: *Localização exata da Batalha de Alésia*, *Origens reais da queda de Teotihuacán*).
4.  **Hipótese (Hypothesis):** Teorias científicas propostas por historiadores de destaque baseadas em indícios indiretos, mas que ainda não possuem comprovação arqueológica irrefutável (ex: *Teoria de que o incêndio de Alexandria foi 100% acidental*, *Existência histórica de certas dinastias primordiais da China*).
5.  **Lenda / Mito (Mythological / Tradition):** Narrativas tradicionais transmitidas de forma oral ou poética, cujo valor histórico reside na transmissão de cultura, ética e cosmologia da civilização, e não na realidade material dos fatos (ex: *Mitologia Nórdica*, *Fundação de Roma por Rômulo e Remo*).

### 4.2. Campo de Justificativa Historiográfica
A propriedade de evidência não é apenas um rótulo estático. Toda classificação é acompanhada por:
*   `evidence_justification`: Texto analítico conciso detalhando o porquê daquela nota (ex: *"Classificado como tema de debate devido à contradição entre os relatos de Júlio César no De Bello Gallico e as recentes descobertas de trincheiras arqueológicas na França"*).
*   `primary_sources_count`: Inteiro indicando o número de documentos contemporâneos ao fato catalogados na base que atestam a entidade.

---

## 5. Escalabilidade e Evolução Tecnológica do CKE

A separação absoluta entre a **arquitetura lógica de dados do grafo** e a **camada de apresentação visual (telas)** garante que o CHRONOS possa crescer indefinidamente sem sofrer com refatorações estruturais dolorosas ou lentidão.

### 5.1. IA Historiador (RAG de Precisão)
Em vez de permitir que uma inteligência artificial gere respostas livres com base em pesos probabilísticos (o que gera "alucinações históricas"), a IA Historiador usará o CKE como âncora:
1. O usuário faz uma pergunta no chat: *"Qual a relação entre Júpiter e Júlio César?"*
2. A IA executa uma busca vetorial ou consulta semântica no CKE localizando o caminho do grafo: `Júlio César` $\xrightarrow{\text{WROTE\_BOOK}}$ `De Bello Gallico` $\xrightarrow{\text{ASSOCIATED\_WITH}}$ `Mitologia Romana` $\xleftarrow{\text{BELONGS\_TO\_MYTHOLOGY}}$ `Júpiter`.
3. A IA sintetiza a resposta amparada exatamente na trilha do grafo, garantindo precisão documental e exibindo as fontes bibliográficas.

### 5.2. Linha do Tempo Dinâmica e Infinita
Como cada evento e personagem possui uma âncora temporal uniforme (`TEMPORAL_ANCHOR`), a interface de linha do tempo do aplicativo não precisa de codificação manual. Ela é gerada **sob demanda**. O usuário pode filtrar por "Civilização Egípcia" e o aplicativo coleta todas as entidades egípcias ligadas de forma temporal e as organiza sequencialmente em milissegundos.

### 5.3. Perfis e Modos Adaptativos de Leitura (Nível de Linguagem)
Ao acessar o mesmo nó do grafo (ex: *Guerra do Peloponeso*), a plataforma CHRONOS pode variar a renderização de acordo com o perfil de assinatura do usuário:
*   **Modo Infantil:** O CKE injeta as tags e a descrição simplificada adaptada para gamificação.
*   **Modo Escola / Concurso:** Destaca as palavras-chave obrigatórias (`keywords`) e os fatos de "Alto Consenso" que costumam cair em exames e vestibulares nacionais.
*   **Modo Universitário / Pesquisador:** Expõe o grafo completo de referências cruzadas, exibe textos originais em latim ou grego transladados e detalha as controvérsias historiográficas do nó de "Tema Debatido".

---

## 6. Modelagem em Grafo (Exemplo Visual Textual)

```
        [ DEUS ]
       "Júpiter"
           │
           │ (BELONGS_TO_MYTHOLOGY)
           ▼
     [ MITOLOGIA ]
  "Mitologia Romana" 
           │
           │ (ASSOCIATED_WITH) - Estudo Cultural separado do fato
           ▼
    [ CIVILIZAÇÃO ] 
     "Roma Antiga" ◀─────────────────────────┐
           ▲                                 │
           │ (RULED_EMPIRE)                  │ (PART_OF_CIVILIZATION)
           │                                 │
     [ PERSONAGEM ]                         [ PAÍS ]
     "Júlio César"                      "República Romana"
           │                                 ▲
           │ (PARTICIPATED_IN)               │
           ▼                                 │ (OCCURRED_IN)
       [ EVENTO ]                            │
 "Travessia do Rubicão" ─────────────────────┘
           ▲
           │ (PROVES_EVENT)
           │
      [ DOCUMENTO ]
  "Commentarii de Bello Gallico"
```

---

## 7. Conclusão e Filosofia de Engenharia

O **CHRONOS Knowledge Engine** transforma o CHRONOS de um simples aplicativo educacional em um repositório intelectual unificado. Esta fundação garante que toda contribuição feita por pesquisadores, toda nova tradução de pergaminhos ou revisão historiográfica feita no futuro apenas adicione **nós e arestas** à teia de dados, expandindo o cérebro do CHRONOS sem que uma única linha de código do aplicativo precise ser alterada. É o conhecimento histórico blindado pelo tempo, pronto para os próximos 50 anos de evolução computacional.
