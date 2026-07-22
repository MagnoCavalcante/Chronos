# SPRINT 5.4.1 — Global Search Engine

## Entrega

A Busca Global foi migrada de indexação local de controllers para uma feature desacoplada que consulta o Supabase por RPC paginada.

## Arquivos criados

- `database/migrations/20260722000000_create_global_search_engine.sql`
- `app/lib/features/search/data/datasources/search_remote_datasource.dart`
- `app/lib/features/search/data/models/search_result_model.dart`
- `app/lib/features/search/data/repositories/supabase_search_repository.dart`
- `app/lib/features/search/di/search_di.dart`
- `app/lib/features/search/domain/entities/search_result.dart`
- `app/lib/features/search/domain/repositories/search_repository.dart`
- `app/lib/features/search/domain/usecases/search_use_case.dart`
- `app/lib/features/search/presentation/controllers/search_controller.dart`
- `app/test/features/search/search_controller_test.dart`
- `app/test/features/search/search_use_case_test.dart`
- `app/test/features/search/supabase_search_repository_test.dart`
- `SEARCH_ENGINE.md`

## Arquivos modificados

- `app/lib/core/di/service_locator.dart`
- `app/lib/presentation/pages/search/global_search_page.dart`
- `app/lib/presentation/pages/search/search_bar.dart`
- `app/lib/presentation/pages/search/search_filters.dart`
- `app/lib/presentation/pages/search/search_result_card.dart`
- `app/lib/presentation/pages/search/search_results.dart`
- `app/README.md`
- `docs/ARCHITECTURE.md`

## Arquivo removido

- `app/lib/presentation/pages/search/search_controller.dart` — indexador local legado substituído pelo controller da feature.

## Consultas e campos pesquisáveis

Uma RPC (`search_chronos`) unifica seis domínios: Personagens, Civilizações, Eventos, Artefatos, Localizações e Fontes.

Campos pesquisáveis: título/nome, subtítulo, resumo/descrição, tags e ano cronológico. A pesquisa é parcial, case-insensitive e restringe resultados a registros ativos/publicados.

## Performance

- debounce de 300 ms;
- uma RPC por alteração estabilizada de texto/filtro/ordem;
- paginação no Postgres com limite máximo de 100 itens;
- lazy loading próximo ao fim da lista;
- proteção contra chamadas de página simultâneas no controller.

## Testes

Quatro testes novos aprovados:

- mapeamento de resultado de repositório;
- delegação do use case;
- filtros/ordenação no controller;
- paginação no controller.

## Validação

- `flutter clean`: concluído.
- `flutter pub get`: dependências resolvidas; o processo retorna não-zero por exigência de Developer Mode do Windows para symlinks de plugins.
- `flutter analyze`: `No issues found!`.
- `flutter test test/features/search`: 4 testes aprovados.
- `flutter run -d emulator-5554`: aplicativo iniciado e sincronizado no emulador.

## Pendência obrigatória de implantação

A migration de busca foi criada, mas não foi aplicada remotamente: o repositório não contém configuração Supabase CLI vinculada (`supabase/config.toml`) e não há credencial de banco fornecida para executar `supabase db push`. A feature exibirá o estado de erro Supabase até que `20260722000000_create_global_search_engine.sql` seja aplicada ao projeto Supabase.

## Próxima recomendação

Aplicar a migration em staging/produção, inserir Fontes e tags reais pelo fluxo editorial e adicionar testes de integração contra o ambiente Supabase de staging.
