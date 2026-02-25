import 'package:flutter/material.dart';
import 'package:om_data_grid/src/components/grid_cell.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/enums/grid_border_visibility_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/enums/selection_mode_enum.dart';

class OmGridRow extends StatefulWidget {
  const OmGridRow({
    super.key,
    required this.rowIndex,
    required this.columns,
    required this.row,
    required this.configuration,
    required this.columnWidths,
    this.isSelected = false,
    this.isHovered = false,
    this.globalSearchText = '',
    this.onTap,
    this.onCellTapDown,
    this.onCellPanUpdate,
    this.onCellPanEnd,
    this.isCellSelected,
    this.level = 0,
    this.horizontalScrollController,
    this.visibleIndicesToRender,
    this.onValueChange,
    this.isEditing = false,
    this.isScrolling = false,
    this.onSecondaryTapDown,
  });

  final int rowIndex;
  final List<OmGridColumnModel> columns;
  final Map<String, dynamic> row;
  final OmDataGridConfiguration configuration;
  final List<double?> columnWidths;
  final bool isSelected;
  final bool isHovered;
  final String globalSearchText;
  final VoidCallback? onTap;
  final Function(int columnIndex)? onCellTapDown;
  final Function(int columnIndex)? onCellPanUpdate;
  final VoidCallback? onCellPanEnd;
  final bool Function(int columnIndex)? isCellSelected;
  final int level;
  final ScrollController? horizontalScrollController;
  final List<int>? visibleIndicesToRender;
  final Function(String key, dynamic value)? onValueChange;
  final bool isEditing;
  final bool isScrolling;
  final Function(int columnIndex, TapDownDetails details)? onSecondaryTapDown;

  @override
  State<OmGridRow> createState() => _GridRowState();
}

class _GridRowState extends State<OmGridRow> {
  bool _renderedOnce = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isScrolling) {
      _renderedOnce = true;
    }

    final visibleColumns = <int>[];
    if (widget.visibleIndicesToRender != null) {
      visibleColumns.addAll(widget.visibleIndicesToRender!);
    } else {
      for (int i = 0; i < widget.columns.length; i++) {
        if (widget.columns[i].isVisible) {
          visibleColumns.add(i);
        }
      }
    }

    return RepaintBoundary(
      child: Material(
        color: widget.isSelected
            ? widget.configuration.selectedRowColor
            : (widget.isHovered
                ? widget.configuration.rowHoverColor
                : widget.configuration.rowBackgroundColor),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            height: widget.configuration.rowHeight,
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: (widget.configuration.rowBorderVisibility ==
                            OmGridBorderVisibility.horizontal ||
                        widget.configuration.rowBorderVisibility ==
                            OmGridBorderVisibility.both)
                    ? BorderSide(
                        width: widget.configuration.rowBorderWidth,
                        color: widget.configuration.rowBorderColor,
                      )
                    : BorderSide.none,
              ),
            ),
            child: widget.horizontalScrollController == null
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(children: _buildCells(context, visibleColumns)),
                  )
                : AnimatedBuilder(
                    animation: widget.horizontalScrollController!,
                    builder: (context, _) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: _buildVirtualizedCells(
                            context,
                            visibleColumns,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCells(BuildContext context, List<int> visibleColumns) {
    return List.generate(visibleColumns.length, (vIndex) {
      final index = visibleColumns[vIndex];
      if (index >= widget.columns.length) return const SizedBox();
      final column = widget.columns[index];
      final bool cellSelected = widget.isCellSelected?.call(index) ?? false;
      final bool isFirstVisible = vIndex == 0;

      return _buildCellWrapper(
        context,
        index,
        column,
        cellSelected,
        isFirstVisible,
      );
    });
  }

  List<Widget> _buildVirtualizedCells(
    BuildContext context,
    List<int> visibleColumns,
  ) {
    try {
      if (widget.horizontalScrollController == null ||
          !widget.horizontalScrollController!.hasClients) {
        return _buildCells(context, visibleColumns);
      }

      final double scrollX = widget.horizontalScrollController!.offset;
      final double viewportWidth =
          widget.horizontalScrollController!.position.viewportDimension;
      final double buffer = 400.0; // Buffer to prevent flickering

      final List<Widget> cells = [];
      double currentX = 0;
      double leadingSpace = 0;
      double trailingSpace = 0;

      bool foundFirst = false;

      for (int vIndex = 0; vIndex < visibleColumns.length; vIndex++) {
        final index = visibleColumns[vIndex];
        // Ensure index is within bounds of columnWidths
        if (index >= widget.columnWidths.length) continue;

        final width = widget.columnWidths[index] ?? 100.0;

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
          final column = widget.columns[index];
          final bool cellSelected = widget.isCellSelected?.call(index) ?? false;
          final bool isFirstVisible = vIndex == 0;

          cells.add(
            _buildCellWrapper(
              context,
              index,
              column,
              cellSelected,
              isFirstVisible,
            ),
          );
        }
        currentX += width;
      }

      if (trailingSpace > 0) {
        cells.add(SizedBox(width: trailingSpace));
      }

      return cells;
    } catch (e) {
      // Fallback to non-virtualized rendering
      return _buildCells(context, visibleColumns);
    }
  }

  Widget _buildCellWrapper(
    BuildContext context,
    int index,
    OmGridColumnModel column,
    bool cellSelected,
    bool isFirstVisible,
  ) {
    return MouseRegion(
      onEnter: (event) {
        if (event.down) {
          widget.onCellPanUpdate?.call(index);
        }
      },
      child: GestureDetector(
        onTap: widget.configuration.selectionMode == OmSelectionMode.cell
            ? widget.onTap
            : null,
        onTapDown: (_) => widget.onCellTapDown?.call(index),
        onSecondaryTapDown: (details) {
          widget.onSecondaryTapDown?.call(index, details);
        },
        onTapUp: (_) => widget.onCellPanEnd?.call(),
        onTapCancel: () => widget.onCellPanEnd?.call(),
        onPanStart: (_) => widget.onCellTapDown?.call(index),
        onPanEnd: (_) => widget.onCellPanEnd?.call(),
        onPanCancel: () => widget.onCellPanEnd?.call(),
        child: rowWidget(column, index, context, cellSelected, isFirstVisible),
      ),
    );
  }

  Container rowWidget(
    OmGridColumnModel column,
    int index,
    BuildContext context,
    bool cellSelected,
    bool isFirstVisible,
  ) {
    if (column.key == '__reorder_column__') {
      return Container(
        height: widget.configuration.rowHeight,
        width: widget.columnWidths[index],
        decoration: BoxDecoration(
          color: cellSelected ? widget.configuration.selectedRowColor : null,
          border: const BorderDirectional(start: BorderSide.none),
        ),
        child: Center(
          child: ReorderableDragStartListener(
            index: widget.rowIndex,
            child: Icon(
              Icons.drag_indicator,
              color: widget.configuration.rowForegroundColor.withOpacity(0.5),
              size: 20,
            ),
          ),
        ),
      );
    }

    final double leftPadding =
        isFirstVisible ? 12.0 + (widget.level * 20.0) : 12.0;

    return Container(
      height: widget.configuration.rowHeight,
      padding: EdgeInsets.fromLTRB(leftPadding, 4.0, 12.0, 4.0),
      decoration: BoxDecoration(
        color: cellSelected ? widget.configuration.selectedRowColor : null,
        border: BorderDirectional(
          start: !isFirstVisible &&
                  (widget.configuration.rowBorderVisibility ==
                          OmGridBorderVisibility.vertical ||
                      widget.configuration.rowBorderVisibility ==
                          OmGridBorderVisibility.both)
              ? BorderSide(
                  width: widget.configuration.rowBorderWidth,
                  color: widget.configuration.rowBorderColor,
                )
              : BorderSide.none,
        ),
      ),
      width: widget.columnWidths[index],
      child: Center(
        child: Builder(
          builder: (context) {
            final List<String> terms = [];
            if (widget.globalSearchText.isNotEmpty) {
              terms.add(widget.globalSearchText);
            }
            if (column.quickFilterText != null &&
                column.quickFilterText!.isNotEmpty) {
              terms.add(column.quickFilterText!);
            }
            if (column.advancedFilter != null) {
              for (var cond in column.advancedFilter!.conditions) {
                if (cond.type == OmFilterConditionType.contains &&
                    cond.value.isNotEmpty) {
                  terms.add(cond.value);
                }
              }
            }

            final TextStyle textStyle = (widget.isSelected || cellSelected)
                ? (widget.configuration.selectedRowTextStyle ??
                    widget.configuration.rowTextStyle ??
                    TextStyle(
                      color: widget.configuration.selectedRowForegroundColor,
                      fontSize: 14,
                      fontFamily: widget.configuration.gridFontFamily,
                    ))
                : (widget.configuration.rowTextStyle ??
                    TextStyle(
                      color: widget.configuration.rowForegroundColor,
                      fontSize: 14,
                      fontFamily: widget.configuration.gridFontFamily,
                    ));

            if (widget.isScrolling &&
                !_renderedOnce &&
                widget.configuration.showPlaceholderWhileScrolling &&
                column.showPlaceholderWhileScrolling) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.configuration.rowForegroundColor.withOpacity(
                      0.05,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }

            return GridCell(
              column: column,
              value: widget.row[column.key],
              searchTerms: terms,
              style: textStyle,
              row: widget.row,
              onValueChange: widget.onValueChange,
              isEditing: widget.isEditing,
              configuration: widget.configuration,
            );
          },
        ),
      ),
    );
  }
}
