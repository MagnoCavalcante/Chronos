# PROJECT AUDIT — CHRONOS

**Sprint:** 5.4.0 — Functional Audit & Gap Analysis  
**Data:** 22/07/2026  
**Escopo auditado:** aplicativo Flutter em `app/`. Este documento não altera arquitetura, Design System, banco de dados ou funcionalidades.

## Metodologia e limitações

- Leitura estática de rotas, telas, controllers, fontes Supabase, DI, estados e pontos de interação.
- Validação executada: `flutter analyze`, testes unitários/widget e inicialização no Android Emulator (`emulator-5554`).
- O app instalou/iniciou no emulador, mas a sessão Flutter perdeu conexão antes de ser possível executar uma navegação manual completa. Portanto, os status de interação abaixo são confirmados por código e por inicialização, não por uma sessão E2E integral.
- Não há suíte de integração/E2E, nem testes de navegação, CRUD, responsividade ou Supabase real automatizados.

## Estado Geral

| Área | Estimativa | Diagnóstico |
|---|---:|---|
| Arquitetura | 75% | Camadas e DI existem, mas há módulos duplicados de Civilizações e fronteiras de feature inconsistentes. |
| UI / Design System | 78% | Estrutura visual, estados e responsividade base estão presentes; várias telas ainda usam feedback/placeholder no lugar de fluxo. |
| Backend / Supabase | 65% | Leitura real para Eras, Eventos, Personagens, Civilizações, Artefatos e Localizações; ausência total de escrita/CRUD. |
| Funcionalidades | 42% | Consulta/listagem e busca parcial funcionam; detalhes, mapa, favoritos, ajustes e CRUD não estão entregues. |
| Testes | 35% | 6 de 8 arquivos de teste de feature passam; os 2 testes de controller e o smoke test falham. Não há cobertura de integração. |
| Performance | 70% | Listas usam builders e carga paralela; busca reconstrói índice inteiro, e não há profiling/caching/paginação. |
| Conclusão geral | **55%** | Fundação técnica pronta, experiência de consulta parcialmente funcional, recursos de produto ainda incompletos. |

## Validações executadas

| Comando / fluxo | Resultado | Evidência |
|---|---|---|
| `flutter analyze` | ✅ Passou | Retornou `No issues found!`. O resultado é condicionado por regras ignoradas em `app/analysis_options.yaml`; não equivale a inexistência de diagnósticos de estilo/legado. |
| `flutter test` | ❌ Falhou | A descoberta padrão reportou `Test directory "test" not found`, embora `app/test/widget_test.dart` exista. |
| `flutter test test\\widget_test.dart` | ❌ Falhou | O smoke test não constrói `MaterialApp`; o app depende do `NavigationService` não registrado quando `ChronosApp` é instanciado diretamente. |
| Testes Civilizações | ⚠ Parcial | Entity, model e repository passam; `civilizations_controller_test.dart` falha por dependências `GetCivilizationById`/`GetCivilizationBySlug` não injetadas no fixture. |
| Testes Personagens | ⚠ Parcial | Entity, model e repository passam; `historical_characters_controller_test.dart` falha pelo mesmo padrão de DI obrigatória fora do escopo do teste. |
| Android Emulator | ⚠ Inicialização validada | `flutter run -d emulator-5554` instalou/iniciou o processo; a conexão foi perdida antes da inspeção manual completa. |

## Inventário de telas e módulos

### Shell de Navegação

**Status:** ⚠ Parcial  
**Navegação:** A navegação por abas funciona localmente via `ChronosTab`/`AnimatedSwitcher`; mobile usa `BottomNavigationBar`, tablet usa `NavigationRail` e desktop usa sidebar.  
**Layout:** ✅ Há breakpoints e composição específica por plataforma.  
**Dados / estados:** Não aplicável ao shell.  
**Problemas:**

- As ações de **Notificações** e **Perfil** usam callbacks vazios.
- Trocar abas recria o widget selecionado; estado e carga podem ser reiniciados ao voltar à aba.
- As abas Mapa, Favoritos e Ajustes retornam `ChronosEmptyView`, não telas funcionais.

**Prioridade:** Alta  
**Estimativa:** 3–5 dias para persistência de estado e fluxos; módulos dependentes têm estimativas próprias.  
**Dependências:** serviços de perfil/autenticação, favoritos persistentes, mapa e preferências.

### Home / Dashboard

**Status:** ⚠ Parcial  
**Navegação:** Os cards de Eras, Eventos, Personagens, Civilizações, Artefatos e Localizações chamam rotas nominais.  
**Layout:** ✅ Responsivo com lista no mobile e grids em tablet/desktop; usa tokens e componentes do Design System.  
**Dados:** Apenas conteúdo estático; não há resumo do acervo nem métricas reais.  
**Busca:** ❌ A área de busca mostra `SnackBar` informando que será ativada futuramente, apesar de existir uma aba de Busca funcional.  
**CRUD:** Não aplicável.  
**Estados:** Não possui loading/erro/vazio por não carregar dados.  
**Problemas:** Artefatos e Localizações levam a placeholders; busca da Home não direciona para a aba Busca.  
**Prioridade:** Média  
**Estimativa:** 1–2 dias após definição da estratégia de navegação entre abas.  
**Dependências:** Busca Global e rotas funcionais de Artefatos/Localizações.

### Eras Históricas

**Status:** ⚠ Parcial — listagem real  
**Navegação:** A rota `/eras` está registrada e é acessível pela Home. Não há detalhe ao tocar no card.  
**Layout:** ✅ Usa `ChronosScaffold`, `ChronosPage`, `ChronosList`, `ChronosCard` e estados do Design System.  
**Dados:** ✅ Consulta Supabase `eras` com filtros de ativo/publicado.  
**Busca / filtros / ordenação:** ❌ Não expostos na tela.  
**CRUD:** ❌ Nenhum create, update ou delete existe no app.  
**Estados:** ✅ Loading, erro, vazio, refresh manual e pull-to-refresh.  
**Problemas:** A própria descrição da classe identifica a tela como validação técnica; cards não têm ação de detalhe.  
**Prioridade:** Alta  
**Estimativa:** 3–4 dias para detalhe e filtros; CRUD depende de requisitos/editorial.  
**Dependências:** `EraRemoteDataSource`, `ErasController`, `EntityDetailsPage` ou rota de detalhe.

### Eventos Históricos

**Status:** ⚠ Parcial — listagem real com controles placeholder  
**Navegação:** A rota `/events` está registrada. O toque no card mostra `SnackBar` de “Sprint futura”, sem abrir detalhes.  
**Layout:** ✅ Estados de loading/erro/vazio e lista usam componentes do Design System.  
**Dados:** ✅ Consulta Supabase `historical_events`, com dados de Era associados pelo controller.  
**Busca:** ❌ `ChronosSearchBar` é exibida sem callback/ligação a controller.  
**Filtros / ordenação:** ❌ Chips de tipo e era exibem mensagem “Em breve”; mapa e timeline no módulo abrem sheets placeholder.  
**CRUD:** ❌ Inexistente.  
**Estados:** ✅ Loading, erro, vazio e refresh.  
**Problemas:** Controles sugerem funções que não existem; nenhum fluxo de detalhe está conectado.  
**Prioridade:** Alta  
**Estimativa:** 5–7 dias.  
**Dependências:** rota de detalhe, filtros de controller/datasource e mapa/timeline se os atalhos forem mantidos.

### Linha do Tempo

**Status:** ⚠ Parcial funcional  
**Navegação:** Acessível pela aba Timeline; itens abrem `EntityDetailsPage`.  
**Layout:** ✅ Estrutura responsiva, loading, erro, vazio e lista de itens cronológicos.  
**Dados:** ✅ Carrega Eras e Eventos em paralelo de controllers conectados ao Supabase.  
**Busca / filtros / ordenação:** ✅ Há busca local, filtro por Era/período, ordenação cronológica e agrupamento implementados no `TimelineController`.  
**CRUD:** ❌ Não aplicável/inexistente.  
**Estados:** ✅ Loading, erro, acervo vazio e vazio após filtros.  
**Performance:** ⚠ A carga é paralela e a lista é virtualizada, mas filtros e agrupamento são recomputados em memória; não há paginação/cache persistente.  
**Problemas:** Não há teste de integração; detalhe depende de dados/genéricos e ações do detalhe ainda são simuladas.  
**Prioridade:** Média  
**Estimativa:** 2–3 dias para testes e estabilização; 4–6 dias adicionais para mapa/relacionamentos reais.  
**Dependências:** Eras, Eventos, `EntityDetailsPage` e desenho de relacionamentos.

### Busca Global

**Status:** ⚠ Parcial funcional  
**Navegação:** Acessível apenas pela aba Busca; a busca visual da Home não a aciona. Resultados abrem `EntityDetailsPage`.  
**Layout:** ✅ Campo, filtros, ordenação, loading, erro, vazio e resultados existem.  
**Dados:** ✅ Indexa em memória dados carregados dos controllers de Eras, Eventos, Artefatos, Localizações, Personagens e Civilizações.  
**Busca / filtros / ordenação:** ✅ Debounce de 300 ms, busca textual, filtro de categoria e ordenação por relevância/alfabética/cronológica.  
**CRUD:** ❌ Não aplicável.  
**Estados:** ✅ Carregamento inicial, carregamento de pesquisa, erro e resultado vazio.  
**Problemas:**

- O refresh chama `dispose()` no controller ativo, cria um controller local não atribuído ao campo e não atualiza o `ListenableBuilder`; o fluxo de refresh é quebrado.
- O índice é carregado integralmente no cliente, sem paginação nem pesquisa server-side.
- O resultado depende de registros/metadata do `EntityRegistry`; entidades não registradas são silenciosamente excluídas do índice.

**Prioridade:** Alta  
**Estimativa:** 3–5 dias.  
**Dependências:** controladores de todos os domínios e `EntityRegistry` completo.

### Personagens Notáveis

**Status:** ⚠ Parcial — listagem real  
**Navegação:** Rota `/historical-characters` registrada. Existe também `HistoricalCharactersRoutes` com `/historical_characters`, mas ela não é incorporada ao `AppRouter`; é uma rota órfã/inconsistente. O toque no card só exibe `SnackBar`.  
**Layout:** ✅ Loading, erro, vazio, refresh e lista; carrega Eras contextuais para os cards.  
**Dados:** ✅ Consulta Supabase `historical_characters` com filtros `ativo` e `publication_status`.  
**Busca / filtros / ordenação:** ❌ Não implementados.  
**CRUD:** ❌ Inexistente.  
**Estados:** ✅ Estados de lista e refresh. Erro ao carregar Eras contextuais apenas é logado; o card continua sem contexto, sem feedback ao usuário.  
**Problemas:** Sem detalhe, sem filtro, sem uso de `getById`/`getBySlug` na UI; rota duplicada.  
**Prioridade:** Alta  
**Estimativa:** 4–6 dias.  
**Dependências:** detalhe de entidade, rota canônica e política para referências de Era indisponíveis.

### Civilizações Antigas

**Status:** ⚠ Parcial — listagem real, arquitetura duplicada  
**Navegação:** Rota `/civilizations` está registrada e acessível pela Home. Toque no card só mostra `SnackBar`.  
**Layout:** ⚠ Possui loading/erro/vazio/refresh, mas usa `Scaffold`, cores e padding diretos, menos consistente que as telas que usam o Design System completo.  
**Dados:** ✅ Feature ativa consulta Supabase `civilizations`.  
**Busca / filtros / ordenação:** ❌ Não expostos.  
**CRUD:** ❌ Inexistente.  
**Estados:** ✅ Loading, erro, vazio, pull-to-refresh e ação de sincronizar.  
**Problemas:**

- Há cópias de `Civilization`, model, datasource, repository e controller em `lib/domain|data|presentation` e em `lib/features/civilizations`; isso aumenta risco de divergência.
- A feature importa a entidade canônica, mas o conjunto duplicado legado permanece no repositório.
- Testes do controller falham por dependências não injetadas no fixture.

**Prioridade:** Alta  
**Estimativa:** 3–5 dias para consolidar o módulo e conectar detalhe/filtros.  
**Dependências:** definição do módulo canônico de Civilizações e testes de DI.

### Artefatos & Relíquias

**Status:** ❌ Placeholder / não acessível como módulo funcional  
**Navegação:** A Home e `NavigationService` apontam para `/artifacts`, mas `AppRouter` entrega `_FutureSprintPlaceholderScreen`.  
**Layout:** ✅ Placeholder visual.  
**Dados:** ⚠ Existem datasource, repository, use cases e controller Supabase para `artifacts`, usados apenas pela Busca Global. Não existe tela de listagem/detalhe ligada a eles.  
**Busca:** ⚠ Pesquisável globalmente após indexação.  
**CRUD:** ❌ Inexistente.  
**Estados:** Apenas o placeholder de rota; estados de dados não expostos ao usuário.  
**Prioridade:** Alta  
**Estimativa:** 5–7 dias.  
**Dependências:** tela, rota, detalhe e decisões de imagem/3D.

### Localizações / Mapa

**Status:** ❌ Placeholder / não acessível como módulo funcional  
**Navegação:** `/locations` mostra placeholder; a aba Mapa também é um `ChronosEmptyView`.  
**Layout:** ✅ Placeholders responsivos.  
**Dados:** ⚠ Datasource, repository, use cases e controller Supabase para `historical_locations` existem e alimentam a Busca Global, mas não há listagem ou mapa conectado.  
**Busca:** ⚠ Pesquisável globalmente após indexação.  
**CRUD:** ❌ Inexistente.  
**Estados:** Apenas placeholders na UI.  
**Prioridade:** Alta  
**Estimativa:** 7–10 dias.  
**Dependências:** SDK/estratégia de mapa, permissões, tiles/geocodificação e tela de listagem.

### Detalhe de Entidade

**Status:** ⚠ Parcial  
**Navegação:** Acessível a partir de Timeline e Busca. Não é acessível a partir de Eras, Eventos, Personagens ou Civilizações.  
**Layout:** ✅ Coluna única em telas pequenas e duas colunas em largura >= 800; componentes de conteúdo, metadata e galeria são compostos.  
**Dados:** ⚠ Renderiza a entidade recebida; não busca dados por rota/id nem garante atualização dos relacionamentos.  
**Ações:** ❌ Compartilhar, Favoritar, Timeline e Mapa apenas emitem feedback visual; não executam share, persistência, navegação ou georreferenciamento.  
**Estados:** ✅ Entidade nula mostra vazio; erro de imagem mostra placeholder.  
**Problemas:** Relações são dados estáticos marcados “Conectado”; galeria cria cartões placeholder quando a entidade não oferece imagens.  
**Prioridade:** Alta  
**Estimativa:** 5–8 dias.  
**Dependências:** relacionamento no banco, favoritos, compartilhamento, mapa e rotas de detalhe por ID/slug.

### Favoritos

**Status:** ❌ Placeholder  
**Navegação:** Aba disponível, mas retorna somente `ChronosEmptyView`.  
**Dados / CRUD / estados:** Não implementados.  
**Prioridade:** Média  
**Estimativa:** 3–5 dias.  
**Dependências:** armazenamento local ou Supabase autenticado, identidade de usuário e ações de detalhe reais.

### Ajustes / Configurações

**Status:** ❌ Placeholder  
**Navegação:** A aba Ajustes é um `ChronosEmptyView`; a rota `/settings` também é placeholder.  
**Dados / CRUD / estados:** Não implementados.  
**Prioridade:** Baixa  
**Estimativa:** 2–4 dias.  
**Dependências:** preferências locais, política de sync/offline e autenticação caso sincronizadas.

### Fontes & Referências

**Status:** ❌ Não acessível pela navegação principal / placeholder por rota  
**Navegação:** A rota `/sources` existe, mas não há item na Home, aba ou serviço de navegação para abri-la.  
**Dados / CRUD / estados:** Não implementados.  
**Prioridade:** Média  
**Estimativa:** 5–7 dias.  
**Dependências:** modelo e tabelas de referências, relações com entidades e critérios editoriais.

### Sobre o Projeto

**Status:** ❌ Não acessível pela navegação principal / placeholder por rota  
**Navegação:** `/about` existe somente como placeholder, sem entrada de menu.  
**Prioridade:** Baixa  
**Estimativa:** 0,5–1 dia.  
**Dependências:** conteúdo institucional.

### Conexão Supabase (tela técnica)

**Status:** ⚠ Implementada porém órfã  
**Navegação:** `ConnectionTestScreen` não está registrada em `AppRouter` nem exposta pela UI.  
**Dados:** Executa round-trip real em `eras`.  
**Layout:** Funcional, mas usa estilo próprio e extensa lógica técnica; não é uma tela de usuário final.  
**Prioridade:** Baixa para produto; média para ferramenta interna.  
**Estimativa:** 1 dia para definir rota debug protegida ou removê-la do build de produção.  
**Dependências:** política de diagnóstico e feature flags.

## CRUD

**Status global:** ❌ Não implementado.

A busca por chamadas Supabase de escrita (`insert`, `update`, `delete`) não encontrou operações no `lib/`. O app atualmente é de consulta/leitura. Não há formulários, permissões, validação, confirmação, auditoria nem tratamento de sucesso/erro para criação, edição ou exclusão.

## Dados e Supabase

| Domínio | Leitura Supabase | Tela funcional | Observação |
|---|---|---|---|
| Eras | ✅ | ⚠ Lista | Filtro ativo/publicado. |
| Eventos | ✅ | ⚠ Lista | Busca/filtros/tap não funcionais. |
| Personagens | ✅ | ⚠ Lista | Detalhe e filtros ausentes. |
| Civilizações | ✅ | ⚠ Lista | Módulo duplicado/legado presente. |
| Artefatos | ✅ | ❌ | Somente indexado na Busca Global. |
| Localizações | ✅ | ❌ | Somente indexado na Busca Global. |
| Fontes | ❌ | ❌ | Apenas placeholder de rota. |
| Favoritos / Perfil / Ajustes | ❌ | ❌ | Sem modelo ou persistência. |

## Código morto, órfãos e duplicações

1. **Módulo duplicado de Civilizações (alta prioridade):** há entidades, datasources, repositories, models e controllers duplicados em `lib/features/civilizations` e em camadas legadas de `lib/domain`, `lib/data` e `lib/presentation`. A coexistência afeta manutenção e tipos.
2. **Rotas e classes órfãs:** `HistoricalCharactersRoutes` define `/historical_characters`, mas a rota canônica registrada é `/historical-characters`; `ConnectionTestScreen` não é registrada; `/sources` e `/about` não têm entrada navegável; controllers de Artefatos/Localizações não possuem telas próprias.
3. **Assets de placeholder:** `app/assets/images/placeholder.txt` e `app/assets/icons/placeholder.txt` são os únicos assets declarados nessas pastas. A sidebar tenta carregar `assets/images/logo.png` e usa fallback de ícone em caso de falha.
4. **Funcionalidade simulada:** placeholders explícitos em Home, Eventos, Mapa, Favoritos, Ajustes, rotas futuras e ações do detalhe. Não há marcadores `TODO`/`FIXME` formais relevantes; a intenção futura é expressa em textos e classes placeholder.
5. **Análise estática mascarada:** `app/analysis_options.yaml` ignora várias categorias, incluindo `dead_code`, imports/variáveis não usados, overrides inválidos e regras de estilo. Assim, o resultado de `flutter analyze` não é uma auditoria confiável de código morto.
6. **Testes fora da convenção:** oito testes ficam em `lib/features/**/tests`, não em `test/`; isso reduz descoberta padrão e explica a validação inconsistente. O smoke test também não inicializa o bootstrap/DI necessário.

## Performance e responsividade

- **Pontos positivos:** `ListView.builder`/`ChronosList` são usados em listagens; Timeline e Busca carregam fontes em paralelo; `ChronosResponsive` cobre mobile/tablet/desktop no shell e Home; detalhe usa layout por largura.
- **Riscos:** Busca Global faz seis carregamentos e cria índice integral em memória a cada inicialização; não há paginação, cache, limites ou métricas de renderização. `AnimatedSwitcher` recria a tela da aba ao trocar de tab. Não há benchmark, DevTools trace, teste de scroll longo ou teste em dispositivos de dimensões variadas.
- **Conclusão:** não foi possível classificar desempenho como validado em produção. O risco aumenta com crescimento de acervo.

## ROADMAP RECOMENDADO

### Sprint 5.4.1 — Estabilização e qualidade de entrega

- Corrigir bootstrap/DI dos testes e mover/consolidar testes no diretório `test/`.
- Remover/encaminhar rotas e módulos órfãos; definir rota canônica de Personagens.
- Corrigir refresh da Busca Global.
- Restaurar análise útil: reduzir suppressions e tratar diagnósticos reais, sem esconder código morto.
- Criar smoke/integration tests para bootstrap, shell e rotas principais.

### Sprint 5.4.2 — Navegação e detalhes reais

- Conectar cards de Eras, Eventos, Personagens e Civilizações ao detalhe.
- Substituir ações simuladas do detalhe por comportamento real ou ocultá-las até existir dependência.
- Implementar relações e galeria a partir de dados reais; não apresentar “Conectado” estático.

### Sprint 5.4.3 — Pesquisa e descoberta

- Direcionar busca da Home para Busca Global.
- Corrigir refresh, completar registro de entidades e cobrir busca/filtros/ordenação com testes.
- Avaliar paginação ou pesquisa server-side antes de crescimento de acervo.

### Sprint 5.4.4 — Catálogos de Artefatos e Localizações

- Criar telas de lista/detalhe para os controllers e datasources já existentes.
- Substituir as rotas placeholder `/artifacts` e `/locations`.
- Definir se mapa é requisito desta sprint ou um módulo posterior com SDK próprio.

### Sprint 5.4.5 — Eventos e Timeline avançada

- Ligar busca, filtros de tipo/era e detalhe de Eventos.
- Decidir se os controles de mapa/timeline permanecem na tela de Eventos; implementar apenas após as dependências existirem.
- Cobrir filtros cronológicos e cenários de acervo vazio/erro em integração.

### Sprint 5.4.6 — Favoritos, Ajustes, Fontes e perfil

- Definir autenticação/persistência antes de Favoritos e Perfil.
- Implementar preferências e fonte/referência com modelo de dados claro.
- Retirar placeholders da navegação somente quando houver fluxo completo.

### Sprint posterior — CRUD editorial

- Criar requisitos de autorização, auditoria, validação, formulários e política de publicação antes de expor escrita no Supabase.
- Implementar create/edit/delete por domínio com feedback de sucesso/erro e cobertura de integração.

## Critério de saída sugerido

Considerar o CHRONOS funcionalmente pronto para uma beta de consulta somente quando: todas as rotas expostas abrirem telas reais; cards principais abrirem detalhes reais; busca da Home e Busca Global estiverem consistentes; `flutter test` passar sem comando especial; houver testes de integração de navegação/consulta Supabase; e placeholders não forem apresentados como recursos disponíveis.
