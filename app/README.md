# CHRONOS: Fundação do Aplicativo Móvel (Sprint 3.1)

Este diretório contém a base arquitetural estruturada para a aplicação móvel **CHRONOS**, desenvolvida utilizando o framework **Flutter** e a linguagem **Dart**.

A fundação foi projetada seguindo as melhores práticas de engenharia de software para sistemas móveis corporativos, garantindo que o aplicativo cresça de forma sustentável, testável e sem gargalos de acoplamento à medida que novas features forem integradas.

---

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

### 2. Estilo de Código e Garantia de Qualidade
*   O arquivo `analysis_options.yaml` foi configurado com regras de análise estática rigorosas (`flutter_lints`).
*   Regras como `avoid_print`, `prefer_const_constructors` e `always_declare_return_types` garantem que o código permaneça limpo, livre de gargalos comuns de renderização (através do uso correto de construtores constantes) e perfeitamente tipado para compilações de produção altamente otimizadas.

### 3. Manifesto de Dependências Limpo (`pubspec.yaml`)
*   Mantido exclusivamente com as dependências centrais (`flutter` e `flutter_lints`), permitindo que a fundação seja validada e compilada de maneira limpa e previsível.
*   Estruturação prévia da declaração de assets (`assets/images/` e `assets/icons/`), estabelecendo o padrão de carregamento de recursos visuais estáticos.

---

## 🚀 Próximos Passos (Próxima Sprint)

Na próxima sprint, avançaremos para a **Sprint 3.2**, onde começaremos a introduzir as camadas ativas de dados e interação:
1.  **Integração com Supabase Client**: Adição e configuração do pacote `supabase_flutter` para estabelecer comunicação nativa com nosso banco de dados PostgreSQL.
2.  **Gerenciamento de Estado Reativo**: Configuração do `flutter_riverpod` como o motor de gerenciamento de estado e injeção de dependências do aplicativo.
3.  **Roteamento Avançado**: Implementação do `go_router` para gerenciar transições suaves e roteamento profundo baseado em links do Supabase.
4.  **Desenvolvimento do Primeiro Protótipo Visual da Linha do Tempo**: Criação dos primeiros layouts reativos baseados nos dados históricos reais providos pelo banco.
