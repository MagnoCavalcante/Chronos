# CHRONOS — Release Notes 1.0.0
## RFC-014 — Lançamento Oficial "O Tempo em Camadas" (Sprint 5.2.5)

Temos o orgulho de apresentar a versão **1.0.0 (Release Candidate 1)** do CHRONOS, um ecossistema de exploração e visualização histórica de alta fidelidade e prestígio.

---

## 1. Destaques da Versão 1.0

### 1.1 Identidade Visual Consistente e Premium
Sob o conceito *"O Tempo em Camadas"*, o CHRONOS ostenta uma marca sofisticada e minimalista. Nossas cores e fontes foram selecionadas meticulosamente:
- **Azul Profundo e Ouro Antigo**: Tons que transmitem autoridade científica e o sentimento de descoberta arqueológica.
- **Tipografia de Prestígio**: Pareamento clássico da elegante fonte **Cinzel** para títulos com a moderna e hiper-legível **Inter** para textos e interface geral.

### 1.2 Mecanismo de Busca Global de Alta Relevância
Pesquise instantaneamente por qualquer Era, Evento, Personagem, Civilização ou Artefato. O algoritmo de relevância prioriza correspondências exatas de títulos, além de fornecer ordenação cronológica precisa capaz de unificar anos negativos (B.C.) e anos positivos (A.D.).

### 1.3 Linha do Tempo Contínua e Detalhes Universais
- **Interactive Timeline**: Transite sequencialmente por grandes eventos históricos através de uma linha do tempo clean com carregamento de skeletons reativos.
- **Universal Details (EntityDetailsPage)**: Uma página de visualização rica que unifica todas as entidades históricas em fichas técnicas detalhadas com carrossel de fotos, biografias estruturadas e conexões relacionais imediatas.

---

## 2. Changelog Detalhado

- **Branding**: Criação e organização de toda a árvore de assets oficiais da marca em formato vetorial SVG (`assets/branding/`).
- **UX Hardening**: Implementação do `ChronosSkeleton` para evitar tremulações e saltos de pixels durante requisições de rede.
- **Error States**: Padronização dos componentes `ChronosEmptyState` e `ChronosErrorState` com botões reativos de retentativa para garantir tolerância a falhas.
- **Acessibilidade**: Adequação completa de contraste WCAG AA e ampliação de touch targets para no mínimo `44x44dp`.
- **Platform Integrity**: Limitação rígida de permissões e segurança no manifesto do Android.
