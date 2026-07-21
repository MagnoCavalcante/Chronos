# CHRONOS Design System — Sprint 4.4.4 Shared UI Components

Esta especificação define os novos componentes visuais oficiais reutilizáveis do ecossistema **CHRONOS**. Estes componentes garantem total aderência aos Design Tokens da aplicação, acessibilidade integrada através de `Semantics`, responsividade nativa e consistência estética impecável (evitando valores de cor, espaçamento ou tipografia hardcoded).

---

## 1. Diretrizes Gerais de Implementação

Todos os módulos, telas e componentes futuros do CHRONOS deverão utilizar **exclusivamente** este conjunto de componentes reutilizáveis. Nenhuma tela de apresentação poderá declarar widgets básicos inline se houver correspondente nesta biblioteca oficial.

### Princípios Fundamentais:
1. **Zero Cores Hardcoded**: Todos os estilos visuais utilizam as propriedades do `ChronosColors` ou herdam definições reativas do `Theme.of(context)`.
2. **Acessibilidade Integrada (Semantics)**: Todos os widgets possuem tags semânticas para suporte nativo a leitores de tela, gestos de acessibilidade e tooltips contextuais.
3. **Composição Limpa (KISS, DRY, SOLID)**: Widgets projetados sob o princípio de responsabilidade única e composição escalável.

---

## 2. Catálogo Detalhado de Componentes (`lib/presentation/widgets/`)

### 2.1. ChronosCard (`chronos_card.dart`)
Widget de contêiner unificado para a exibição de qualquer entidade histórica, herói, evento ou civilização do CHRONOS.

#### Propriedades Aceitas:
- `title` (String, obrigatório): Título principal exibido com destaque.
- `subtitle` (String, opcional): Subtítulo explicativo sutil, exibido nas cores do tema (`ChronosColors.accent`).
- `description` (String, opcional): Resumo ou corpo textual informativo de apoio.
- `leading` (Widget, opcional): Elemento decorativo à esquerda (ex: avatar ou miniatura).
- `trailing` (Widget, opcional): Ação rápida ou elemento indicador à direita.
- `onTap` (VoidCallback, opcional): Callback de clique com animação de ripple acoplada.
- `backgroundColor` (Color, opcional): Sobrescrita de fundo (padrão: `ChronosColors.surface`).
- `borderColor` (Color, opcional): Cor de contorno decorativo.
- `elevation` (double, opcional): Intensidade da sombra de elevação.
- `borderRadius` (BorderRadius, opcional): Curvatura dos cantos (padrão: `ChronosRadius.borderRadiusMD`).
- `padding` (EdgeInsetsGeometry, opcional): Espaçamento interno.
- `margin` (EdgeInsetsGeometry, opcional): Margem externa.

#### Exemplo de Uso:
```dart
ChronosCard(
  title: 'Império Romano',
  subtitle: 'Antiguidade Clássica',
  description: 'Uma das maiores e mais influentes civilizações da história da humanidade.',
  leading: Icon(ChronosIcons.era),
  trailing: Icon(ChronosIcons.chevronRight),
  onTap: () => print('Abriu Civilização'),
);
```

---

### 2.2. ChronosSectionHeader (`chronos_section_header.dart`)
Componente padronizado para representar cabeçalhos de seções, blocos de conteúdo e divisões temáticas.

#### Propriedades Aceitas:
- `title` (String, obrigatório): Título principal com tipografia `titleLarge`.
- `subtitle` (String, opcional): Texto de apoio inferior com tipografia de corpo reduzido.
- `action` (Widget, opcional): Elemento interativo à direita (ex: botão "Ver Mais").
- `icon` (IconData, opcional): Ícone temático posicionado à esquerda do título.

#### Exemplo de Uso:
```dart
ChronosSectionHeader(
  title: 'Civilizações em Destaque',
  subtitle: 'Explore os impérios e dinastias que moldaram o mundo moderno.',
  icon: ChronosIcons.era,
  action: TextButton(
    onPressed: () {},
    child: Text('Ver Tudo'),
  ),
);
```

---

### 2.3. ChronosLoadingView (`chronos_loading_view.dart`)
Controla e centraliza visualmente as transições, requisições assíncronas e estados de carregamento do applet.

#### Propriedades Aceitas:
- `message` (String, opcional): Texto de apoio informando o processo em andamento.
- `icon` (IconData, opcional): Ícone decorativo posicionado acima do indicador circular.

#### Exemplo de Uso:
```dart
ChronosLoadingView(
  message: 'Alinhando registros cronológicos do tempo...',
  icon: ChronosIcons.hourglass,
);
```

---

### 2.4. ChronosErrorView (`chronos_error_view.dart`)
Componente oficial do sistema para apresentação de falhas operacionais, erros de rede ou ausência de conectividade.

#### Propriedades Aceitas:
- `failure` (Failure, opcional): Entidade contendo o erro estruturado vindo das regras de negócio.
- `message` (String, opcional): Mensagem customizada de amparo amigável ao usuário.
- `onRetry` (VoidCallback, opcional): Ação de retentativa rápida (habilita o botão vermelho de retry).

#### Exemplo de Uso:
```dart
ChronosErrorView(
  failure: Failure('Sem conexão com o banco de dados de eras.'),
  onRetry: () => controller.loadCivilizations(),
);
```

---

### 2.5. ChronosEmptyView (`chronos_empty_view.dart`)
Informativo semântico exibido quando listas de busca, listagens padrão ou filtros retornam conjuntos de dados vazios.

#### Propriedades Aceitas:
- `icon` (IconData, padrão: `ChronosIcons.empty`): Ícone descritivo central.
- `title` (String, obrigatório): Título em destaque do estado de vazios.
- `description` (String, obrigatório): Texto descritivo sugerindo como contornar o estado vazio.
- `action` (Widget, opcional): Botão ou gatilho de ação inferior (ex: "Cadastrar Nova Civilização").

#### Exemplo de Uso:
```dart
ChronosEmptyView(
  title: 'Nenhuma Civilização Encontrada',
  description: 'Tente ajustar os termos da busca ou os filtros aplicados.',
  icon: ChronosIcons.hourglass,
  action: ElevatedButton(
    onPressed: () {},
    child: Text('Cadastrar'),
  ),
);
```

---

### 2.6. ChronosSearchBar (`chronos_search_bar.dart`)
Campo de busca unificado e totalmente reativo. Pronto para buscas locais com filtragem ou acoplamento de debounce para buscas remotas.

#### Propriedades Aceitas:
- `hintText` (String, opcional): Texto de dica (placeholder).
- `onChanged` (ValueChanged<String>, opcional): Evento disparado a cada tecla digitada.
- `onClear` (VoidCallback, opcional): Evento acionado ao apagar toda a consulta.
- `controller` (TextEditingController, opcional): Controlador do input de texto.
- `focusNode` (FocusNode, opcional): Gerenciador de foco do campo.

#### Exemplo de Uso:
```dart
ChronosSearchBar(
  hintText: 'Buscar dinastias pelo nome...',
  onChanged: (value) => controller.filterLocalList(value),
);
```

---

### 2.7. ChronosStatusChip (`chronos_status_chip.dart`)
Tag visual expressa para representar a propriedade `publicationStatus` de uma entidade (conforme regras comerciais do CHRONOS).

#### Estados Suportados Nativamente:
- `draft` (Rascunho): Azul (Informativo).
- `review` (Em Revisão): Laranja (Atenção/Alerta).
- `published` (Publicado): Verde (Sucesso).
- `archived` (Arquivado): Cinza (Desabilitado).

#### Exemplo de Uso:
```dart
ChronosStatusChip(status: 'published');
```

---

### 2.8. ChronosImageBanner (`chronos_image_banner.dart`)
Banner visual para imagens de topo de telas (Hero / Banners), cuidando do carregamento assíncrono e exibição de falhas de renderização de forma automática.

#### Propriedades Aceitas:
- `imageUrl` (String, opcional): URL da imagem remota.
- `placeholder` (Widget, opcional): Elemento exibido durante o download da imagem.
- `fallback` (Widget, opcional): Elemento exibido em caso de falha de conexão ou ausência de URL.
- `aspectRatio` (double, padrão: `16/9`): Proporção de tela desejada para enquadramento.
- `borderRadius` (BorderRadius, opcional): Curvatura dos cantos (padrão: `ChronosRadius.borderRadiusMD`).

#### Exemplo de Uso:
```dart
ChronosImageBanner(
  imageUrl: 'https://images.unsplash.com/photo-example',
  aspectRatio: 21 / 9,
);
```

---

### 2.9. ChronosInfoTile (`chronos_info_tile.dart`)
Linhas estilizadas e estruturadas para apresentação clara de atributos-chave e propriedades técnicas de entidades.

#### Propriedades Aceitas:
- `label` (String, obrigatório): Nome da característica (ex: "Capital", "Idioma").
- `value` (String, obrigatório): Descrição ou dado puro da característica.
- `icon` (IconData, opcional): Ícone de ambientação esquerda.
- `trailing` (Widget, opcional): Elemento final à direita para detalhamentos adicionais.

#### Exemplo de Uso:
```dart
ChronosInfoTile(
  label: 'Capital',
  value: 'Constantinopla',
  icon: ChronosIcons.location,
);
```

---

## 3. Conformidade com o ChronosTheme

Nenhum dos componentes criados possui cores hardcoded ou dimensões arbitrárias fora da estrutura definida nos tokens globais:
- **Cores**: `ChronosColors`
- **Espaçamentos**: `ChronosSpacing`
- **Arredondamento**: `ChronosRadius`
- **Tipografia**: `ChronosTypography`
- **Ícones**: `ChronosIcons`
