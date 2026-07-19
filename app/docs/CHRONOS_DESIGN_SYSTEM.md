# CHRONOS Design System (v1.0)

O **CHRONOS Design System** é a infraestrutura oficial de interface de usuário (UI) para o ecossistema CHRONOS. Ele estabelece uma linguagem visual coesa, fundamentada em **Design Tokens** e implementada por meio de componentes semânticos, robustos e modulares.

### Princípio da Coexistência e Reutilização Sustentável
* **Uso nas Features**: Todas as telas e fluxos visuais de novas features devem construir sua interface utilizando estritamente os componentes encapsulados e unificados do ecossistema (**`Chronos*`**).
* **Uso Interno no Design System**: Os componentes `Chronos*` podem (e devem) encapsular, parametrizar e reutilizar componentes nativos do **Material 3** internamente quando fizer sentido. Isso evita reinventar comportamentos já consolidados e aproveita a acessibilidade e maturidade da biblioteca nativa do Flutter, mantendo a consistência visual em nível de aplicação.

---

## 1. Arquitetura de Design Tokens

Os Design Tokens são as unidades indivisíveis de design do ecossistema. Eles garantem que valores como cores, tipografia, espaçamento e raios sejam consistentes em todo o aplicativo.

A hierarquia de resolução de estilo segue o fluxo de dependência:
`Cores/Tipografia` ➔ `Espaçamentos/Arredondamentos` ➔ `Sombras/Ícones` ➔ `Componentes`.

### 1.1. Cores (`ChronosColors`)
A paleta de cores adota uma identidade moderna e confortável para leitura, focada em tons de ardósia escuros (*Slate*) e destaques em âmbar (*Amber*).

- **Principais:**
  - `ChronosColors.primary` (`0xFF0F172A`): Cor de marca primária (Slate 900).
  - `ChronosColors.primaryLight` (`0xFF1E293B`): Tom intermediário (Slate 800).
  - `ChronosColors.accent` (`0xFFF59E0B`): Cor de destaque e interatividade (Amber 500).
- **Superfícies:**
  - `ChronosColors.background` (`0xFF0B0F19`): Fundo principal do applet.
  - `ChronosColors.surface` (`0xFF151D30`): Fundo de cards, modais e caixas flutuantes.
- **Tipográficas:**
  - `ChronosColors.textPrimary` (`0xFFF8FAFC`): Texto principal de altíssimo contraste (Slate 50).
  - `ChronosColors.textSecondary` (`0xFF94A3B8`): Texto de descrição ou metadados (Slate 400).
  - `ChronosColors.textMuted` (`0xFF64748B`): Texto desabilitado ou de apoio sutil (Slate 500).
- **Semânticas:**
  - `ChronosColors.success` (`0xFF10B981`): Estados de sucesso e aprovação.
  - `ChronosColors.error` (`0xFFEF4444`): Estados de erro, falhas ou ações destrutivas.
  - `ChronosColors.warning` (`0xFFF59E0B`): Alertas e pendências de revisão.
  - `ChronosColors.info` (`0xFF3B82F6`): Informações e fluxos gerais de suporte.

### 1.2. Tipografia (`ChronosTypography`)
Estilos tipográficos projetados para clareza e ritmo de leitura. Baseia-se na família **Inter** (sans-serif) para texto geral e **JetBrains Mono** (mono) para dados numéricos, anos históricos e tags estruturadas.

- **Display (Grandes cabeçalhos):**
  - `displayLarge` (32px, Bold)
  - `displayMedium` (26px, Bold)
  - `displaySmall` (22px, Bold)
- **Title (Títulos de seções e cards):**
  - `titleLarge` (18px, Bold)
  - `titleMedium` (16px, SemiBold)
  - `titleSmall` (14px, SemiBold)
- **Body (Textos informativos e descritivos):**
  - `bodyLarge` (16px, Regular, h: 1.5)
  - `bodyMedium` (14px, Regular, h: 1.4)
  - `bodySmall` (12px, Regular, h: 1.3)
- **Label (Botões, chips, badges):**
  - `labelLarge` (14px, Bold, letterSpacing: 1.25)
  - `labelMedium` (12px, Bold, letterSpacing: 1.0)
  - `labelSmall` (10px, Bold, letterSpacing: 1.5)
- **Code/Mono (Anos a.C., IDs, dados estatísticos):**
  - `codeMedium` (13px, Medium, JetBrains Mono)
  - `codeSmall` (11px, Medium, JetBrains Mono)

### 1.3. Espaçamento (`ChronosSpacing`)
Evita qualquer margem ou padding hardcoded, garantindo alinhamento rítmico perfeito.
- `ChronosSpacing.xxs`: 2.0
- `ChronosSpacing.xs`: 4.0
- `ChronosSpacing.sm`: 8.0
- `ChronosSpacing.md`: 12.0
- `ChronosSpacing.lg`: 16.0
- `ChronosSpacing.xl`: 20.0
- `ChronosSpacing.xxl`: 24.0
- `ChronosSpacing.xxxl`: 32.0

*Aplicações úteis:* `ChronosSpacing.vSizedBoxMD` (SizedBox vertical de 12px) e `ChronosSpacing.edgeInsetsAllLG` (EdgeInsets de 16px).

### 1.4. Arredondamento (`ChronosRadius`)
Define a curvatura dos cantos para cada categoria de elemento.
- `ChronosRadius.xs` (4px): Bordas finas, badges.
- `ChronosRadius.sm` (8px): Chips, botões pequenos, caixas de feedback.
- `ChronosRadius.md` (12px): Cards padrão, text fields, botões grandes.
- `ChronosRadius.lg` (16px): Dialogs, modais, cabeçalhos flutuantes.
- `ChronosRadius.xl` (24px): Bottom sheets e painéis expansivos.
- `ChronosRadius.circular` (999px): Avatares e botões circulares.

### 1.5. Sombra e Elevação (`ChronosShadows`)
Adiciona profundidade controlada, prevenindo ruído visual.
- `ChronosShadows.none`: Plana, ideal para inputs e layouts de contorno puro.
- `ChronosShadows.sm`: Elevação leve (Cards secundários).
- `ChronosShadows.md`: Elevação padrão (Cards principais e botões primários).
- `ChronosShadows.lg`: Elevação alta (Dialogs, Bottom Sheets e SnackBars).

### 1.6. Ícones (`ChronosIcons`)
Ícones padronizados para consistência visual e semântica.
- **Ações:** `sync`, `refresh`, `search`, `add`, `edit`, `delete`, `save`, `close`, `chevronRight`, `chevronLeft`.
- **Estados:** `success`, `error`, `warning`, `info`, `empty`.
- **Temáticos:** `era`, `event`, `character`, `hourglass`, `historyDoc`, `location`, `artifact`.

---

## 2. Catálogo de Componentes Reutilizáveis

Todos os componentes abaixo estão exportados no barrel oficial `import 'package:chronos/core/presentation/widgets/widgets.dart';`.

### 2.1. Estrutura e Layout
- **`ChronosScaffold`**: Estrutura geral de tela. Configura background Slate, AppBar estilizada com títulos automáticos, botão de voltar intuitivo e ações secundárias.
- **`ChronosPage`**: Wrapper interno de tela que cuida de `SafeArea`, margens padronizadas, comportamento rolável (`scrollable`) e transição fade-in nativa de carregamento. Suporta Pull-to-Refresh embutido através do parâmetro `onRefresh`.
- **`ChronosResponsive`**: Divide visualizações entre `mobile` (largura < 600px), `tablet` (600px a 1024px) e `desktop` (> 1024px) automaticamente.

### 2.2. Containers e Listas
- **`ChronosCard`**: Container básico para agrupamento visual de informações. Suporta interações de clique (`onTap`), bordas customizadas e sombras derivadas dos tokens.
- **`ChronosList`**: ListView inteligente que já aplica espaçamentos e divisores automáticos entre elementos a partir de listas de dados puros.
- **`ChronosGrid`**: Grid responsivo que recalcula automaticamente o número ideal de colunas baseando-se no Viewport disponível do usuário.

### 2.3. Interação e Ação
- **`ChronosButton`**: Botão unificado do sistema. Oferece as variantes `primary`, `secondary`, `outline` e `text`, com estados de carregamento animado (`isLoading`), desabilitado e suporte a prefixos de ícones.
- **`ChronosIconButton`**: Botão circular para ações compactas (como fechar, editar, voltar) com suporte a tooltip semântico e bordas ativáveis.
- **`ChronosRetryButton`**: Botão de repetição pré-configurado com ícone de sincronização e label de retorno unificado.

### 2.4. Feedbacks e Estados de Fluxo
- **`ChronosBadge`**: Pequena tag elíptica para indicação de status de dados (e.g. `success`, `draft`, `review`, `error`, `neutral`).
- **`ChronosChip`**: Tag de filtro interativa e selecionável (`isSelected`) com suporte a ações de exclusão.
- **`ChronosAvatar`**: Exibe fotos remotas com tratamento assíncrono refinado. Em caso de ausência de imagem ou falha de rede, gera automaticamente um fallback com as iniciais do nome do usuário ou ícone oficial.
- **`ChronosLoading`**: Indicador de progresso circular centralizado, acompanhado de descrição opcional de processo.
- **`ChronosSkeleton`**: Retângulo ou círculo pulsante para carregamentos pré-renderizados premium (Skeleton Screen).
- **`ChronosEmptyState`**: Layout informativo de ausência de registros (composto por ícone circular sutil, título de impacto, descrição de apoio e botão de ação para criar novos dados).
- **`ChronosErrorState`**: Layout robusto para tratamento de exceções de requisição e indisponibilidade de dados (composto por ícone de atenção vermelho, mensagem técnica legível e botão integrado de recarregamento rápida).

### 2.5. Diálogos e Overlays
- **`ChronosSnackBar`**: Dispara alertas dinâmicos e temporários (sucesso, erro, alerta, info) de forma flutuante e suave sem empilhar mensagens lentas.
- **`ChronosDialog`**: Caixa modal centralizada para decisões críticas. Oferece controle completo de botões de decisão.
- **`ChronosConfirmationDialog`**: Diálogo opinativo imediato (Sim/Não) retornando booleanos simplificados de confirmação diretamente da chamada assíncrona.
- **`ChronosBottomSheet`**: Painel flutuante que emerge do rodapé da tela em dispositivos móveis, com drag-handle sutil.

### 2.6. Formulários e Entradas
- **`ChronosSearchBar`**: Campo de busca simplificado com ícone de lupa fixado e botão de limpar automático ao começar a digitar.
- **`ChronosTextField`**: Caixa de entrada de dados totalmente adaptada à estilização escura do ecossistema CHRONOS.
- **`ChronosDropdown`**: Caixa seletora estilizada para formulários de cadastro e refinamento de dados.

---

## 3. Exemplo Prático de Implementação

Abaixo, um exemplo completo de tela de apresentação utilizando exclusivamente o ecossistema do **CHRONOS Design System**:

```dart
import 'package:flutter/material.dart';
import 'package:chronos/core/theme/theme.dart';
import 'package:chronos/core/presentation/widgets/widgets.dart';

class ErasListScreen extends StatelessWidget {
  const ErasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Usando ChronosScaffold para estruturação da tela
    return ChronosScaffold(
      title: 'ERAS HISTÓRICAS',
      actions: [
        ChronosIconButton(
          icon: ChronosIcons.search,
          tooltip: 'Pesquisar Eras',
          onPressed: () => _openSearch(context),
        ),
      ],
      // 2. Usando ChronosPage para cuidar de SafeArea, margens, transição suave e gestos de arrastar
      body: ChronosPage(
        scrollable: false,
        onRefresh: () async => _refreshData(),
        child: Column(
          children: [
            const ChronosSectionTitle(
              title: 'Linha do Tempo',
              subtitle: 'Selecione uma era para visualizar seus eventos históricos cadastrados.',
            ),
            ChronosSpacing.vSizedBoxMD,
            Expanded(
              child: _buildErasList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErasList() {
    final listItems = ['Antiguidade', 'Idade Média', 'Idade Moderna', 'Idade Contemporânea'];

    // 3. Usando ChronosList para listar elementos de forma estruturada e espaçada
    return ChronosList<String>(
      items: listItems,
      showSeparator: false,
      itemBuilder: (context, eraName, index) {
        // 4. Usando ChronosCard para envolver cada item da lista com cantos e sombras dos tokens
        return ChronosCard(
          onTap: () => _viewEraDetails(context, eraName),
          child: Row(
            children: [
              const ChronosAvatar(
                name: 'Era',
                fallbackIcon: ChronosIcons.era,
                size: 40,
              ),
              ChronosSpacing.hSizedBoxLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eraName,
                      style: ChronosTypography.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Explore as narrativas, reinos e conquistas deste período.',
                      style: ChronosTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                ChronosIcons.chevronRight,
                color: ChronosColors.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSearch(BuildContext context) {
    ChronosBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ChronosSearchBar(hintText: 'Buscar por eras ou civilizações...'),
          ChronosSpacing.vSizedBoxLG,
          ChronosButton(
            label: 'Buscar',
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _viewEraDetails(BuildContext context, String eraName) {
    ChronosSnackBar.show(
      context,
      message: 'Navegando para o período de $eraName...',
      type: ChronosSnackBarType.success,
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

---

## 4. Convenções e Boas Práticas

1. **Zero Hardcoding**: Não use valores diretos para `double` em paddings ou margens. Use sempre `ChronosSpacing` e `ChronosRadius`.
2. **Coesão Cromática**: Evite utilizar `Colors.amber` ou `Colors.grey`. Substitua-as por `ChronosColors.accent` e `ChronosColors.textSecondary`/`ChronosColors.textMuted`.
3. **Gerenciamento de Estados de Fluxo**: Sempre apresente carregamentos estruturados por meio do `ChronosLoading` ou `ChronosSkeleton`. Para listas que possam falhar ou estar vazias, retorne obrigatoriamente os widgets semânticos `ChronosErrorState` e `ChronosEmptyState` para manter uma experiência de altíssimo nível para o usuário.
4. **Abordagem Consistente de Componentes**: Novas telas de features devem priorizar e utilizar sempre a biblioteca `Chronos*`. Se um novo comportamento visual ou componente for necessário, encapsule-o em um widget do CHRONOS reutilizando elementos consolidados do Material 3 internamente.

---

## 5. Versionamento e Governança

- **Versão Atual:** `1.0.0`
- **Controle de Alterações:** Alterações de cores globais, novos componentes fundamentais ou modificações que quebrem compatibilidade tipográfica devem ser discutidas na Sprint Design do CHRONOS e aplicadas sequencialmente.
- **Expansão:** Novos componentes de interface de uso geral de nível de módulo devem ser adicionados na camada `core/presentation/widgets` para reuso contínuo.
