# CHRONOS Architecture Guardian

O **Architecture Guardian** é o conjunto permanente de políticas, regras de integridade e restrições estruturais do projeto **CHRONOS**. Ele atua como o validador supremo do código para assegurar que o desenvolvimento de novas funcionalidades respeite rigorosamente os padrões de engenharia estabelecidos.

---

## 1. Regras de Integridade e Restrições de Dependência

A regra mais sagrada da arquitetura do CHRONOS é a **Regra de Dependência (Dependency Rule)**: as dependências de código só podem apontar para dentro, em direção às camadas de maior abstração (regras de negócio puras).

```
Experience Layer (Presentation, Controllers, Widgets)
        │
        ▼
Knowledge Engine (Use Cases)
        │
        ▼
Knowledge Engine (Entities / Repository Contracts)
        │
        ▼
Core Platform (Result, Failure, Base Classes)
```

### 1.1. Restrições do Domínio (Domain Layer Constraints)
- **Zero Dependências de Terceiros / Frameworks**: O domínio (`lib/domain/` ou subpastas de domínio nas features) deve ser escrito em Dart puro. É terminantemente proibido importar qualquer pacote do Flutter (`package:flutter/...`) ou pacotes de persistência física (como Supabase ou Hive) nesta camada.
- **Isolamento de Negócio**: Entidades e Casos de Uso não devem conhecer detalhes de serialização (como métodos `fromJson` ou `toJson`).

### 1.2. Restrições de Dados (Data Layer Constraints)
- **Implementação Física de Contratos**: A camada de dados implementa as interfaces de repositório definidas no domínio. Ela converte modelos de dados (`Models`) vindos de fontes externas (`DataSources`) em entidades puras de negócio.
- **Tratamento de Exceções**: Qualquer exceção de infraestrutura (banco de dados, rede, permissões) deve ser interceptada nos repositórios e encapsulada em uma mônada de erro estruturada `Failure` antes de ser retornada ao fluxo de aplicação.

### 1.3. Restrições de Apresentação (Experience / Presentation Layer Constraints)
- **Acesso Exclusivo a Use Cases**: Widgets e controladores da camada de apresentação **nunca** devem interagir diretamente com fontes de dados (`DataSources`) ou acessar bancos de dados físicos. Toda interação de escrita ou leitura deve passar obrigatoriamente por um `UseCase`.
- **Imutabilidade de Dados**: Listas e entidades expostas pelos controladores para renderização de telas devem ser imutáveis (ex: usando `List.unmodifiable` ou pacotes que garantam congelamento de estados).

---

## 2. Princípios de Engenharia Mandatórios

Para garantir conformidade com o ecossistema CHRONOS, toda alteração de código deve se alinhar a estes pilares:

### SOLID, DRY e KISS
- **S**ingle Responsibility Principle: Cada classe possui um e apenas um motivo para mudar. UseCases contêm exatamente um fluxo comercial regulado pelo método `call(...)`.
- **O**pen/Closed Principle: Novas regras de negócio devem ser adicionadas criando novos UseCases ou decoradores, nunca alterando fluxos consolidados e testados.
- **D**on't Repeat Yourself (DRY): A duplicação de códigos visuais é mitigada pelo uso estrito da biblioteca reutilizável em `lib/presentation/widgets/`.
- **K**eep It Simple, Stupid (KISS): Evite superengenharia. Código limpo e legível é infinitamente superior a abstrações excessivas e desnecessárias.

### Padrão Result e Tratamento de Falhas
- Todas as operações assíncronas que possam falhar devem retornar a mônada de controle estruturado `Result<Type>`.
- O sucesso é representado pela classe `Success(data)`.
- O erro é encapsulado no tipo `Failure(message)`. Exceções de sistema nunca devem vazar para a camada de apresentação.

### Diagnósticos e Rastreabilidade (`ChronosLogger`)
- Todo início de carregamento, sucesso ou erro comercial deve ser explicitamente registrado usando o `ChronosLogger` com tags de identificação precisas.
- Logs arbitrários usando `print` ou `debugPrint` do Flutter são terminantemente proibidos no ambiente de produção.

### Acoplamento de Estilo (Design System)
- Todo componente de interface deve utilizar exclusivamente a infraestrutura reativa fornecida pelo `ChronosTheme`.
- Nenhuma cor, margem, raio de borda ou estilo tipográfico pode ser declarado de forma inline ou hardcoded no projeto.
