# SPRINT 5.4.RF — Structural Refactoring & Codebase Consolidation

## Resultado

A consolidação estrutural foi concluída sem alteração intencional de aparência, fluxos de navegação ativos, regras de negócio, Supabase ou banco de dados.

## Arquivos removidos

| Categoria | Arquivos |
|---|---|
| Implementação Civilizações duplicada (legado) | `app/lib/domain/entities/civilization.dart`, `app/lib/domain/usecases/get_all_civilizations.dart`, `app/lib/domain/usecases/get_civilization_by_id.dart`, `app/lib/domain/usecases/get_civilization_by_slug.dart`, `app/lib/data/models/civilization_model.dart`, `app/lib/data/datasources/civilization_remote_datasource.dart`, `app/lib/data/repositories/civilization_repository_impl.dart`, `app/lib/presentation/controllers/civilizations_controller.dart` |
| Rota/classe órfã | `app/lib/features/historical_characters/routes/historical_characters_routes.dart`, `app/lib/presentation/screens/connection_test_screen.dart` |
| Assets sem consumo | `app/assets/images/placeholder.txt`, `app/assets/icons/placeholder.txt` |

**Total removido:** 12 arquivos.

## Consolidações e correções

- **Civilizações:** a implementação oficial é `app/lib/features/civilizations/`. A entidade, modelos, repositório, casos de uso, controller, tela, DI e testes ativos usam a mesma feature-domain entity.
- **DI:** `setupServiceLocator()` passou a limpar registros antes de registrar dependências, permitindo bootstrap repetível em testes sem registros antigos.
- **Rotas:** removido o import morto da tela técnica de conexão e eliminada a rota alternativa não registrada de Personagens. Rotas visíveis existentes permanecem inalteradas.
- **Testes:** os testes de controller agora injetam todos os casos de uso exigidos, sem recorrer a serviços globais não registrados. O smoke test inicializa a DI antes de construir `ChronosApp`.
- **Dependências:** nenhuma dependência de `pubspec.yaml` foi removida; Flutter, Supabase e lints são usadas pela aplicação e pela suíte de testes.

## Métricas

| Métrica | Resultado |
|---|---:|
| Arquivos removidos | 12 |
| Implementações de Civilizações consolidadas | 8 arquivos legados removidos; 1 feature canônica mantida |
| Rotas/classes órfãs removidas | 2 |
| Assets sem uso removidos | 2 |
| Imports mortos removidos | 1 (`connection_test_screen.dart`) |
| Testes estruturais corrigidos | 3 arquivos: smoke test e 2 controllers |
| Testes aprovados na validação explícita | 21 casos em 9 arquivos |
| Cobertura estimada | Não mensurada; não há pipeline de cobertura configurado |

## Validação

| Verificação | Resultado |
|---|---|
| `flutter analyze` | `No issues found!` |
| Smoke test | Aprovado |
| Testes de Civilizações | Aprovados |
| Testes de Personagens | Aprovados |
| Suíte explícita de 9 arquivos | Aprovada: 21 casos |
| `flutter clean` | Concluído |
| `flutter pub get` | Dependências resolvidas, mas o comando retornou não-zero porque o Windows exige Developer Mode para suporte a symlinks de plugins. |
| `flutter run -d emulator-5554` | APK debug foi gerado, app iniciou, Supabase registrou inicialização concluída e o VM Service ficou disponível; a sessão CLI perdeu conexão posteriormente. |

## Ganhos

- Uma única fonte de verdade para Civilizações reduz risco de tipos e repositórios divergentes.
- DI de teste previsível elimina falhas por resolução implícita de dependências.
- Menor superfície de manutenção pela remoção de código e ativos órfãos.
- Documentação de débito técnico centralizada em `TECH_DEBT.md`.

## Limites preservados

- Placeholders e funcionalidades incompletas não foram implementados ou removidos porque fazem parte do comportamento/navegação atual.
- A migração total de todos os módulos legados para feature-first foi registrada como débito técnico: fazê-la nesta sprint exigiria movimentação ampla e risco desnecessário de regressão.
- Não houve alteração de layout, Design System, banco, consultas Supabase ou regras de negócio.

## Próxima sprint recomendada

**Sprint 5.5.0 — Convergência arquitetural e qualidade:** mover testes para `test/`, reduzir suppressions do analyzer, consolidar os módulos legados restantes no padrão feature-first e atualizar documentação histórica de tecnologias não utilizadas.
