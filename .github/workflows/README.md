# Integração e Entrega Contínua (/.github/workflows)

Este diretório contém os arquivos de configuração de automação de fluxo de trabalho (Workflows) do GitHub Actions para o projeto CHRONOS.

---

## 🧭 Objetivo

Garantir a integridade, qualidade e estabilidade do código do ecossistema CHRONOS de forma contínua e automatizada. Através da execução automática de testes unitários, análise estática de código (linting) e geração de builds de homologação/produção a cada push ou pull request, mantemos uma esteira profissional de desenvolvimento.

---

## 🗂️ Estrutura de Automação de Workflows

No futuro, esta pasta conterá arquivos YAML como:

*   `flutter_ci.yml`: Disparado em Pull Requests para verificar erros de formatação (lint), executar testes unitários do Flutter e compilar o aplicativo móvel.
*   `supabase_deploy.yml`: Disparado após aprovação de PRs na branch `main` para aplicar migrações de banco de dados e políticas RLS no ambiente de staging ou produção do Supabase.
*   `lint_content.yml`: Script de automação que valida se os novos dossiês de Markdown em `knowledge/` seguem rigorosamente os padrões editoriais de formatação e referências científicas.

---

## 🎯 Exemplos de Jobs e Etapas Planejadas

### Pipeline do Flutter CI
```yaml
name: Flutter CI

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## 🛡️ Boas Práticas

1. **Testes Obrigatórios:** Nenhum Pull Request para as ramificações `develop` ou `main` deve ser mesclado se as validações automáticas do CI/CD falharem.
2. **Segurança de Credenciais (Secrets):** Nunca declare chaves de API, senhas ou tokens de banco de dados diretamente nos scripts YAML. Utilize as **GitHub Secrets** (`secrets.SUPABASE_ACCESS_TOKEN`, `secrets.GEMINI_API_KEY`, etc.).
3. **Cache de Dependências:** Sempre configure cache para as ferramentas do Flutter/Dart e pacotes npm no CI, reduzindo drasticamente o tempo de build e economizando recursos computacionais.
