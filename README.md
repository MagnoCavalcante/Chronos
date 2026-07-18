# CHRONOS

> **"Explore a História através do Tempo."**

CHRONOS é uma plataforma revolucionária de exploração histórica, mitológica e arqueológica projetada para funcionar como um verdadeiro "GPS do Tempo". O projeto combina o poder do desenvolvimento multi-plataforma com dispositivos móveis modernos, inteligência artificial integrada e um motor semântico robusto para oferecer narrativas históricas interativas baseadas em rigor científico e excelência de experiência de usuário (UI/UX).

---

## 🧭 Missão e Visão

### Missão
Democratizar o acesso ao conhecimento histórico de alta fidelidade científica por meio de tecnologia imersiva, aproximando as pessoas das origens da civilização humana e desmistificando o passado através de evidências concretas, narrativas envolventes e inteligência artificial responsável.

### Visão
Tornar-se a maior referência global em enciclopédia histórica interativa e motor semântico de conhecimento do passado, servindo como uma ponte entre a academia científica e o público entusiasta através de aplicativos móveis refinados.

---

## 📜 Princípios Editoriais

Toda a base de dados, dossiês e conteúdos gerados ou consolidados no ecossistema CHRONOS seguem diretrizes rígidas que garantem a credibilidade e excelência do projeto:

1. **História Baseada em Evidências:** Todo fato narrado deve ser ancorado em evidências materiais (arqueologia), epigráficas (inscrições), numismáticas (moedas) ou documentais (textos primários).
2. **Separação Rígida entre Fatos, Interpretações e Hipóteses:** O conteúdo deve deixar claro o que é um fato historicamente comprovado, o que é uma interpretação historiográfica amplamente aceita e o que é uma hipótese ou debate em aberto.
3. **Fontes Verificáveis:** Disponibilização sistemática de referências bibliográficas e fontes originais para que o usuário ou pesquisador possa rastrear a origem da informação.
4. **Neutralidade Metodológica:** Abordagem imparcial e científica de eventos políticos, conflitos militares, transformações religiosas e dinâmicas sociais, evitando anacronismos e julgamentos morais contemporâneos.
5. **Transparência:** Clareza sobre os limites do conhecimento atual ("não sabemos") e sobre os processos de curadoria editorial da plataforma.

---

## 🛠️ Stack Tecnológico

A fundação do ecossistema CHRONOS foi projetada para alta performance, escalabilidade e integridade de dados:

*   **Frontend Mobile & Web:** [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/) (Interface reativa, animações fluidas de alta performance a 60/120fps).
*   **Backend & Serverless:** [Supabase](https://supabase.com/) (Infraestrutura robusta de backend-as-a-service integrada).
*   **Banco de Dados:** [PostgreSQL](https://www.postgresql.org/) (Modelo relacional de dados com suporte a extensões de busca e indexação).
*   **Autenticação:** [Supabase Auth](https://supabase.com/docs/guides/auth) (Gerenciamento de identidades seguro com suporte a OAuth e login social).
*   **Armazenamento de Arquivos:** [Supabase Storage](https://supabase.com/docs/guides/storage) (Hospedagem otimizada de mídias, áudios históricos e ilustrações).
*   **Hospedagem de Repositório & CI/CD:** [GitHub](https://github.com/) (Automação de builds, testes e entrega contínua).
*   **Inteligência Artificial & Agentes:** [Google AI Studio](https://aistudio.google.com/) (Modelagem de agentes especialistas de IA utilizando a API do Gemini para enriquecimento semântico, RAG e suporte editorial).

---

## 📁 Organização do Repositório

A arquitetura do repositório CHRONOS segue um padrão modular rigoroso, onde cada pasta desempenha um papel explícito no ciclo de vida do desenvolvimento e curadoria de conteúdo:

```
chronos/
├── .ai/                    # IA, agentes especialistas, prompts e guias de contexto
├── .github/                # Integração contínua (CI/CD) e workflows de automação
├── app/                    # Código-fonte principal do aplicativo móvel (Flutter)
├── assets/                 # Recursos estáticos (imagens, áudio, fontes, mapas)
├── database/               # Modelagem, migrações, sementes (seeds) e RLS do Supabase
├── docs/                   # Documentação detalhada de arquitetura, produto e UI/UX
├── knowledge/              # Base editorial e dossiês de curadoria histórica em Markdown
├── scripts/                # Scripts de automação de tarefas, limpeza de dados e utilitários
├── .gitignore              # Definição de arquivos ignorados pelo Git
├── LICENSE                 # Termos de licença do projeto
└── README.md               # Este arquivo de documentação principal
```

Para compreender os detalhes operacionais de cada diretório, consulte o arquivo `README.md` localizado dentro de cada respectiva pasta.

---

## 🧑‍💻 Boas Práticas de Contribuição

*   **Rastreabilidade:** Toda alteração no código deve estar associada a uma issue ou especificação em `docs/`.
*   **Fidelidade Arquitetural:** Respeite rigorosamente a separação de camadas definida em `docs/architecture/`.
*   **Padrão Editorial:** Nenhuma inserção de dados no banco de dados deve ignorar as diretrizes em `.ai/standards/` e `knowledge/`.

---
*CHRONOS © 2026. Todos os direitos reservados. "O tempo é um fluxo, a história é o seu registro."*
