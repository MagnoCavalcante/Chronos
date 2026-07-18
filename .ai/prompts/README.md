# Prompts Oficiais e Reutilizáveis (/.ai/prompts)

Este diretório armazena os prompts de sistema e templates de engenharia de prompt (Prompt Engineering) reutilizáveis para o ecossistema CHRONOS.

---

## 🧭 Objetivo

O objetivo deste diretório é centralizar a inteligência conversacional e procedimental do projeto. Ao manter os prompts versionados e organizados por casos de uso, garantimos que diferentes microsserviços de IA (e os próprios editores/desenvolvedores humanos) acessem e usem as mesmas estruturas otimizadas de instrução, promovendo consistência absoluta nas saídas geradas por LLMs.

---

## 🗂️ Organização dos Prompts

Os prompts são organizados pelas seguintes categorias de processos:

*   `generation/`: Prompts focados em criar novos conteúdos (ex: geração de biografias sintéticas de personagens com base em fichas arqueológicas).
*   `validation/`: Prompts para auditoria e controle de qualidade (ex: validação de consistência cronológica em textos históricos).
*   `extraction/`: Prompts para minerar entidades e relacionamentos semânticos (ex: extrair nós e arestas de um texto acadêmico e formatá-los em JSON para o CKE).
*   `translation/`: Prompts especializados em tradução contextual e terminológica de termos latinos, gregos ou línguas modernas.

---

## 🎯 Exemplos de Conteúdo

Cada prompt deve ser armazenado como um arquivo Markdown (`.md`) ou JSON (`.json`) para facilitar a leitura e o carregamento programático. Exemplo de arquivo `extraction/entity_miner.md`:

```markdown
# Prompt: Minerador de Entidades Semânticas para o Grafo CHRONOS
## Contexto
Você receberá um texto historiográfico bruto. Sua tarefa é extrair personagens, batalhas, datas e civilizações...
## Formato de Saída Obrigatório
Sua resposta deve ser estritamente um objeto JSON com o formato:
{
  "nodes": [...],
  "edges": [...]
}
```

---

## 🛡️ Boas Práticas

1. **Evite Jargões Ambíguos:** Use linguagem direta, imperative e forneça exemplos de poucas passagens (Few-Shot Prompting) sempre que uma saída complexa (como JSON) for requerida.
2. **Defina Casos de Erro (Fallback):** Todo prompt deve instruir o modelo sobre como responder caso as informações de entrada sejam insuficientes ou inválidas (ex: `"Se o texto não contiver datas explícitas, retorne um array vazio"`).
3. **Controle de Tokens:** Mantenha os prompts objetivos para não consumir tokens desnecessários no contexto do modelo Gemini, agilizando as respostas do backend.
