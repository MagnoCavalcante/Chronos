# CHRONOS — Padrão Oficial de Arquitetura de Features
## Versão 1.0.0 (Sprint 4.1.12 - Arquitetura Congelada)

Este documento define e congela a arquitetura oficial para todas as novas funcionalidades do ecossistema **CHRONOS**. Ele serve como padrão obrigatório e modelo de referência para guiar os engenheiros na expansão do projeto para as próximas entidades (Eventos, Personagens, Civilizações, Artefatos, Fontes, Localizações e Relações).

---

## 1. Estrutura Oficial de Pastas (Padrão de Feature)

Cada nova funcionalidade dentro do ecossistema móvel CHRONOS (baseado em Flutter e Clean Architecture) deve ser dividida em camadas rígidas de isolamento no diretório `lib/`. A feature **Eras** serve como o padrão ouro:

```text
lib/
├── core/                         # Infraestrutura compartilhada transversal
│   ├── di/                       # Injeção de dependências e Service Locator
│   │   └── service_locator.dart  # Registro central de Singletons e Factories
│   ├── errors/                   # Tratamento padronizado de erros e falhas
│   │   ├── exceptions.dart       # Exceções técnicas físicas (camada de dados)
│   │   └── failure.dart          # Falhas abstratas de negócio (camada de domínio)
│   └── utils/                    # Utilitários de sistema puros
│       ├── logger.dart           # Logger centralizado do sistema (ChronosLogger)
│       └── result.dart           # Mônada de controle funcional (Result<T>)
│
├── domain/                       # Camada de Domínio (Pureza total de negócios)
│   ├── entities/                 # Entidades puras (Ex: era.dart, event.dart)
│   ├── repositories/             # Contratos de interfaces abstratas dos repositórios
│   └── usecases/                 # Casos de uso específicos (SRP, Callable Classes)
│
├── data/                         # Camada de Dados (Persistência e Infraestrutura física)
│   ├── datasources/              # Pontes de dados (Abstração e Implementação)
│   ├── models/                   # Modelos físicos de dados (Ex: era_model.dart)
│   └── repositories/             # Implementações concretas dos repositórios de domínio
│
├── presentation/                 # Camada de Apresentação (Interface visual e reatividade)
│   ├── controllers/              # Gerenciadores de estado reativo (ChangeNotifier/Controller)
│   └── screens/                  # Widgets e telas completas de UI (Flutter puro)
│
└── main.dart                     # Inicialização do Flutter, Supabase e Service Locator
```

---

## 2. Fluxo de Execução & Regra de Dependências (End-to-End)

O fluxo de dados do ecossistema CHRONOS segue uma estrutura estritamente **unidirecional** e **desacoplada**. Conforme a regra de dependência da Clean Architecture, as camadas externas dependem de abstrações das camadas internas; **a camada de Domínio nunca conhece nada sobre as camadas de Apresentação ou Dados**.

```text
  [ Camada de Apresentação ]
         UI (Screens) <== ListenableBuilder ==> Controller (ChangeNotifier)
                                                       ||
                                                       || (Resolve & Invoca)
                                                       \/
  [ Camada de Domínio ]
                                            UseCase (Caso de Uso puro)
                                                       ||
                                                       || (Depende de)
                                                       \/
                                            Repository (Contrato / Interface)
                                                       ||
                                                       || (Implementado por)
                                                       \/
  [ Camada de Dados ]
                                            RepositoryImpl (Mapeia e Trata)
                                                       ||
                                                       || (Consome)
                                                       \/
                                            RemoteDataSource (Abstração / Implementação)
                                                       ||
                                                       || (Consultas Relacionais)
                                                       \/
                                            Supabase Client / PostgreSQL
```

### Mecanismo de Segurança de Camadas:
1. **Erros**: Se uma falha física de rede/banco acontecer no `RemoteDataSource`, ele dispara uma exceção técnica `ServerException`.
2. **Result**: O `RepositoryImpl` intercepta a `ServerException`, faz o logging via `ChronosLogger`, mapeia-a para um domínio de erro `Failure` (ex: `NetworkFailure`), e encapsula a resposta na mônada funcional `Result.failure(failure)`.
3. **Sem Exceptions na UI**: O `UseCase` repassa o `Result<T>` intacto. O `Controller` recebe o `Result` e usa `.fold()` para atualizar reativamente a lista em caso de sucesso, ou exibir uma mensagem limpa amigável ao usuário em caso de falha, sem nunca arriscar travar a aplicação por exceções não tratadas.

---

## 3. Responsabilidades de Cada Camada

### A. Domínio (Domain) - *O Coração do Aplicativo*
- **Entities**: Objetos puramente lógicos que representam conceitos reais de negócios. Devem usar `const`, imutabilidade, herdar igualdade estrutural (`operator ==` e `hashCode`) e não conter referências a bibliotecas, frameworks ou parsers de dados (sem JSON/Supabase).
- **Repositories (Interfaces)**: Declaram as operações que o negócio exige. Definem o contrato conceitual (o "que" fazer), garantindo que as regras não saibam "como" os dados são armazenados.
- **UseCases**: Classes de finalidade única (SRP) e focadas (Callable Classes com o método `call()`). Contêm as regras de processo do aplicativo.

### B. Dados (Data) - *A Conexão com o Mundo Físico*
- **Models**: Extensões diretas das entidades de domínio. Responsáveis pela serialização/deserialização (`fromJson`, `toJson`) e conversão segura bidirecional de e para entidades puras de negócio (`toEntity()` e `fromEntity()`).
- **DataSources**: Interfaces e implementações que interagem diretamente com drivers externos ou APIs (Supabase). Lançam exceções físicas estruturadas (`ServerException`).
- **Repositories (Implementações)**: Implementam as interfaces de domínio. São os portões de segurança: chamam os DataSources, traduzem modelos físicos para entidades de domínio imutáveis e convertem exceções cruas para `Failure`s seguros encapsulados no tipo `Result<T>`.

### C. Apresentação (Presentation) - *A Experiência Visual Reativa*
- **Controllers**: Classes que mantêm o estado dinâmico da tela e reagem aos inputs do usuário. Estendem `ChangeNotifier`, disparam Casos de Uso e consomem o retorno via padrão `Result<T>`. Utilizam `ChronosLogger` para rastrear transições de estados e notificam a UI cirurgicamente via `notifyListeners()`.
- **Screens**: Widgets de visualização completos de tela. Consomem instâncias de controllers obtidas exclusivamente via `locate<Controller>()` do `ServiceLocator`. Não possuem lógica de tratamento de dados de baixo nível.

---

## 4. Convenções Oficiais de Nomenclatura

Para manter a consistência em um projeto de larga escala com múltiplas entidades futuras, as convenções abaixo de nomenclatura e sintaxe de arquivos são obrigatórias:

| Elemento Arquitetural | Sufixo Recomendado | Exemplo Real (Eras) | Exemplo Futuro (Eventos) |
| :--- | :--- | :--- | :--- |
| **Arquivo de Entidade** | `[nome_singular].dart` | `era.dart` | `event.dart` |
| **Classe de Entidade** | `[NomeCamelCase]` | `class Era` | `class Event` |
| **Arquivo de Modelo** | `[nome_singular]_model.dart` | `era_model.dart` | `event_model.dart` |
| **Classe de Modelo** | `[NomeCamelCase]Model` | `class EraModel` | `class EventModel` |
| **Interface DataSource** | `[nome_singular]_remote_datasource.dart` | `era_remote_datasource.dart` | `event_remote_datasource.dart` |
| **Classe DataSource** | `[NomeCamelCase]RemoteDataSourceImpl` | `class EraRemoteDataSourceImpl` | `class EventRemoteDataSourceImpl` |
| **Contrato Repositório**| `[nome_singular]_repository.dart` | `era_repository.dart` | `event_repository.dart` |
| **Classe Repositório** | `[NomeCamelCase]RepositoryImpl` | `class EraRepositoryImpl` | `class EventRepositoryImpl` |
| **Caso de Uso (Arquivo)**| `[acao]_[entidade_plural]_usecase.dart` | `get_all_eras_usecase.dart` | `get_events_by_era_usecase.dart` |
| **Caso de Uso (Classe)** | `[Acao][EntidadePlural]UseCase` | `class GetAllErasUseCase` | `class GetEventsByEraUseCase` |
| **Controller (Arquivo)** | `[entidade_plural]_controller.dart` | `eras_controller.dart` | `events_controller.dart` |
| **Controller (Classe)** | `[EntidadePlural]Controller` | `class ErasController` | `class EventsController` |
| **Screen (Arquivo)** | `[entidade_plural]_screen.dart` | `eras_screen.dart` | `events_screen.dart` |
| **Screen (Classe)** | `[EntidadePlural]Screen` | `class ErasScreen` | `class EventsScreen` |

---

## 5. Sequência Recomendada de Implementação de uma Feature

Ao expandir o ecossistema CHRONOS com uma nova entidade (ex: **Eventos**), o desenvolvedor deve seguir rigorosamente a sequência de construção de baixo para alto nível de forma a garantir testes constantes e integridade modular:

```text
Passo 1: Banco de Dados ──────> Passo 2: Domínio ─────────> Passo 3: Dados ──────────> Passo 4: Apresentação
(Migration + Seeds SQL)     (Entity + Repository Intf)    (Model + DataSource + Impl)   (Controller + Screens)
```

1. **Camada de Infraestrutura Relacional**:
   - Criar e executar a migração SQL (`/database/migrations/`) definindo tabelas, RLS e índices.
   - Criar os dados iniciais fundamentais via scripts de sementes (`/database/seeds/` ou migrações equivalentes).
2. **Camada de Domínio (Sem Dependências)**:
   - Criar os Enums conceituais e a **Entidade** pura de negócio com igualdade estrutural.
   - Criar o contrato abstrato do **Repository** contendo os retornos envelopados na mônada `Result<T>`.
   - Implementar os **UseCases** focados herdando a interface do repositório.
3. **Camada de Dados**:
   - Implementar o **Model** de persistência adicionando `fromJson` e `toEntity()`.
   - Definir a interface e implementação concreta do **RemoteDataSource** com acesso ao cliente do Supabase.
   - Implementar o **RepositoryImpl**, adicionando conversões de entidades e tratamento seguro de exceções de infraestrutura.
4. **Camada de Apresentação & Integração**:
   - Implementar o **Controller** estendendo `ChangeNotifier`, orquestrando estados reativos com o uso de `ChronosLogger` e `Result`.
   - Registrar todas as novas classes criadas no método `setupServiceLocator()` do `/lib/core/di/service_locator.dart`.
   - Construir a tela de UI (**Screen**) resolvendo o controller reativo através do atalho global `locate<Controller>()`.

---

## 6. Checklist de Qualidade Obrigatório (DoD - Definition of Done)

Nenhuma feature de entidade do CHRONOS deve ser dada como concluída sem antes certificar a conformidade completa de todos os seguintes itens:

### ☑ Infraestrutura Relacional (Banco de Dados)
- [ ] **Migration**: Tabela criada com chaves primárias UUID geradas automaticamente pelo banco, slugs indexadas de forma única, e triggers automáticas de atualização para `updated_at`.
- [ ] **RLS (Row Level Security)**: Ativado para a nova tabela no Supabase, garantindo que consultas públicas (`SELECT`) sejam liberadas anonimamente, mas operações de escrita sejam restritas a administradores ou vetadas na aplicação móvel padrão.
- [ ] **Seed**: Sementes históricas mínimas oficiais populadas com idempotência (`ON CONFLICT (slug) DO UPDATE`).

### ☑ Camada de Domínio (Business Core)
- [ ] **Entity**: Totalmente imutável, livre de qualquer importação de terceiros, serializadores ou pacotes de dados. Implementa igualdade estrutural por valor (`operator ==` e `hashCode`).
- [ ] **UseCase**: Focado em um único propósito comercial, estruturado como callable class (`call()`) e com retorno encapsulado em `Result<T>`.

### ☑ Camada de Dados (Infrastructure & Persistence)
- [ ] **Model**: Isolado e estendendo a entidade correspondente. Serializadores `fromJson` perfeitamente tipados com tratamentos preventivos para valores numéricos e enums de banco de dados.
- [ ] **DataSource**: Abstraído por interface e isolando o acesso direto às chamadas REST ou Supabase SDK. Captura e dispara unicamente exceções tipadas unificadas (`ServerException`).
- [ ] **RepositoryImpl**: Atua como o limitador de vazamentos de dados. Captura as exceções do DataSource de forma segura, gera logs explicativos consistentes via `ChronosLogger` e envelopa o retorno para a camada de negócios em objetos limpos de tipo `Result<T>`.

### ☑ Camada de Apresentação (UI & Reatividade)
- [ ] **Controller**: Utiliza o estado reativo sem re-renderizações cíclicas infinitas. Usa `ChronosLogger` para documentar no console as transições cruciais e fluxos normais ou de erros do módulo.
- [ ] **Service Locator**: Todas as novas classes estão cadastradas corretamente em `setupServiceLocator()` respeitando seus tempos de vida (`LazySingleton` para fontes e repositórios; `Factory` para controllers e instâncias transitórias).
- [ ] **Screen**: Widget limpo e livre de lógica pesada de controle de rede ou persistência. Resolve suas dependências de forma limpa usando a função atalho `locate<Controller>()` e monitora estados usando `ListenableBuilder` de forma cirúrgica.

### ☑ Qualidade & Compilação Geral
- [ ] **Imports**: Sem caminhos absolutos locais incorretos e sem importações cruzadas inadequadas (camadas internas nunca importam camadas externas).
- [ ] **Linter**: Execução de `npm run lint` ou `flutter analyze` sem nenhum aviso ou aviso residual.
- [ ] **Compilação**: Build de produção limpo obtendo sucesso total (`compile_applet` verificado).
