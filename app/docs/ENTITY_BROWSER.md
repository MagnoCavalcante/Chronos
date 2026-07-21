# CHRONOS — Generic Entity Browser

O **Entity Browser** é um ecossistema de componentes reutilizáveis projetado especificamente para unificar e padronizar a navegação, busca, filtragem e ordenação de qualquer entidade de negócio do **Knowledge Engine** (Eras, Eventos, Personagens, Civilizações, Artefatos, Localizações, Fontes e Relações) no ecossistema CHRONOS.

Nenhuma tela ou recurso individual deve implementar sua própria listagem física ou controles de filtros específicos do zero. Toda a interação visual com coleções de entidades é delegada ao `EntityBrowser`.

---

## 1. Arquitetura e Estrutura de Arquivos

Os arquivos estão localizados em `lib/presentation/widgets/browser/` e são organizados de forma altamente modular:

*   `browser.dart`: Arquivo central de exportação (Index).
*   `entity_browser.dart`: O orquestrador central e reativo que gerencia barras de ferramentas, filtros rápidos ativos e os modos visuais de renderização.
*   `entity_card.dart`: Representação visual individual de uma entidade suportando 4 modos visuais exclusivos (`compact`, `list`, `grid`, `large`).
*   `entity_list.dart`: Layout de renderização em fluxo de rolagem vertical padrão (Lista).
*   `entity_grid.dart`: Layout adaptativo de alto nível utilizando bento-grid modular reativo.
*   `entity_filters.dart`: Planilha inferior (BottomSheet) contendo formulários acessíveis para filtragem avançada (Status, Período, Tipo, Categoria).
*   `entity_sort_menu.dart`: Menu suspenso flutuante estilizado para controlar a ordenação dos dados.
*   `entity_search_delegate.dart`: Integração com o fluxo nativo e de alta performance de busca do Flutter (`SearchDelegate`).

---

## 2. Fluxo de Dados e Reatividade

O `EntityBrowser` consome apenas **Casos de Uso** e controladores abstratos herdados da classe `BaseController`, respeitando estritamente a **Clean Architecture** e as diretrizes do **Architecture Guardian** do CHRONOS:

1.  **Reação do Estado**: O `EntityBrowser` é envolto em um `ListenableBuilder` que escuta as atualizações do `BaseController<List<T>>`.
2.  **Mapeamento Unificado**: Como os domínios possuem estruturas de dados variadas, o `EntityBrowser` consome um mapeador genérico `ChronosEntityDisplay Function(T)` para traduzir a entidade em propriedades visuais padronizadas (Título, Subtítulo, Ícone, Cor de Destaque, etc.).
3.  **Processamento Local**: Filtros de texto, filtros avançados e ordenação cronológica/alfabética são executados sob demanda no estado do widget de forma assíncrona ou síncrona de altíssima performance.
4.  **Acessibilidade Integrada**: Todos os elementos interativos possuem marcação de semântica com o widget `Semantics` do Flutter, garantindo suporte exemplar a leitores de tela e navegação por teclado física ou virtual.

---

## 3. Exemplo Prático de Utilização

Abaixo está um exemplo de como integrar o `EntityBrowser` para renderizar a lista de **Eras Históricas** dentro de uma tela:

```dart
import 'package:flutter/material.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/chronos_page.dart';
import 'package:chronos/presentation/widgets/browser/browser.dart';
import 'package:chronos/domain/entities/era.dart';
import 'package:chronos/presentation/controllers/eras_controller.dart'; // Exemplo fictício de controller

class ErasBrowserScreen extends StatelessWidget {
  final ErasController controller;

  const ErasBrowserScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChronosPage(
      child: EntityBrowser<Era>(
        controller: controller,
        title: 'Eras Históricas',
        subtitle: 'Grandes divisões da odisseia temporal humana.',
        icon: Icons.hourglass_empty_rounded,
        displayMapper: (era) => ChronosEntityDisplay(
          id: era.id,
          title: era.nome,
          subtitle: era.tituloCurto,
          description: era.descricaoResumida,
          status: era.publicationStatus,
          chronology: '${era.inicioAno} a.C. — ${era.fimAno} d.C.',
          chronologyValue: era.inicioAno,
          color: _parseHexColor(era.corHex),
          icon: Icons.auto_stories_rounded,
        ),
        onNavigate: (era) {
          // Navegar para os detalhes da Era
          Navigator.of(context).pushNamed('/eras/details', arguments: era.id);
        },
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return ChronosColors.accent;
    }
  }
}
```

---

## 4. Boas Práticas

*   **Evitar Acoplamento**: Jamais introduza referências diretas a conexões HTTP, chamadas ao Supabase, ou queries em Drizzle/SQL dentro de qualquer widget do `EntityBrowser`. Consuma unicamente os estados expostos pelo `BaseController`.
*   **Acessibilidade em Primeiro Lugar**: Sempre utilize o widget `Semantics` ao implementar customizações adicionais e configure `Focus` para acessibilidade de teclados.
*   **Imutabilidade de Parâmetros**: Mantenha o modelo `EntityFilterParams` estritamente imutável, utilizando o padrão `copyWith` para atualizações de filtros parciais.
*   **Responsividade Fluida**: Sempre respeite os breakpoints de responsividade padrão expostos em `ChronosResponsive` (Móvel, Tablet, Desktop) ao renderizar os cards em bento-grids.
