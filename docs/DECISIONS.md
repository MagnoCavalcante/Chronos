# DECISIONS: Registro de Decisões Arquiteturais (ADR)

Este documento registra de forma transparente e atemporal as decisões de arquitetura de software, infraestrutura e governança adotadas no ecossistema CHRONOS. Ele serve como o repositório histórico do projeto, permitindo que novos desenvolvedores, pesquisadores e colaboradores compreendam as escolhas técnicas, seus trade-offs e os contextos em que foram consolidadas.

---

## Índice de Decisões Registradas (ADRs)

| ID | Título | Categoria | Status | Data | Responsável |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ADR-0001** | Adoção do Flutter como SDK Frontend | Frontend | Implementado | 17/07/2026 | Equipe de Engenharia |
| **ADR-0002** | Supabase como Backend as a Service | Backend | Implementado | 17/07/2026 | Equipe de Engenharia |
| **ADR-0003** | Arquitetura de Dados Híbrida | Dados | Aprovado | 17/07/2026 | Equipe de Dados |
| **ADR-0004** | GitHub como Fonte da Verdade | DevOps | Implementado | 17/07/2026 | DevOps CHRONOS |
| **ADR-0005** | AI Studio na Prototipação de Fase 1 | Governança | Implementado | 17/07/2026 | Líder de Produto |
| **ADR-0006** | VS Code como Ambiente Oficial (IDE) | Governança | Implementado | 17/07/2026 | Equipe de Engenharia |

---

## Princípios para Novas Decisões

Para que o ecossistema CHRONOS permaneça coeso, sustentável e fiel aos seus propósitos fundacionais, qualquer nova proposta de decisão arquitetural deve, obrigatoriamente, ser submetida ao seguinte checklist de governança antes de sua aprovação:

*   **[ ] Resolve um problema real?** (*A proposta ataca um gargalo tangível ou é apenas preciosismo técnico ou estético secundário?*)
*   **[ ] Está alinhada ao VISION.md?** (*A escolha respeita o foco em contextualização histórica e as restrições sobre o que deliberadamente escolhemos não ser?*)
*   **[ ] Respeita o MANIFESTO.md?** (*A alternativa estimula o respeito ao método científico, à transparência e à honestidade intelectual?*)
*   **[ ] Respeita o PRINCIPLES.md?** (*A decisão apoia ativamente os nossos princípios fundamentais divididos em Produto, UX e Arquitetura?*)
*   **[ ] Simplifica o sistema?** (*A nova tecnologia ou padrão reduz a complexidade geral ou introduz acoplamento excessivo e redundância?*)
*   **[ ] É sustentável por vários anos?** (*O componente ou biblioteca possui licença aberta, comunidade madura e arquitetura que previne a obsolescência rápida?*)
*   **[ ] Existe alternativa mais simples?** (*Se sim, por que ela foi descartada?*)

---

## Template de Decisão Arquitetural (ADR)

Toda nova decisão deve ser registrada seguindo o modelo formal abaixo:

```markdown
### ADR-XXXX: [Título Curto e Objetivo]
* **Data**: DD/MM/AAAA
* **Status**: [Planejado | Em avaliação | Aprovado | Implementado | Substituído | Obsoleto | Cancelado]
* **Categoria**: [Produto | Arquitetura | Dados | Frontend | Backend | UX | DevOps | Governança]
* **Responsável**: [Nome ou Equipe Responsável]
* **Próxima Revisão**: DD/MM/AAAA

#### 1. Contexto
[Qual era a situação do projeto e as necessidades de desenvolvimento no momento desta decisão?]

#### 2. Problema
[Qual o desafio técnico, de design ou estratégico que precisava ser resolvido de forma urgente ou preventiva?]

#### 3. Alternativas Avaliadas
*   *Opção A*: [Descrição sucinta, pontos fortes e pontos fracos]
*   *Opção B*: [Descrição sucinta, pontos fortes e pontos fracos]

#### 4. Decisão Adotada
[Qual foi a escolha final e por que ela se sobrepôs às demais alternativas?]

#### 5. Motivação
[Argumentos lógicos de suporte baseados no checklist de governança e nos documentos conceituais do CHRONOS.]

#### 6. Consequências
*   **Consequências Positivas**: [Quais benefícios diretos e indiretos foram obtidos para a equipe, usuário ou infraestrutura?]
*   **Consequências Negativas (Trade-offs)**: [Quais ônus, custos de aprendizado ou limitações foram voluntariamente aceitos?]
```

---

## Registro Histórico de Decisões (ADRs)

### ADR-0001: Adoção do Flutter como SDK Frontend
* **Data**: 17/07/2026
* **Status**: Implementado
* **Categoria**: Frontend
* **Responsável**: Equipe de Engenharia e Arquitetura CHRONOS
* **Próxima Revisão**: 17/07/2027

#### 1. Contexto
O ecossistema CHRONOS precisa ser executado de forma consistente em múltiplas plataformas (Web, Android, iOS e Desktop) mantendo altíssima fluidez visual na renderização de linhas do tempo dinâmicas e grafos interativos de causalidade.

#### 2. Problema
Desenvolver e manter quatro bases de código nativas separadas consumiria recursos de engenharia excessivos e geraria inconsistências visuais e lógicas graves entre as plataformas.

#### 3. Alternativas Avaliadas
*   *React Native*: Excelente ecossistema e facilidade de contratação de profissionais. Contudo, a renderização de componentes visuais complexos depende da ponte nativa (bridge), o que poderia introduzir gargalos de latência na navegação de grafos de dados densos.
*   *Flutter*: Renderização direta via motor Skia/Impeller, controle absoluto pixel-a-pixel da interface e código unificado de alta performance em Dart.

#### 4. Decisão Adotada
Adotar o Flutter como SDK oficial de desenvolvimento para a camada de apresentação multiplataforma do CHRONOS.

#### 5. Motivação
O controle absoluto sobre a tela e a renderização de alta performance do Flutter garantem que a nossa visão de uma interface simples, elegante, fluida e com transições refinadas de tempo seja realizada de forma idêntica em qualquer sistema operacional.

#### 6. Consequências
*   **Consequências Positivas**: Base de código única e altamente reutilizável em Dart, excelente tempo de carregamento inicial em dispositivos móveis e desktop, e suporte robusto para micro-animações nativas de transição de eras.
*   **Consequências Negativas (Trade-offs)**: Curva de aprendizado inicial da linguagem Dart para novos contribuidores e menor suporte a SEO nativo na web em comparação a geradores de sites estáticos.

---

### ADR-0002: Supabase como Backend as a Service (BaaS) Oficial
* **Data**: 17/07/2026
* **Status**: Implementado
* **Categoria**: Backend
* **Responsável**: Equipe de Arquitetura CHRONOS
* **Próxima Revisão**: 17/07/2027

#### 1. Contexto
O CHRONOS exige uma infraestrutura de backend robusta, com capacidades de autenticação segura de pesquisadores, banco de dados relacional de alto desempenho e extensibilidade futura sem as dores de cabeça do gerenciamento manual de servidores físicos.

#### 2. Problema
Desenvolver um backend personalizado do zero em linguagens como Node.js ou Go exigiria semanas de trabalho em segurança básica, setups de banco de dados e controle de sessões que poderiam ser aplicados diretamente nas regras de negócio e na visualização cronológica.

#### 3. Alternativas Avaliadas
*   *Firebase*: Ótimo BaaS, mas seu banco principal (Firestore) é NoSQL por padrão, o que dificulta o estabelecimento de integridade referencial estrita e restrições estruturais necessárias para dados históricos complexos.
*   *Supabase*: Plataforma open-source baseada nativamente no PostgreSQL, com suporte a SQL relacional completo, Row Level Security (RLS) avançado e geração instantânea de APIs REST seguras.

#### 4. Decisão Adotada
Utilizar o Supabase como a plataforma de BaaS oficial para hospedagem de banco de dados, autenticação de usuários e serviços auxiliares de API do CHRONOS.

#### 5. Motivação
A aderência nativa ao PostgreSQL garante que possamos aplicar regras de validação historiográfica rígidas diretamente na infraestrutura de dados (constraints, chaves estrangeiras), preservando a soberania e a integridade de longo prazo de nossas tabelas.

#### 6. Consequências
*   **Consequências Positivas**: Redução drástica do esforço de desenvolvimento do backend, APIs seguras geradas automaticamente, controle de acesso refinado diretamente no banco por meio de políticas de RLS e facilidade de migração do banco para qualquer infraestrutura PostgreSQL padrão caso necessário.
*   **Consequências Negativas (Trade-offs)**: Acoplamento inicial à infraestrutura gerenciada do Supabase para serviços de autenticação e menor flexibilidade em cenários que exijam lógica customizada pesada no lado do servidor (Edge Functions).

---

### ADR-0003: Arquitetura de Dados Híbrida (Relacional + Grafo)
* **Data**: 17/07/2026
* **Status**: Aprovado
* **Categoria**: Dados
* **Responsável**: Arquitetura de Banco de Dados CHRONOS
* **Próxima Revisão**: 17/01/2027

#### 1. Contexto
O ecossistema precisa gerenciar dados estruturados clássicos (como as Eras, metadados de eventos e fontes acadêmicas) ao mesmo tempo em que precisa mapear, encadear e consultar eficientemente complexas teias de relações dinâmicas (causalidade, influências temáticas, heranças).

#### 2. Problema
Bancos de dados puramente relacionais sofrem com junções (joins) recursivas e lentas ao navegar em cadeias de causalidade profundas. Por outro lado, bancos de dados de grafos puros são complexos de manter, possuem menor suporte comunitário e carecem de ferramentas simples para manter a integridade de metadados padrão.

#### 3. Alternativas Avaliadas
*   *Apenas Relacional (Postgres Tradicional)*: Simples de implementar e excelente para consistência, mas ineficiente para consultas dinâmicas de causalidade de múltiplos níveis temporais na interface.
*   *Híbrida (Postgres Relacional + Modelagem de Grafo por Tabelas de Arestas)*: Manter as entidades (Eras, Eventos) em tabelas relacionais normais e mapear as relações de causalidade em tabelas associativas dedicadas que resolvem as arestas.

#### 4. Decisão Adotada
Implementar uma arquitetura de dados híbrida rodando sobre o banco PostgreSQL do Supabase, gerenciando conexões de causalidade através de uma modelagem otimizada de arestas e tabelas associativas indexadas.

#### 5. Motivação
Essa escolha equilibra consistência e flexibilidade. Permite desfrutar do melhor de dois mundos: as restrições estritas e confiáveis de chaves estrangeiras com a capacidade de consultar árvores de influência causal recursivas usando instruções SQL eficientes (Recursive Common Table Expressions - CTEs).

#### 6. Consequências
*   **Consequências Positivas**: Consultas de causa e efeito performáticas diretamente no banco de dados, redução de latência na interface do usuário, e manutenção da integridade referencial nativa entre eventos e eras históricas.
*   **Consequências Negativas (Trade-offs)**: Complexidade adicional na escrita de consultas SQL avançadas e na modelagem inicial de arestas que conectam os dados historiográficos.

---

### ADR-0004: GitHub como Fonte da Verdade (Infrastructure & Code)
* **Data**: 17/07/2026
* **Status**: Implementado
* **Categoria**: DevOps
* **Responsável**: DevOps CHRONOS
* **Próxima Revisão**: 17/07/2027

#### 1. Contexto
O desenvolvimento e as definições físicas de infraestrutura (como esquemas de banco de dados, políticas de segurança e configurações do Flutter) devem ser auditáveis, rastreáveis e protegidos contra modificações manuais pontuais em produção.

#### 2. Problema
Modificações manuais de esquemas diretamente no painel administrativo do Supabase ou alterações de código sem controle de versão destroem a reprodutibilidade do ambiente e geram graves vulnerabilidades de segurança e falhas de sincronização no time.

#### 3. Alternativas Avaliadas
*   *Gestão Manual (Supabase Dashboard)*: Rápida para testes pontuais e ideal para protótipos rápidos, mas falha gravemente no controle de auditoria de dados exigido para um projeto acadêmico de longo prazo.
*   *GitHub como Fonte da Verdade*: Todo o código-fonte, configurações de infraestrutura e scripts de migração de banco de dados (`.sql`) são versionados sob Git e gerenciados no repositório oficial do projeto.

#### 4. Decisão Adotada
Estabelecer o repositório oficial do GitHub como a única fonte da verdade para o código da aplicação e definições de banco de dados.

#### 5. Motivação
A governança e a transparência do CHRONOS exigem que toda alteração física passe por processos de revisão por pares (Pull Requests) e rastreabilidade permanente de autoria, alinhando-se aos princípios de descentralização e auditoria pública.

#### 6. Consequências
*   **Consequências Positivas**: Absoluta reprodutibilidade do ambiente local de desenvolvimento, histórico imutável de todas as modificações técnicas e eliminação de inconsistências de dados entre homologação e produção.
*   **Consequências Negativas (Trade-offs)**: Exige maior disciplina de engenharia de todos os colaboradores, que não podem realizar ajustes rápidos direto no banco sem criar uma migration e submeter uma revisão de código.

---

### ADR-0005: AI Studio na Prototipação de Fase 1
* **Data**: 17/07/2026
* **Status**: Implementado
* **Categoria**: Governança
* **Responsável**: Líder de Produto CHRONOS
* **Próxima Revisão**: 18/10/2026 (Fim da Fase 1)

#### 1. Contexto
A validação de fluxos visuais, conceitos e integridade de conexões dinâmicas do CHRONOS necessita de ciclos de validação muito rápidos na fase de inicialização do ecossistema, permitindo testes táteis antes do congelamento dos designs para engenharia pesada.

#### 2. Problema
Criar protótipos estáticos tradicionais não permite validar o comportamento em tempo real de chamadas ao banco e transições animadas fluidas no Flutter, enquanto criar ambientes dedicados de staging de rede desde o primeiro dia pode desacelerar o processo de experimentação de layouts.

#### 3. Alternativas Avaliadas
*   *Ambiente Tradicional de Staging*: Seguro, mas lento para realizar iterações de layout rápidas, exigindo builds constantes e pipelines complexas de CI/CD para visualização rápida.
*   *AI Studio como Sandbox de Prototipação*: Ambiente de execução isolado que permite simular em tempo real o código do app Flutter e as APIs de rede em um container de teste rápido.

#### 4. Decisão Adotada
Adotar o AI Studio temporariamente como nossa ferramenta oficial de prototipação rápida **apenas durante a Fase 1 (Identidade e Alinhamento Conceitual)**. Esta escolha é uma estratégia de viabilização inicial, o que significa que o ecossistema pode transicionar para fluxos tradicionais de homologação e CI/CD na Fase 2 sem qualquer impacto ou dependência técnica residual.

#### 5. Motivação
Permite simular cenários de rede com Supabase e comportamentos dinâmicos de interface em segundos, acelerando o fechamento do design conceitual e das convenções de governança com custo de infraestrutura zero.

#### 6. Consequências
*   **Consequências Positivas**: Agilidade extrema na experimentação de layouts e no alinhamento de fluxos visuais de timeline com o banco de dados antes da Fase de Engenharia.
*   **Consequências Negativas (Trade-offs)**: Limitações do iframe do ambiente de testes para certas APIs do Flutter Web e necessidade de migração manual ou automatizada dos commits acumulados para o repositório Git definitivo na transição de fase.

---

### ADR-0006: VS Code como Ambiente Oficial de Desenvolvimento (IDE)
* **Data**: 17/07/2026
* **Status**: Implementado
* **Categoria**: Governança
* **Responsável**: Equipe de Engenharia CHRONOS
* **Próxima Revisão**: 17/07/2027

#### 1. Contexto
O time global de desenvolvimento do CHRONOS necessita de uma plataforma unificada e ágil de desenvolvimento local para codificar, documentar e revisar de forma produtiva os arquivos em Dart, Markdown e SQL.

#### 2. Problema
O uso de diferentes IDEs ou ambientes pesados sem padronização introduz ruídos de formatação de código, dificulta a depuração compartilhada e cria barreiras de entrada para colaboradores voluntários externos no ecossistema.

#### 3. Alternativas Avaliadas
*   *IDEs Proprietárias Robustas*: Ricas em recursos integrados de fábrica, mas caras, pesadas e com curva de adoção complexa que afasta contribuidores open-source.
*   *VS Code (Visual Studio Code)*: Plataforma leve, modular, open-source e com suporte excepcional às linguagens do ecossistema por meio de seu amplo ecossistema de extensões.

#### 4. Decisão Adotada
Padronizar o VS Code como a IDE oficial recomendada para o desenvolvimento do ecossistema CHRONOS.

#### 5. Motivação
A modularidade, velocidade e ampla adoção mercadológica do VS Code estão em perfeita harmonia com os nossos princípios de acessibilidade, colaboração transparente e simplicidade operacional.

#### 6. Consequências
*   **Consequências Positivas**: Configuração ágil do ambiente de desenvolvimento por meio de extensões oficiais (`Dart`, `Flutter`, `SQLTools`), padronização de formatação de código de forma automática (`format on save`) e facilidade de integração com ferramentas Git.
*   **Consequências Negativas (Trade-offs)**: Dependência do gerenciamento de extensões por parte do usuário para obter o máximo desempenho de depuração de código em comparação a ambientes focados exclusivamente em uma única linguagem.
