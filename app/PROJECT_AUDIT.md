# CHRONOS — PROJECT AUDIT

## Sprint 8.1.0 — Knowledge Graph, Navegação Inteligente e Jornada de Estudo

**Data**: 2025-07-23

### Critérios de Aceite

| Critério | Status |
|---|---|
| Nenhuma página fica isolada | ✅ Relações bidirecionais garantem conectividade |
| Todo registro possui ligações | ✅ 40+ relações no seed, graph service bidirecional |
| Continue estudando funcionando | ✅ ContinueStudyingSection com priorização |
| Linha do tempo contextual | ✅ ContextualTimelineSection com antes/durante/depois |
| Mapa contextual | ✅ MapLocationsSection com locais navegáveis |
| Busca agrupada | ✅ GroupedSearchResults por tipo de entidade |
| Breadcrumb funcionando | ✅ HistoryBreadcrumb com navegação hierárquica |
| Relações cronológicas completas | ✅ EventChainSection com cadeia de acontecimentos |
| flutter analyze sem erros | ✅ No issues found |
| Projeto compilando normalmente | ✅ 266 testes passando |

### Arquitetura

- **KnowledgeGraphService**: serviço central para traversal do grafo
  - Relações bidirecionais (outgoing + incoming)
  - Continue estudando (priorização por tipo)
  - Descoberta inteligente (segundo nível)
  - Cadeia de acontecimentos (antecedentes/consequências)
  - Breadcrumb hierárquico
  - Mapa contextual
  - Busca agrupada
  - Dados de civilização
  - Pessoas relacionadas
- **Repository/DataSource**: suporta `fetchReverseRelations`
- **DI**: `KnowledgeGraphService` registrado no ServiceLocator

### Novos Widgets

| Widget | Função |
|---|---|
| `ContinueStudyingSection` | Recomendações baseadas no grafo |
| `DiscoverySection` | Sugestões de segundo nível |
| `EventChainSection` | Cadeia cronológica de eventos |
| `HistoryBreadcrumb` | Navegação hierárquica |
| `ContextualTimelineSection` | Timeline com antes/durante/depois |
| `MapLocationsSection` | Locais navegáveis |
| `RelatedPeopleSection` | Card visual de pessoas relacionadas |
| `GroupedSearchResults` | Busca agrupada por tipo |

### Testes

- 266 testes totais (14 novos para KnowledgeGraphService)
- Cobertura: relações bidirecionais, deduplicação, priorização, cadeia de eventos, breadcrumb, mapa, busca agrupada, filtragem de pessoas, dados de civilização

### Banco de Dados

- Migration `002_knowledge_graph_enhancements.sql`:
  - Colunas `source_type` e `source_name` em `knowledge_relations`
  - Índices para busca reversa, tipo de relação, tipo de target
  - Índice full-text para busca por nome

### Escalabilidade

- Cache em memória com TTL 30min
- Índices otimizados para milhões de relações
- Lazy loading em todas as seções
- Consultas N+1 evitadas por cache de relações
