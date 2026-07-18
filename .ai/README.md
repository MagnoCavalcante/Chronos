# Inteligência Artificial e Agentes (/.ai)

Este diretório centraliza toda a lógica de inteligência artificial, engenharia de prompts, definições de agentes autônomos de IA e guias de contexto que alimentam o ecossistema do **CHRONOS**. Ele funciona como a ponte de conhecimento entre os modelos de linguagem de larga escala (LLMs) via Google AI Studio (Gemini) e a base de conhecimento histórico.

---

## 🧭 Objetivo

O objetivo desta pasta é estruturar, padronizar e documentar de forma reprodutível como as IAs do CHRONOS interagem com o conteúdo do projeto. Isso garante que qualquer agente de IA (como redatores de conteúdo, revisores históricos ou engenheiros de software) execute suas tarefas com consistência editorial e aderência técnica aos padrões do projeto, eliminando alucinações e variações indesejadas de comportamento.

---

## 🗂️ Estrutura de Subdiretórios

Esta pasta é subdividida em quatro pilares fundamentais:

```
.ai/
├── agents/             # Definição e especificações dos agentes especialistas de IA
├── prompts/            # Repositório de prompts oficiais e reutilizáveis (System Prompts)
├── standards/          # Guias de desenvolvimento, diretrizes editoriais e padrões de escrita
└── context/            # Arquivos de contexto histórico, regras do mundo e ontologias
```

### 1. `agents/`
*   **Propósito:** Contém os perfis psicológicos, instruções de sistema, restrições e escopos de cada agente especialista do projeto CHRONOS.
*   **Exemplos de Conteúdo:** Definições para o *Historian Agent*, *Flutter Engineer Agent*, *UX Designer Agent* e *Editor Agent*.

### 2. `prompts/`
*   **Propósito:** Repositório centralizado de prompts de alta performance (engenharia de prompt) para tarefas como sumarização de linhas do tempo, verificação de anacronismos, tradução contextual e geração de questionários de fixação.
*   **Exemplos de Conteúdo:** Prompts para extração de entidades semânticas, geração de resumos em linguagem natural e formatação de questionários arqueológicos.

### 3. `standards/`
*   **Propósito:** Armazena guias técnicos e editoriais formais para a IA. Define as regras de codificação e como a IA deve formatar e validar informações históricas.
*   **Exemplos de Conteúdo:** `CHRONOS_EDITORIAL_STANDARD.md` (transferido para esta subpasta), guias de estilo de código Flutter/Dart e convenções de nomenclatura.

### 4. `context/`
*   **Propósito:** Documentos e esquemas estruturados que servem de "âncora de realidade" (RAG) para as IAs, fornecendo o escopo geográfico, cronológico e os limites de fantasia/realidade do CHRONOS.
*   **Exemplos de Conteúdo:** Arquivos de ontologia de relacionamento, limites de precisão para datas antes de Cristo (a.C.), e bases terminológicas arqueológicas recomendadas.

---

## 🎯 Exemplos de Uso

### Ativação de um Agente Especialista (ex: Historiador)
Ao iniciar uma sessão com uma IA no Google AI Studio, o prompt de sistema deve ser carregado diretamente de `.ai/agents/historian.md` combinado com as regras de estilo de `.ai/standards/CHRONOS_EDITORIAL_STANDARD.md`.

---

## 🛡️ Boas Práticas

1. **Versionamento Estrito:** Nunca modifique um prompt oficial diretamente em produção. Todas as alterações em prompts devem passar por code review e ser testadas no ambiente sandbox do Google AI Studio.
2. **Separação de Instruções:** Mantenha as diretrizes de personalidade do agente em `agents/` e as instruções procedimentais de tarefas específicas em `prompts/`.
3. **Ancoragem Histórica:** Ao instruir IAs a gerarem conteúdos de história, exija sempre a injeção dos arquivos em `context/` ou da base em `knowledge/` para mitigar alucinações.
