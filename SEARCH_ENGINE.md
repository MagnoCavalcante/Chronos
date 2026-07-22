# Global Search Engine — CHRONOS

## Visão geral

A Busca Global consulta o Supabase por uma única função `search_chronos`, entregando resultados normalizados para Personagens, Civilizações, Eventos, Artefatos, Localizações e Fontes Históricas. A UI consome apenas o controller da feature, sem conhecer SQL ou o SDK Supabase.

## Arquitetura

```text
GlobalSearchPage
  → ChronosSearchController
    → SearchUseCase
      → SearchRepository
        → SearchRemoteDataSource
          → Supabase RPC search_chronos
```

- **`SearchQuery`:** texto, categoria, ordenação, página e tamanho de página.
- **`SearchResultModel`:** adapta a linha normalizada da RPC para `SearchResult`.
- **`SearchState`:** carrega resultados, loading, paginação, erro e filtros ativos.
- **`SearchResultItem`:** adaptador de apresentação que reaproveita os cards e detalhes existentes do Design System.

## Consulta Supabase

A migration `database/migrations/20260722000000_create_global_search_engine.sql` cria:

- `historical_sources` para Fontes Históricas.
- `entity_tags` para tags associadas a qualquer tipo de entidade.
- índices de consulta para Fontes e tags.
- RPC `search_chronos(p_query, p_category, p_sort, p_limit, p_offset)`.

A função busca parcialmente, sem distinguir maiúsculas/minúsculas, em título, subtítulo, resumo/descrição, tags e ano cronológico. Ela também filtra registros ativos/publicados, pagina no banco e retorna relevância calculada.

## Categorias e ordenação

| Categoria | Tipo RPC |
|---|---|
| Todos | todos os tipos |
| Personagens | `historical_character` |
| Civilizações | `civilization` |
| Eventos | `historical_event` |
| Artefatos | `artifact` |
| Localizações | `historical_location` |
| Fontes | `historical_source` |

Ordenações: Mais relevantes, Nome A-Z, Nome Z-A, Mais recentes e Mais antigos.

## Performance

- Debounce de 300 ms antes da consulta textual.
- Uma consulta RPC por atualização de filtro/ordenação.
- `p_limit` e `p_offset` aplicados pelo Postgres.
- `loadMore()` só executa quando há próxima página e não existe consulta em andamento.
- Lista usa `ListView.builder` e aciona lazy loading próximo ao fim do scroll.

## Acessibilidade

Os resultados usam `Semantics` descritivo e `ChronosCard` interativo, que usa `InkWell` e participa da navegação por teclado/foco do Flutter. O toque/ativação abre `EntityDetailsPage` com o descritor da entidade pesquisada.

## Aplicação da migration

A RPC e as tabelas precisam ser aplicadas ao projeto Supabase antes da publicação desta feature. Sem a migration, o repositório retorna estado de erro Supabase de forma explícita para a UI.

## Testes

Os testes em `app/test/features/search/` cobrem:

- mapeamento do repositório;
- delegação do use case;
- filtros e ordenação no controller;
- paginação do controller.
