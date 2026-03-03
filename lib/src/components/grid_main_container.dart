import 'dart:async';
import 'package:om_data_grid/src/enums/column_pinning_enum.dart';
import 'package:om_data_grid/src/components/grid_aggregation_row.dart';
import 'package:om_data_grid/src/components/grid_body.dart';
import 'package:om_data_grid/src/components/grid_header.dart';
import 'package:om_data_grid/src/components/quick_search_bar.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/datagrid_utils.dart';
import 'package:flutter/material.dart';

class GridMainContainer extends StatefulWidget {
  final OmDataGridController controller;
  final List<OmGridColumnModel> internalColumns;
  final List<double?> columnWidths;
  final List<Map<String, dynamic>> filterDatasource;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;
  final ScrollController frozenLeftScrollController;
  final ScrollController frozenRightScrollController;
  final BoxConstraints constraints;
  final bool isSidePanelExpanded;

  // Props for OmGridBody
  final List<dynamic> flattenedItems;
  final Set<String> expandedGroups;
  final Set<Map<String, dynamic>> selectedRows;
  final int? hoveredRowIndex;
  final void Function(String groupId) onToggleGroup;
  final void Function(Map<String, dynamic> row) onRowTap;
  final void Function(int colIndex, int rowIndex) onCellTapDown;
  final void Function(int colIndex, int rowIndex) onCellPanUpdate;
  final VoidCallback onCellPanEnd;
  final bool Function(int colIndex, int rowIndex) isCellSelected;
  final void Function(
    BuildContext context,
    Offset position,
    int rowIndex, [
    int? colIndex,
  ]) onShowContextMenu;
  final void Function(int? index) onHoverChanged;
  final void Function(int index, double newWidth) onColumnResize;
  final void Function(dynamic newData) onSearch;
  final void Function(String columnKey, {bool? ascending}) onSort;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int oldIndex, int newIndex)? onRowReorder;
  final void Function(String key, String value) onQuickSearchChanged;
  final String? sortColumnKey;
  final bool? sortAscending;
  final bool isEditing;

  const GridMainContainer({
    super.key,
    required this.controller,
    required this.internalColumns,
    required this.columnWidths,
    required this.filterDatasource,
    required this.horizontalScrollController,
    required this.verticalScrollController,
    required this.frozenLeftScrollController,
    required this.frozenRightScrollController,
    required this.constraints,
    required this.isSidePanelExpanded,
    required this.flattenedItems,
    required this.expandedGroups,
    required this.selectedRows,
    required this.hoveredRowIndex,
    required this.onToggleGroup,
    required this.onRowTap,
    required this.onCellTapDown,
    required this.onCellPanUpdate,
    required this.onCellPanEnd,
    required this.isCellSelected,
    required this.onShowContextMenu,
    required this.onHoverChanged,
    required this.onColumnResize,
    required this.onSearch,
    required this.onSort,
    required this.onReorder,
    this.onRowReorder,
    required this.onQuickSearchChanged,
    this.sortColumnKey,
    this.sortAscending,
    this.isEditing = false,
  });

  @override
  State<GridMainContainer> createState() => _GridMainContainerState();
}

class _GridMainContainerState extends State<GridMainContainer> {
  bool _isScrolling = false;
  Timer? _scrollEndTimer;
  final ValueNotifier<bool> _vScrollbarVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(GridMainContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
    _vScrollbarVisible.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
      _scrollEndTimer?.cancel();
    } else if (notification is ScrollUpdateNotification) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    } else if (notification is ScrollEndNotification) {
      _scrollEndTimer?.cancel();
      _scrollEndTimer = Timer(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final config = widget.controller.configuration;
    final sidePanelConfig = config.sidePanelConfiguration;
    double sidePanelWidth = sidePanelConfig.collapsedWidth;
    if (widget.isSidePanelExpanded) {
      sidePanelWidth += sidePanelConfig.expandedWidth;
    }

    final gridConstraints = BoxConstraints.loose(
      Size(
        widget.constraints.maxWidth - sidePanelWidth,
        widget.constraints.maxHeight,
      ),
    );

    final currentColumnWidths = OmDatagridUtils.calculateColumnWidths(
      columns: widget.internalColumns,
      data: widget.filterDatasource,
      configuration: config,
      constraints: gridConstraints,
      previousWidths: widget.columnWidths,
    );

    final visibleIndices = <int>[];
    for (int i = 0; i < widget.internalColumns.length; i++) {
      if (widget.internalColumns[i].isVisible) {
        visibleIndices.add(i);
      }
    }

    final frozenCount = config.frozenColumnCount;
    final footerFrozenCount = config.footerFrozenColumnCount;

    final leftIndices = <int>[];
    final rightIndices = <int>[];
    final otherIndices = <int>[];

    final legacyLeft = visibleIndices.take(frozenCount).toSet();
    final legacyRight =
        visibleIndices.skip(visibleIndices.length - footerFrozenCount).toSet();

    for (var i in visibleIndices) {
      final col = widget.internalColumns[i];
      if (col.pinning == OmColumnPinning.start || legacyLeft.contains(i)) {
        leftIndices.add(i);
      } else if (col.pinning == OmColumnPinning.end ||
          legacyRight.contains(i)) {
        rightIndices.add(i);
      } else {
        otherIndices.add(i);
      }
    }

    final bool isSticky =
        config.frozenPaneScrollMode == OmFrozenPaneScrollMode.sticky;

    final middleIndices = isSticky ? visibleIndices : otherIndices;

    double leftWidth = leftIndices.fold(
      0.0,
      (sum, i) => sum + (currentColumnWidths[i] ?? 0),
    );
    double rightWidth = rightIndices.fold(
      0.0,
      (sum, i) => sum + (currentColumnWidths[i] ?? 0),
    );
    double middleTotalWidth = middleIndices.fold(
      0.0,
      (sum, i) => sum + (currentColumnWidths[i] ?? 0),
    );

    // Builds header + optional quick-search row for a given set of column indices.
    Widget buildHeader({
      required List<int> indices,
      bool isMiddle = false,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OmGridHeader(
            controller: widget.controller,
            columns: widget.internalColumns,
            visibleIndicesToRender: indices,
            configuration: config,
            columnWidths: currentColumnWidths,
            onColumnResize: widget.onColumnResize,
            orgData: widget.controller.data,
            srchData: widget.filterDatasource,
            globalSearchText: widget.controller.globalSearchText,
            onSearch: widget.onSearch,
            sortColumnKey: widget.sortColumnKey,
            sortAscending: widget.sortAscending,
            onSort: widget.onSort,
            onReorder: widget.onReorder,
            horizontalScrollController:
                isMiddle ? widget.horizontalScrollController : null,
          ),
          if (config.showQuickSearch)
            QuickSearchBar(
              columns: widget.internalColumns,
              visibleIndicesToRender: indices,
              columnWidths: currentColumnWidths,
              configuration: config,
              onSearchChanged: widget.onQuickSearchChanged,
            ),
        ],
      );
    }

    // Builds the full column (header + body + aggregation) for frozen segments.
    Widget buildPart({
      required List<int> indices,
      ScrollController? verticalController,
      bool isMiddle = false,
    }) {
      if (indices.isEmpty && !isMiddle) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            config.shrinkWrapRows ? MainAxisSize.min : MainAxisSize.max,
        children: [
          buildHeader(indices: indices, isMiddle: isMiddle),
          if (config.shrinkWrapRows)
            OmGridBody(
              flattenedItems: widget.flattenedItems,
              configuration: config,
              internalColumns: widget.internalColumns,
              columnWidths: currentColumnWidths,
              expandedGroups: widget.expandedGroups,
              selectedRows: widget.selectedRows,
              hoveredRowIndex: widget.hoveredRowIndex,
              controller: verticalController,
              verticalScrollController: widget.verticalScrollController,
              horizontalScrollController:
                  isMiddle ? widget.horizontalScrollController : null,
              onToggleGroup: widget.onToggleGroup,
              onRowTap: widget.onRowTap,
              onCellTapDown: widget.onCellTapDown,
              onCellPanUpdate: widget.onCellPanUpdate,
              onCellPanEnd: widget.onCellPanEnd,
              isCellSelected: widget.isCellSelected,
              onShowContextMenu: widget.onShowContextMenu,
              onHoverChanged: widget.onHoverChanged,
              visibleIndicesToRender: indices,
              showScrollbar: false,
              globalSearchText: widget.controller.globalSearchText,
              onRowReorder: widget.onRowReorder,
              isEditing: widget.isEditing,
              isScrolling: _isScrolling,
            )
          else
            Expanded(
              child: OmGridBody(
                flattenedItems: widget.flattenedItems,
                configuration: config,
                internalColumns: widget.internalColumns,
                columnWidths: currentColumnWidths,
                expandedGroups: widget.expandedGroups,
                selectedRows: widget.selectedRows,
                hoveredRowIndex: widget.hoveredRowIndex,
                controller: verticalController,
                verticalScrollController: widget.verticalScrollController,
                horizontalScrollController:
                    isMiddle ? widget.horizontalScrollController : null,
                onToggleGroup: widget.onToggleGroup,
                onRowTap: widget.onRowTap,
                onCellTapDown: widget.onCellTapDown,
                onCellPanUpdate: widget.onCellPanUpdate,
                onCellPanEnd: widget.onCellPanEnd,
                isCellSelected: widget.isCellSelected,
                onShowContextMenu: widget.onShowContextMenu,
                onHoverChanged: widget.onHoverChanged,
                visibleIndicesToRender: indices,
                showScrollbar: false,
                globalSearchText: widget.controller.globalSearchText,
                onRowReorder: widget.onRowReorder,
                isEditing: widget.isEditing,
                isScrolling: _isScrolling,
              ),
            ),
          GridAggregationRow(
            controller: widget.controller,
            columns: widget.internalColumns,
            columnWidths: currentColumnWidths,
            visibleIndices: indices,
          ),
        ],
      );
    }

    Widget buildLeftSegment(
      double width,
      List<int> indices,
    ) {
      return Container(
        width: width,
        decoration: BoxDecoration(
          color: config.gridBackgroundColor,
          boxShadow: config.frozenPaneElevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: config.frozenPaneElevation,
                    offset: Offset(
                      isRTL
                          ? -config.frozenPaneElevation / 2
                          : config.frozenPaneElevation / 2,
                      0,
                    ),
                  ),
                ]
              : null,
          border: BorderDirectional(
            end: config.frozenPaneBorderSide ?? BorderSide.none,
          ),
        ),
        child: buildPart(
          indices: indices,
          verticalController: widget.frozenLeftScrollController,
        ),
      );
    }

    Widget buildRightSegment(
      double width,
      List<int> indices,
    ) {
      return Container(
        width: width,
        decoration: BoxDecoration(
          color: config.gridBackgroundColor,
          boxShadow: config.frozenPaneElevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: config.frozenPaneElevation,
                    offset: Offset(
                      isRTL
                          ? config.frozenPaneElevation / 2
                          : -config.frozenPaneElevation / 2,
                      0,
                    ),
                  ),
                ]
              : null,
          border: BorderDirectional(
            start: config.frozenPaneBorderSide ?? BorderSide.none,
          ),
        ),
        child: buildPart(
          indices: indices,
          verticalController: widget.frozenRightScrollController,
        ),
      );
    }

    Widget buildMiddleSegment(
      double leftWidth,
      double rightWidth,
      double middleTotalWidth,
      List<int> middleIndices,
    ) {
      final double availableWidth = isSticky
          ? gridConstraints.maxWidth
          : (gridConstraints.maxWidth - leftWidth - rightWidth);

      // In non-shrinkWrap mode the vertical scrollbar strip sits outside the
      // SingleChildScrollView and takes vScrollbarWidth px, so we must subtract
      // it from the available viewport width — otherwise contentWidth > viewport
      // by exactly vScrollbarWidth and the horizontal scrollbar never hides.
      // We only subtract if the v-scrollbar is actually visible.
      const double vScrollbarWidth = 12.0;
      const double hScrollbarHeight = 12.0;
      final bool vScrollbarShown = _vScrollbarVisible.value;
      final double effectiveAvailableWidth = config.shrinkWrapRows
          ? availableWidth
          : (vScrollbarShown
              ? availableWidth - vScrollbarWidth
              : availableWidth);

      final double contentWidth = config.shrinkWrapColumns
          ? middleTotalWidth
          : (middleTotalWidth < effectiveAvailableWidth
              ? effectiveAvailableWidth
              : middleTotalWidth);

      if (config.shrinkWrapRows) {
        // shrinkWrap: keep original single-scroll layout
        return Scrollbar(
          thumbVisibility: true,
          controller: widget.horizontalScrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.horizontalScrollController,
            child: SizedBox(
              width: contentWidth,
              child: buildPart(
                indices: middleIndices,
                verticalController: widget.verticalScrollController,
                isMiddle: true,
              ),
            ),
          ),
        );
      }

      // Non-shrinkWrap layout:
      // ┌─────────────────────────────────┬────┐
      // │  SingleChildScrollView (horiz)  │    │
      // │  ┌──────────────────────────┐   │ V  │
      // │  │ header                   │   │ s  │
      // │  ├──────────────────────────┤   │ c  │
      // │  │ body (ListView)          │   │ r  │
      // │  ├──────────────────────────┤   │ l  │
      // │  │ aggregation              │   │    │
      // │  └──────────────────────────┘   │    │
      // ├─────────────────────────────────┘    │
      // │  H scrollbar (custom painted)        │
      // └──────────────────────────────────────┘
      //
      // The vertical scrollbar is in the OUTER Stack (right column),
      // completely outside the horizontal SingleChildScrollView, so it
      // never moves when the user scrolls left/right.

      // Safe colour helper — never calls resolve() to avoid web JS-null crash.
      Color safeTrackColor() => Colors.black12;
      Color safeThumbColor() => Colors.grey;

      // ── Vertical scrollbar (custom painted, outside horiz scroll) ──────────
      Widget buildVScrollbar() {
        return LayoutBuilder(
          builder: (context, box) {
            final double trackH = box.maxHeight;
            return AnimatedBuilder(
              animation: widget.verticalScrollController,
              builder: (context, _) {
                try {
                  final vc = widget.verticalScrollController;
                  if (!vc.hasClients) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_vScrollbarVisible.value) {
                        _vScrollbarVisible.value = false;
                      }
                    });
                    return const SizedBox.shrink();
                  }
                  final pos = vc.position;
                  final double? viewport = pos.viewportDimension as double?;
                  final double? maxExt = pos.maxScrollExtent as double?;
                  final double? pixels = pos.pixels as double?;
                  if (viewport == null ||
                      maxExt == null ||
                      pixels == null ||
                      maxExt < 5 ||
                      viewport <= 0 ||
                      trackH <= 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_vScrollbarVisible.value) {
                        _vScrollbarVisible.value = false;
                      }
                    });
                    return const SizedBox.shrink();
                  }
                  final double vf = viewport / (maxExt + viewport);
                  if (vf >= 1.0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_vScrollbarVisible.value) {
                        _vScrollbarVisible.value = false;
                      }
                    });
                    return const SizedBox.shrink();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_vScrollbarVisible.value) {
                      _vScrollbarVisible.value = true;
                    }
                  });
                  final double thumbH = (vf * trackH).clamp(30.0, trackH);
                  final double thumbRange = trackH - thumbH;
                  final double thumbTop = (pixels / maxExt) * thumbRange;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (d) {
                      try {
                        if (!vc.hasClients) return;
                        final curMax =
                            vc.position.maxScrollExtent as double? ?? 0.0;
                        final ratio = curMax / thumbRange;
                        vc.jumpTo(
                          (vc.offset + d.delta.dy * ratio).clamp(0.0, curMax),
                        );
                      } catch (_) {}
                    },
                    child: SizedBox(
                      width: vScrollbarWidth,
                      height: trackH,
                      child: CustomPaint(
                        painter: _VerticalScrollbarPainter(
                          thumbTop: thumbTop,
                          thumbHeight: thumbH,
                          trackWidth: vScrollbarWidth,
                          radius: 2,
                          trackColor: safeTrackColor(),
                          thumbColor: safeThumbColor(),
                        ),
                      ),
                    ),
                  );
                } catch (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_vScrollbarVisible.value) {
                      _vScrollbarVisible.value = false;
                    }
                  });
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      }

      // ── Horizontal scrollbar (custom painted, outside horiz scroll) ─────────
      Widget buildHScrollbar() {
        return LayoutBuilder(
          builder: (context, box) {
            final double trackW = box.maxWidth;
            return AnimatedBuilder(
              animation: widget.horizontalScrollController,
              builder: (context, _) {
                try {
                  final hc = widget.horizontalScrollController;
                  if (!hc.hasClients) return const SizedBox.shrink();
                  final pos = hc.position;
                  final double? viewport = pos.viewportDimension as double?;
                  final double? maxExt = pos.maxScrollExtent as double?;
                  final double? pixels = pos.pixels as double?;
                  if (viewport == null ||
                      maxExt == null ||
                      pixels == null ||
                      maxExt < 15 ||
                      viewport <= 0 ||
                      trackW <= 0) {
                    return const SizedBox.shrink();
                  }
                  final double vf = viewport / (maxExt + viewport);
                  if (vf >= 1.0) return const SizedBox.shrink();
                  final double thumbW = (vf * trackW).clamp(30.0, trackW);
                  final double thumbRange = trackW - thumbW;
                  final double thumbLeft = (pixels / maxExt) * thumbRange;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (d) {
                      try {
                        if (!hc.hasClients) return;
                        final curMax =
                            hc.position.maxScrollExtent as double? ?? 0.0;
                        final ratio = curMax / thumbRange;
                        hc.jumpTo(
                          (hc.offset + d.delta.dx * ratio).clamp(0.0, curMax),
                        );
                      } catch (_) {}
                    },
                    child: SizedBox(
                      width: trackW,
                      height: hScrollbarHeight,
                      child: CustomPaint(
                        painter: _HorizontalScrollbarPainter(
                          thumbLeft: thumbLeft,
                          thumbWidth: thumbW,
                          trackHeight: hScrollbarHeight,
                          radius: 2,
                          trackColor: safeTrackColor(),
                          thumbColor: safeThumbColor(),
                        ),
                      ),
                    ),
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      }

      // ── Main layout ─────────────────────────────────────────────────────────
      // Wrap in ValueListenableBuilder so the layout recomputes when
      // v-scrollbar visibility changes (affects effectiveAvailableWidth).
      return ValueListenableBuilder<bool>(
          valueListenable: _vScrollbarVisible,
          builder: (context, _, __) => Stack(
                children: [
                  // Left part: horizontal scroll area + h-scrollbar below it.
                  // Right part: vertical scrollbar strip.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Scrollable content (header + body + aggregation).
                            Expanded(
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: false),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: widget.horizontalScrollController,
                                  child: SizedBox(
                                    width: contentWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        buildHeader(
                                          indices: middleIndices,
                                          isMiddle: true,
                                        ),
                                        Expanded(
                                          child: ScrollConfiguration(
                                            behavior:
                                                ScrollConfiguration.of(context)
                                                    .copyWith(
                                                        scrollbars: false),
                                            child: OmGridBody(
                                              flattenedItems:
                                                  widget.flattenedItems,
                                              configuration: config,
                                              internalColumns:
                                                  widget.internalColumns,
                                              columnWidths: currentColumnWidths,
                                              expandedGroups:
                                                  widget.expandedGroups,
                                              selectedRows: widget.selectedRows,
                                              hoveredRowIndex:
                                                  widget.hoveredRowIndex,
                                              controller: widget
                                                  .verticalScrollController,
                                              verticalScrollController: widget
                                                  .verticalScrollController,
                                              horizontalScrollController: widget
                                                  .horizontalScrollController,
                                              onToggleGroup:
                                                  widget.onToggleGroup,
                                              onRowTap: widget.onRowTap,
                                              onCellTapDown:
                                                  widget.onCellTapDown,
                                              onCellPanUpdate:
                                                  widget.onCellPanUpdate,
                                              onCellPanEnd: widget.onCellPanEnd,
                                              isCellSelected:
                                                  widget.isCellSelected,
                                              onShowContextMenu:
                                                  widget.onShowContextMenu,
                                              onHoverChanged:
                                                  widget.onHoverChanged,
                                              visibleIndicesToRender:
                                                  middleIndices,
                                              showScrollbar: false,
                                              globalSearchText: widget
                                                  .controller.globalSearchText,
                                              onRowReorder: widget.onRowReorder,
                                              isEditing: widget.isEditing,
                                              isScrolling: _isScrolling,
                                            ),
                                          ),
                                        ),
                                        GridAggregationRow(
                                          controller: widget.controller,
                                          columns: widget.internalColumns,
                                          columnWidths: currentColumnWidths,
                                          visibleIndices: middleIndices,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Vertical scrollbar — collapses to 0 width when not needed.
                            ValueListenableBuilder<bool>(
                              valueListenable: _vScrollbarVisible,
                              builder: (context, visible, _) {
                                return SizedBox(
                                  width: visible ? vScrollbarWidth : 0,
                                  child: buildVScrollbar(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Horizontal scrollbar — full width minus v-scrollbar.
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: vScrollbarShown ? vScrollbarWidth : 0,
                        ),
                        child: buildHScrollbar(),
                      ),
                    ],
                  ),
                ],
              ));
    }

    Widget buildStickyBody() {
      return AnimatedBuilder(
        animation: widget.horizontalScrollController,
        builder: (context, child) {
          final double scrollX = widget.horizontalScrollController.hasClients
              ? widget.horizontalScrollController.offset
              : 0.0;

          double thresholdLeftX = 0;
          for (int i = 0; i < leftIndices.length - 1; i++) {
            thresholdLeftX += (currentColumnWidths[leftIndices[i]] ?? 0);
          }

          final stickyLeftIndices = <int>[];
          double stickyLeftWidth = 0;
          if (leftIndices.isNotEmpty && scrollX > thresholdLeftX) {
            final idx = leftIndices.last;
            stickyLeftIndices.add(idx);
            stickyLeftWidth = currentColumnWidths[idx] ?? 0;
          }

          double totalGridWidth = visibleIndices.fold(
            0.0,
            (sum, i) => sum + (currentColumnWidths[i] ?? 0),
          );
          final double viewportWidth = gridConstraints.maxWidth;

          double rightBoundaryOffset = totalGridWidth;
          for (int i = rightIndices.length - 1; i > 0; i--) {
            rightBoundaryOffset -= (currentColumnWidths[rightIndices[i]] ?? 0);
          }

          final stickyRightIndices = <int>[];
          double stickyRightWidth = 0;
          if (rightIndices.isNotEmpty) {
            final idx = rightIndices.first;
            final colWidth = currentColumnWidths[idx] ?? 0;
            if (scrollX + viewportWidth < rightBoundaryOffset) {
              stickyRightIndices.add(idx);
              stickyRightWidth = colWidth;
            }
          }

          return Stack(
            children: [
              buildMiddleSegment(
                0,
                0,
                middleTotalWidth,
                middleIndices,
              ),
              if (stickyLeftIndices.isNotEmpty)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: buildLeftSegment(
                    stickyLeftWidth,
                    stickyLeftIndices,
                  ),
                ),
              if (stickyRightIndices.isNotEmpty)
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  bottom: 0,
                  child: buildRightSegment(
                    stickyRightWidth,
                    stickyRightIndices,
                  ),
                ),
            ],
          );
        },
      );
    }

    Widget buildNonStickyBody() {
      return Row(
        children: [
          if (leftIndices.isNotEmpty)
            buildLeftSegment(
              leftWidth,
              leftIndices,
            ),
          Expanded(
            child: buildMiddleSegment(
              leftWidth,
              rightWidth,
              middleTotalWidth,
              middleIndices,
            ),
          ),
          if (rightIndices.isNotEmpty)
            buildRightSegment(
              rightWidth,
              rightIndices,
            ),
        ],
      );
    }

    final gridBody = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!config.shrinkWrapRows)
                Expanded(
                  child: isSticky ? buildStickyBody() : buildNonStickyBody(),
                )
              else
                isSticky ? buildStickyBody() : buildNonStickyBody(),
            ],
          ),
        ),
      ],
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScrollNotification(notification);
        return false;
      },
      child: gridBody,
    );
  }
}

/// Paints a horizontal scrollbar track + thumb without requiring a Scrollable
/// child, so it can share a [ScrollController] that already has one position.
class _HorizontalScrollbarPainter extends CustomPainter {
  final double thumbLeft;
  final double thumbWidth;
  final double trackHeight;
  final double radius;
  final Color trackColor;
  final Color thumbColor;

  const _HorizontalScrollbarPainter({
    required this.thumbLeft,
    required this.thumbWidth,
    required this.trackHeight,
    required this.radius,
    required this.trackColor,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()..color = trackColor;
    final Paint thumbPaint = Paint()..color = thumbColor;
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, trackHeight, Radius.circular(radius)),
      trackPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        thumbLeft,
        0,
        thumbLeft + thumbWidth,
        trackHeight,
        Radius.circular(radius),
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_HorizontalScrollbarPainter old) =>
      old.thumbLeft != thumbLeft ||
      old.thumbWidth != thumbWidth ||
      old.trackColor != trackColor ||
      old.thumbColor != thumbColor;
}

/// Paints a vertical scrollbar track + thumb without requiring a Scrollable
/// child, so it can be used as an overlay independent of the scroll tree.
class _VerticalScrollbarPainter extends CustomPainter {
  final double thumbTop;
  final double thumbHeight;
  final double trackWidth;
  final double radius;
  final Color trackColor;
  final Color thumbColor;

  const _VerticalScrollbarPainter({
    required this.thumbTop,
    required this.thumbHeight,
    required this.trackWidth,
    required this.radius,
    required this.trackColor,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()..color = trackColor;
    final Paint thumbPaint = Paint()..color = thumbColor;
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, trackWidth, size.height, Radius.circular(radius)),
      trackPaint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        thumbTop,
        trackWidth,
        thumbTop + thumbHeight,
        Radius.circular(radius),
      ),
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_VerticalScrollbarPainter old) =>
      old.thumbTop != thumbTop ||
      old.thumbHeight != thumbHeight ||
      old.trackColor != trackColor ||
      old.thumbColor != thumbColor;
}
