# Tutor AI — Documentação

## Visão Geral

O Tutor Inteligente usa a Base de Conhecimento do Chronos como fonte exclusiva, adaptando explicações ao nível do usuário.

## Modos Disponíveis

| Modo | Descrição |
|---|---|
| `explainBeginner` | Explicação simples, sem jargões |
| `explainIntermediate` | Profundidade moderada, causas e consequências |
| `explainAdvanced` | Debates historiográficos, fontes primárias |
| `summarize1min` | Resumo em 3 frases (~1 minuto) |
| `summarize5min` | Resumo completo (~5 minutos de leitura) |
| `createAnalogy` | Analogia com cotidiano moderno |
| `createPracticalExample` | Cenário hipotético ilustrativo |
| `highlightForExam` | Pontos mais cobrados (ENEM/vestibulares) |

## Fluxo

```
1. Usuário seleciona modo de tutor
2. TutorService.generateTutorPrompt() → gera prompt contextualizado
3. Prompt inclui: nível do perfil + entidade + modo + restrições
4. Resultado é exibido na interface
```

## Explicações Contextuais (pós-erro)

Quando o usuário erra uma questão:
1. `generateContextualExplanation()` é chamado
2. Retorna: resposta correta, explicação, link para conteúdo, eventos e personagens relacionados
3. Interface mostra seção "Entenda melhor" com links navegáveis

## Adaptação ao Nível

O prompt é automaticamente ajustado:
- **Iniciante**: linguagem simples, exemplos básicos
- **Intermediário**: contexto histórico completo
- **Avançado**: debates acadêmicos, fontes primárias

## Integração

- `LearnerProfileService` → fornece nível atual
- `Knowledge Base` → fonte exclusiva de conteúdo
- `Knowledge Graph` → eventos e personagens relacionados
- `DifficultyDetectionService` → gera review prompts para temas difíceis
