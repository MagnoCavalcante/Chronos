# TECH_DEBT — CHRONOS

**Base:** auditoria funcional 5.4.0 e consolidação estrutural 5.4.RF.  
**Escopo:** itens deliberadamente não implementados nesta sprint estrutural.

## Arquitetura

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Consolidar os domínios restantes do layout legado horizontal (`data`, `domain`, `presentation`) no padrão feature-first adotado por Personagens e Civilizações. | Organização e isolamento de mudanças ainda são inconsistentes entre módulos. | Alta | 8–12 dias | 5.5.0 |
| Definir uma política única para controllers: dependências obrigatórias por construtor, sem fallback ao service locator. | Melhora testes e reduz acoplamento implícito. | Média | 3–5 dias | 5.5.0 |
| Substituir o `ServiceLocator` manual por composição explícita no bootstrap, se a complexidade do produto justificar. | Reduz resolução em runtime e dependências ocultas. | Baixa | 5–8 dias | Pós-5.5 |

## Performance

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Paginar, limitar ou mover a Busca Global para consulta server-side. | O índice atual carrega seis domínios integralmente em memória. | Alta | 4–6 dias | 5.4.3 |
| Preservar estado das abas no shell. | Troca de aba pode recriar páginas e repetir carregamentos. | Média | 2–3 dias | 5.5.1 |
| Medir renderização, uso de memória e consultas Supabase com acervo representativo. | Não há baseline de desempenho nem profiling automatizado. | Média | 2–4 dias | 5.5.1 |

## Testes

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Mover os testes de feature de `lib/features/**/tests` para `test/features/**` e configurar execução única da suíte. | A convenção atual dificulta descoberta padrão e cobertura consolidada. | Alta | 2–3 dias | 5.5.0 |
| Criar testes de integração para bootstrap, rotas, Busca Global e carregamento Supabase controlado. | Não há garantia automatizada dos fluxos visíveis. | Alta | 5–8 dias | 5.5.1 |
| Adotar cobertura de código e threshold de CI. | Não há métrica de cobertura confiável. | Média | 2–3 dias | 5.5.1 |

## UI/UX

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Substituir placeholders de Mapa, Favoritos, Ajustes, Artefatos, Localizações, Fontes e Sobre por fluxos completos somente quando especificados. | Recursos expostos ainda não entregam valor funcional. | Alta | 15+ dias | Conforme roadmap |
| Conectar cards de Eras, Eventos, Personagens e Civilizações a detalhes reais. | Listagens atuais terminam em feedback temporário ou não têm ação. | Alta | 5–8 dias | 5.4.2 |
| Implementar ações reais de compartilhar, favoritar, timeline e mapa na página de detalhes. | As ações atuais são apenas feedback visual. | Média | 4–6 dias | 5.4.2 |

## Flutter

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Reduzir as suppressions de `analysis_options.yaml` e corrigir diagnósticos de origem. | `flutter analyze` não expõe todo débito de estilo e código morto. | Alta | 4–6 dias | 5.5.0 |
| Padronizar componentes das telas de Civilizações e Personagens com os componentes base do Design System. | Há inconsistência interna de scaffold, cores e espaçamento. | Média | 2–3 dias | 5.5.2 |

## Supabase

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Validar consultas reais, RLS e esquema contra ambiente de staging em integração automatizada. | A aplicação consulta dados remotos, mas não há validação E2E repetível. | Alta | 3–5 dias | 5.5.1 |
| Definir contratos de paginação e filtros no banco para catálogos grandes. | Evita crescimento de tempo/memória no cliente. | Média | 3–4 dias | 5.4.3 |

## Segurança

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Remover valores padrão de URL/chave Supabase do código de produção e exigir `--dart-define` no pipeline de release. | Reduz risco de configuração exposta e divergência de ambiente. | Alta | 1–2 dias | 5.5.0 |
| Definir autenticação e autorização antes de qualquer CRUD ou favoritos sincronizados. | Escrita sem política de acesso seria insegura. | Alta | 3–5 dias | Antes do CRUD |

## Documentação

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Revisar documentação histórica que ainda menciona Riverpod e GoRouter, tecnologias não presentes no `pubspec.yaml`. | Evita decisões técnicas baseadas em documentação desatualizada. | Média | 2–3 dias | 5.5.0 |
| Manter diagrama de rotas e inventário de módulos a cada sprint. | Reduz retorno de rotas e classes órfãs. | Baixa | 0,5 dia/sprint | Contínuo |

## Código

| Descrição | Impacto | Prioridade | Esforço | Sprint recomendada |
|---|---|---|---|---|
| Remover ou completar textos/classes de recursos futuros quando a funcionalidade correspondente for entregue. | Placeholders tornam intenção de produto e estado do código difíceis de distinguir. | Média | 1–2 dias por módulo | Conforme roadmap |
| Dividir componentes grandes e medir complexidade ciclomática. | Algumas telas/controllers concentram orquestração e UI. | Baixa | 3–5 dias | Pós-5.5 |
