# CHRONOS - Enciclopédia Histórica Interativa

**Versão:** 1.0.0 | **Build:** 1 | **Flutter** 3.24+ | **Dart** 3.0+

Aplicativo móvel premium de história interativa com Timeline, Mapa, IA, Sistema de Estudos e Exportação.

---

## Funcionalidades

- **Timeline** — Linha do tempo interativa com filtros por era, tipo e período
- **Mapa Histórico** — OpenStreetMap com clustering, lazy loading e animações
- **Chronos AI** — Assistente RAG com múltiplos provedores (OpenAI, Gemini, Claude)
- **Sistema de Estudos** — Flashcards, quizzes e revisão espaçada
- **Exportação** — Markdown, HTML, PDF, Image via ExportEngine central
- **Busca Global** — Pesquisa federada com filtros e ordenação
- **Gamificação** — Conquistas, níveis e progresso
- **Modo Apresentação** — Fullscreen com gestos, teclado e Bluetooth
- **Acessibilidade** — Alto contraste, daltonismo, escala de fontes, haptic
- **Offline First** — Funciona sem conexão após sincronização inicial

---

## Setup

```bash
cd app
flutter pub get
flutter run
```

### Variáveis de Ambiente

```bash
--dart-define=SUPABASE_URL=<url>
--dart-define=SUPABASE_ANON_KEY=<key>
```

---

## Arquitetura

```
lib/
├── core/           # Theme, DI, Navigation, Utils, Base classes
├── data/           # Models, DataSources, Repositories (impl)
├── domain/         # Entities, Repositories (contracts), UseCases
├── features/       # Módulos independentes (feature-first)
│   ├── ai/
│   ├── accessibility/
│   ├── analytics/
│   ├── civilizations/
│   ├── dev_tools/
│   ├── export/
│   ├── feedback/
│   ├── historical_characters/
│   ├── map/
│   ├── onboarding/
│   ├── presentation_mode/
│   ├── search/
│   └── whats_new/
└── presentation/   # Pages, Controllers, Widgets
```

**Padrões:** Clean Architecture | Feature-First | ChangeNotifier | Service Locator

---

## Comandos

| Comando | Descrição |
|---------|----------|
| `flutter analyze` | Análise estática |
| `flutter test` | Executa 195 testes |
| `flutter build apk --release` | APK Release |
| `flutter build appbundle --release` | AAB Release |
| `powershell scripts/health_check.ps1` | Health check completo |

---

## Dependências

| Pacote | Uso |
|--------|-----|
| supabase_flutter | Backend, auth, storage |
| shared_preferences | Cache local |
| flutter_map | Mapa interativo |
| latlong2 | Coordenadas geográficas |

---

## Documentação

- [CHANGELOG](CHANGELOG.md)
- [Privacy Policy](PRIVACY_POLICY.md)
- [Terms of Use](TERMS_OF_USE.md)
- [Quality Report](QUALITY_REPORT.md)
- [Publication Checklist](PUBLICATION_CHECKLIST.md)
- [License](LICENSE)

---

## Licença

MIT License - Ver [LICENSE](LICENSE)
