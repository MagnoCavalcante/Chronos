# CHRONOS: Fundação do Aplicativo Móvel (Sprint 3.1)

Este diretório contém a aplicação móvel **CHRONOS**, desenvolvida com **Flutter** e **Dart**. A base atual usa Clean Architecture híbrida, Service Locator interno e módulos feature-first para domínios consolidados.

A fundação foi projetada seguindo as melhores práticas de engenharia de software para sistemas móveis corporativos, garantindo que o aplicativo cresça de forma sustentável, testável e sem gargalos de acoplamento à medida que novas features forem integradas.

---

## Estado atual da arquitetura

- **Bootstrap:** `main.dart` inicializa configuração, Supabase e `setupServiceLocator()` antes de construir `ChronosApp`.
- **DI:** `core/di/service_locator.dart` centraliza registros. Serviços de infraestrutura são lazy singletons; controllers são factories.
- **Navegação:** `core/navigation/app_router.dart` é a fonte de verdade das rotas nominais. A navegação por abas é mantida por `AppShell`.
- **Features consolidadas:** `features/civilizations/` é a única implementação de Civilizações e contém `data/`, `domain/`, `presentation/`, `di/` e `routes/`.
- **Fluxo de dados:** `presentation → use case → repository → datasource → Supabase`; modelos convertem JSON e entidades permanecem no domínio.
- **Testes:** o smoke test está em `test/`; testes de features existentes estão em `lib/features/**/tests` e devem migrar para `test/features/` em sprint futura.

## 🧭 Estrutura de Diretórios Inicial

A estrutura de pastas foi dividida seguindo um modelo híbrido (**Clean Architecture** com abordagem **Feature-First**) sob a pasta `/app`:

```
app/
├── assets/                     # Recursos visuais estáticos do aplicativo
│   ├── icons/                  # Ícones personalizados do grafo e mapas
│   └── images/                 # Ilustrações históricas e fundos de tela
├── lib/                        # Código-fonte Dart da aplicação
│   ├── main.dart               # Ponto de entrada do aplicativo e tela de fundação
│   ├── core/                   # Camadas fundamentais compartilhadas por todas as frentes
│   │   ├── config/             # Constantes, rotas de APIs e configurações de ambiente
│   │   ├── navigation/         # Configurações de rotas e transições entre telas
│   │   ├── theme/              # Design System do app (cores, tipografia, estilos)
│   │   └── utils/              # Funções de auxílio e formatadores históricos
│   ├── features/               # Módulos independentes e isolados de negócios (Feature-First)
│   └── shared/                 # Componentes compartilhados reutilizáveis
│       ├── models/             # Entidades e modelos comuns a múltiplas telas
│       ├── repositories/       # Contratos de persistência e interfaces de dados
│       ├── screens/            # Telas genéricas comuns (carregamento, erro, etc.)
│       ├── services/           # Serviços transversais (armazenamento local, logs)
│       └── widgets/            # Peças visuais reutilizáveis do Design System
├── analysis_options.yaml       # Configuração de análise estática e linter estrito do Dart
└── pubspec.yaml                # Manifesto do projeto, dependências fundamentais e assets
```

---

## 🛠️ Justificativa e Engenharia por Trás da Estrutura

### 1. Separação Estrita de Responsabilidades
A divisão entre `core/`, `features/` e `shared/` resolve o maior problema de aplicativos de médio e grande porte: o acoplamento de código.
*   **`core/`**: Garante que regras de infraestrutura comuns (ex: formatação de datas históricas, navegação e tema) fiquem em um único local isolado de mudanças visuais.
*   **`features/`**: Utiliza a abordagem **Feature-First**. Módulos como `timeline`, `maps`, `dossiers` e `auth` ficarão completamente autocontidos. Cada um deles terá suas próprias camadas internas (UI, domínio e dados), evitando que uma mudança no motor do mapa afete, por exemplo, a tela de login.
*   **`shared/`**: Evita a duplicação de componentes, garantindo que botões, cartões de dossiês e layouts de erro possuam consistência de design em todo o aplicativo.

### 2. Qualidade e dependências

- A validação é executada com `flutter analyze` e `flutter test`.
- As dependências ativas são `flutter`, `supabase_flutter`, `flutter_test` e `flutter_lints`.
- O controle de estado usa `ChangeNotifier`/`ListenableBuilder`; o roteamento usa `MaterialApp` e `AppRouter`. Riverpod e GoRouter não fazem parte da implementação atual.

### 3. Documentação de referência

- `docs/ARCHITECTURE.md`: princípios e fluxo arquitetural.
- `PROJECT_AUDIT.md`: inventário funcional e lacunas de produto.
- `TECH_DEBT.md`: débitos remanescentes, impacto e planejamento.
- `REFACTORING_REPORT.md`: consolidações estruturais da Sprint 5.4.RF.
- `SEARCH_ENGINE.md`: arquitetura, consultas e operação da Busca Global.
