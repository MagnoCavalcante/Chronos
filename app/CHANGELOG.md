# Changelog

Todas as alterações notáveis deste projeto serão documentadas neste arquivo.

## [8.4.0] - 2026-07-23

### Tutor Inteligente e Aprendizagem Adaptativa
- **LearnerProfileService** - Perfil versionado com refresh automático (nível, tópicos, accuracy, preferências)
- **TutorService** - 8 modos de explicação adaptados ao nível (iniciante/intermediário/avançado, resumos, analogias, prova)
- **AdaptiveRecommendationEngine** - Motor desacoplado via RecommendationStrategy (ML-ready), cache 15min, explainability
- **AdaptiveQuizService** - Dificuldade dinâmica (easy→medium→hard→expert), trigger review após 3 erros
- **StudyPlanService** - Plano semanal personalizado (revisão 20% + quiz 10% + conteúdo novo 70%)
- **DifficultyDetectionService** - Detecção automática: baixa accuracy (<60%), revisões pendentes, tempo excessivo
- **LearningReportService** - Relatórios semanais/mensais com evolução, recomendações, tópicos dominados
- **LearningPrivacyService** - Exportar/excluir dados de aprendizagem (LGPD-ready)
- **4 tabelas Supabase** - learner_profiles (versionado), study_plans, learning_reports, adaptive_recommendations
- **Documentação** - ADAPTIVE_LEARNING.md, RECOMMENDATION_ENGINE.md, TUTOR_AI.md
- **24 novos testes** - 342 testes totais, flutter analyze 0 issues

## [8.3.0] - 2026-07-23

### Learning Paths (Trilhas de Aprendizagem)
- **PathProgressService** - Start path, complete content, unlock modules sequencialmente
- **CertificateService** - Geração automática de certificados ao concluir trilha
- **PathRecommendationService** - Recomendações baseadas em categorias relacionadas
- **6 tabelas Supabase** - learning_paths, path_modules, path_contents, path_progress, module_progress, path_certificates
- **8 trilhas seed** - Egito, Roma, Grécia, Idade Média, Renascimento, Rev. Francesa, WW2, Brasil Colonial
- **Desbloqueio sequencial** - Módulos bloqueados até completar o anterior
- **12 categorias** - Antiguidade, Idade Média, Moderna, Contemporânea, Civilizações, Guerras, Filosofia, etc.
- **4 níveis de dificuldade** - Beginner, Intermediate, Advanced, Expert
- **19 novos testes** - 318 testes totais, flutter analyze 0 issues

## [8.2.0] - 2026-07-23

### Learning Engine V1
- **StudyTrackerService** - Histórico automático com tempo de leitura, frequência e último acesso
- **SpacedRepetitionService** - Revisão espaçada SM-2 (1, 3, 7, 15, 30 dias)
- **QuizEngineService** - Quiz inteligente com acertos, erros e tempo de resposta
- **GoalsService** - Metas de estudo personalizáveis (minutos, personagens, eventos)
- **AchievementsService** - Badges, XP, 6 níveis, desafios diários e semanais
- **StatsService** - Horas estudadas, dias consecutivos, horário favorito, evolução semanal/mensal
- **RecommendationService** - Recomendações baseadas no histórico (integrado com Knowledge Graph)
- **9 tabelas Supabase** - study_history, study_progress, study_reviews, quiz_questions, quiz_answers, study_goals, achievements, user_study_stats, study_challenges
- **33 novos testes** - 299 testes totais, flutter analyze 0 issues

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
