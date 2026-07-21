# CHRONOS — Code Review Checklist

Este checklist oficial deve ser executado obrigatoriamente antes de cada integração de código na fenda temporal do **CHRONOS**. Ele serve para assegurar que todas as diretrizes de qualidade do **Architecture Guardian** foram integralmente cumpridas.

---

## 1. Camada de Domínio (Domain Layer)
- [ ] As entidades herdam de `BaseEntity` e possuem identidade forte?
- [ ] Os Casos de Uso (Use Cases) herdam de `BaseUseCase` e expõem uma interface de comando único via `call(...)`?
- [ ] Os contratos de repositório (interfaces abstratas) estão definidos no domínio?
- [ ] Existe dependência direta do Flutter ou de qualquer biblioteca de infraestrutura/terceiros no domínio? *(Se sim, deve ser removida).*

## 2. Camada de Dados (Data Layer)
- [ ] Os modelos (`Models`) estendem `BaseModel` e encapsulam as operações de serialização e desserialização (`fromJson`/`toJson`)?
- [ ] Os repositórios implementam as interfaces definidas no domínio?
- [ ] Exceções físicas de banco de dados (ex: Supabase, HTTP, banco local) são devidamente capturadas (`try/catch`) e mapeadas para entidades estruturadas `Failure`?
- [ ] Os dados expostos pelos repositórios utilizam coleções seguras/imutáveis?

## 3. Camada de Apresentação e Aplicação (Presentation & Application Layer)
- [ ] Os controladores de estado herdam de `BaseController<T>`?
- [ ] O fluxo de transições de tela respeita integralmente as variações de estado de `ViewState` (initial, loading, success, empty, error, refreshing)?
- [ ] Os controladores de tela consomem exclusivamente `UseCases` para realizar interações de negócio? *(Terminantemente proibido acessar DataSources diretamente).*
- [ ] As coleções e listagens expostas pelos controladores para a UI são imutáveis (ex: `List.unmodifiable(...)`)?

## 4. Componentes Visuais & Widgets (Design System)
- [ ] Os novos componentes utilizam os widgets oficiais do Design System (`ChronosCard`, `ChronosSectionHeader`, etc.)?
- [ ] Há declarações de cores, espaçamentos, cantos arredondados ou sombras de forma hardcoded? *(Tudo deve usar os tokens de `ChronosColors`, `ChronosSpacing` e `ChronosRadius`).*
- [ ] Os componentes visuais suportam e implementam de forma robusta a árvore de semântica do Flutter (`Semantics`) para acessibilidade?
- [ ] O contraste e legibilidade das cores respeitam os padrões de usabilidade WCAG para todos os perfis de usuário?

## 5. Qualidade de Código & Testabilidade
- [ ] Todos os novos fluxos de execução e controladores possuem testes unitários ou de widget correspondentes?
- [ ] Os registros de log utilizam de forma exclusiva e estruturada o `ChronosLogger` com tags de identificação?
- [ ] O código passa de forma impecável na validação estática do `flutter analyze` (sem warnings ou hints não resolvidos)?
- [ ] A injeção de dependências foi registrada de forma segura no `ServiceLocator` (`sl`) protegida por checagens de `isRegistered<T>()` para evitar duplicidades em ambiente de testes?
