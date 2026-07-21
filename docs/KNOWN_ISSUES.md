# CHRONOS — Known Issues & Bug Tracking
## Versão 1.0 — Incidentes e Melhorias Catalogadas (Sprint 5.2.6)

Este documento registra, rastreia e consolida o status de todos os problemas técnicos, bugs ou oportunidades de usabilidade identificados ao longo do desenvolvimento e do Beta Fechado do CHRONOS 1.0.0.

---

## 1. Classificação e Resolução de Bugs (Beta Fechado)

### Bug #051: Sutil Piscada na Imagem de Capa em Detalhes (Media Loading)
- **Descrição**: No Redmi Note 10, ao abrir rapidamente a `EntityDetailsPage` sob conexões 3G limitadas, havia uma sutil cintilação (piscada) na renderização da imagem de capa antes da transição do esqueleto do `ChronosSkeleton`.
- **Resultado Esperado**: Transição suave de opacidade e caching de imagens.
- **Gravidade / Prioridade**: **Baixa**
- **Status**: **RESOLVIDO (Sprint 5.2.6)**
- **Resolução**: Implementada otimização de pré-carregamento de imagens (`precacheImage`) e transição suave com curvas de fade-in no carregamento de mídia na `EntityDetailsPage`.

---

### Bug #052: Scroll Vertical da Busca no Filtro de Categorias (Ajuste de UX)
- **Descrição**: Ao alternar rapidamente entre filtros de categoria (ex: mudar de "Eras" para "Civilizações") após fazer uma rolagem longa na busca, o scroll permanecia na posição anterior ao invés de retornar ao topo.
- **Resultado Esperado**: O scroll deve retornar automaticamente para o topo (posição `0.0`) para visualização clara dos primeiros resultados.
- **Gravidade / Prioridade**: **Média**
- **Status**: **RESOLVIDO (Sprint 5.2.6)**
- **Resolução**: Adicionado comando explícito de reset de posição no controlador de busca (`_scrollController.jumpTo(0)`) sempre que um novo chip de categoria de filtragem for acionado pelo usuário.

---

## 2. Oportunidades de Melhoria Planejadas (Versão 1.1 / Backlog v2)

- **Sugestão #101 (Fuzzy Search)**: Integração de tolerância a pequenos erros de digitação (ex: "Mesopotamea" encontrar "Mesopotâmia") para aumentar a resiliência do mecanismo de busca em dispositivos móveis.
- **Sugestão #102 (Indicadores de Progresso de Leitura)**: Adição de uma sutil barra de progresso horizontal no topo da página de detalhes universais para indicar o avanço da leitura do dossiê.
- **Sugestão #103 (Caching Local de Metadados)**: Sincronização offline preliminar de textos rápidos utilizando persistência leve local no cliente.
