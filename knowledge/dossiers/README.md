# Dossiês Históricos e Mitológicos (/knowledge/dossiers)

Este diretório contém os dossiês e biografias completos de personagens, batalhas, civilizações e elementos míticos antes de serem publicados na base de dados do CHRONOS.

---

## 🧭 Objetivo

Padronizar a escrita e formatação de todos os artigos da plataforma. Este diretório fornece o modelo (template) e as diretrizes estruturais de escrita de modo que todos os dossiês mantenham um tom literário de alta imersão sem abdicar do rigor científico da historiografia moderna.

---

## 🗂️ Modelo de Dossiê Padrão (Template)

Para criar um novo dossiê, utilize a estrutura abaixo salvando o arquivo em Markdown (`.md`):

```markdown
---
id: <identificador_unico_do_cke>
name: <Nome de Exibição Comercial>
category: <Personagem | Civilização | Batalha | Deus | etc>
era: <Era Histórica de Enquadramento>
evidence_level: <Nível de Evidência Científica>
---

# <Nome de Exibição Comercial>

## 🧭 Visão Geral
[Um parágrafo de 3-4 linhas resumindo de forma épica e cativante o impacto histórico ou mítico da entidade]

## 📜 Narrativa Histórica e Contexto
[Desenvolvimento textual dividido em subtítulos claros descrevendo a trajetória, decisões, conflitos e legados históricos]

## 🛡️ Relações Semânticas (Grafo CKE)
- **Origem:** [Entidade A] -> `RELATION_TYPE` -> [Esta Entidade]
- **Destino:** [Esta Entidade] -> `RELATION_TYPE` -> [Entidade B]

## 📚 Fontes e Referências
- **Fontes Primárias:** [Lista de fontes em /knowledge/sources]
- **Bibliografia Moderna:** [Lista de livros de referência em /knowledge/bibliography]
```

---

## 🛡️ Boas Práticas

1. **Campos Obrigatórios no Frontmatter:** Todo dossiê deve obrigatoriamente iniciar com as tags YAML especificando o `id`, `name`, `category`, `era` e `evidence_level`. Isso possibilita que os scripts de automação leiam e insiram os metadados diretamente no banco de dados.
2. **Uso de Citações Literárias:** Sempre que possível, insira blocos de citações (`>`) contendo falas reais de fontes clássicas primárias para aumentar o engajamento e fidelidade dramática do dossiê.
3. **Imagens de Apoio:** Não decore o texto com imagens aleatórias. Toda imagem incluída deve possuir legendas explicativas ligando o artefato material ou monumento à narrativa do texto.
