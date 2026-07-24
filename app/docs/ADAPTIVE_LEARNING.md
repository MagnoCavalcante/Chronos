# Adaptive Learning — Arquitetura

## Visão Geral

O módulo de Aprendizagem Adaptativa transforma o Chronos em um tutor pessoal de História, ajustando automaticamente recomendações, revisões, quizzes e explicações conforme o desempenho do usuário.

## Componentes

```
features/adaptive_learning/
├── domain/
│   ├── entities/adaptive_learning_entities.dart
│   └── repositories/adaptive_learning_repository.dart
├── data/
│   ├── datasources/adaptive_learning_remote_datasource.dart
│   └── repositories/adaptive_learning_repository_impl.dart
├── services/
│   ├── learner_profile_service.dart
│   ├── tutor_service.dart
│   ├── adaptive_recommendation_engine.dart
│   ├── adaptive_quiz_service.dart
│   ├── study_plan_service.dart
│   ├── difficulty_detection_service.dart
│   ├── learning_report_service.dart
│   └── privacy_service.dart
└── di/adaptive_learning_di.dart
```

## Entidades

| Entidade | Função |
|---|---|
| `LearnerProfile` | Perfil versionado (nível, tópicos, accuracy, preferências) |
| `AdaptiveRecommendation` | Recomendação com motivo explícito (explainability) |
| `StudyPlan` / `DailyPlan` / `PlanItem` | Plano semanal personalizado |
| `LearningReport` | Relatório semanal/mensal |
| `DifficultyAlert` | Alerta de dificuldade detectada |
| `ContextualExplanation` | Explicação após erro em quiz |

## Fluxo de Dados

```
Interação → LearnerProfileService.refreshProfile()
         → AdaptiveRecommendationEngine.generateRecommendations()
         → AdaptiveQuizService.getAdaptiveDifficulty()
         → DifficultyDetectionService.detectDifficulties()
         → StudyPlanService.generateWeeklyPlan()
         → LearningReportService.generateWeeklyReport()
```

## Integração

- **Learning Engine** — Dados de quiz, revisão, progresso
- **Learning Paths** — Trilhas em andamento
- **Knowledge Graph** — Conteúdo relacionado
- **Chronos AI** — Prompts adaptativos do TutorService
- **Gamificação** — XP meta no plano semanal

## Privacidade

- Dados armazenados apenas no Supabase do usuário
- Exportação completa via `LearningPrivacyService.exportAllData()`
- Exclusão total via `LearningPrivacyService.deleteAllData()`
