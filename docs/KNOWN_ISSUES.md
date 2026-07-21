# CHRONOS — Known Issues & Bug Tracking
## Versão 1.0 — Incidentes e Melhorias Catalogadas (Sprint 5.2.5)

Este documento registra e prioriza os problemas técnicos ou oportunidades de usabilidade identificados no período de Beta Fechado do CHRONOS 1.0.0.

---

## 1. Classificação de Bugs e Problemas Conhecidos

### Bug #051: Sutil Piscada na Imagem de Capa em Detalhes (Media Loading)
- **Descrição**: No Redmi Note 10, ao abrir rapidamente a `EntityDetailsPage` sob conexões 3G limitadas, há uma sutil cintilação (piscada) na renderização da imagem histórica de capa antes de o esqueleto do `ChronosSkeleton` sumir por completo.
- **Passos para Reprodução**:
  1. Ativar throttling de rede móvel limitada.
  2. Clicar em qualquer evento ou personagem histórico.
  3. Observar a imagem do topo (Hero).
- **Resultado Esperado**: Transição suave e contínua do placeholder de carregamento para a imagem real.
- **Resultado Obtido**: Transição com piscada rápida de opacidade.
- **Gravidade / Prioridade**: **Baixa**
- **Ação**: Direcionado para polimento no ciclo de correções pós-RC (Sprint 5.2.6) através de caching de imagens no cliente.

---

### Bug #052: Scroll Vertical da Busca no Filtro de Categorias (Ajuste de UX)
- **Descrição**: Ao alternar rapidamente entre filtros de categoria (ex: mudar de "Eras" para "Civilizações") após fazer uma rolagem longa na busca, o scroll permanece na posição atual em vez de retornar ao topo.
- **Passos para Reprodução**:
  1. Pesquisar por um termo genérico.
  2. Rolar a listagem até o final.
  3. Clicar no chip de categoria "Civilizações".
- **Resultado Esperado**: O scroll deve retornar automaticamente para o topo (posição `0.0`) para que o usuário veja os primeiros resultados.
- **Resultado Obtido**: A lista atualiza os dados, mas mantém o scroll no meio ou fim da tela.
- **Gravidade / Prioridade**: **Média**
- **Ação**: Resolvido adicionando uma chamada de reset de scroll na controller de busca sempre que a categoria ativa for alterada.

---

## 2. Oportunidades de Melhoria Planejadas (Versão 1.1)

- **Sugestão #101 (Fuzzy Search)**: Integração de tolerância a pequenos erros de digitação (ex: "Mesopotamea" encontrar "Mesopotâmia") para aumentar a resiliência do mecanismo de busca em dispositivos móveis.
- **Sugestão #102 (Indicadores de Progresso de Leitura)**: Adição de uma sutil barra de progresso horizontal no topo da página de detalhes universais para indicar o avanço da leitura do dossiê.
