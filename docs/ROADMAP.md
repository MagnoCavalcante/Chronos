# ROADMAP: Evolução do Ecossistema CHRONOS

Este documento estabelece o plano estratégico de evolução do CHRONOS. Ele descreve nossa jornada sob a perspectiva da experiência do usuário, apresentando as funcionalidades que serão entregues e como a infraestrutura técnica atua como suporte invisível para viabilizar esse valor.

---

## Estado Atual
* **Fase**: Fase 1 (Identidade & Alinhamento Estratégico)
* **Sprint**: 1 (Consolidação da Documentação Oficial)
* **Versão**: V1 (Fundação e Conectividade)
* **Status Geral**: Ativo
* **Data da Última Atualização**: 18/07/2026

---

## V1: Fundação e Conectividade (Fase Atual)

### Objetivo Principal
Estabelecer as bases fundamentais do ecossistema, garantindo que o usuário possa visualizar as grandes eras da história de forma contínua, com feedback claro de rede e integridade de dados.

### Valor Entregue ao Usuário
Oferece uma interface inicial fluida e confiável para navegar pelas eras históricas mundiais, amparada por uma conexão estável e monitorada em tempo real com nossas fontes de dados.

---

### ## Funcionalidades do Produto

#### 1. Visualização Cronológica das Eras (Timeline)
* **Objetivo**: Apresentar as grandes eras da história da humanidade em uma ordem temporal contínua e visualmente harmônica.
* **Valor para o Usuário**: Permite compreender instantaneamente a sequência cronológica dos acontecimentos, estimulando a percepção da duração e transição entre diferentes períodos da nossa história.
* **Prioridade**: P1 (Crítica)
* **Status**: Em desenvolvimento

#### 2. Painel de Rastreamento de Conexão e Integridade
* **Objetivo**: Oferecer uma interface de feedback transparente sobre a qualidade de rede e o status de inicialização do banco de dados.
* **Valor para o Usuário**: Garante a segurança de que as informações exibidas estão atualizadas, identificando de forma clara e sem jargões técnicos se o dispositivo está offline ou se há alguma instabilidade de rede.
* **Prioridade**: P1 (Crítica)
* **Status**: Concluído

---

### ## Infraestrutura Técnica

#### 1. Integração e Inicialização de SDK
* **Justificativa**: Configurar a conectividade segura e a inicialização robusta do cliente de dados (Supabase) para consumir as informações dinamicamente a partir de um servidor escalável.
* **Prioridade**: P1 (Crítica)
* **Status**: Concluído

#### 2. Modelagem Relacional e Esquemas Básicos
* **Justificativa**: Estruturar e aplicar as tabelas físicas primárias (como a tabela `eras` e metadados básicos) no banco de dados com constraints e validações rígidas.
* **Prioridade**: P1 (Crítica)
* **Status**: Concluído

---

### ## Critérios de Conclusão da V1
A versão V1 só é considerada concluída quando:
* Todas as funcionalidades de interface planejadas estiverem operacionais e sem quebras visuais;
* A detecção de rede discernir corretamente falhas físicas de rede, credenciais inválidas ou erros de payload;
* O banco de dados estiver com as tabelas primárias criadas por meio de migrations auditadas;
* A performance de transição entre estados de rede e carregamento de dados for fluida e instantânea.

---

## V2: Grafos de Causalidade e Curadoria

### Objetivo Principal
Implementar as conexões de rede de causa e efeito, permitindo que o usuário investigue não apenas as datas, mas as influências intelectuais, científicas e culturais que conectam os fatos históricos.

### Valor Entregue ao Usuário
Substitui a memorização mecânica pela compreensão real das conexões históricas, fornecendo evidências documentadas e ferramentas de busca rápida para explorar o passado.

---

### ## Funcionalidades do Produto

#### 1. Navegação em Rede de Causa e Efeito (Grafo Histórico)
* **Objetivo**: Exibir de forma interativa as teias de influência, causas e heranças que ligam acontecimentos, civilizações ou descobertas.
* **Valor para o Usuário**: Permite ver como uma ideia na antiguidade influenciou revoluções científicas ou sociais centenas de anos depois, estimulando o pensamento crítico e a descoberta autônoma.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

#### 2. Central de Fontes e Evidências
* **Objetivo**: Disponibilizar um painel acoplado a cada registro de evento histórico exibindo a bibliografia e as fontes acadêmicas que dão suporte àquela informação.
* **Valor para o Usuário**: Permite verificar de forma transparente a origem e o lastro histórico de cada dado apresentado, promovendo a honestidade intelectual.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

#### 3. Busca e Filtragem Temática de Conhecimento
* **Objetivo**: Oferecer um motor de pesquisa intuitivo capaz de cruzar dados por faixas temporais, regiões geográficas e temas (ciência, arte, política).
* **Valor para o Usuário**: Permite localizar qualquer personagem, evento ou civilização em poucos segundos, facilitando a elaboração de estudos e pesquisas.
* **Prioridade**: P2 (Alta)
* **Status**: Planejado

---

### ## Infraestrutura Técnica

#### 1. Modelagem Híbrida de Grafos (PostgreSQL)
* **Justificativa**: Implementar tabelas de arestas e restrições de causalidade, otimizando as buscas recursivas de árvore de relações diretamente no banco de dados para garantir performance instantânea na interface.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

#### 2. Políticas de Acesso Seguro (Row Level Security)
* **Justificativa**: Configurar as diretrizes de segurança (RLS) no Supabase para garantir que dados sensíveis e acessos de escrita permaneçam restritos, enquanto dados públicos são acessíveis para leitura geral.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

---

### ## Critérios de Conclusão da V2
A versão V2 só é considerada concluída quando:
* O motor de busca e filtragem dinâmica retornar os dados na UI em menos de 200ms;
* A renderização de redes e conexões causais se mantiver fluida em diferentes tamanhos de tela;
* O banco híbrido validar corretamente a integridade das conexões historiográficas cadastradas;
* A interface do painel de fontes acadêmicas e bibliografia estiver integrada de forma sóbria e funcional.

---

## V3: Colaboração Acadêmica e Rastreabilidade

### Objetivo Principal
Abrir a plataforma para a contribuição auditada de historiadores e pesquisadores, tornando o CHRONOS um organismo de curadoria vivo, escalável e de credibilidade internacional.

### Valor Entregue ao Usuário
Oferece um ecossistema confiável e dinâmico onde o conhecimento histórico é continuamente revisado, atualizado e disponibilizado de forma aberta para uso profissional, acadêmico e pessoal.

---

### ## Funcionalidades do Produto

#### 1. Proposta de Revisão Historiográfica (Historiografia Aberta)
* **Objetivo**: Disponibilizar um fluxo para que especialistas autenticados proponham correções de dados, datas ou bibliografias.
* **Valor para o Usuário**: Garante que o conhecimento na plataforma reflita as discussões historiográficas mais recentes e o consenso acadêmico, de forma descentralizada e transparente.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

#### 2. Ferramentas de Exportação Acadêmica
* **Objetivo**: Permitir o download de subgrafos, cronologias e referências bibliográficas em formatos padronizados (JSON-LD, BibTeX, CSV).
* **Valor para o Usuário**: Permite que escritores, jornalistas, roteiristas e estudantes integrem os dados e linhas do tempo gerados diretamente em seus artigos, teses e produções de mídia.
* **Prioridade**: P2 (Alta)
* **Status**: Planejado

---

### ## Infraestrutura Técnica

#### 1. Autenticação e Gestão de Perfis Acadêmicos
* **Justificativa**: Integrar o Supabase Auth e modelar papéis de acesso (leitor, colaborador, curador, revisor) para garantir a governança e a auditoria de autoria das modificações.
* **Prioridade**: P1 (Crítica)
* **Status**: Planejado

#### 2. Versionamento e Histórico de Alterações de Dados
* **Justificativa**: Criar trilhas de auditoria imutáveis no banco de dados para rastrear quem alterou determinado registro e possibilitar a restauração de versões anteriores em caso de necessidade.
* **Prioridade**: P2 (Alta)
* **Status**: Planejado

---

### ## Critérios de Conclusão da V3
A versão V3 só é considerada concluída quando:
* O sistema de aprovação de edições acadêmicas for validado e aprovado por um conselho de teste de historiadores;
* As exportações gerarem dados válidos sob os padrões de citação científica aceitos internacionalmente;
* A autenticação de colaboradores for totalmente criptografada e segura contra acessos não autorizados;
* Toda modificação de registro produzir uma entrada automática na tabela de auditoria sem impacto perceptível de performance.

---

## Backlog, Pesquisa e Experimentos

> **Nota de Governança**: Os itens listados abaixo representam possibilidades de evolução futura baseadas em estudos e tendências, sem compromisso fixo de data ou implementação na grade principal. Eles são continuamente avaliados e reordenados conforme as necessidades do ecossistema.

### 1. Backlog de Produto
* **Sincronização Offline-First Completa**: Capacidade de baixar e atualizar dados locais de eras históricas, permitindo que pesquisadores acessem as informações em viagens de campo isoladas ou salas de aula sem internet estável. (*P2 - Planejado*)
* **Selo de Revisão Historiográfica**: Indicador visual sutil no aplicativo para destacar tópicos e conexões que foram revisados por especialistas de instituições científicas oficiais parceiras do projeto. (*P3 - Planejado*)

### 2. Pesquisa
* **Interfaces Imersivas de Visualização Temporal**: Estudar representações tridimensionais (3D) ou dinâmicas espaciais de fluxos cronológicos focadas puramente em didática e engajamento educacional de massa. (*P3 - Planejado*)

### 3. Experimentos
* **Processamento Cognitivo de Fontes**: Avaliar o uso de modelos semânticos locais que atuem estritamente como assistentes silenciosos para pesquisadores, sugerindo formatações prévias de referências acadêmicas e facilitando a estruturação e preenchimento inicial de novas arestas históricas. (*P3 - Planejado*)
