# Documentação Geral do Projeto (/docs)

Este diretório centraliza toda a documentação conceitual, estratégica, metodológica e de design do ecossistema CHRONOS.

---

## 🧭 Objetivo

Funcionar como a "Enciclopédia de Engenharia e Design" do projeto. Aqui, qualquer membro do time, parceiro editorial ou novo desenvolvedor pode compreender as decisões estratégicas por trás da plataforma, as especificações técnicas, os roteiros de lançamento e a identidade visual que norteia as interfaces do aplicativo.

---

## 🗂️ Categorias de Documentação

Para manter os documentos fáceis de navegar, o diretório é subdividido em cinco grandes pilares temáticos:

```
docs/
├── architecture/       # Visão estrutural de software, ontologia de dados e motores
├── product/            # Visões estratégicas do CHRONOS, especificações V1 e metas
├── content/            # Metodologia editorial de redação e estrutura de dados histórico-mítica
├── ui-ux/              # Estudo de interfaces, guias de estilo e wireframes das telas
└── roadmap/            # Roteiros de entregas incrementais de funcionalidades e temas
```

### 1. `architecture/`
*   **Propósito:** Hospeda as fundações estruturais de engenharia de software e ontologias conceituais do motor.
*   **Documentos Disponíveis:**
    *   `CHRONOS_ARCH_FOUNDATION.md`: Detalhamento completo do motor semântico CKE, categorias de nós do Grafo e representação de níveis de evidência arqueológico-científica.
    *   `CHRONOS_WORLD_ENGINE.md`: Detalhamento de como o motor renderiza eventos e conexões espaciais e territoriais ao longo do tempo.

### 2. `product/`
*   **Propósito:** Especificações de negócio do projeto, metas comerciais, análise competitiva e os limites do escopo do aplicativo móvel.
*   **Documentos Disponíveis:**
    *   `CHRONOS_PRODUCT_BIBLE.md`: A bíblia de produto detalhando o que é e o que não é o aplicativo CHRONOS.
    *   `CHRONOS_PRODUCT_STRATEGY.md`: Alinhamento estratégico e posicionamento de mercado.
    *   `CHRONOS_V1_SPECIFICATION.md`: O escopo funcional para o lançamento da primeira versão estável do aplicativo móvel.

### 3. `content/`
*   **Propósito:** Guias teóricos para a formulação de conteúdo, taxonomia dos dossiês e organização textual.
*   **Documentos Disponíveis:**
    *   `CHRONOS_CONTENT_FRAMEWORK.md`: Estrutura teórica dos conteúdos e as taxonomias utilizadas pelos editores.

### 4. `ui-ux/`
*   **Propósito:** Estudo de interfaces do usuário (UI), guias de paletas de cores, especificações tipográficas, regras de contraste para acessibilidade e wireframes estruturais.

### 5. `roadmap/`
*   **Propósito:** O planejamento macro de lançamento do projeto. Dividido em sprints, trimestres (OKRs) e eras históricas (ex: Lançamento do Tema da Grécia Antiga, Roma Antiga, Idade Média, etc.).

---

## 🛡️ Boas Práticas de Documentação

1. **Simplicidade de Leitura:** Escreva os documentos em formato Markdown (`.md`) de fácil leitura, com formatações elegantes de subtítulos, tabelas de dados e diagramas visuais explicativos.
2. **Atualização Contínua:** Sempre que uma funcionalidade de produto for adicionada, alterada ou descontinuada, atualize imediatamente os arquivos correspondentes para que a documentação não fique obsoleta.
3. **Foco no Leitor:** Lembre-se de estruturar os textos de forma acessível para diferentes profissionais (designers de interface devem conseguir ler documentos de produto, e historiadores devem conseguir compreender as ontologias de arquitetura).
4. **Histórico de Alterações:** Se possível, insira uma pequena seção de tabela no início de cada documento rastreando a versão, data e autor que aplicou a última revisão técnica.
