# Gamificação do CHRONOS

Este documento descreve o sistema de gamificação do aplicativo CHRONOS, incluindo XP, níveis, conquistas, desafios, sequência de estudos e integrações futuras.

## Objetivo

Engajar o usuário no estudo da história através de recompensas reais baseadas em progresso: XP, badges, títulos de historiador, desafios periódicos e resumos semanais.

## Arquitetura

- **Backend:** Supabase com tabelas `user_profiles`, `achievements`, `user_achievements`, `titles`, `user_titles`, `xp_events`, `challenges`, `weekly_summaries` e `ranking_entries`.
- **Cache offline:** `SharedPreferences` via `GamificationCacheService`.
- **Coordenação central:** `GamificationService` orquestra os repositórios e aplica a lógica.
- **Decoupling:** ranking e integrações com Play Games/Game Center são preparadas via `RankingRepository` e interfaces futuras, mas não implementadas ainda.

## Fluxo de XP

| Ação | XP |
|------|-----|
| Visualizar conteúdo | +2 |
| Concluir estudo | +10 |
| Concluir coleção | +50 |
| Meta diária | +20 |
| Concluir desafio | +100 |

## Níveis

O nível é calculado por `LevelCalculator` usando fórmula progressiva:

- Cada nível exige `xp = 100 * level * (level + 1) / 2` (aproximadamente).
- O nível sobe automaticamente quando o XP total atinge o limiar.
- O título do usuário é atualizado automaticamente com base no XP e nível.

## Conquistas

Conquistas desbloqueadas automaticamente ao atingir critérios (`view_count`, `complete_count`, `streak_days`, etc.). Cada conquista pode conceder XP e desbloquear títulos ou coleções especiais.

## Desafios

Desafios diários, semanais e mensais são gerados automaticamente na tabela `challenges`. Eles incrementam progresso por critérios (`study_minutes`, `view_count`, `search_count`, `complete_count`, `create_collection`).

## Sequência (Streak)

A cada estudo concluído (`onStudyCompleted`), a sequência de dias é atualizada: incrementa se o último estudo foi ontem, mantém se foi hoje, e reseta se o intervalo for maior que um dia.

## Resumo Semanal

`WeeklySummaryRepository` agrega XP, horas estudadas, conquistas e coleções concluídas da semana atual, além das categorias mais estudadas.

## Telas

- **Home:** card de progresso diário com XP, nível, sequência e desafios ativos.
- **Perfil:** nível, XP, títulos, estatísticas e ações para conquistas, desafios e resumo semanal.
- **Conquistas:** lista de badges com progresso.
- **Desafios:** separados por diários, semanais e mensais.
- **Resumo Semanal:** métricas da semana e categorias favoritas.

## Notificações e Coleções Especiais

A infraestrutura para notificações locais e coleções especiais foi preparada no modelo (`Achievement.specialCollectionSlug`) e no `GamificationService`, mas a implementação completa será feita em sprint futura.

## Ranking e Integrações Externas

- `RankingRepository` e `RankingEntry` preparam a arquitetura para ranking online.
- Integração com Google Play Games e Apple Game Center será adicionada futuramente sem alterar a lógica central.
