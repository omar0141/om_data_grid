import 'package:flutter/material.dart';
import 'package:om_data_grid/src/components/mobile/mobile_default_card.dart';
import 'package:om_data_grid/src/components/mobile/mobile_filter_sheet.dart';
import 'package:om_data_grid/src/components/mobile/mobile_sort_sheet.dart';
import 'package:om_data_grid/src/components/mobile/mobile_toolbar.dart';
import 'package:om_data_grid/src/enums/mobile_scroll_mode_enum.dart';
import 'package:om_data_grid/src/enums/mobile_view_type_enum.dart';
import 'package:om_data_grid/src/enums/selection_mode_enum.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A mobile-first data grid body widget that provides a card-based layout with
/// all OmDataGrid features:
///
/// - Global search and column filtering
/// - Sorting via full-screen column chooser
/// - Pagination **or** infinite scroll
/// - Row selection (single / multiple)
/// - Skeleton loading animation via `skeletonizer`
/// - Customisable card builder
/// - Three layout modes: [OmMobileViewType.list], [OmMobileViewType.grid],
///   [OmMobileViewType.compact]
/// - Sticky or scrollable toolbar, chips bar, and pagination footer
/// - Floating action button for the add action
///
/// Example:
/// ```dart
/// Scaffold(
///   body: OmMobileDataGrid(
///     controller: myController,
///     viewType: OmMobileViewType.list,
///     scrollMode: OmMobileScrollMode.pagination,
///     stickyToolbar: true,
///     stickyChips: true,
///     stickyPagination: true,
///   ),
/// );
/// ```
class OmMobileDataGrid extends StatefulWidget {
  /// The controller carrying data, column definitions and configuration.
  final OmDataGridController controller;

  /// Layout type for the card list. Defaults to [OmMobileViewType.list].
  final OmMobileViewType viewType;

  /// Whether to paginate or use infinite scroll.
  final OmMobileScrollMode scrollMode;

  /// Custom card builder. When provided, replaces the default card UI.
  /// The third argument [searchTerm] is the current global search string —
  /// use it to highlight matching text in your custom card.
  final Widget Function(
    Map<String, dynamic> row,
    List<OmGridColumnModel> columns,
    String searchTerm,
  )? cardBuilder;

  /// Show skeleton loading animation.
  final bool isLoading;

  /// Number of skeleton placeholders shown while [isLoading] is `true`.
  final int skeletonCount;

  /// Called when a row card is tapped.
  final void Function(Map<String, dynamic> row)? onRowTap;

  /// Called when selected rows change.
  final void Function(List<Map<String, dynamic>> selectedRows)?
      onSelectionChanged;

  /// Called when the filtered/sorted data changes.
  final void Function(List<dynamic>)? onSearch;

  /// **Infinite scroll only.** Called when the user scrolls near the bottom.
  final Future<void> Function()? onLoadMore;

  /// **Infinite scroll only.** Whether there are more items to load.
  final bool hasMoreData;

  /// Called when the user pulls down to refresh. When provided a
  /// [RefreshIndicator] is added around the card list. Your callback should
  /// reload the data and call [OmDataGridController.updateData].
  final Future<void> Function()? onRefresh;

  /// Scroll physics for the card list.
  final ScrollPhysics? physics;

  /// Padding around the card list content.
  final EdgeInsetsGeometry? contentPadding;

  // ── Sticky / scrollable controls ──────────────────────────────────────────

  /// Whether the search + sort/filter toolbar stays pinned at the top.
  /// When `false` the toolbar scrolls with the list. Defaults to `true`.
  final bool stickyToolbar;

  /// Whether the active-filter/sort chips bar stays pinned below the toolbar.
  /// When `false` the chips scroll with the list. Defaults to `true`.
  final bool stickyChips;

  /// Whether the pagination footer stays pinned at the bottom.
  /// When `false` the footer appears after the last card. Defaults to `true`.
  final bool stickyPagination;

  /// Whether to show the built-in search/sort/filter toolbar.
  /// Set to `false` when you want to drive filter and sort from your own
  /// widgets using [OmMobileFilterSheet.show] and [OmMobileSortSheet.show].
  /// Defaults to `true`.
  final bool showToolbar;

  /// Whether to show the sort button inside the built-in toolbar.
  /// Defaults to `true`.
  final bool showSortButton;

  /// Whether to show the filter button inside the built-in toolbar.
  /// Defaults to `true`.
  final bool showFilterButton;

  /// Sort key managed externally (e.g. when [showToolbar] is `false` and you
  /// call [OmMobileSortSheet.show] yourself). When provided, the sort chip in
  /// [OmMobileChipsBar] reflects this value instead of the internal sort.
  final String? externalSortKey;

  /// Sort direction for [externalSortKey]. Defaults to `true` (ascending).
  final bool externalSortAscending;

  /// Called when the user taps the ✕ on the external sort chip.
  final VoidCallback? onExternalSortClear;

  /// Whether to show the "Showing N entries" stats bar below the toolbar.
  /// Defaults to `true`.
  final bool showEntriesBar;

  const OmMobileDataGrid({
    super.key,
    required this.controller,
    this.viewType = OmMobileViewType.list,
    this.scrollMode = OmMobileScrollMode.pagination,
    this.cardBuilder,
    this.isLoading = false,
    this.skeletonCount = 8,
    this.onRowTap,
    this.onSelectionChanged,
    this.onSearch,
    this.onLoadMore,
    this.hasMoreData = false,
    this.onRefresh,
    this.physics,
    this.contentPadding,
    this.stickyToolbar = true,
    this.stickyChips = true,
    this.stickyPagination = true,
    this.showToolbar = true,
    this.showSortButton = true,
    this.showFilterButton = true,
    this.externalSortKey,
    this.externalSortAscending = true,
    this.onExternalSortClear,
    this.showEntriesBar = true,
  });

  @override
  State<OmMobileDataGrid> createState() => _OmMobileDataGridState();
}

class _OmMobileDataGridState extends State<OmMobileDataGrid> {
  late List<OmGridColumnModel> _internalColumns;
  late List<Map<String, dynamic>> _filteredData;
  late List<Map<String, dynamic>> _sortedData;
  late List<Map<String, dynamic>> _displayData;

  String? _sortColumnKey;
  bool _sortAscending = true;
  int _currentPage = 0;
  late int _rowsPerPage;
  bool _isInternalUpdate = false;
  bool _isLoadingMore = false;

  final Set<Map<String, dynamic>> _selectedRows = {};
  final ScrollController _scrollController = ScrollController();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.controller.configuration.rowsPerPage;
    _syncFromController();
    widget.controller.addListener(_handleControllerChange);
    if (widget.scrollMode == OmMobileScrollMode.infiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(OmMobileDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
      _syncFromController(resetSort: true);
      return;
    }
    if (widget.controller.configuration.rowsPerPage !=
        oldWidget.controller.configuration.rowsPerPage) {
      _rowsPerPage = widget.controller.configuration.rowsPerPage;
      _rebuildDisplay();
    }
    // Re-sort in-place when the external sort key or direction changes.
    if (widget.externalSortKey != oldWidget.externalSortKey ||
        widget.externalSortAscending != oldWidget.externalSortAscending) {
      setState(() {
        _currentPage = 0;
        _applySort();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Controller sync ────────────────────────────────────────────────────────

  void _handleControllerChange() {
    if (mounted && !_isInternalUpdate) {
      _syncFromController(resetSort: false);
    }
  }

  void _syncFromController({bool resetSort = false}) {
    setState(() {
      _internalColumns = List.from(widget.controller.columnModels);
      _filteredData = widget.controller.filteredData
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (resetSort) {
        _sortColumnKey = null;
        _sortAscending = true;
      }
      _currentPage = 0; // reset page BEFORE rebuilding display data
      _selectedRows.clear();
      _applySort();
      widget.onSearch?.call(_sortedData);
    });
  }

  // ── Sorting ────────────────────────────────────────────────────────────────

  void _applySort() {
    _sortedData = List.from(_filteredData);

    // Determine the effective sort key: internal first, then external.
    final effectiveKey = _sortColumnKey ?? widget.externalSortKey;
    final effectiveAscending =
        _sortColumnKey != null ? _sortAscending : widget.externalSortAscending;

    if (effectiveKey != null) {
      final colMatches =
          _internalColumns.where((c) => c.key == effectiveKey).toList();
      if (colMatches.isEmpty) {
        _rebuildDisplay();
        return;
      }
      final col = colMatches.first;
      final bool isDateOrTime = [
        OmGridRowTypeEnum.date,
        OmGridRowTypeEnum.time,
        OmGridRowTypeEnum.dateTime,
      ].contains(col.type);
      final bool isTime = col.type == OmGridRowTypeEnum.time;

      _sortedData.sort((a, b) {
        dynamic valA = a[effectiveKey];
        dynamic valB = b[effectiveKey];
        if (valA == null && valB == null) return 0;
        if (valA == null) return effectiveAscending ? 1 : -1;
        if (valB == null) return effectiveAscending ? -1 : 1;
        int result;
        if (isDateOrTime) {
          final dA = OmGridDateTimeUtils.tryParse(valA, isTime: isTime);
          final dB = OmGridDateTimeUtils.tryParse(valB, isTime: isTime);
          if (dA != null && dB != null) {
            result = dA.compareTo(dB);
          } else {
            result = valA.toString().compareTo(valB.toString());
          }
        } else if (valA is Comparable && valB is Comparable) {
          result = valA.compareTo(valB);
        } else {
          result = valA.toString().compareTo(valB.toString());
        }
        return effectiveAscending ? result : -result;
      });
    }
    _rebuildDisplay();
  }

  void _rebuildDisplay() {
    _displayData = _currentPageData;
  }

  List<Map<String, dynamic>> get _currentPageData {
    if (widget.scrollMode == OmMobileScrollMode.infiniteScroll) {
      return _sortedData;
    }
    final config = widget.controller.configuration;
    if (!config.allowPagination) return _sortedData;
    final int start = _currentPage * _rowsPerPage;
    final int end = start + _rowsPerPage;
    if (start >= _sortedData.length) return [];
    return _sortedData.sublist(
      start,
      end > _sortedData.length ? _sortedData.length : end,
    );
  }

  int get _totalPages {
    if (_sortedData.isEmpty) return 1;
    return (_sortedData.length / _rowsPerPage).ceil();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  void _handleGlobalSearch(String text) {
    _isInternalUpdate = true;
    widget.controller.updateGlobalSearchText(text);
    _isInternalUpdate = false;
    setState(() {
      _filteredData = widget.controller.filteredData
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _currentPage = 0;
      _selectedRows.clear();
      _applySort();
    });
    widget.onSearch?.call(_sortedData);
  }

  void _handleFilterSearch(List<dynamic> newFilteredData) {
    final mapped = newFilteredData
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    _isInternalUpdate = true;
    widget.controller.updateFilteredData(mapped);
    _isInternalUpdate = false;
    setState(() {
      _filteredData = mapped;
      _currentPage = 0;
      _selectedRows.clear();
      _applySort();
    });
    widget.onSearch?.call(mapped);
  }

  void _clearColumnFilter(OmGridColumnModel col) {
    col.filter = false;
    col.quickFilterText = null;
    col.notSelectedFilterData = null;
    col.advancedFilter = null;
    final newData = OmFilterUtils.performFiltering(
      data: widget.controller.data,
      allColumns: _internalColumns,
      globalSearch: widget.controller.globalSearchText,
    ).map((e) => Map<String, dynamic>.from(e)).toList();
    _isInternalUpdate = true;
    widget.controller.updateFilteredData(newData);
    _isInternalUpdate = false;
    setState(() {
      _filteredData = newData;
      _currentPage = 0;
      _selectedRows.clear();
      _applySort();
    });
  }

  void _clearAllFilters() {
    for (final col in _internalColumns) {
      col.filter = false;
      col.quickFilterText = null;
      col.notSelectedFilterData = null;
      col.advancedFilter = null;
    }
    final newData = widget.controller.data
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _isInternalUpdate = true;
    widget.controller.updateFilteredData(newData);
    _isInternalUpdate = false;
    setState(() {
      _filteredData = newData;
      _currentPage = 0;
      _selectedRows.clear();
      _applySort();
    });
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void _handleRowTap(Map<String, dynamic> row) {
    widget.onRowTap?.call(row);
    final mode = widget.controller.configuration.selectionMode;
    if (mode == OmSelectionMode.none) return;
    setState(() {
      if (mode == OmSelectionMode.single) {
        if (_selectedRows.contains(row)) {
          _selectedRows.clear();
        } else {
          _selectedRows
            ..clear()
            ..add(row);
        }
      } else {
        if (_selectedRows.contains(row)) {
          _selectedRows.remove(row);
        } else {
          _selectedRows.add(row);
        }
      }
    });
    widget.onSelectionChanged?.call(_selectedRows.toList());
  }

  // ── Infinite scroll ────────────────────────────────────────────────────────

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMoreData) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= max - 200) _triggerLoadMore();
  }

  Future<void> _triggerLoadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore!();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  // ── Toolbar actions ────────────────────────────────────────────────────────

  Future<void> _openSortSheet() async {
    final result = await OmMobileSortSheet.show(
      context: context,
      columns: _internalColumns,
      configuration: widget.controller.configuration,
      currentSortKey: _sortColumnKey,
      currentAscending: _sortAscending,
    );
    if (result == null) return; // user cancelled
    setState(() {
      if (result.isClear) {
        _sortColumnKey = null;
      } else {
        _sortColumnKey = result.columnKey;
        _sortAscending = result.ascending;
      }
      _currentPage = 0;
      _applySort();
    });
  }

  void _openFilterSheet() {
    OmMobileFilterSheet.show(
      context: context,
      columns: _internalColumns,
      data: widget.controller.data,
      filteredData: _filteredData,
      configuration: widget.controller.configuration,
      onSearch: _handleFilterSearch,
      globalSearchText: widget.controller.globalSearchText,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = widget.controller.configuration;
    final isGrid = widget.viewType == OmMobileViewType.grid;
    final showFab =
        config.showAddButton && widget.controller.onAddPressed != null;
    final effectiveSortKey = widget.externalSortKey ?? _sortColumnKey;
    final hasChips =
        (effectiveSortKey != null && effectiveSortKey.isNotEmpty) ||
            _internalColumns.any((c) => c.isFiltered);

    // FAB bottom offset: sit above sticky pagination when visible.
    final hasStickyPag = widget.stickyPagination &&
        widget.scrollMode == OmMobileScrollMode.pagination &&
        config.allowPagination;
    final fabBottomOffset = hasStickyPag ? 88.0 : 24.0;

    return Stack(
      children: [
        Column(
          children: [
            // ── Sticky toolbar ──────────────────────────────────────────
            if (widget.showToolbar && widget.stickyToolbar)
              _buildToolbar(config),

            // ── Sticky chips bar ────────────────────────────────────────
            if (widget.stickyChips && hasChips)
              _buildChipsBar(config, effectiveSortKey),

            // ── Stats bar ────────────────────────────────────────────
            if (widget.showEntriesBar) _buildStatsBar(config),

            // ── Card list / skeleton / empty ────────────────────────────
            Expanded(
              child: widget.isLoading
                  ? _buildSkeletonList(isGrid)
                  : _displayData.isEmpty
                      ? _buildEmptyState(config)
                      : _buildScrollContent(
                          config,
                          isGrid,
                          hasChips,
                          showFab,
                          fabBottomOffset,
                          effectiveSortKey,
                        ),
            ),

            // ── Sticky pagination ────────────────────────────────────────
            if (hasStickyPag) _buildPaginationFooter(config),
          ],
        ),

        // ── Floating action button ──────────────────────────────────────
        if (showFab)
          Positioned(
            bottom: fabBottomOffset + MediaQuery.of(context).padding.bottom,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'om_mobile_fab',
              onPressed: widget.controller.onAddPressed,
              backgroundColor: config.primaryColor,
              foregroundColor: config.primaryForegroundColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, size: 26),
            ),
          ),
      ],
    );
  }

  // ── Sub-builders ───────────────────────────────────────────────────────────

  Widget _buildToolbar(OmDataGridConfiguration config) {
    return OmMobileToolbar(
      configuration: config,
      columns: _internalColumns,
      initialSearch: widget.controller.globalSearchText,
      activeSortKey: _sortColumnKey,
      showSort: widget.showSortButton,
      showFilter: widget.showFilterButton,
      onSearchChanged: _handleGlobalSearch,
      onSortTap: _openSortSheet,
      onFilterTap: _openFilterSheet,
    );
  }

  Widget _buildChipsBar(OmDataGridConfiguration config,
      [String? overrideSortKey]) {
    final sortKey = overrideSortKey ?? _sortColumnKey;
    final isExternal = widget.externalSortKey != null;
    return OmMobileChipsBar(
      configuration: config,
      columns: _internalColumns,
      activeSortKey: sortKey,
      sortAscending: isExternal ? widget.externalSortAscending : _sortAscending,
      onClearSort: isExternal
          ? widget.onExternalSortClear
          : () => setState(() {
                _sortColumnKey = null;
                _applySort();
              }),
      onClearColumnFilter: _clearColumnFilter,
    );
  }

  /// Builds the scrollable card content.
  ///
  /// Uses a [CustomScrollView] when any section is non-sticky so that those
  /// sections can scroll alongside the cards.
  Widget _buildScrollContent(
    OmDataGridConfiguration config,
    bool isGrid,
    bool hasChips,
    bool showFab,
    double fabOffset,
    String? effectiveSortKey,
  ) {
    final needsCustomScroll = (widget.showToolbar && !widget.stickyToolbar) ||
        !widget.stickyChips ||
        !widget.stickyPagination;

    // Extra bottom padding so the FAB doesn't overlap the last card.
    final fabPad = showFab ? fabOffset + 56 : 0.0;

    if (!needsCustomScroll) {
      if (isGrid) {
        return _buildGridView(config, EdgeInsets.only(bottom: fabPad));
      }
      return _buildListView(
          config, EdgeInsets.only(top: 6, bottom: 12 + fabPad));
    }

    // ─ CustomScrollView with optional non-sticky header/footer slivers ─
    final scrollView = CustomScrollView(
      controller: widget.scrollMode == OmMobileScrollMode.infiniteScroll
          ? _scrollController
          : null,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Non-sticky toolbar
        if (widget.showToolbar && !widget.stickyToolbar)
          SliverToBoxAdapter(child: _buildToolbar(config)),

        // Non-sticky chips
        if (!widget.stickyChips && hasChips)
          SliverToBoxAdapter(child: _buildChipsBar(config, effectiveSortKey)),

        // Cards
        if (isGrid) ...[
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                .copyWith(bottom: 6 + fabPad),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildCard(_displayData[i]),
                childCount: _displayData.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
            ),
          ),
        ] else ...[
          SliverPadding(
            padding: EdgeInsets.only(top: 6, bottom: 12 + fabPad),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (widget.scrollMode == OmMobileScrollMode.infiniteScroll &&
                      i == _displayData.length) {
                    return _buildLoadMoreIndicator(config);
                  }
                  return _buildCard(_displayData[i]);
                },
                childCount: _displayData.length +
                    (widget.scrollMode == OmMobileScrollMode.infiniteScroll &&
                            _isLoadingMore
                        ? 1
                        : 0),
              ),
            ),
          ),
        ],

        // Non-sticky pagination footer
        if (!widget.stickyPagination &&
            widget.scrollMode == OmMobileScrollMode.pagination &&
            widget.controller.configuration.allowPagination)
          SliverToBoxAdapter(
            child: _buildPaginationFooter(config),
          ),
      ],
    );
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: config.primaryColor,
        child: scrollView,
      );
    }
    return scrollView;
  }

  Widget _buildListView(OmDataGridConfiguration config, EdgeInsets padding) {
    final list = ListView.builder(
      controller: widget.scrollMode == OmMobileScrollMode.infiniteScroll
          ? _scrollController
          : null,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      padding: widget.contentPadding ?? padding,
      itemCount: _displayData.length +
          (widget.scrollMode == OmMobileScrollMode.infiniteScroll &&
                  _isLoadingMore
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == _displayData.length) {
          return _buildLoadMoreIndicator(config);
        }
        return _buildCard(_displayData[index]);
      },
    );
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: config.primaryColor,
        child: list,
      );
    }
    return list;
  }

  Widget _buildGridView(OmDataGridConfiguration config, EdgeInsets extraPad) {
    final grid = GridView.builder(
      controller: widget.scrollMode == OmMobileScrollMode.infiniteScroll
          ? _scrollController
          : null,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      padding: (widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 6, vertical: 6))
          .add(extraPad) as EdgeInsets,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _displayData.length,
      itemBuilder: (context, index) => _buildCard(_displayData[index]),
    );
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        color: config.primaryColor,
        child: grid,
      );
    }
    return grid;
  }

  Widget _buildCard(Map<String, dynamic> row) {
    final isSelected = _selectedRows.contains(row);
    if (widget.cardBuilder != null) {
      return GestureDetector(
        onTap: () => _handleRowTap(row),
        child: widget.cardBuilder!(
          row,
          _internalColumns,
          widget.controller.globalSearchText,
        ),
      );
    }
    return OmMobileDefaultCard(
      row: row,
      columns: _internalColumns,
      configuration: widget.controller.configuration,
      viewType: widget.viewType,
      isSelected: isSelected,
      searchTerm: widget.controller.globalSearchText,
      onTap: () => _handleRowTap(row),
      onLongPress:
          widget.controller.configuration.selectionMode != OmSelectionMode.none
              ? _handleRowTap
              : null,
    );
  }

  Widget _buildStatsBar(OmDataGridConfiguration config) {
    final total = _filteredData.length;
    final selected = _selectedRows.length;
    final labels = config.labels;

    return Container(
      color: config.headerBackgroundColor,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 2),
      child: Row(
        children: [
          Text(
            '${labels.showing} ',
            style: TextStyle(fontSize: 12, color: config.secondaryTextColor),
          ),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: config.primaryColor,
            ),
          ),
          Text(
            ' ${labels.entries}',
            style: TextStyle(fontSize: 12, color: config.secondaryTextColor),
          ),
          if (selected > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: config.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$selected ${'selected'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: config.primaryColor,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (selected > 0)
            GestureDetector(
              onTap: () {
                setState(() => _selectedRows.clear());
                widget.onSelectionChanged?.call([]);
              },
              child: Icon(
                Icons.cancel_outlined,
                size: 16,
                color: config.errorColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList(bool isGrid) {
    final config = widget.controller.configuration;
    final effect = ShimmerEffect(
      baseColor: config.rowBackgroundColor.withOpacity(0.9),
      highlightColor: config.rowBackgroundColor,
      duration: const Duration(milliseconds: 1000),
    );

    if (isGrid) {
      return Skeletonizer(
        enabled: true,
        effect: effect,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: widget.skeletonCount,
          itemBuilder: (_, __) => OmMobileSkeletonCard(
            viewType: widget.viewType,
            configuration: widget.controller.configuration,
          ),
        ),
      );
    }
    return Skeletonizer(
      enabled: true,
      effect: effect,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6, bottom: 12),
        itemCount: widget.skeletonCount,
        itemBuilder: (_, __) => OmMobileSkeletonCard(
          viewType: widget.viewType,
          configuration: widget.controller.configuration,
        ),
      ),
    );
  }

  Widget _buildEmptyState(OmDataGridConfiguration config) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 56,
            color: config.secondaryTextColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            config.labels.noData,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: config.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          if (widget.controller.globalSearchText.isNotEmpty ||
              _internalColumns.any((c) => c.isFiltered))
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: Icon(Icons.cancel_outlined,
                  size: 16, color: config.errorColor),
              label: Text(
                config.labels.clearFilter,
                style: TextStyle(color: config.errorColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(OmDataGridConfiguration config) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: config.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(OmDataGridConfiguration config) {
    final totalPages = _totalPages;
    final current = _currentPage;
    final labels = config.labels;

    final startRow = _sortedData.isEmpty ? 0 : current * _rowsPerPage + 1;
    final endRow = ((current + 1) * _rowsPerPage) > _sortedData.length
        ? _sortedData.length
        : (current + 1) * _rowsPerPage;

    return Container(
      decoration: BoxDecoration(
        color: config.paginationBackgroundColor,
        border: Border(
          top: BorderSide(color: config.gridBorderColor, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${labels.showing} $startRow ${labels.toLabel} $endRow ${labels.ofLabel} ${_sortedData.length} ${labels.entries}',
            style: TextStyle(
              fontSize: 12,
              color: config.paginationTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PaginationButton(
                icon: Icons.keyboard_double_arrow_left_rounded,
                enabled: current > 0,
                config: config,
                onTap: () => setState(() {
                  _currentPage = 0;
                  _rebuildDisplay();
                }),
              ),
              const SizedBox(width: 4),
              _PaginationButton(
                icon: Icons.keyboard_arrow_left_rounded,
                enabled: current > 0,
                config: config,
                onTap: () => setState(() {
                  _currentPage--;
                  _rebuildDisplay();
                }),
              ),
              const SizedBox(width: 12),
              _buildPageNumbers(current, totalPages, config),
              const SizedBox(width: 12),
              _PaginationButton(
                icon: Icons.keyboard_arrow_right_rounded,
                enabled: current < totalPages - 1,
                config: config,
                onTap: () => setState(() {
                  _currentPage++;
                  _rebuildDisplay();
                }),
              ),
              const SizedBox(width: 4),
              _PaginationButton(
                icon: Icons.keyboard_double_arrow_right_rounded,
                enabled: current < totalPages - 1,
                config: config,
                onTap: () => setState(() {
                  _currentPage = totalPages - 1;
                  _rebuildDisplay();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers(
      int current, int totalPages, OmDataGridConfiguration config) {
    const maxButtons = 5;
    int start =
        (current - 2).clamp(0, (totalPages - maxButtons).clamp(0, totalPages));
    int end = (start + maxButtons).clamp(0, totalPages);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = start; i < end; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: i == current
                  ? null
                  : () => setState(() {
                        _currentPage = i;
                        _rebuildDisplay();
                      }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: i == current
                      ? config.paginationSelectedBackgroundColor
                      : config.paginationUnselectedBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: i == current
                        ? config.paginationSelectedForegroundColor
                        : config.paginationUnselectedForegroundColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Pagination helper ──────────────────────────────────────────────────────────

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final OmDataGridConfiguration config;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? config.paginationUnselectedBackgroundColor
              : config.paginationUnselectedBackgroundColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? config.paginationUnselectedForegroundColor
              : config.paginationUnselectedForegroundColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
