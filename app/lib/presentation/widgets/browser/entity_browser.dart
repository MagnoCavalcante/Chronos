import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/base_controller.dart';
import '../../../core/presentation/widgets/chronos_card.dart';
import '../../../core/presentation/widgets/chronos_responsive.dart';
import '../../widgets/chronos_section_header.dart';
import '../../widgets/chronos_loading_view.dart';
import '../../widgets/chronos_empty_view.dart';
import '../../widgets/chronos_error_view.dart';
import 'entity_card.dart';
import 'entity_list.dart';
import 'entity_grid.dart';
import 'entity_filters.dart';
import 'entity_sort_menu.dart';
import 'entity_search_delegate.dart';

/// Componente unificado, reativo e acessível de navegação e busca por Entidades Históricas (Entity Browser).
///
/// Permite gerenciar de forma genérica listagem, filtragem, ordenação e pesquisa em qualquer
/// módulo de dados do Knowledge Engine do CHRONOS.
class EntityBrowser<T> extends StatefulWidget {
  final BaseController<List<T>> controller;
  final ChronosEntityDisplay Function(T) displayMapper;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget>? actions;

  // Recursos de busca e customização
  final bool enableSearch;
  final bool enableSort;
  final bool enableFilter;
  final bool selectionMode;

  // Listagem de tipos e categorias disponíveis para o filtro
  final List<String>? availableTypes;
  final List<String>? availableCategories;

  // Callbacks de navegação ou alteração de estado
  final Function(T)? onNavigate;
  final Function(List<T>)? onSelectionChanged;

  // Estrutura de paginação futura (Preparada)
  final Future<void> Function()? onLoadNextPage;
  final bool hasMorePages;

  const EntityBrowser({
    super.key,
    required this.controller,
    required this.displayMapper,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actions,
    this.enableSearch = true,
    this.enableSort = true,
    this.enableFilter = true,
    this.selectionMode = false,
    this.availableTypes,
    this.availableCategories,
    this.onNavigate,
    this.onSelectionChanged,
    this.onLoadNextPage,
    this.hasMorePages = false,
  });

  @override
  State<EntityBrowser<T>> createState() => _EntityBrowserState<T>();
}

class _EntityBrowserState<T> extends State<EntityBrowser<T>> {
  EntityViewMode _viewMode = EntityViewMode.list;
  EntitySortOption _sortOption = EntitySortOption.nameAsc;
  EntityFilterParams _filterParams = const EntityFilterParams();
  String _searchQuery = '';

  final List<String> _selectedIds = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (widget.hasMorePages && widget.onLoadNextPage != null) {
        widget.onLoadNextPage!();
      }
    }
  }

  List<T> _getFilteredAndSortedItems(List<T> rawItems) {
    var filtered = List<T>.from(rawItems);

    // 1. Busca local
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((item) {
        final display = widget.displayMapper(item);
        return display.title.toLowerCase().contains(q) ||
            display.subtitle.toLowerCase().contains(q) ||
            (display.description?.toLowerCase().contains(q) ?? false) ||
            (display.chronology?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // 2. Filtros locais
    if (!_filterParams.isEmpty) {
      filtered = filtered.where((item) {
        final display = widget.displayMapper(item);

        if (_filterParams.status != null && display.status != _filterParams.status) {
          return false;
        }

        if (_filterParams.startYear != null) {
          final val = display.chronologyValue;
          if (val == null || val < _filterParams.startYear!) {
            return false;
          }
        }

        if (_filterParams.endYear != null) {
          final val = display.chronologyValue;
          if (val == null || val > _filterParams.endYear!) {
            return false;
          }
        }

        if (_filterParams.type != null && display.type != _filterParams.type) {
          return false;
        }

        if (_filterParams.category != null && display.category != _filterParams.category) {
          return false;
        }

        return true;
      }).toList();
    }

    // 3. Ordenação local
    filtered.sort((a, b) {
      final dispA = widget.displayMapper(a);
      final dispB = widget.displayMapper(b);

      switch (_sortOption) {
        case EntitySortOption.nameAsc:
          return dispA.title.toLowerCase().compareTo(dispB.title.toLowerCase());
        case EntitySortOption.nameDesc:
          return dispB.title.toLowerCase().compareTo(dispA.title.toLowerCase());
        case EntitySortOption.chronologyAsc:
          final valA = dispA.chronologyValue ?? 0;
          final valB = dispB.chronologyValue ?? 0;
          return valA.compareTo(valB);
        case EntitySortOption.chronologyDesc:
          final valA = dispA.chronologyValue ?? 0;
          final valB = dispB.chronologyValue ?? 0;
          return valB.compareTo(valA);
        case EntitySortOption.newest:
          final dateA = dispA.dateValue ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = dispB.dateValue ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateB.compareTo(dateA);
        case EntitySortOption.oldest:
          final dateA = dispA.dateValue ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dateB = dispB.dateValue ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dateA.compareTo(dateB);
        case EntitySortOption.custom:
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _onItemSelectionChanged(T item, bool isSelected) {
    final display = widget.displayMapper(item);
    setState(() {
      if (isSelected) {
        if (!_selectedIds.contains(display.id)) {
          _selectedIds.add(display.id);
        }
      } else {
        _selectedIds.remove(display.id);
      }
    });

    if (widget.onSelectionChanged != null) {
      final List<T> rawItems = widget.controller.data ?? const [];
      final selectedItems = rawItems.where((x) {
        return _selectedIds.contains(widget.displayMapper(x).id);
      }).toList();
      widget.onSelectionChanged!(selectedItems);
    }
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EntityFiltersSheet(
          initialParams: _filterParams,
          availableTypes: widget.availableTypes,
          availableCategories: widget.availableCategories,
          onApply: (newParams) {
            setState(() {
              _filterParams = newParams;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final status = widget.controller.status;

        return Column(
          children: [
            _buildToolbar(context, status.data ?? const []),
            _buildActiveFiltersRow(),
            Expanded(
              child: _buildBody(status),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, List<T> rawItems) {
    return Container(
      color: ChronosColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ChronosSectionHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  icon: widget.icon,
                ),
              ),
              if (widget.actions != null) ...widget.actions!,
            ],
          ),
          ChronosSpacing.vSizedBoxSM,
          Row(
            children: [
              // 1. Campo de busca rápida
              if (widget.enableSearch) ...[
                Expanded(
                  child: Semantics(
                    label: 'Campo de Pesquisa',
                    hint: 'Toque para pesquisar de forma simplificada por texto ou data',
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar nesta seção...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ChronosRadius.sm),
                          borderSide: const BorderSide(color: ChronosColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: ChronosSpacing.md,
                          vertical: ChronosSpacing.sm,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      style: ChronosTypography.bodyMedium,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                ChronosSpacing.hSizedBoxMD,
              ],

              // 2. Filtros e ordenação
              if (widget.enableFilter) ...[
                Semantics(
                  label: 'Abrir Filtros',
                  child: ChronosCard(
                    padding: const EdgeInsets.all(ChronosSpacing.sm),
                    borderColor: _filterParams.isEmpty ? ChronosColors.border : ChronosColors.accent,
                    onTap: _showFiltersSheet,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: _filterParams.isEmpty ? ChronosColors.textPrimary : ChronosColors.accent,
                          size: 18,
                        ),
                        ChronosSpacing.hSizedBoxXS,
                        Text(
                          'Filtros',
                          style: ChronosTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _filterParams.isEmpty ? ChronosColors.textPrimary : ChronosColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ChronosSpacing.hSizedBoxSM,
              ],

              if (widget.enableSort) ...[
                EntitySortMenu(
                  selectedOption: _sortOption,
                  onSelected: (opt) {
                    setState(() {
                      _sortOption = opt;
                    });
                  },
                ),
                ChronosSpacing.hSizedBoxSM,
              ],

              // 3. Modos de Visualização
              _buildViewModeToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildViewModeButton(EntityViewMode.list, Icons.view_list_rounded, 'Lista'),
        _buildViewModeButton(EntityViewMode.grid, Icons.grid_view_rounded, 'Grade'),
        _buildViewModeButton(EntityViewMode.compact, Icons.view_headline_rounded, 'Compacta'),
        _buildViewModeButton(EntityViewMode.large, Icons.view_agenda_rounded, 'Destaques'),
      ],
    );
  }

  Widget _buildViewModeButton(EntityViewMode mode, IconData icon, String label) {
    final isSelected = _viewMode == mode;
    return Semantics(
      label: 'Alternar para visualização em $label',
      selected: isSelected,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? ChronosColors.accent : ChronosColors.textMuted,
          size: 18,
        ),
        onPressed: () {
          setState(() {
            _viewMode = mode;
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    if (_filterParams.isEmpty && _searchQuery.isEmpty) return const SizedBox.shrink();

    return Container(
      color: ChronosColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Filtros ativos: ',
              style: ChronosTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: ChronosColors.textSecondary,
              ),
            ),
            ChronosSpacing.hSizedBoxSM,
            if (_searchQuery.isNotEmpty)
              _buildFilterChip('Busca: "$_searchQuery"', () {
                setState(() {
                  _searchQuery = '';
                });
              }),
            if (_filterParams.status != null)
              _buildFilterChip('Status: ${_filterParams.status!.value.toUpperCase()}', () {
                setState(() {
                  _filterParams = _filterParams.copyWith(clearStatus: true);
                });
              }),
            if (_filterParams.startYear != null)
              _buildFilterChip('Início: ${_filterParams.startYear}', () {
                setState(() {
                  _filterParams = _filterParams.copyWith(clearStartYear: true);
                });
              }),
            if (_filterParams.endYear != null)
              _buildFilterChip('Término: ${_filterParams.endYear}', () {
                setState(() {
                  _filterParams = _filterParams.copyWith(clearEndYear: true);
                });
              }),
            if (_filterParams.type != null)
              _buildFilterChip('Tipo: ${_filterParams.type}', () {
                setState(() {
                  _filterParams = _filterParams.copyWith(clearType: true);
                });
              }),
            if (_filterParams.category != null)
              _buildFilterChip('Categoria: ${_filterParams.category}', () {
                setState(() {
                  _filterParams = _filterParams.copyWith(clearCategory: true);
                });
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: ChronosSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: ChronosColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(ChronosRadius.sm),
        border: Border.all(color: ChronosColors.accent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ChronosTypography.bodySmall.copyWith(
              color: ChronosColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          ChronosSpacing.hSizedBoxXS,
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: ChronosColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ViewStatus<List<T>> status) {
    if (status.isLoading) {
      return const ChronosLoadingView();
    }

    if (status.isError) {
      return ChronosErrorView(
        failure: status.error,
        onRetry: widget.controller.retry,
      );
    }

    final rawItems = status.data ?? const [];
    final items = _getFilteredAndSortedItems(rawItems);

    if (items.isEmpty) {
      return const ChronosEmptyView(
        title: 'Nenhuma entidade correspondente',
        description: 'Tente ajustar ou remover filtros para expandir a fenda de busca.',
      );
    }

    if (_viewMode == EntityViewMode.grid || _viewMode == EntityViewMode.large) {
      return EntityGrid<T>(
        items: items,
        displayMapper: widget.displayMapper,
        viewMode: _viewMode,
        scrollController: _scrollController,
        selectionMode: widget.selectionMode,
        selectedIds: _selectedIds,
        onTap: widget.onNavigate,
        onSelectedChanged: _onItemSelectionChanged,
      );
    } else {
      return EntityList<T>(
        items: items,
        displayMapper: widget.displayMapper,
        viewMode: _viewMode,
        scrollController: _scrollController,
        selectionMode: widget.selectionMode,
        selectedIds: _selectedIds,
        onTap: widget.onNavigate,
        onSelectedChanged: _onItemSelectionChanged,
      );
    }
  }
}
