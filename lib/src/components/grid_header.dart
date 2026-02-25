import 'package:om_data_grid/src/components/grid_column_menu.dart';
import 'package:om_data_grid/src/components/grid_filter/grid_filter.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:om_data_grid/src/enums/grid_border_visibility_enum.dart';
import 'package:flutter/material.dart';
import '../models/datagrid_configuration.dart';

class OmGridHeader extends StatelessWidget {
  const OmGridHeader({
    super.key,
    required this.controller,
    required this.columns,
    required this.configuration,
    required this.columnWidths,
    required this.onColumnResize,
    required this.orgData,
    required this.srchData,
    required this.onSearch,
    this.sortColumnKey,
    this.sortAscending = true,
    this.onSort,
    this.onReorder,
    this.globalSearchText,
    this.horizontalScrollController,
    this.visibleIndicesToRender,
  });

  final OmDataGridController controller;
  final List<OmGridColumnModel> columns;
  final OmDataGridConfiguration configuration;
  final List<double?> columnWidths;
  final Function(int, double) onColumnResize;
  final List<Map<String, dynamic>> orgData;
  final List<Map<String, dynamic>> srchData;
  final void Function(List<dynamic>) onSearch;
  final String? sortColumnKey;
  final bool? sortAscending;
  final Function(String, {bool? ascending})? onSort;
  final void Function(int, int)? onReorder;
  final String? globalSearchText;
  final ScrollController? horizontalScrollController;
  final List<int>? visibleIndicesToRender;

  @override
  Widget build(BuildContext context) {
    if (visibleIndicesToRender != null && visibleIndicesToRender!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleIndices = <int>[];
    if (visibleIndicesToRender != null) {
      visibleIndices.addAll(visibleIndicesToRender!);
    } else {
      for (int i = 0; i < columns.length; i++) {
        if (columns[i].isVisible) {
          visibleIndices.add(i);
        }
      }
    }

    final hController = horizontalScrollController;
    if (hController == null || !hController.hasClients) {
      return Container(
        height: configuration.headerHeight,
        decoration: BoxDecoration(
          color: configuration.headerBackgroundColor,
          border: BorderDirectional(
            bottom: (configuration.headerBorderVisibility ==
                        OmGridBorderVisibility.horizontal ||
                    configuration.headerBorderVisibility ==
                        OmGridBorderVisibility.both)
                ? BorderSide(
                    width: configuration.headerBorderWidth,
                    color: configuration.headerBorderColor,
                  )
                : BorderSide.none,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(children: _buildHeaderCells(visibleIndices)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: hController,
      builder: (context, _) {
        // Defensive check inside builder
        if (!hController.hasClients) {
          return Container(
            decoration: BoxDecoration(
              color: configuration.headerBackgroundColor,
              border: BorderDirectional(
                bottom: (configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.horizontal ||
                        configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.both)
                    ? BorderSide(
                        width: configuration.headerBorderWidth,
                        color: configuration.headerBorderColor,
                      )
                    : BorderSide.none,
              ),
            ),
            height: configuration.headerHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: _buildHeaderCells(visibleIndices)),
            ),
          );
        }

        try {
          final virtualizedCells = _buildVirtualizedHeaderCells(
            visibleIndices,
            hController,
          );
          return Container(
            decoration: BoxDecoration(
              color: configuration.headerBackgroundColor,
              border: BorderDirectional(
                bottom: (configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.horizontal ||
                        configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.both)
                    ? BorderSide(
                        width: configuration.headerBorderWidth,
                        color: configuration.headerBorderColor,
                      )
                    : BorderSide.none,
              ),
            ),
            height: configuration.headerHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: virtualizedCells),
            ),
          );
        } catch (e) {
          return Container(
            decoration: BoxDecoration(
              color: configuration.headerBackgroundColor,
              border: BorderDirectional(
                bottom: (configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.horizontal ||
                        configuration.headerBorderVisibility ==
                            OmGridBorderVisibility.both)
                    ? BorderSide(
                        width: configuration.headerBorderWidth,
                        color: configuration.headerBorderColor,
                      )
                    : BorderSide.none,
              ),
            ),
            height: configuration.headerHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(children: _buildHeaderCells(visibleIndices)),
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildHeaderCells(List<int> visibleIndices) {
    return List.generate(visibleIndices.length, (vIndex) {
      final index = visibleIndices[vIndex];
      // Defensive range check
      if (index < 0 || index >= columns.length) {
        return const SizedBox.shrink();
      }
      final column = columns[index];
      final isFirstVisible = vIndex == 0;
      final isFused = column.key == '__reorder_column__';

      Widget cell = _GridHeaderCell(
        controller: controller,
        column: column,
        index: index,
        columns: columns,
        configuration: configuration,
        columnWidths: columnWidths,
        onColumnResize: onColumnResize,
        orgData: orgData,
        srchData: srchData,
        onSearch: onSearch,
        sortColumnKey: sortColumnKey,
        sortAscending: sortAscending,
        onSort: onSort,
        isFirstVisible: isFirstVisible,
        globalSearchText: globalSearchText,
      );

      if (configuration.allowColumnReordering &&
          onReorder != null &&
          !isFused) {
        return DragTarget<OmGridColumnDragData>(
          onWillAcceptWithDetails: (details) {
            if (details.data.source == 'header' &&
                details.data.column.key != column.key &&
                details.data.column.key != '__reorder_column__') {
              final oldIndex = columns.indexWhere(
                (c) => c.key == details.data.column.key,
              );
              if (oldIndex != -1 && oldIndex != index) {
                onReorder!(oldIndex, index);
              }
            }
            return true;
          },
          onAcceptWithDetails: (details) {},
          builder: (context, candidateData, rejectedData) => cell,
        );
      }
      return cell;
    });
  }

  List<Widget> _buildVirtualizedHeaderCells(
    List<int> visibleIndices,
    ScrollController? hController,
  ) {
    if (hController == null || !hController.hasClients) {
      return _buildHeaderCells(visibleIndices);
    }

    final double scrollX = hController.hasClients ? hController.offset : 0;
    final double viewportWidth =
        hController.hasClients ? hController.position.viewportDimension : 0;
    final double buffer = 400.0;

    final List<Widget> cells = [];
    double currentX = 0;
    double leadingSpace = 0;
    double trailingSpace = 0;
    bool foundFirst = false;

    for (int vIndex = 0; vIndex < visibleIndices.length; vIndex++) {
      final index = visibleIndices[vIndex];
      // Defensive range checks
      if (index < 0 || index >= columns.length) continue;

      final width =
          (index < columnWidths.length) ? (columnWidths[index] ?? 0.0) : 0.0;

      if (currentX + width < scrollX - buffer) {
        leadingSpace += width;
      } else if (currentX > scrollX + viewportWidth + buffer) {
        trailingSpace += width;
      } else {
        if (!foundFirst) {
          if (leadingSpace > 0) {
            cells.add(SizedBox(width: leadingSpace));
          }
          foundFirst = true;
        }

        final column = columns[index];
        final isFirstVisible = vIndex == 0;
        final isFused = column.key == '__reorder_column__';

        Widget cell = _GridHeaderCell(
          controller: controller,
          column: column,
          index: index,
          columns: columns,
          configuration: configuration,
          columnWidths: columnWidths,
          onColumnResize: onColumnResize,
          orgData: orgData,
          srchData: srchData,
          onSearch: onSearch,
          sortColumnKey: sortColumnKey,
          sortAscending: sortAscending,
          onSort: onSort,
          isFirstVisible: isFirstVisible,
          globalSearchText: globalSearchText,
        );

        if (configuration.allowColumnReordering &&
            onReorder != null &&
            !isFused) {
          cells.add(
            DragTarget<OmGridColumnDragData>(
              onWillAcceptWithDetails: (details) {
                if (details.data.source == 'header' &&
                    details.data.column.key != column.key &&
                    details.data.column.key != '__reorder_column__') {
                  final oldIndex = columns.indexWhere(
                    (c) => c.key == details.data.column.key,
                  );
                  if (oldIndex != -1 && oldIndex != index) {
                    onReorder!(oldIndex, index);
                  }
                }
                return true;
              },
              onAcceptWithDetails: (details) {},
              builder: (context, candidateData, rejectedData) => cell,
            ),
          );
        } else {
          cells.add(cell);
        }
      }
      currentX += width;
    }

    if (trailingSpace > 0) {
      cells.add(SizedBox(width: trailingSpace));
    }

    return cells;
  }
}

class _GridHeaderCell extends StatefulWidget {
  final OmDataGridController controller;
  final OmGridColumnModel column;
  final int index;
  final List<OmGridColumnModel> columns;
  final OmDataGridConfiguration configuration;
  final List<double?> columnWidths;
  final Function(int, double) onColumnResize;
  final List<Map<String, dynamic>> orgData;
  final List<Map<String, dynamic>> srchData;
  final void Function(List<dynamic>) onSearch;
  final String? sortColumnKey;
  final bool? sortAscending;
  final Function(String, {bool? ascending})? onSort;
  final bool isFirstVisible;
  final String? globalSearchText;

  const _GridHeaderCell({
    required this.controller,
    required this.column,
    required this.index,
    required this.columns,
    required this.configuration,
    required this.columnWidths,
    required this.onColumnResize,
    required this.orgData,
    required this.srchData,
    required this.onSearch,
    this.sortColumnKey,
    this.sortAscending,
    this.onSort,
    required this.isFirstVisible,
    this.globalSearchText,
  });

  @override
  State<_GridHeaderCell> createState() => _GridHeaderCellState();
}

class _GridHeaderCellState extends State<_GridHeaderCell> {
  bool _isHovered = false;
  final MenuController _menuController = MenuController();
  Offset _menuPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final column = widget.column;
    final index = widget.index;
    final configuration = widget.configuration;
    final isExpanded = widget.columnWidths[index] == null;
    final isSorting =
        widget.sortColumnKey == column.key && widget.sortAscending != null;
    final isFiltered = column.isFiltered;

    final isFused = column.key == '__reorder_column__';
    Widget cellContent = MenuAnchor(
      controller: _menuController,
      alignmentOffset: _menuPosition,
      style: MenuStyle(
        alignment: Alignment.topLeft,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      menuChildren: [
        OmGridColumnMenu(
          controller: widget.controller,
          column: widget.column,
          sortColumnKey: widget.sortColumnKey,
          sortAscending: widget.sortAscending,
          onSort: (key, {ascending}) {
            widget.onSort?.call(key, ascending: ascending);
            _menuController.close();
          },
        ),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onSecondaryTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localOffset = box.globalToLocal(
              details.globalPosition,
            );

            // Adjust position to be exactly at click point or slightly offset
            setState(() {
              _menuPosition = Offset(localOffset.dx, localOffset.dy + 4);
            });
            controller.open();
          },
          child: Container(
            padding: isFused ? EdgeInsets.zero : const EdgeInsets.all(12),
            width: isExpanded ? null : widget.columnWidths[index],
            height: configuration.headerHeight,
            decoration: BoxDecoration(
              color: controller.isOpen
                  ? configuration.primaryColor.withOpacity(0.05)
                  : Colors.transparent,
              border: BorderDirectional(
                start: !widget.isFirstVisible &&
                        (configuration.headerBorderVisibility ==
                                OmGridBorderVisibility.vertical ||
                            configuration.headerBorderVisibility ==
                                OmGridBorderVisibility.both)
                    ? BorderSide(
                        width: configuration.headerBorderWidth,
                        color: configuration.headerBorderColor,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: (configuration.allowSorting &&
                            column.isAllowSorting &&
                            !isFused)
                        ? () {
                            widget.onSort?.call(column.key);
                            _menuController.close();
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: column.textAlign == TextAlign.center
                          ? MainAxisAlignment.center
                          : (column.textAlign == TextAlign.right
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start),
                      children: [
                        Flexible(
                          child: Text(
                            column.title,
                            textAlign: column.textAlign,
                            overflow: TextOverflow.ellipsis,
                            style: configuration.headerTextStyle ??
                                TextStyle(
                                  color: configuration.headerForegroundColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: configuration.gridFontFamily,
                                ),
                          ),
                        ),
                        if (isSorting)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              widget.sortAscending == true
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 16,
                              color: configuration.sortIconColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _isHovered,
                  maintainSize: false,
                  maintainAnimation: true,
                  maintainState: true,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTapDown: (details) {
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final Offset localOffset = box.globalToLocal(
                          details.globalPosition,
                        );
                        setState(() {
                          // Open slightly below the click point to avoid covering the icon
                          _menuPosition = Offset(
                            localOffset.dx - 120,
                            localOffset.dy + 20,
                          );
                        });
                        controller.open();
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 6),
                        child: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: isSorting
                              ? configuration.primaryColor
                              : configuration.sortIconColor,
                        ),
                      ),
                    ),
                  ),
                ),
                if (column.isAllowFiltering && !isFused)
                  Visibility(
                    visible: !configuration.showFilterOnHover ||
                        _isHovered ||
                        isFiltered,
                    maintainSize: false,
                    maintainAnimation: true,
                    maintainState: true,
                    child: GridFilter(
                      key: ValueKey(isFiltered),
                      orgData: widget.orgData,
                      dataSource: widget.srchData,
                      onSearch: widget.onSearch,
                      attributes: column,
                      allAttributes: widget.columns,
                      configuration: configuration,
                      globalSearchText: widget.globalSearchText,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if ((configuration.allowColumnReordering ||
            (configuration.enableGrouping && configuration.allowGrouping)) &&
        !isFused) {
      cellContent = Draggable<OmGridColumnDragData>(
        data: OmGridColumnDragData(column: column, source: 'header'),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () {
          widget.controller.setIsDraggingColumnOutside(false);
        },
        onDragUpdate: (details) {
          final isInside = GridUtils.isPointInsideKey(
            details.globalPosition,
            widget.controller.gridKey,
          );
          widget.controller.setIsDraggingColumnOutside(!isInside);
        },
        onDragEnd: (details) {
          if (widget.controller.isDraggingColumnOutside) {
            final colModel = widget.column;
            if (colModel.isVisible) {
              colModel.isVisible = false;
              colModel.savedWidth = colModel.width;
              colModel.width = 0;
              widget.controller.updateColumnModels(
                widget.controller.columnModels,
              );
            }
          }
          widget.controller.setIsDraggingColumnOutside(false);
        },
        feedback: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, child) {
            final isOutside = widget.controller.isDraggingColumnOutside;
            return Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOutside
                      ? Colors.red.withOpacity(0.9)
                      : configuration.headerBackgroundColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOutside)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.visibility_off,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    Text(
                      column.title,
                      style: (configuration.headerTextStyle ??
                              TextStyle(
                                color: configuration.headerForegroundColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: configuration.gridFontFamily,
                              ))
                          .copyWith(color: isOutside ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: cellContent),
        child: cellContent,
      );
    }

    Widget content = MouseRegion(
      cursor: (configuration.allowColumnReordering ||
                  (configuration.enableGrouping &&
                      configuration.allowGrouping)) &&
              !isFused
          ? SystemMouseCursors.grab
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: cellContent,
    );

    final showSmallDivider = !widget.isFirstVisible &&
        configuration.headerBorderVisibility !=
            OmGridBorderVisibility.vertical &&
        configuration.headerBorderVisibility != OmGridBorderVisibility.both;

    if (!column.isResizable && !showSmallDivider) {
      return content;
    }

    return Stack(
      children: [
        content,
        if (showSmallDivider)
          PositionedDirectional(
            start: 0,
            top: configuration.headerHeight * 0.25,
            bottom: configuration.headerHeight * 0.25,
            child: Container(
              width: 2,
              color: configuration.headerBorderColor.withOpacity(0.3),
            ),
          ),
        if (column.isResizable)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _ResizeHandle(
              onResize: (delta) {
                final currentWidth = widget.columnWidths[index] ?? 0.0;
                final minWidth = configuration.minColumnWidth;
                final newWidth = (currentWidth + delta).clamp(
                  minWidth,
                  double.infinity,
                );
                widget.onColumnResize(index, newWidth);
              },
              color: configuration.resizeHandleColor,
              width: configuration.resizeHandleWidth,
            ),
          ),
      ],
    );
  }
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({required this.onResize, this.color, this.width});

  final Function(double) onResize;
  final Color? color;
  final double? width;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  double? _startX;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          _startX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (_startX != null) {
            final delta = details.globalPosition.dx - _startX!;
            _startX = details.globalPosition.dx;
            widget.onResize(delta);
          }
        },
        onHorizontalDragEnd: (_) {
          _startX = null;
        },
        child: Container(
          width: widget.width ?? 8,
          color: widget.color ?? Colors.transparent,
        ),
      ),
    );
  }
}
