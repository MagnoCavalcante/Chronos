# CHRONOS — Observações de UX & Validação de Campo
## RFC-010 — Diário de Uso e Testes com Usuário Real (Sprint 5.2.1)

Este documento registra as experiências empíricas coletadas ao interagir com o CHRONOS utilizando o conteúdo histórico real semeado no banco de dados.

---

## 1. Dificuldades Encontradas e Pontos de Fricção

Durante a execução dos fluxos principais, identificamos as seguintes oportunidades de polimento:

- **Controle de Scroll na Busca**: Ao digitar termos rápidos e filtrar simultaneamente por categorias (ex: alternar de "Eras" para "Artefatos" na Busca), o scroll vertical por vezes mantinha a posição anterior, forçando o usuário a subir a página manualmente para visualizar os primeiros resultados destacados.
- **Destaque Visual nos Filtros Desativados**: Os chips de filtro inativos apresentavam um contraste sutil demais em condições de forte iluminação externa. Aumentar ligeiramente a opacidade das bordas melhora a acessibilidade sem poluir o visual minimalista.
- **Sensibilidade de Toque nos Itens da Linha do Tempo**: Na tela de Timeline, o toque para abrir os detalhes de um evento específico exigia precisão excessiva na bolha do nó. Expandir o touch target para abranger todo o card lateral resolveu esse ponto de fricção.

---

## 2. Fluxos Confusos e Problemas de Navegação

- **Navegação de Retorno de Detalhes para Busca**: Ao pesquisar por "Egito", clicar em "Busto de Nefertiti", visualizar os detalhes e retornar, o input de texto do formulário de busca era preservado, mas a lista de resultados por vezes sofria um reset visual momentâneo antes do debounce de 300ms. O estado de pesquisa foi totalmente sincronizado na controller para evitar piscadas visuais.
- **Relação de Hierarquia de Pais em Localizações**: Algumas localizações arqueológicas possuem vínculos hierárquicos (ex: "Templo do Sol" localizado dentro de "Machu Picchu"). Quando exibido na `EntityDetailsPage`, o botão para navegar ao local pai precisava de um indicador visual mais explícito de herança estrutural.

---

## 3. Melhorias Percebidas com o Hardening da RC

- **Suavidade Absoluta com Skeletons**: A substituição do antigo indicador circular de progresso por skeletons sob medida para a Timeline e Busca Global aumentou drasticamente a percepção de performance. A tela agora parece carregar instantaneamente, pois o esqueleto preserva a estrutura espacial do conteúdo histórico.
- **Animações de Transição de Entrada**: O sutil efeito de *fade-in* com escalonamento nas listas de resultados removeu a sensação de transição brusca e robótica, conferindo um aspecto "Premium" e artesanal ao aplicativo.
- **Feedback Semântico em Estados Vazios**: Quando o usuário pesquisa por termos deliberadamente inexistentes (ex: "foguete em Esparta"), a ilustração neutra com o botão sugerido de redefinição de filtros guia o usuário de volta de forma natural, sem causar frustração.

---

## 4. Sugestões e Roadmap para Próximas Sprints

- **Otimização de Renderização na Timeline**: Para cronologias massivas com centenas de eventos, sugere-se implementar a virtualização dinâmica de lista (ListView.builder personalizado) para renderizar apenas os elementos visíveis na viewport (viewport culling).
- **Precisão Semântica na Busca (Fuzzy Match)**: Integrar algoritmos de distância Levenshtein de forma leve no cliente para permitir que pequenos erros de digitação (ex: "Socratez" em vez de "Sócrates") ainda retornem a entidade correta.
- **Richness em Detalhes Geográficos**: Permitir a expansão de coordenadas diretamente em visualizações estáticas de mapas, preparando o CHRONOS para o futuro módulo cartográfico (Epic 4).
