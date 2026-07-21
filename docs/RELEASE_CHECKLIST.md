# CHRONOS — Checklist de Release & Quality Gates
## RFC-010 — Garantia de Qualidade e Prontidão de Entrega (Sprint 5.2.1)

Este documento estabelece o fluxo de verificação necessário para aprovar uma versão Release Candidate (RC) do CHRONOS antes da publicação oficial.

---

## 1. Fluxo de Quality Gate

Nenhuma versão do CHRONOS é promovida para produção se não cumprir integralmente o seguinte fluxo de portões de qualidade:

```
+--------------------+      +--------------------+      +--------------------+
|  Build & Linter    | ---> |   Guarda de Arq.   | ---> |  Validação Conteúdo|
+--------------------+      +--------------------+      +--------------------+
          |                           |                           |
          v                           v                           v
     Sem Erros                  Nenhum Desvio                 100+ Nós Reais
          |                           |                           |
          +---------------------------+---------------------------+
                                      |
                                      v
                        +--------------------+
                        |   Aprovação RC     |
                        +--------------------+
```

---

## 2. Checklist do Portão de Qualidade

### 2.1 Compilação & Estática
- [ ] **Flutter Build**: O aplicativo compila com sucesso para todas as plataformas alvo (Web, iOS, Android) sem erros de bundling.
- [ ] **Flutter Analyze / Linter**: Execução limpa do analisador de código, sem warnings, erros de importação ou referências obsoletas.
- [ ] **Type Safety**: Tipagem estática em 100% dos retornos e parâmetros das controllers e entidades de domínio.

### 2.2 Verificação de Arquitetura (Architecture Guardian)
- [ ] **Desacoplamento de Camadas**: Nenhum widget da camada de apresentação acessa repositórios ou data sources de infraestrutura diretamente.
- [ ] **Injeção de Dependências**: Todos os domain controllers são obtidos por meio de injeção centralizada de dependências.
- [ ] **Unificação de Telas**: Todas as exibições detalhadas de dados históricos herdam ou direcionam fluxos de consumo para a `EntityDetailsPage` comum.

### 2.3 Validação Baseada em Conteúdo Real (Content-Driven QA)
- [ ] **Carga de Teste**: O banco de dados de homologação contém a matriz de sementes históricas validada:
  - Mínimo de 10 Eras completas.
  - Mínimo de 50 Eventos históricos contextualizados.
  - Mínimo de 30 Personagens descritos com riqueza de detalhes.
  - Mínimo de 15 Civilizações cadastradas.
  - Mínimo de 20 Artefatos associados.
  - Mínimo de 20 Localizações arqueológicas e geográficas.
- [ ] **Integridade Relacional**: Os links entre personagens, eras e localizações resolvem e carregam os cards relacionados em menos de 100ms.

### 2.4 Acessibilidade & UX (a11y/UI QA)
- [ ] **Skeletons ativos**: Ao forçar throttling de conexão de dados, as telas exibem o `ChronosSkeleton` sem tremulações bruscas ou saltos de pixels.
- [ ] **Error Recovery**: Ao simular perda total de internet, o aplicativo exibe o `ChronosErrorState` correspondente com o botão "Tentar Novamente".
- [ ] **Áreas de Toque**: Todos os botões interativos possuem área ativa de no mínimo 44x44dp.
- [ ] **Contraste de Cores**: Todo elemento de texto possui índice de contraste adequado (mínimo 4.5:1) em relação ao seu background.

### 2.5 Indicadores de Desempenho (Performance Benchmarks)
- [ ] **Taxa de Quadros**: Rolagens rápidas na busca global e na timeline histórica mantêm taxas constantes de 60 FPS / 120 FPS.
- [ ] **Evitação de Over-rebuilding**: Componentes pesados (como a busca e listagem) utilizam builders incrementais e seletores de estado granulares.
