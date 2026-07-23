# LEARNING SYSTEM - Sistema de Estudos do CHRONOS

## Visão Geral

O **Learning System** (Sprint 6.6.0) permite que o usuário organize estudos sobre história, acompanhe progresso, crie coleções, anotações pessoais, metas, planos cronológicos e revisões espaçadas. Todos os dados são persistidos no Supabase com cache offline via `SharedPreferences`.

## Tabelas do Banco de Dados

- `collections` - coleções pessoais de entidades.
- `collection_items` - itens pertencentes a uma coleção.
- `collection_tags` - vinculação N:N entre coleções e tags.
- `study_progress` - progresso de estudo por entidade.
- `notes` - anotações pessoais por entidade.
- `highlights` - marcações de texto por entidade.
- `tags` - tags pessoais do usuário.
- `study_goals` - metas de estudo com tipo e valor alvo.
- `study_plans` - planos de estudo cronológicos.
- `study_plan_items` - itens diários de um plano.
- `review_items` - agendamento de revisão futura.
- `study_sessions` - sessões individuais de estudo.
- `user_stats` - estatísticas acumuladas do usuário.

Todas as tabelas possuem RLS garantindo que cada usuário acesse apenas seus próprios dados.

## Modelos

Localizados em `app/lib/core/study/study_models.dart`:

- `Collection`, `CollectionItem`, `StudyProgress`, `Note`, `Highlight`, `Tag`, `StudyGoal`, `StudyPlan`, `StudyPlanItem`, `ReviewItem`, `UserStats`.
- Enum `StudyStatus` com estados `notStarted`, `inStudy`, `completed`, `review`.
- Serialização `fromJson` / `toJson` para todos os modelos.

## Repositórios

Localizados em `app/lib/core/study/`:

- `collection_repository.dart` - CRUD de coleções, itens, duplicação e reordenação.
- `progress_repository.dart` - leitura e atualização de progresso, cache offline.
- `notes_repository.dart` - notas e marcações pessoais.
- `tags_repository.dart` - tags e vinculação a coleções.
- `goal_repository.dart` - metas de estudo e progresso.
- `study_plan_repository.dart` - planos e itens diários.
- `review_repository.dart` - agendamento e conclusão de revisões.
- `stats_repository.dart` - estatísticas e sessões de estudo.
- `study_cache_service.dart` - cache local via `SharedPreferences`.

## Controllers

Localizados em `app/lib/presentation/controllers/`:

- `collections_controller.dart` - gerencia estado das coleções.
- `study_dashboard_controller.dart` - alimenta dashboard de aprendizagem.
- `study_plan_controller.dart` - gerencia planos de estudo.
- `review_controller.dart` - gerencia modo revisão.

## Interface

Telas em `app/lib/presentation/pages/study/`:

- `study_dashboard_page.dart` - horas, sequência, metas, revisões e atalhos.
- `collections_page.dart` - listagem e criação de coleções.
- `collection_detail_page.dart` - detalhes, progresso e itens.
- `study_plan_page.dart` - planos cronológicos.
- `review_page.dart` - revisões pendentes.

Widgets reutilizáveis em `app/lib/presentation/widgets/study/`:

- `collection_card.dart`, `progress_bar.dart`, `study_goal_card.dart`, `tag_chip.dart`.

## Integração com Home

`HomeRepository` e `HomeController` foram estendidos para:

- `getContinueStudying()` - exibe o último item acessado no estudo.
- `getRecommendations()` - usa `RelationshipEngine.suggestions` baseado no item em estudo.

A `HomePage` exibe as seções **Continue Estudando** e **Recomendado para você**.

## Cache Offline e Sincronização

- `StudyCacheService` persiste coleções, progresso e notas localmente.
- `CollectionRepository` e `ProgressRepository` tentam buscar do Supabase; em caso de falta de conexão retornam o cache local.
- Após um carregamento online bem-sucedido, o cache é regravado automaticamente.
- O campo `last_sync` registra a última atualização.

## Fluxo de Uso

1. O usuário acessa uma entidade; `ProgressRepository.updateProgress` registra o status.
2. A Home exibe **Continue Estudando** com base no `study_progress` mais recente.
3. O usuário cria coleções, adiciona itens e acompanha a barra de progresso.
4. Notas e marcações são salvas por entidade.
5. Metas e planos guiam o ritmo de estudos.
6. Revisões são agendadas e exibidas na tela de revisão.
7. Sessões de estudo alimentam `user_stats`.

## Testes

Testes localizados em `app/test/core/study/` e `app/test/presentation/controllers/`:

- Serialização dos modelos.
- Cache offline (`StudyCacheService`).
- Estado e carga do `CollectionsController`.

## Validação

Comandos executados:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```
