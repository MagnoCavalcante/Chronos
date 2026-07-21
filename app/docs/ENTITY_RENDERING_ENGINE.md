# CHRONOS — Universal Entity Rendering Engine

O **Universal Entity Rendering Engine** é o núcleo de apresentação unificado, dinâmico e flexível pertencente à **Experience Layer (Pillar III)** do ecossistema CHRONOS.

Sua missão central é **separar totalmente o conhecimento (dados de negócio/entidades) de sua representação visual**. Nenhuma entidade no CHRONOS possui conhecimento sobre como deve ser desenhada em tela, e nenhuma tela conhece os atributos ou campos físicos específicos de cada classe do domínio.

---

## 1. Fluxograma Completo da Arquitetura

O diagrama abaixo detalha o fluxo completo do processamento de renderização, desde o momento em que a entidade bruta é fornecida ao motor até a montagem final do Widget na tela.

```
       [ Entidade Histórica Bruta (ex: Era, Event) ]
                           │
                           ▼
              ┌─────────────────────────┐
              │      EntityFactory      │
              └────────────┬────────────┘
                           │ (Descobre tipo dinâmico e constrói)
                           ▼
              ┌─────────────────────────┐
              │     EntityRenderer      │
              └────────────┬────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
 [ EntityRegistry ]                  [ EntityViewRegistry ]
 ├─ Resolve o Descriptor             ├─ Verifica se há renderizador
 └─ Resolve os Metadados             │  especializado registrado.
                                     └─ Se não, recorre ao genérico.
                                              │
                           ┌──────────────────┘
                           ▼
             ┌───────────────────────────┐
             │   EntityRenderContext     │
             │   - Tema, Tamanho de Tela │
             │   - Acessibilidade, Visão │
             └─────────────┬─────────────2
                           │
                           ▼
             ┌───────────────────────────┐
             │   EntityRenderPipeline    │
             └─────────────┬─────────────┘
                           │
                           ▼ (Execução dos 8 Estágios Isolados)
   [ 1. Metadata Resolution ] ──► Resolve campos visíveis e ocultos.
   [ 2. Layout Resolution ]   ──► Ajusta limites de acordo com tela.
   [ 3. Theme Resolution ]    ──► Adapta paleta de cores e tipografia.
   [ 4. Accessibility Res. ]  ──► Injeta Semantics e descrições áudio.
   [ 5. Animation Resolution ]──► Aplica transições e obedece ReduceMotion.
   [ 6. Interaction Res. ]    ──► Configura eventos de toque e focos físicos.
   [ 7. Rendering ]           ──► Processa estilizações estéticas adicionais.
   [ 8. Final Composition ]   ──► Envolve com preenchimentos e margens coerentes.
                           │
                           ▼
              ┌─────────────────────────┐
              │   Widget Pronto (UI)    │
              └─────────────────────────┘
```

---

## 2. Diagrama do Pipeline

Cada estágio do pipeline funciona de forma estritamente isolada e opera em modelo de middleware sequencial:

```
                  ┌──────────────────────┐
                  │ BaseRenderer Output  │
                  └──────────┬───────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │ MetadataResolutionStage   │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │   LayoutResolutionStage   │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │    ThemeResolutionStage   │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │ AccessibilityResolution   │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │ AnimationResolutionStage  │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │ InteractionResolutionStage│
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │      RenderingStage       │
               └─────────────┬─────────────┘
                             │
                             ▼
               ┌───────────────────────────┐
               │   FinalCompositionStage   │
               └─────────────┬─────────────┘
                             │
                             ▼
                     [ COMPOSIÇÃO FINAL ]
```

---

## 3. Os Componentes da Engine

### A. Entity Descriptor (`EntityDescriptor`)
Classe estruturada imutável que informa as configurações visuais, prioridades de navegação e suportes específicos que o tipo de entidade possui (como suporte a timelines, mapas ou grafos).

### B. Entity Metadata (`EntityMetadata`)
Responsável por mapear e expor de forma abstrata os campos que são visíveis, ocultos, pesquisáveis, comparáveis, utilizáveis por motores de Inteligência Artificial, etc. Com isso, evitamos que componentes visuais conheçam campos físicos diretamente (ex: `entity.nascimentoAno`).

### C. Entity Registry (`EntityRegistry`)
O centralizador lógico e *Thread-Safe* que pré-cadastra os descritores e metadados das 8 entidades originais do CHRONOS:
1. **Era Histórica** (`Era`)
2. **Evento Histórico** (`HistoricalEvent` / `Event`)
3. **Personagem Histórico** (`HistoricalCharacter` / `Character`)
4. **Civilização** (`Civilization`)
5. **Artefato** (`Artifact`)
6. **Localização Histórica** (`HistoricalLocation`)
7. **Fonte Histórica** (`HistoricalSource` / `Source`)
8. **Relação Semântica** (`Relationship` / `Relation`)

### D. Entity View Registry (`EntityViewRegistry`)
Registro independente que mapeia quais Widgets desenham qual visão (`EntityView`) de uma entidade. É o elemento chave para suportar extensibilidade e injeção de plugins visuais terceiros.

### E. Entity Render Context (`EntityRenderContext`)
Classe de dados compartilhada que flui pelas etapas do pipeline de renderização, agregando as variáveis do ambiente: o tema físico, as restrições e breakpoints de tela, o modo de seleção, se há acessibilidade ativa, animações e permissões de segurança.

### F. Entity Render Pipeline (`EntityRenderPipeline`)
O orquestrador sequencial de middlewares que recebe o Widget desenhado pelo Renderer e o enriquece ao longo dos 8 estágios mandatórios, isolando responsabilidades como acessibilidade, animações e gestos.

---

## 4. Estratégia de Extensibilidade e Plugins Futuros

O design do motor foi estruturado especificamente para respeitar o princípio Open/Closed (OCP) do SOLID. Caso novas visões ou motores sejam concebidos na Experience Layer, não há necessidade de modificar o núcleo do motor:

### Sincronização com o Timeline Engine
O módulo `timeline` pode registrar um renderizador especializado para qualquer entidade no `EntityViewRegistry`:
```dart
EntityViewRegistry().registerSpecialized(
  entityType: 'historical_event',
  view: EntityView.timeline,
  renderer: (entity, descriptor, metadata, context) {
    // Retorna o nó especializado da Timeline com linhas verticais conectadas
    return MyInteractiveTimelineNode(event: entity);
  },
);
```

### Sincronização com o Graph Engine
O módulo `graph` herda as chaves semânticas informadas no `EntityMetadata` pelos campos marcados com `isGraphField` e pode renderizar os nodes semânticos de forma autônoma:
```dart
EntityViewRegistry().registerSpecialized(
  entityType: 'relationship',
  view: EntityView.graph,
  renderer: (entity, descriptor, metadata, context) {
    return SemanticsGraphEdgeWidget(relation: entity);
  },
);
```

### Sincronização com o Map Engine
O módulo `map` resolve dinamicamente as localizações a serem plotadas consultando quais campos possuem a marcação `isMapField` nos metadados, desenhando os pontos no mapa com as cores e ícones fornecidos pelo `EntityDescriptor`.

### Sincronização com o AI Explorer
O assistente de IA Gemini consome o mapeamento do `EntityMetadata` acessando apenas as strings marcadas com `isAiField` para sintetizar biografias e descrições semânticas ricas, alimentando o renderizador nativo `EntityView.aiResult`.

---

## 5. Boas Práticas e Diretrizes de Engenharia

1. **Evitar Acoplamentos Físicos**: Nunca acesse diretamente atributos específicos de uma classe de domínio de fora da estrutura do `EntityRenderer._extractValue`.
2. **Priorizar Composição**: Se precisar adicionar interações customizadas para um fluxo de negócio específico, prefira injetar um `EntityRenderPipeline` contendo stages personalizados ao invés de herdar widgets.
3. **Respeitar o Quality Gate**: Todas as modificações ou expansões visuais devem passar pelas rotinas do `Flutter Analyze` e testes estruturais sem gerar advertências de tipagem imprecisa (`dynamic` sem tratamento de exceção).
4. **Semantics Sempre**: Todo novo elemento inserido no pipeline deve herdar ou declarar parâmetros de acessibilidade via `Semantics`.
