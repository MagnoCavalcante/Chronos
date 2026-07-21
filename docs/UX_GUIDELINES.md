# CHRONOS — Diretrizes de UX/UI e Design System
## RFC-010 — Camada de Experiência e Consistência (Sprint 5.2.1)

Este documento oficializa os padrões de Experiência do Usuário (UX), Interface Gráfica (UI) e Acessibilidade do ecossistema CHRONOS, servindo de guia para garantir consistência visual e interativa.

---

## 1. Filosofia de Design: Craftsmanship over Defaults

A identidade do CHRONOS baseia-se na sofisticação minimalista, usando tipografia expressiva e contraste polido em vez de elementos decorativos desnecessários.
- **Tipografia**: Uso da fonte "Inter" para legibilidade e clareza de dados, pareada com "Space Grotesk" para títulos expressivos e "JetBrains Mono" para contextos técnicos e cronológicos.
- **Cores**: Paleta sóbria de cinzas profundos e off-whites com acentos precisos de cor primária/ouro para evocar um sentimento de prestígio histórico.
- **Espaçamento**: Proporções harmoniosas de padding e margem para manter uma estrutura limpa e sem ruídos visuais.

---

## 2. Experiência de Carregamento (Skeleton Loading)

Para evitar quebras abruptas de layout e transições desconfortáveis para o usuário, o CHRONOS utiliza o padrão **Skeleton Loading** reativo em substituição a indicadores de progresso circulares (spinners) genéricos.

### 2.1 Componente `ChronosSkeleton`
- **Animação**: Pulsação cíclica suave de opacidade (de `0.35` a `0.65`) com duração de `1000ms`.
- **Estilo**: Bordas levemente arredondadas (`ChronosRadius.borderRadiusSM`) combinando com a estrutura dos cards reais.

### 2.2 Padrões de Implementação por Tela:
- **Timeline Skeleton**: Renderiza uma linha vertical de guia acompanhada por placeholders retangulares simulando os nós de anos e descrições dos eventos históricos.
- **Card Skeleton**: Substitui imagens de capa e blocos de texto por formas geométricas equivalentes de cor neutra.
- **Details Skeleton**: Exibe placeholders de cabeçalho amplo (hero image), linhas de parágrafo e metadados estruturados.

```dart
// Exemplo de uso ideal do ChronosSkeleton para textos
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ChronosSkeleton(height: 24, width: 200),
    const SizedBox(height: 8),
    ChronosSkeleton(height: 16, width: double.infinity),
  ],
)
```

---

## 3. Estados Vazios Padronizados (Empty States)

Um estado vazio deve sempre instruir o usuário de maneira útil e amigável sobre o que ocorreu e como ele pode prosseguir.

### 3.1 Componente `ChronosEmptyState`
Cada estado vazio deve obrigatoriamente possuir:
1. **Ícone Semântico**: Representação visual do estado (ex: busca vazia, sem favoritos).
2. **Título Direto**: Mensagem principal sem jargões técnicos.
3. **Descrição Clara**: Contexto inteligível sobre a ausência do dado.
4. **Ação Sugerida**: Botão opcional que permite reiniciar o fluxo (ex: "Limpar busca").

### 3.2 Casos de Uso Comuns:
- **Pesquisa Sem Resultados**: Ícone de busca com lupa cortada. Título: "Nenhum registro encontrado". Ação: "Redefinir Filtros".
- **Sem Favoritos/Dossiês**: Ícone de marcador vazio. Título: "Seu dossiê está vazio". Ação: "Explorar Eras".

---

## 4. Tratamento de Erros e Recuperação (Error Recovery)

Falhas de rede, problemas de comunicação e indisponibilidades de microsserviços devem ser encapsulados por completo, impedindo que logs brutos e exceções de pilha (stack traces) sejam apresentados ao usuário.

### 4.1 Componente `ChronosErrorState`
Toda tela sujeita a falhas externas deve implementar a estratégia de recuperação:
- **Mensagem Amigável**: "Não foi possível carregar os dados históricos agora."
- **Ação de Retentativa**: Botão destacado "Tentar Novamente" (`ChronosRetryButton`) que reinicia a chamada à controller.
- **Registro Silencioso**: Toda exceção técnica é enviada automaticamente para o `ChronosLogger` para auditoria interna.

---

## 5. Microinterações e Animações

As animações no CHRONOS servem para reforçar a hierarquia visual e suavizar a introdução de novos estados na tela. Elas devem ser discretas e altamente performáticas.

- **Entrada de Cards (Fade + Scale)**: Entrada sutil com transição de opacidade e leve escalonamento (de `0.95` para `1.00`), utilizando duração máxima de `300ms` com curva `Curves.easeOutCubic`.
- **Mudança de Filtros**: Deslizamento horizontal amortecido e indicador de seleção ativo com transição de opacidade rápida (`150ms`).
- **Expansão de Conteúdo**: Transição suave do contêiner de metadados reduzindo pulos abruptos de scroll.

---

## 6. Acessibilidade (a11y)

O CHRONOS é projetado para ser inclusivo, atendendo integralmente as diretrizes de acessibilidade:

- **Semântica (Semantics)**: Todas as imagens históricas decorativas recebem rótulos semânticos vazios ou descrições ricas quando representarem informações cruciais.
- **Navegação por Teclado**: Foco visual claro em botões, campos de busca e itens de lista, respeitando a ordem natural de tabulação.
- **Contraste de Cores**: Relação de contraste de texto mínima de `4.5:1` em relação aos fundos, em conformidade com as diretrizes WCAG AA.
- **Touch Targets**: Área mínima de clique de `44dp x 44dp` para todos os botões e áreas interativas.
- **Escala de Fontes**: Uso de tamanhos relativos e flexibilidade para responder ao dimensionamento de fontes nativo do sistema operacional sem quebrar layouts.
