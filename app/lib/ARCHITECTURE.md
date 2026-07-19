# CHRONOS — Documentação de Arquitetura e Fluxo de Dados

Este documento descreve detalhadamente a arquitetura do projeto **CHRONOS**, baseada estritamente nos princípios da **Clean Architecture** (Arquitetura Limpa), e orienta as diretrizes para desenvolvimento, integração e as futuras expansões do ecossistema.

---

## 1. Princípios de Design e Diretrizes Fundamentais

O projeto CHRONOS segue rigorosamente os seguintes padrões de engenharia:
- **Separação de Preocupações (SoC)**: Cada camada possui responsabilidades perfeitamente delimitadas.
- **Princípio de Responsabilidade Única (SRP)**: Cada classe, caso de uso ou controller realiza apenas uma tarefa específica.
- **Princípio de Inversão de Dependência (DIP)**: Módulos de alto nível (Domínio/Negócio) não dependem de módulos de baixo nível (Dados/Apresentação/Infraestrutura). Ambos dependem de abstrações (interfaces).
- **Sem Vazamento de Detalhes**: Modelos físicos de persistência (JSON, EraModel, SupabaseClient) nunca cruzam a fronteira do repositório para a camada de Domínio ou Apresentação.

---

## 2. Estrutura de Camadas e Fluxo de Dados End-to-End

O pipeline de execução segue o fluxo unidirecional abaixo:

```text
  [ Camada de Apresentação ]
         UI (Widgets) <== ListenableBuilder ==> ErasController (ChangeNotifier)
                                                        ||
                                                        || (Invoca)
                                                        \/
  [ Camada de Domínio ]
                                             GetAllErasUseCase (Caso de Uso)
                                                        ||
                                                        || (Depende de)
                                                        \/
                                             EraRepository (Interface / Contrato)
                                                        ||
                                                        || (Implementado por)
                                                        \/
  [ Camada de Dados ]
                                             EraRepositoryImpl (Implementação)
                                                        ||
                                                        || (Consome)
                                                        \/
                                             EraRemoteDataSource (Abstração)
                                                        ||
                                                        || (Implementado por)
                                                        \/
                                             EraRemoteDataSourceImpl (Acesso Físico)
                                                        ||
                                                        || (Queries)
                                                        \/
                                             Supabase (PostgreSQL)
```

### Detalhamento das Etapas de Execução (Fase de Validação):
1. **Bootstrapping**: No arquivo `main.dart`, `WidgetsFlutterBinding.ensureInitialized()` é chamado, seguido pela inicialização única e protegida de `SupabaseConfig.initialize()`.
2. **Ciclo da UI**: A tela `ErasScreen` é renderizada e, no método `initState`, solicita o carregamento inicial de dados chamando `_controller.carregarEras()`.
3. **Gerenciamento de Estado**: O `ErasController` altera o estado interno para `isLoading = true`, limpa erros anteriores e dispara a notificação para a UI via `notifyListeners()`.
4. **Regra de Negócio**: O controller invoca o método `call()` do caso de uso puro `GetAllErasUseCase`.
5. **Inversão de Controle**: O caso de uso delega a operação para a interface abstrata `EraRepository`.
6. **Acesso aos Dados**: A implementação física `EraRepositoryImpl` consome o `EraRemoteDataSource` para obter a coleção imutável de `EraModel`.
7. **Conversão e Tipagem**: O `EraRemoteDataSourceImpl` faz uma requisição filtrada à tabela `eras` do Supabase. Os objetos relacionais retornados são deserializados para `EraModel` através do factory `fromJson`.
8. **Mapeamento Domain-Bound**: O repositório converte a lista física de `EraModel` em entidades puras imutáveis `Era` utilizando o método `toEntity()`.
9. **Tratamento de Exceções**: Se ocorrer qualquer falha física (banco de dados, rede ou autenticação), o `DataSource` lança uma exceção tipada `EraDataSourceException`. O `Repository` intercepta e mapeia essa exceção para um objeto puro de erro `Failure` (ex: `NetworkFailure`, `DatabaseFailure`), que é repassado ao `Controller`.
10. **Apresentação de Estados**: O `ErasController` recebe as entidades ou a falha, ajusta seus estados (`eras` ou `errorMessage`), altera `isLoading = false` e emite `notifyListeners()`. O `ListenableBuilder` na `ErasScreen` intercepta a alteração e atualiza cirurgicamente a tela.

---

## 3. Estrutura Preparada para Futuras Entidades

O ecossistema CHRONOS foi planejado e estruturado para receber novas entidades de forma modular, prevenindo acoplamentos indesejados. 

### Entidades Mapeadas para Próximas Sprints:
- **Eventos (`Event`)**: Fatos históricos datados e pertencentes a uma ou mais Eras.
- **Personagens (`Character`)**: Figuras históricas proeminentes com conexões com Eras e Eventos.
- **Artefatos (`Artifact`)**: Objetos físicos, documentos ou criações de relevância arqueológica e histórica.
- **Civilizações (`Civilization`)**: Culturas e impérios que se desenvolveram ao longo das Eras.
- **Fontes (`Source`)**: Referências bibliográficas, literárias ou documentais que atestam a veracidade dos registros.
- **Localizações (`Location`)**: Coordenadas geográficas, regiões ou fronteiras mutáveis ao longo da história.
- **Relações (`Relation`)**: Grafos ou vínculos conceituais e lógicos conectando qualquer uma das entidades acima de forma semântica.

### Localização Recomendada dos Arquivos de Expansão:

Para cada uma das novas entidades, deve-se manter o isolamento absoluto de camadas seguindo os diretórios predefinidos:

```text
lib/
├── domain/
│   ├── entities/
│   │   ├── era.dart
│   │   ├── event.dart           <-- Nova Entidade
│   │   ├── character.dart       <-- Nova Entidade
│   │   ├── artifact.dart        <-- Nova Entidade
│   │   ├── civilization.dart    <-- Nova Entidade
│   │   ├── source.dart          <-- Nova Entidade
│   │   ├── location.dart        <-- Nova Entidade
│   │   └── relation.dart        <-- Nova Entidade
│   ├── repositories/
│   │   ├── era_repository.dart
│   │   └── event_repository.dart
│   └── usecases/
│       ├── get_all_eras_usecase.dart
│       └── get_events_by_era_usecase.dart
│
├── data/
│   ├── datasources/
│   │   ├── era_remote_datasource.dart
│   │   └── event_remote_datasource.dart
│   ├── models/
│   │   ├── era_model.dart
│   │   └── event_model.dart
│   └── repositories/
│       ├── era_repository_impl.dart
│       └── event_repository_impl.dart
```

---

## 4. Estratégia de Testabilidade

Graças ao desacoplamento imposto pelas interfaces de repositório e fontes de dados:
- **Testes Unitários**: O `ErasController` pode ser testado isoladamente fornecendo um mock do `GetAllErasUseCase`. O `GetAllErasUseCase` pode ser testado mockando-se a interface `EraRepository`.
- **Testes de Integração**: O `EraRepositoryImpl` pode ser testado fornecendo-se um mock ou fake do `EraRemoteDataSource`.
