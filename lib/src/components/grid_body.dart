import 'package:om_data_grid/src/components/grid_group_header.dart';
import 'package:om_data_grid/src/components/grid_row.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';

class OmGridBody extends StatelessWidget {
  final List<dynamic> flattenedItems;
  final OmDataGridConfiguration configuration;
  final List<OmGridColumnModel> internalColumns;
  final List<double?> columnWidths;
  final Set<String> expandedGroups;
  final Set<Map<String, dynamic>> selectedRows;
  final int? hoveredRowIndex;
  final ScrollController?
      controller; // This is the vertical controller for the list
  final ScrollController verticalScrollController;
  final ScrollController?
      horizontalScrollController; // Added for horizontal virtualization
  final List<int>? visibleIndicesToRender;
  final bool showScrollbar;
  final String globalSearchText;
  final bool isEditing;
  final bool isScrolling;

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
  final void Function(int oldIndex, int newIndex)? onRowReorder;

  const OmGridBody({
    super.key,
    required this.flattenedItems,
    required this.configuration,
    required this.internalColumns,
    required this.columnWidths,
    required this.expandedGroups,
    required this.selectedRows,
    required this.hoveredRowIndex,
    required this.controller,
    required this.verticalScrollController,
    this.horizontalScrollController, // Optional, only for segments that scroll horizontally
    required this.onToggleGroup,
    required this.onRowTap,
    required this.onCellTapDown,
    required this.onCellPanUpdate,
    required this.onCellPanEnd,
    required this.isCellSelected,
    required this.onShowContextMenu,
    required this.onHoverChanged,
    this.onRowReorder,
    required this.visibleIndicesToRender,
    required this.globalSearchText,
    this.showScrollbar = false,
    this.isEditing = false,
    this.isScrolling = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = flattenedItems.length;

    int frozenTopCount = configuration.frozenRowCount;
    int frozenBottomCount = configuration.footerFrozenRowCount;

    if (frozenTopCount + frozenBottomCount > totalItems) {
      frozenTopCount = totalItems;
      frozenBottomCount = 0;
    }

    final bool isSticky =
        configuration.frozenPaneScrollMode == OmFrozenPaneScrollMode.sticky;

    // Use Iterable instead of toList() to avoid eager copying if possible
    final Iterable<dynamic> topRows = flattenedItems.take(frozenTopCount);
    final Iterable<dynamic> middleItems;

    if (isSticky) {
      middleItems = flattenedItems;
    } else {
      if (totalItems >= (frozenTopCount + frozenBottomCount)) {
        middleItems = flattenedItems
            .skip(frozenTopCount)
            .take(totalItems - frozenTopCount - frozenBottomCount);
      } else {
        middleItems = flattenedItems.skip(frozenTopCount);
      }
    }

    final Iterable<dynamic> bottomRows =
        (totalItems >= (frozenTopCount + frozenBottomCount))
            ? flattenedItems.skip(totalItems - frozenBottomCount)
            : [];

    Widget buildList() {
      final middleItemsList = middleItems.toList(); // Only copy once here
      if (configuration.allowRowReordering &&
          onRowReorder != null &&
          configuration.frozenRowCount == 0 &&
          configuration.footerFrozenRowCount == 0 &&
          !configuration.shrinkWrapRows) {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: showScrollbar),
          child: ReorderableListView.builder(
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            scrollController: controller,
            // ReorderableListView uses its own physics or inherits
            // physics: const ClampingScrollPhysics(),
            itemCount: middleItemsList.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              // If there are frozen rows (though we checked == 0 above), add offset
              final int offset = frozenTopCount;
              onRowReorder!(oldIndex + offset, newIndex + offset);
            },
            itemExtent: configuration.rowHeight,
            itemBuilder: (context, index) {
              // ReorderableListView requires a key. content has ValueKey(row).
              // We need to wrap with ReorderableDragStartListener if we want custom handle,
              // but default works with whole item.
              final item = middleItemsList[index];
              return Container(
                key: ValueKey(
                  item,
                ), // Important: Key is required for ReorderableListView
                child: _buildRowOrGroup(
                  context,
                  item,
                  isSticky ? index : frozenTopCount + index,
                  visibleIndicesToRender: visibleIndicesToRender,
                ),
              );
            },
          ),
        );
      }

      if (configuration.shrinkWrapRows) {
        return Column(
          children: List.generate(
            middleItemsList.length,
            (i) => _buildRowOrGroup(
              context,
              middleItemsList[i],
              isSticky ? i : frozenTopCount + i,
              visibleIndicesToRender: visibleIndicesToRender,
            ),
          ),
        );
      } else {
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: showScrollbar),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            controller: controller,
            physics: const ClampingScrollPhysics(),
            itemCount: middleItemsList.length,
            itemExtent: configuration.rowHeight,
            cacheExtent: configuration.cacheExtent,
            itemBuilder: (context, index) {
              return _buildRowOrGroup(
                context,
                middleItemsList[index],
                isSticky ? index : frozenTopCount + index,
                visibleIndicesToRender: visibleIndicesToRender,
              );
            },
          ),
        );
      }
    }

    if (isSticky && !configuration.shrinkWrapRows) {
      final Widget listWidget = buildList();
      final topRowsList = topRows.toList();
      final bottomRowsList = bottomRows.toList();

      return AnimatedBuilder(
        animation: verticalScrollController,
        builder: (context, _) {
          final double scrollY = verticalScrollController.hasClients
              ? verticalScrollController.offset
              : 0.0;

          final stickyTopRows = <dynamic>[];
          if (topRowsList.isNotEmpty) {
            double thresholdY =
                (topRowsList.length - 1) * configuration.rowHeight;
            if (scrollY > thresholdY) {
              stickyTopRows.add(topRowsList.last);
            }
          }

          final stickyBottomRows = <dynamic>[];

          return LayoutBuilder(
            builder: (context, box) {
              final double vh = box.maxHeight;

              if (bottomRowsList.isNotEmpty) {
                int boundaryIdx = totalItems - bottomRowsList.length;
                double rowBottomEdge =
                    (boundaryIdx + 1) * configuration.rowHeight;

                if (scrollY + vh < rowBottomEdge) {
                  stickyBottomRows.add(bottomRowsList.first);
                }
              }

              return Stack(
                children: [
                  listWidget,
                  if (stickyTopRows.isNotEmpty)
                    PositionedDirectional(
                      top: 0,
                      start: 0,
                      end: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: configuration.gridBackgroundColor,
                          boxShadow: configuration.frozenPaneElevation > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius:
                                        configuration.frozenPaneElevation,
                                    offset: Offset(
                                      0,
                                      configuration.frozenPaneElevation / 2,
                                    ),
                                  ),
                                ]
                              : null,
                          border: Border(
                            bottom: configuration.frozenPaneBorderSide ??
                                BorderSide.none,
                          ),
                        ),
                        child: _buildRowOrGroup(
                          context,
                          stickyTopRows.first,
                          topRowsList.length - 1,
                          visibleIndicesToRender: visibleIndicesToRender,
                        ),
                      ),
                    ),
                  if (stickyBottomRows.isNotEmpty)
                    PositionedDirectional(
                      bottom: 0,
                      start: 0,
                      end: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: configuration.gridBackgroundColor,
                          boxShadow: configuration.frozenPaneElevation > 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius:
                                        configuration.frozenPaneElevation,
                                    offset: Offset(
                                      0,
                                      -configuration.frozenPaneElevation / 2,
                                    ),
                                  ),
                                ]
                              : null,
                          border: Border(
                            top: configuration.frozenPaneBorderSide ??
                                BorderSide.none,
                          ),
                        ),
                        child: _buildRowOrGroup(
                          context,
                          stickyBottomRows.first,
                          totalItems - bottomRowsList.length,
                          visibleIndicesToRender: visibleIndicesToRender,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    }

    return buildList();
  }

  Widget _buildRowOrGroup(
    BuildContext context,
    dynamic item,
    int index, {
    List<int>? visibleIndicesToRender,
  }) {
    if (item is Map && item['isGroup'] == true) {
      final group = Map<String, dynamic>.from(item);
      return MouseRegion(
        onEnter: (_) {
          onHoverChanged(index);
          // Selection logic for groups if needed, but usually only rows
        },
        onExit: (_) {
          onHoverChanged(null);
        },
        child: GridGroupHeader(
          group: group,
          config: configuration,
          isExpanded: expandedGroups.contains(group['groupId']),
          isHovered: hoveredRowIndex == index,
          onTap: () => onToggleGroup(group['groupId']),
        ),
      );
    }
    return _buildRow(
      context,
      item as Map<String, dynamic>,
      index,
      visibleIndicesToRender: visibleIndicesToRender,
    );
  }

  Widget _buildRow(
    BuildContext context,
    Map<String, dynamic> row,
    int index, {
    List<int>? visibleIndicesToRender,
  }) {
    final level = row['level'] as int? ?? 0;
    return MouseRegion(
      onEnter: (_) {
        onHoverChanged(index);
      },
      onExit: (_) {
        onHoverChanged(null);
      },
      child: OmGridRow(
        key: ValueKey(row),
        rowIndex: index,
        columns: internalColumns,
        row: row,
        globalSearchText: globalSearchText,
        configuration: configuration,
        columnWidths: columnWidths,
        isSelected: selectedRows.contains(row),
        isHovered: hoveredRowIndex == index,
        onTap: () => onRowTap(row),
        onCellTapDown: (colIndex) => onCellTapDown(colIndex, index),
        onCellPanUpdate: (colIndex) => onCellPanUpdate(colIndex, index),
        onCellPanEnd: onCellPanEnd,
        isCellSelected: (colIndex) => isCellSelected(colIndex, index),
        isEditing: isEditing,
        isScrolling: isScrolling,
        level: level,
        horizontalScrollController: horizontalScrollController,
        visibleIndicesToRender: visibleIndicesToRender,
        onSecondaryTapDown: (colIndex, details) {
          onShowContextMenu(context, details.globalPosition, index, colIndex);
        },
      ),
    );
  }
}
