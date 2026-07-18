# Base Editorial de Conhecimento (/knowledge)

Este diretório abriga toda a base documental, pesquisas acadêmicas, referências e dossiês de curadoria histórica estruturados antes de serem migrados ou salvos fisicamente nas tabelas do banco de dados (Supabase/PostgreSQL).

---

## 🧭 Objetivo

Servir como a central de redação offline e de pesquisa para o time de historiadores e redatores humanos, em cooperação com as IAs. Esta pasta funciona separadamente do banco de dados, servindo de ambiente seguro para escrever, revisar, traduzir e polir os textos e relações do Grafo de Conhecimento Semântico antes de sua efetiva publicação.

---

## 🗂️ Estrutura de Subdiretórios

```
knowledge/
├── dossiers/           # Dossiês históricos completos sobre personagens, locais e impérios
├── bibliography/       # Fichas bibliográficas de livros acadêmicos contemporâneos de referência
├── sources/            # Registros textuais de fontes primárias históricas (traduções de textos antigos)
├── maps/               # Arquivos e descrições detalhadas de fronteiras e campanhas militares
└── timeline/           # Linhas do tempo estruturadas sequencialmente por eras ou temas
```

### 1. `dossiers/`
*   **Finalidade:** Hospeda artigos estruturados em Markdown sobre entidades históricas mestre (ex: `julius_caesar.md`, `athens.md`, `punic_wars.md`). Estes arquivos devem possuir cabeçalhos em formato YAML (frontmatter) para fácil extração de metadados.

### 2. `bibliography/`
*   **Finalidade:** Fichas bibliográficas detalhadas de livros e tratados de historiadores modernos (ex: Marc Bloch, Edward Gibbon) que embasam cientificamente as informações registradas na plataforma.

### 3. `sources/`
*   **Finalidade:** Contém traduções em domínio público ou fragmentos catalogados de fontes textuais primárias de relevância (ex: textos de Cícero, Heródoto, epigrafias gravadas em pedras antigas).

### 4. `maps/`
*   **Finalidade:** Descrições e coordenadas de marcação territorial de reinos do passado em diferentes recortes cronológicos, auxiliando na renderização do mapa dinâmico do tempo.

### 5. `timeline/`
*   **Finalidade:** Encadeamentos sequenciais de eventos organizados cronologicamente por eixos geográficos ou civilizacionais.
*   **Documento de Referência:**
    *   `CHRONOS_MASTER_TIMELINE.md`: O cronograma conceitual de eventos e as bases da linha do tempo do projeto.

---

## 🎯 Exemplo de Estrutura de Dossiê (YAML Frontmatter)

Arquivo `knowledge/dossiers/julio_cesar.md`:
```markdown
---
id: character_julio_cesar
name: Júlio César
category: Personagem
era: Roma Antiga (Fim da República)
timeline_anchor: 100 a.C. - 44 a.C.
scientific_evidence_level: Textual Primário & Epigráfico
---
# Júlio César

Gaius Iulius Caesar foi um patrício, líder militar e político romano...
```

---

## 🛡️ Boas Práticas Editoriais

1. **Rigor Científico de Redação:** Nenhum dossiê deve ser aceito na pasta `dossiers/` sem conter uma seção explícita e organizada de referências, listando as fontes primárias e secundárias do diretório `sources/` e `bibliography/`.
2. **Nomenclatura em Snake_Case:** Nomeie todos os arquivos markdown com letras estritamente minúsculas separadas por underline (ex: `cleopatra_vii.md`, `guerra_do_peloponeso.md`).
3. **Imagens Otimizadas:** Ao referenciar mídias dentro do dossiê, utilize os caminhos relativos para os arquivos salvos em `assets/images/` ou `assets/illustrations/`, garantindo que os vínculos persistam.
4. **Respeito às Categorias da Ontologia:** Certifique-se de que a categoria (`category`) declarada nos metadados YAML do dossiê coincida exatamente com um dos tipos de nós de dados suportados pelo Grafo do CHRONOS Knowledge Engine.
