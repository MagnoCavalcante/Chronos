# CHRONOS — Padrão de Arquitetura de Features (STANDARD_FEATURE_ARCHITECTURE)

Este documento estabelece o padrão arquitetural oficial para todas as novas funcionalidades (features) integradas ao ecossistema **CHRONOS**.

---

## 1. Fluxo da Presentation Layer (Camada de Apresentação)

A camada de apresentação no CHRONOS é responsável pela interação direta com o usuário, renderização visual com Material 3 e gerenciamento de estado reativo, totalmente desacoplada de detalhes físicos de banco de dados ou infraestrutura.

O fluxo de dados segue a arquitetura reativa unidirecional:

```text
[ Tela / UI (Widgets) ] 
       │
       │ (1) Dispara ação de negócio (ex: load, refresh, retry)
       ▼
[ Controller da Feature (estende BaseController) ]
       │
       │ (2) Invoca operação de negócio assíncrona
       ▼
[ Caso de Uso (UseCase) ] ─────► Retorna Result<T> ───┐
                                                       │ (3) Retorna mônada pura
[ Controller da Feature (estende BaseController) ] ◄───┘
       │
       │ (4) Mede tempo, atualiza ViewStatus imutável, e notifica ouvintes
       ▼
[ Tela / UI (Widgets) ] (ListenableBuilder / consome ViewStatus)
```

---

## 2. Responsabilidades do BaseController

O `BaseController<T>` é o coração da infraestrutura de apresentação do ecossistema CHRONOS. Ele centraliza responsabilidades comuns a todas as features, reduzindo drasticamente códigos repetidos (DRY) e garantindo robustez:

- **Gerenciamento de Estados**: Gerencia os estados unificados de [ViewState] (`initial`, `loading`, `success`, `empty`, `error`, `refreshing`).
- **Orquestração Segura (`execute`)**: Envolve chamadas de Casos de Uso com medição automática de tempo, controle de exceções indevidas na UI (mapeando-as para `UnknownFailure`) e publicação de logs informativos/falhas com o `ChronosLogger`.
- **Prevenção de Vazamento de Memória**: Bloqueia chamadas de `notifyListeners()` se o controlador já foi destruído (`_isDisposed`).
- **Tratamento de Concorrência**: Utiliza tokens de controle assíncronos (`_operationCount`) para que operações obsoletas (decorrentes de disparos múltiplos ou rápidos) sejam descartadas com segurança sem interferir na UI.

---

## 3. Ciclo de Vida (Lifecycle)

O ciclo de vida padrão de uma tela integrada com o `BaseController` é estruturado da seguinte forma:

1. **Instanciação**: O controller é injetado via `ServiceLocator` ou instanciado com o estado inicial [ViewState.initial].
2. **Inicialização da UI (initState)**: A tela se registra para ouvir o controller e agenda a carga de dados no primeiro frame:
   ```dart
   @override
   void initState() {
     super.initState();
     _controller = locate<MyFeatureController>();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       _controller.loadMyData();
     });
   }
   ```
3. **Carregamento (Loading/Refreshing)**: Durante a execução assíncrona, o estado é atualizado reativamente para informar a tela sobre o progresso físico (Skeleton Loader / Skeletons em primeiro plano).
4. **Resolução de Estado (Success/Empty/Error)**: O controller consome a resposta `Result<T>` atualizando o status imutável, notificando os ouvintes.
5. **Atualização Manual (Refresh)**: O usuário dispara uma atualização (RefreshIndicator/Sync Button) elevando o estado para `refreshing`, preservando dados anteriores para evitar oscilações visuais bruscas.
6. **Descarte (dispose)**: O controlador cancela operações ativas de forma limpa e é removido da memória.

---

## 4. Gerenciamento de Estado (ViewStatus)

O estado da camada de apresentação é mantido em uma única estrutura imutável chamada `ViewStatus<T>`.

```dart
class ViewStatus<T> {
  final ViewState state;
  final T? data;
  final Failure? error;
  final DateTime timestamp;
  final Duration loadingTime;
}
```

Isso garante previsibilidade, simplifica a testabilidade (State Verification) e impede alterações colaterais indesejadas a partir da UI. Os Widgets consomem esse estado diretamente ou por meio de facilitadores (getters):

- `isLoading` / `isRefreshing`: Controlam indicadores de progresso ou skeletons.
- `isSuccess` / `isEmpty`: Renderizam dados recuperados ou um informativo ilustrado em caso de coleções sem itens.
- `isError` / `hasError`: Renderizam telas de falha amigáveis com botão de re-execução (Retry).

---

## 5. Boas Práticas na Apresentação

Para manter o ecossistema CHRONOS uniforme e livre de anomalias operacionais, siga rigorosamente as seguintes práticas:

1. **Jamais altere estado diretamente**: Toda transição de estado deve ocorrer exclusivamente através do método `execute(...)` do `BaseController`.
2. **Proteja as Views contra rebuilds robóticos**: Utilize sempre `ListenableBuilder` limitando o escopo de reconstrução da árvore ao menor nível granular possível.
3. **Retorno de listas vazias**: Evite retornar erros de negócio (Failure) para coleções vazias. O banco responder com sucesso sem dados deve resultar no estado `ViewState.empty`.
4. **Mantenha os Controladores extremamente limpos**: Os controladores específicos de feature devem apenas herdar de `BaseController` e delegar aos casos de uso. Lógicas genéricas pertencem à infraestrutura compartilhada.
5. **Logs exclusivos**: Nunca utilize `print()`. Use sempre `ChronosLogger` para documentar chamadas e tempos de execução.
6. **Componentes Visuais Compartilhados**: Caso qualquer componente visual seja reutilizável em múltiplas Features (por exemplo, badges de status editorial), ele deve ser extraído para a pasta global de componentes reutilizáveis em `core/presentation/widgets/` (ex: `StatusBadge`).

---

## 6. Camada de Navegação (Navigation Layer)

O CHRONOS possui uma camada de roteamento e navegação totalmente desacoplada e modularizada, projetada para respeitar os limites de separação de conceitos da Clean Architecture.

### 6.1 Fluxo de Navegação Desacoplado

Toda transição de fluxo da aplicação ocorre por meio de uma abstração unificada. **Nenhuma Screen ou Controller pode usar diretamente o `Navigator` do Flutter ou o `BuildContext` para transicionar telas.**

```text
[ Controller ou UI ] ───(Invoquação de Rota Semântica)───► [ NavigationService (Abstração) ]
                                                                      │
                                                        (Aplica RouteGuards de Segurança)
                                                                      ▼
[ MaterialApp ] ◄────(Consome navigatorKey & router)─────── [ AppRouter (Centralizador) ]
```

### 6.2 Componentes e Responsabilidades

A Navigation Layer é dividida em quatro componentes bem-definidos:

1. **`RouteNames` (`core/navigation/route_names.dart`)**:
   Centraliza constantes nominais para todas as rotas físicas do ecossistema CHRONOS. Evita digitação de strings brutas (hardcoded) espalhadas pela base de código.
2. **`NavigationService` (`core/navigation/navigation_service.dart`)**:
   Interface injetável que abstrai a API de navegação do Flutter. Fornece métodos genéricos (`goTo`, `replace`, `replaceAll`, `back`) e métodos semânticos de negócio de alto nível (`openEra()`, `openHistoricalEvent()`, `openHistoricalCharacter()`).
3. **`AppRouter` (`core/navigation/app_router.dart`)**:
   Gerenciador e definidor central de todas as rotas nominais. Realiza o mapeamento de widgets e fornece suporte para parâmetros dinâmicos e telas placeholder amigáveis de Sprints futuras.
4. **`RouteGuard` (`core/navigation/route_guards.dart`)**:
   Contrato e infraestrutura extensível de segurança. Permite interceptar navegações para validar:
   - **Autenticação** (`AuthGuard`)
   - **Permissões de Perfil** (`PermissionGuard`)
   - **Feature Flags** (`FeatureFlagGuard`)
   - **Rotas Experimentais** (`ExperimentalRouteGuard`)

### 6.3 Boas Práticas de Navegação

1. **Isolamento de Controllers**: Controllers e UseCases nunca devem importar ou fazer referências diretas ao pacote `package:flutter` ou ao objeto `BuildContext`. Use `locate<NavigationService>()` para invocar ações de navegação.
2. **Uso de Métodos Semânticos**: Dê preferência a chamadas semânticas explícitas em vez de strings literais ao navegar para módulos principais do CHRONOS. Exemplo: use `navigationService.openEra()` em vez de `navigationService.goTo(RouteNames.eras)`.
3. **Mapeamento Prévio de Recursos Futuros**: Recursos de Sprints futuras devem ter suas rotas previamente registradas no `AppRouter` apontando para o widget de placeholder visual customizado (`_FutureSprintPlaceholderScreen`), garantindo que o sistema não quebre ao tentar acessá-los.
4. **Acoplamento do MaterialApp**: No `main.dart`, vincule obrigatoriamente o `navigatorKey` e as rotas aos providos pelo serviço:
   ```dart
   MaterialApp(
     navigatorKey: locate<NavigationService>().navigatorKey,
     initialRoute: AppRouter.initialRoute,
     onGenerateRoute: AppRouter.onGenerateRoute,
   )
   ```

