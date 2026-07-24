# Recommendation Engine — Documentação

## Arquitetura

O motor de recomendações é **desacoplado** via interface `RecommendationStrategy`, permitindo futura substituição por modelos de ML sem alterar a aplicação.

```dart
abstract class RecommendationStrategy {
  Future<List<AdaptiveRecommendation>> generateRecommendations({
    required LearnerProfile profile,
    required int limit,
  });
}
```

## Implementação Atual: AdaptiveRecommendationEngine

### Algoritmo de Scoring

| Tipo | Prioridade | Score Base |
|---|---|---|
| Revisão pendente (spaced repetition) | 10 | 1.0 |
| Dificuldade identificada | 8 | 0.9 - accuracy |
| Trilha em andamento | 6 | 0.7 |
| Conteúdo relacionado (última sessão) | 4 | 0.5 |

### Fontes de Dados

1. **Revisões pendentes** — Learning Engine (SpacedRepetition)
2. **Tópicos difíceis** — LearnerProfile.difficultTopics
3. **Trilhas em andamento** — Learning Paths progress
4. **Histórico recente** — Learning Engine history

### Cache

- Duração: 15 minutos
- Invalidação manual via `invalidateCache()`
- Persistência em Supabase para resiliência

### Explainability

Toda recomendação inclui campo `reason` com texto explícito:
- "Revisão programada para hoje (repetição espaçada, intervalo: 3 dias)."
- "Recomendado porque teve dificuldade neste tema (taxa de acerto: 40%)."
- "Continue sua trilha 'Egito Antigo' (33% concluído)."

## Preparação para ML

A interface `RecommendationStrategy` permite:
1. Criar `MLRecommendationEngine implements RecommendationStrategy`
2. Registrar via DI sem alterar consumers
3. A/B testing entre engine rule-based e ML
4. Coleta de dados (impressions, clicks, completions) para treinamento futuro
