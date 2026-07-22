# TIMELINE.md — Interactive Historical Timeline

## Visão Geral

A **Timeline Histórica Interativa** é um dos diferenciais do Chronos. Ela consolida registros de múltiplas categorias — **civilizações, personagens, eventos, artefatos, localizações e fontes históricas** — em uma única linha do tempo navegável.

## Arquitetura

```
presentation/pages/timeline/
├── timeline_page.dart        # Tela principal com pull-to-refresh
├── timeline_controller.dart  # Gerenciamento de estado, filtros, paginação
├── timeline_list.dart        # Lista vertical, lazy loading e Hero animations
├── timeline_header.dart      # Categorias, período, zoom e botão Comparar
├── timeline_filters.dart     # Filtros avançados (bottom sheet)
├── timeline_detail_page.dart # Detalhes com itens cronologicamente relacionados
└── period_compare_page.dart  # Comparação lado a lado de períodos

core/timeline/
├── timeline_item.dart        # Modelo unificado TimelineDisplayItem
└── timeline_repository.dart  # Consultas RPC otimizadas

database/migrations/20260722000003_interactive_timeline.sql
```

## Fluxo de Dados

1. **TimelineController** dispara `carregarDados()` com os filtros atuais.
2. **TimelineRepository** chama a RPC `get_timeline` do Supabase.
3. A RPC realiza `UNION ALL` entre as 6 tabelas principais, filtra, ordena e pagina no servidor.
4. Os resultados são mapeados em `TimelineDisplayItem`.
5. **TimelineList** exibe os itens, carrega mais ao chegar próximo ao fim da rolagem (scroll +200px).

## Filtros

| Filtro        | Implementação                         |
|---------------|----------------------------------------|
| Categoria     | `TimelineItemType` mapeado para `entity_type` na RPC |
| Período       | `start_year` e `end_year` passados à RPC |
| Presets       | Pré-História, Antiguidade, Idade Média, Idade Moderna, Idade Contemporânea |
| Busca         | `p_search` com `ILIKE` no título |
| Zoom          | Apenas UI; controle de densidade visual (Décadas/Séculos/Milênios) |
| Ordenação     | Inversão da lista carregada (`isAscending`) |

## Consultas Supabase

- `get_timeline(p_filter, p_start_year, p_end_year, p_search, p_limit, p_offset)`
- `get_related_items(p_entity_type, p_entity_id, p_radius)`

As consultas utilizam `UNION ALL` sobre as tabelas e índices em `start_year`/`estimated_year` para performance.

## Performance

- **Lazy loading**: 50 itens por página, carregados sob demanda.
- **Índices**: `idx_*_start_year` e `idx_artifacts_estimated_year`.
- **Cache local**: controlador mantém `_items` em memória enquanto a tela estiver ativa.
- **Rebuild mínimo**: `notifyListeners` apenas após lotes de dados.

## Comparação de Períodos

A página `PeriodComparePage` dispara duas consultas `get_timeline` em paralelo, uma para cada período selecionado, e exibe as listas lado a lado. Reutiliza o mesmo `TimelineRepository` e `TimelineDisplayItem` da Timeline principal.

## UX

- Skeleton loading em listas e cards.
- Pull to Refresh na tela principal.
- Empty States para filtros sem resultados.
- Hero Animation entre `TimelineList` e `TimelineDetailPage`.
- Cores e ícones próprios por categoria.

## Acessibilidade

- Cada card de timeline possui `Semantics` implícito via `ChronosCard`.
- Ícones e cores refletem categorias para melhor reconhecimento.
- Modo escuro suportado pelas cores do Design System.

## Testes

- `test/presentation/pages/timeline/timeline_controller_test.dart`
- `test/core/timeline/timeline_item_test.dart`

Cobrem: estado inicial, carregamento sem rede, ordenação e formatação de rótulos cronológicos.

## Recomendações Futuras

- Materializar a view `get_timeline` em uma tabela `timeline_materialized` para acervos muito grandes.
- Adicionar cache persistente via `SharedPreferences` para os últimos filtros.
- Implementar seleção visual na linha do tempo (scrubber) para navegação rápida por milênios.
