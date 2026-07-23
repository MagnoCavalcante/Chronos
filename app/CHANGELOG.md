# Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.

## [8.1.0] - 2026-07-23

### Knowledge Graph & Navegação Inteligente
- **KnowledgeGraphService** - Serviço central de traversal do grafo com relações bidirecionais
- **Continue Estudando** - Recomendações baseadas no grafo, priorizadas por tipo
- **Descoberta Inteligente** - Sugestões de segundo nível ("Talvez você também queira estudar")
- **Cadeia de Acontecimentos** - Antecedentes → Evento → Consequências → Eventos Posteriores
- **Breadcrumb Histórico** - Navegação hierárquica (História → Era → Civilização → Entidade)
- **Linha do Tempo Contextual** - Destaque automático antes/durante/depois
- **Mapa Contextual** - Locais de nascimento, morte, campanhas, eventos navegáveis
- **Busca Agrupada** - Resultados organizados por Personagens, Eventos, Civilizações, etc.
- **Pessoas Relacionadas** - Card visual horizontal com personagens conectados
- **Relações Bidirecionais** - Nenhuma página fica isolada no grafo
- **DB Migration** - Índices reversos, full-text search, colunas source_type/name
- **14 novos testes** - 266 testes totais, flutter analyze 0 issues

## [1.0.0-beta.1] - 2026-07-23

### Beta Infrastructure
- **Bug Tracker** - Sistema de registro com prioridade, categoria e status
- **Telemetria Local** - Tempo de uso, pesquisas, features, crashes (sem envio externo)
- **Beta Center** - Painel interno com versão, status API/DB, storage, sessões
- **Feature Toggle** - Ativar/desativar funcionalidades sem recompilar
- **Feedback Assistant** - Captura automática de erros com descrição do usuário
- **Release Metrics** - Comparação automática entre versões (cold start, memória, erros)

### Qualidade
- **233 testes** automatizados passando
- Versionamento beta: 1.0.0-beta.1+2

---

## [1.0.0] - 2026-07-23

### Funcionalidades Principais
- **Dashboard** - Tela principal com métricas e acesso rápido
- **Timeline** - Linha do tempo interativa com filtros por era, tipo e período
- **Relationship Engine** - Motor de relações entre entidades históricas
- **Sistema de Estudos** - Flashcards, quizzes e revisão espaçada
- **Chronos AI** - Assistente inteligente com RAG e múltiplos provedores
- **Mapa Histórico** - OpenStreetMap com clustering, lazy loading e animações
- **Exportação** - Markdown, HTML, PDF, Image via ExportEngine central
- **Modo Apresentação** - Fullscreen com gestos, teclado e controle Bluetooth
- **Busca Global** - Pesquisa federada com filtros e ordenação

### Infraestrutura
- **Offline First** - Cache inteligente com SharedPreferences
- **Supabase** - Backend com autenticação, banco e storage
- **Design System** - Tokens de cores, tipografia, espaçamento, elevação, animação
- **Acessibilidade** - Alto contraste, daltonismo, escala de fontes, haptic feedback
- **Analytics Local** - Métricas sem envio externo

### UX/UI
- **Onboarding** - Introdução guiada em 8 passos
- **Tooltips** - Dicas contextuais de primeira utilização
- **Microinterações** - Animações suaves (fade, scale, shimmer, bounce)
- **Empty/Error States** - Estados padronizados com ações
- **Skeleton Loading** - Loading states consistentes
- **What's New** - Release notes automáticas

### Qualidade
- **195 testes** automatizados passando
- **flutter analyze** sem issues
- **Arquitetura limpa** - Domain, Data, Presentation separados
- **DI** - Service Locator com módulos por feature
- **Desacoplamento** - Providers abstratos para map, AI, export
