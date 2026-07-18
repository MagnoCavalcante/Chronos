# Design de Interface e Experiência do Usuário (/docs/ui-ux)

Este diretório contém os estudos, wireframes, paletas de cores, guias tipográficos e especificações de acessibilidade (UI/UX) do aplicativo móvel CHRONOS.

---

## 🧭 Objetivo

Garantir que o aplicativo CHRONOS ofereça uma experiência de uso extremamente imersiva, elegante, responsiva e acessível. Este diretório orienta designers e engenheiros de frontend sobre como materializar as interfaces físicas do produto em harmonia com os preceitos de consistência tipográfica, espaçamento rítmico e feedback interativo.

---

## 🗂️ Estrutura de Documentação de Design

Os documentos planejados e em desenvolvimento nesta pasta compreendem:

*   `design_system_tokens.md`: Definição de cores hexadecimais, tamanhos de fonte, pesos tipográficos e curvas de bordas arredondadas do aplicativo.
*   `accessibility_guide.md`: Diretrizes para garantir contrastes adequados de texto (padrão WCAG AA), tamanhos mínimos de botões para telas touch (mínimo de 44x44px) e suporte a leitores de tela.
*   `navigation_flows.md`: Mapeamento das jornadas de navegação por gestos na tela principal, transição do túnel do tempo e abertura de gavetas (drawers) informativas.

---

## 🎨 Paleta de Cores e Tipografia Básica (Estilo CHRONOS)

*   **Tema Principal (Cosmic Slate - Escuro):** Um fundo em tons profundos de ardósia e carvão, com detalhes em bronze antigo e luzes sutis neon (azul ciano histórico ou dourado) para representar os pontos quentes do tempo.
*   **Tipografia de Cabeçalhos:** *Space Grotesk* ou *Outfit* (Estilo moderno, limpo, focado em alta tecnologia e ficção científica histórica).
*   **Tipografia de Corpo de Texto:** *Inter* (Legibilidade impecável, ideal para longos blocos de leitura de dossiês históricos).
*   **Tipografia de Dados (Mono):** *JetBrains Mono* (Ideal para anos cronológicos, coordenadas de mapas e telemetrias temporais).

---

## 🛡️ Boas Práticas de UI/UX

1. **Feedback ao Toque (Micro-interações):** Todo botão clicável deve oferecer uma resposta tátil ou animação de toque sutil (como o efeito de ripple ou encolhimento de 2-3%), aumentando a sensação de controle do usuário.
2. **Animações com Propósito:** Utilize transições suaves de fade e deslocamento lateral para indicar movimentações na linha do tempo. Evite animações espalhafatosas ou lentas que possam causar cansaço visual ou frustração de uso após múltiplos cliques.
3. **Contraste de Texto:** O aplicativo deve garantir que textos pequenos em cinza escuro ou ardósia possuam contraste nítido contra o fundo, prevenindo fadiga ocular em ambientes de baixa luminosidade.
4. **Mobile First, Desktop Responsive:** Embora o Flutter compile para múltiplas plataformas, o design de interface do CHRONOS deve priorizar a usabilidade de uso em telas móveis verticais de toque rápido, expandindo a disposição lateral de dados de forma adaptativa e fluida em telas maiores.
