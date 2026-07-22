# RELATIONSHIP_ENGINE.md – Historical Knowledge Graph

## Visão Geral

A **RelationshipEngine** é a camada central do Grafo de Conhecimento Histórico do Chronos. Ela descobre e classifica conexões automáticas entre todas as entidades do acervo, sem listas fixas ou mocks.

## Arquitetura

```
core/relationships/
├── relationship_item.dart      # Modelos RelatedItem, RelationType e RelationStrength
├── relationship_repository.dart # Cliente RPC do Supabase
└── relationship_engine.dart    # Lógica de descoberta, cache e agrupamento

presentation/
├── controllers/relationship_controller.dart  # Estado reativo
├── widgets/relationship_section.dart         # Lista agrupada de relacionamentos
├── widgets/knowledge_graph_view.dart         # Grafo visual interativo
└── widgets/discovery_line.dart               # Linha de Descoberta

database/migrations/20260722000004_knowledge_graph.sql
```

## Fluxo de Dados

1. A tela de detalhes (`EntityDetailsPage`) identifica `entity_type` e `id` da entidade atual.
2. `RelationshipController` solicita `RelationshipEngine.discover()`.
3. A engine consulta `RelationshipRepository.getRelated()` que chama a RPC `get_relationships` do Supabase.
4. A RPC `get_relationships` executa regras específicas por tipo de entidade, usando `JOINs` implícitos e filtros cronológicos.
5. A engine agrupa itens por `relation_type` e ordena por `strength`.
6. A UI renderiza `RelationshipSection`, `KnowledgeGraphView` e sugestões.

## Regras de Relacionamento

| Origem          | Relacionamentos principais                                           |
|-----------------|----------------------------------------------------------------------|
| Personagem      | Civilização principal, personagens relacionados (mesma civilização/era), eventos próximos, localizações importantes, artefatos relacionados, fontes |
| Civilização     | Personagens, eventos, artefatos, localizações, civilizações contemporâneas, fontes |
| Evento          | Personagens envolvidos, civilizações participantes, eventos anteriores/posteriores, localizações, artefatos, fontes |
| Localização     | Eventos ocorridos, civilizações, personagens, artefatos encontrados, fontes |
| Artefato        | Origem civilizacional, localização, personagens, eventos relacionados |
| Fonte Histórica | Autores, eventos citados, civilizações, artefatos |

## Intensidade de Relação

- **Direta (90-100)**: FK direta (ex: `civilizacao_principal_id`, `origin_civilization_id`).
- **Forte (60-89)**: Mesma era, localização ou civilização.
- **Média/Fraca (0-59)**: Proximidade cronológica calculada por `100 - ABS(ano - ano_fonte) / fator`.

## Cache e Performance

- A `RelationshipEngine` mantém um `_cache` em memória (`Map<String, List<RelatedItem>>`).
- Cada consulta utiliza `LIMIT` configurável na RPC para evitar carregamento excessivo.
- Consultas reutilizáveis e centralizadas evitam duplicação no código.

## Grafo Visual

`KnowledgeGraphView` renderiza a entidade central e seus relacionamentos em círculo, usando:
- `InteractiveViewer` para zoom e pan.
- `CustomPainter` para as arestas.
- Nós coloridos por categoria; toque abre a tela de detalhes.

## Linha de Descoberta

`DiscoveryLine` registra automaticamente cada entidade visitada via `DiscoveryLineService` (`SharedPreferences`). O usuário pode:
- Ver o caminho de exploração horizontal.
- Voltar a qualquer passo.
- Limpar a trilha.
- Futuramente salvá-la para continuar depois.

## Testes

- `test/core/relationships/relationship_item_test.dart`
- `test/presentation/controllers/relationship_controller_test.dart`

## Sugestões Inteligentes

A engine expõe `suggestions()` que retorna os `N` itens mais fortes de todos os grupos de relacionamento. A tela de detalhes exibe como "Você também pode gostar de...".

## Consultas Supabase

- `get_relationships(p_entity_type, p_entity_id, p_limit)`

A função foi implementada como `plpgsql` com branches por tipo de entidade, retornando `relation_type` e `strength` calculados.

## Analytics

A engine está preparada para registrar conexões mais acessadas e tipos de relação. O envio ao servidor foi deixado para sprint futura, conforme critério.

## Recomendações Futuras

- Criar tabela `entity_relationships` para relações explícitas (professor/discípulo, aliado/inimigo).
- Materializar view de grafos para grandes volumes.
- Implementar busca de caminho (BFS) entre entidades com mais de 1 salto.
