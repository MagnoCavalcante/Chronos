# Arquitetura de Software e Ontologias (/docs/architecture)

Este diretório abriga a documentação de arquitetura de software, modelagem de banco de dados, design patterns e a ontologia do **CHRONOS Knowledge Engine (CKE)**.

---

## 🧭 Objetivo

Orientar desenvolvedores de software, engenheiros de dados e agentes de IA sobre as regras estruturais e de comunicação lógica do sistema. Este diretório garante que a engenharia do projeto permaneça limpa, escalável e fiel aos preceitos conceituais de redes de causalidade histórica descritas no CKE.

---

## 🗂️ Documentos Principais

*   **`CHRONOS_ARCH_FOUNDATION.md`:** Documento de fundação que estabelece o funcionamento conceitual do motor semântico CKE, a ontologia de nós (personagens, batalhas, civilizações, etc.), os relacionamentos (arestas) e a inovadora escala científica de níveis de evidência.
*   **`CHRONOS_WORLD_ENGINE.md`:** Especificação do motor espacial-temporal do CHRONOS. Explica como os eventos e fronteiras territoriais se transformam dinamicamente ao longo das coordenadas espaciais em paralelo ao fluxo temporal linear.

---

## 🎯 Exemplos de Arquitetura em Ação

### O Grafo de Conhecimento Semântico
Para modelar o assassinato de Júlio César:
*   **Nó A (Personagem):** *Júlio César*
*   **Aresta (`TEMPORAL_ANCHOR`):** Ancorado no ano *44 a.C.*
*   **Aresta (`PARTICIPATED_IN`):** Participou de: *Idos de Março* (Nó B - Evento)
*   **Aresta (`KILLED_BY`):** Assassinado por: *Marcus Junius Brutus* (Nó C - Personagem)
*   **Nó B (Evento):** Ocorreu em: *Teatro de Pompeu, Roma* (Nó D - Construção)

---

## 🛡️ Boas Práticas

1. **Clean Architecture Obrigatória:** Qualquer especificação de novas features de software deve respeitar as barreiras das camadas da Clean Architecture, impedindo o acoplamento de widgets visuais com fontes externas de dados.
2. **Definição de Tipos e Enums:** Novas classes de modelos ou colunas do Supabase devem ser devidamente tipadas e documentadas em conformidade com as categorias e arestas descritas na fundação do CKE.
3. **Escalabilidade Computacional:** Evite a criação de relacionamentos bidirecionais densos e desnecessários que possam onerar as consultas recursivas no banco de dados. Projete arestas direcionadas precisas.
4. **Padrão de Nome de Arquivo:** Todos os novos documentos técnicos adicionados nesta pasta devem possuir o prefixo `CHRONOS_` seguido por caixa alta com underlines (`snake_case` em caixa alta) (ex: `CHRONOS_CACHING_STRATEGY.md`).
