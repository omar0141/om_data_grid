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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollEndTimer?.cancel();
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

    Widget buildPart({
      required List<int> indices,
      ScrollController? verticalController,
      bool isMiddle = false,
      bool showVerticalScrollbar = false,
    }) {
      if (indices.isEmpty && !isMiddle) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            config.shrinkWrapRows ? MainAxisSize.min : MainAxisSize.max,
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
              showScrollbar: showVerticalScrollbar,
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
                showScrollbar: showVerticalScrollbar,
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
      List<int> indices, {
      bool showVerticalScrollbar = false,
    }) {
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
          showVerticalScrollbar: showVerticalScrollbar,
        ),
      );
    }

    Widget buildRightSegment(
      double width,
      List<int> indices, {
      bool showVerticalScrollbar = false,
    }) {
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
          showVerticalScrollbar: showVerticalScrollbar,
        ),
      );
    }

    Widget buildMiddleSegment(
      double leftWidth,
      double rightWidth,
      double middleTotalWidth,
      List<int> middleIndices, {
      bool showVerticalScrollbar = false,
    }) {
      final double availableWidth = isSticky
          ? gridConstraints.maxWidth
          : (gridConstraints.maxWidth - leftWidth - rightWidth);

      return Scrollbar(
        thumbVisibility: true,
        controller: widget.horizontalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: widget.horizontalScrollController,
          child: SizedBox(
            width: config.shrinkWrapColumns
                ? middleTotalWidth
                : (middleTotalWidth < availableWidth
                    ? availableWidth
                    : middleTotalWidth),
            child: buildPart(
              indices: middleIndices,
              verticalController: widget.verticalScrollController,
              isMiddle: true,
              showVerticalScrollbar: showVerticalScrollbar,
            ),
          ),
        ),
      );
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

          final bool showInRight =
              rightIndices.isNotEmpty || stickyRightIndices.isNotEmpty;

          return Stack(
            children: [
              buildMiddleSegment(
                0,
                0,
                middleTotalWidth,
                middleIndices,
                showVerticalScrollbar: showInRight,
              ),
              if (stickyLeftIndices.isNotEmpty)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: buildLeftSegment(
                    stickyLeftWidth,
                    stickyLeftIndices,
                    showVerticalScrollbar: false,
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
                    showVerticalScrollbar: true,
                  ),
                ),
            ],
          );
        },
      );
    }

    Widget buildNonStickyBody() {
      final bool showInRight = rightIndices.isNotEmpty;
      return Row(
        children: [
          if (leftIndices.isNotEmpty)
            buildLeftSegment(
              leftWidth,
              leftIndices,
              showVerticalScrollbar: false,
            ),
          Expanded(
            child: buildMiddleSegment(
              leftWidth,
              rightWidth,
              middleTotalWidth,
              middleIndices,
              showVerticalScrollbar: !showInRight,
            ),
          ),
          if (rightIndices.isNotEmpty)
            buildRightSegment(
              rightWidth,
              rightIndices,
              showVerticalScrollbar: true,
            ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScrollNotification(notification);
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!config.shrinkWrapRows)
            Expanded(child: isSticky ? buildStickyBody() : buildNonStickyBody())
          else
            isSticky ? buildStickyBody() : buildNonStickyBody(),
        ],
      ),
    );
  }
}
