# Chronos AI

Módulo de assistente histórico inteligente integrado ao aplicativo **Chronos**.  
Prioriza o **acervo local validado** (personagens, eventos, civilizações, artefatos, localizações, fontes, timeline e relacionamentos) antes de recorrer a provedores de IA externos.

---

## 1. Objetivo

Oferecer uma experiência de perguntas e respostas sobre História, onde o assistente:

- Busca primeiro no banco de dados do Chronos.
- Usa **RAG (Retrieval-Augmented Generation)** para enriquecer o prompt com contexto real.
- Reduz alucinações, exibe citações e links para entidades relacionadas.
- Funciona **offline** quando não houver conectividade ou chaves de IA configuradas.
- Permite múltiplos modos de resposta (professor, resumo, detalhado, comparação, linha do tempo).

---

## 2. Arquitetura

```text
┌────────────────────────────────────────────────────────────────┐
│  Presentation                                                  │
│  ┌───────────────────────────┐    ┌─────────────────────────┐  │
│  │ AiAssistantPage           │    │ ConversationController  │  │
│  └───────────────────────────┘    └─────────────────────────┘  │
└──────────────────────────────────┬─────────────────────────────┘
                                   │
┌──────────────────────────────────▼─────────────────────────────┐
│  Domain / Services                                             │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ AiService                                                  ││
│  │  ├─ PromptBuilder (RAG)                                  ││
│  │  ├─ AIRepository (provedor + cache + fallback)            ││
│  │  └─ ConversationRepository (histórico local)              ││
│  └──────────────────────────────────────────────────────────┘│
└──────────────────────────────────┬─────────────────────────────┘
                                   │
┌──────────────────────────────────▼─────────────────────────────┐
│  Data / Providers                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐          │
│  │ OpenAI       │ │ Gemini       │ │ Claude       │          │
│  │ Adapter      │ │ Adapter      │ │ Adapter      │          │
│  └──────────────┘ └──────────────┘ └──────────────┘          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐          │
│  │ Modelo Local │ │ Offline      │ │ Provider     │          │
│  │ Adapter      │ │ Adapter      │ │ Factory      │          │
│  └──────────────┘ └──────────────┘ └──────────────┘          │
└────────────────────────────────────────────────────────────────┘
```

---

## 3. Fluxo de uma pergunta

1. **Modo detectado**: `PromptBuilder` identifica se a pergunta pede professor, resumo, comparação ou timeline.
2. **Busca no acervo**: `SearchUseCase` retorna entidades relevantes.
3. **Expansão de contexto**: `RelationshipEngine` traz relacionamentos (personagens, eventos, civilizações, etc.).
4. **Contexto temporal**: para modos `timeline`, `TimelineRepository` filtra eventos por ano.
5. **Montagem do prompt**: prompt RAG com instrução de modo, entidades, relacionamentos e timeline.
6. **Geração**: `AIRepository` envia o prompt para o provedor ativo.
7. **Cache**: resposta armazenada para evitar chamadas repetidas.
8. **Fallback**: se o provedor falhar, `OfflineAdapter` responde com os dados do acervo.
9. **Histórico**: `ConversationRepository` salva a pergunta, resposta e metadados.

---

## 4. Provedores de IA

| Provedor   | Adapter             | Disponibilidade                         |
|------------|---------------------|------------------------------------------|
| OpenAI     | `OpenAiAdapter`     | Quando `apiKey` fornecida                |
| Google     | `GeminiAdapter`     | Quando `apiKey` fornecida                |
| Anthropic  | `ClaudeAdapter`     | Quando `apiKey` fornecida                |
| Local      | `LocalModelAdapter` | Sempre (stub para modelo on-device)      |
| Offline    | `OfflineAdapter`    | Sempre (fallback acervo Chronos)         |

A seleção ocorre em `ProviderFactory`. Por padrão, sem chaves configuradas, o módulo usa `OfflineAdapter`, garantindo funcionamento offline.

### 4.1 Trocar de provedor

A troca não afeta o resto do aplicativo. Em `AiDI` ou ao instanciar `AIRepositoryImpl`, passe o `AIProvider` desejado:

```dart
final provider = ProviderFactory.create(openAiApiKey: 'sk-...');
final repository = AIRepositoryImpl(primaryProvider: provider);
```

---

## 5. PromptBuilder e RAG

O `PromptBuilder` localiza em `lib/features/ai/data/services/prompt_builder.dart` realiza:

- **Detecção de modo**: palavras-chave como "professor", "resumidamente", "compare", "linha do tempo" e anos.
- **Busca textual**: retorna até 5 entidades mais relevantes do `SearchUseCase`.
- **Relacionamentos**: expande cada entidade com a `RelationshipEngine`.
- **Timeline**: se o modo for timeline, consulta `TimelineRepository.getTimeline(startYear, endYear)`.
- **Citações**: entidades do tipo `historical_source` são extraídas como fontes.
- **Prompt final**: texto estruturado com instrução de modo, acervo e pergunta.

---

## 6. Cache e Fallback Offline

### Cache de respostas

- `AIRepositoryImpl` gera uma chave a partir da pergunta normalizada + modo.
- Se a chave existir em cache, a resposta é retornada sem nova chamada.
- `AiCacheService` usa `SharedPreferences` quando disponível; em testes sem binding, fallback em memória.

### Fallback

- `AIRepositoryImpl.generate` tenta o provedor primário.
- Se indisponível ou com erro, cai automaticamente para `OfflineAdapter`.
- `OfflineAdapter` monta a resposta apenas com dados presentes no `AiRequest`.

### Histórico offline

- `ConversationRepositoryImpl` persiste conversas localmente via `AiCacheService`.
- Suporta favoritar, fixar, excluir e listar recentes sem internet.

---

## 7. Módulos do Chronos AI

### 7.1 Entidades (`lib/features/ai/domain/entities/ai_entities.dart`)

- `AiMode`: modos de resposta.
- `AiProviderType`: provedores suportados.
- `AiRequest`: entrada enriquecida para o provedor.
- `AiResponse`: resposta final com citações, entidades relacionadas e sugestões.
- `ConversationMessage`: registro de pergunta/resposta salvo no histórico.

### 7.2 Repositórios

- `AIRepository` (`domain/repositories/ai_repository.dart`)
- `AIRepositoryImpl` (`data/repositories/ai_repository_impl.dart`)
- `ConversationRepository` (`domain/repositories/conversation_repository.dart`)
- `ConversationRepositoryImpl` (`data/repositories/conversation_repository_impl.dart`)

### 7.3 Provedores

- `AIProvider` (`data/providers/ai_provider.dart`) — interface única.
- `ProviderAdapter` (`data/providers/provider_adapter.dart`) — base para adapters.
- Adapters: `OpenAiAdapter`, `GeminiAdapter`, `ClaudeAdapter`, `LocalModelAdapter`, `OfflineAdapter`.
- `ProviderFactory` (`data/providers/provider_factory.dart`) — cria o provedor ativo.

### 7.4 Serviços

- `PromptBuilder` — monta contexto RAG.
- `AiService` — orquestra busca, geração, cache e histórico.

### 7.5 Apresentação

- `AiAssistantPage` (`features/ai/presentation/pages/ai_assistant_page.dart`)
- `ConversationController` (`features/ai/presentation/controllers/conversation_controller.dart`)

### 7.6 Injeção de dependências

- `AiDI` (`features/ai/di/ai_di.dart`) registra todas as dependências no `ServiceLocator`.
- Chamada adicionada em `core/di/service_locator.dart`.

---

## 8. Navegação e UI

- Nova rota: `RouteNames.ai` (`/ai`) registrada em `AppRouter`.
- Ícone `auto_fix_high_rounded` adicionado na `AppBar` do `AppShell`.
- Tela própria com:
  - Barra de modos (professor, resumo, detalhado, comparar, timeline).
  - Lista de conversas (perguntas e respostas).
  - Citações e entidades relacionadas em chips.
  - Sugestões de próximas perguntas.
  - Botões de favoritar e fixar por mensagem.
  - Input de nova pergunta.

---

## 9. Testes

Suite localizada em `test/features/ai/`:

- `data/providers/provider_adapter_test.dart`
- `data/cache/ai_cache_service_test.dart`
- `data/repositories/ai_repository_impl_test.dart`
- `data/repositories/conversation_repository_impl_test.dart`
- `data/services/prompt_builder_test.dart`
- `services/ai_service_test.dart`
- `presentation/controllers/conversation_controller_test.dart`

Para executar:

```bash
flutter test
```

---

## 10. Próximos passos (preparados, não implementados)

- Integração real com APIs REST da OpenAI, Gemini e Claude usando `http`.
- Execução de modelos locais (ONNX / TensorFlow Lite / ML Kit) no `LocalModelAdapter`.
- Chat por voz e entrada OCR/imagens.
- Sincronização do histórico com Supabase.
- Melhorias no parser de datas e entidades para RAG.
