import 'package:om_data_grid/src/components/formula_builder_dialog.dart';
import 'package:om_data_grid/src/components/grid_combo_box/grid_combo_box.dart';
import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';

class ColumnsTab extends StatefulWidget {
  final OmDataGridController controller;

  const ColumnsTab({super.key, required this.controller});

  @override
  State<ColumnsTab> createState() => _ColumnsTabState();
}

class _ColumnsTabState extends State<ColumnsTab> {
  final TextEditingController _columnSearchController = TextEditingController();
  String _columnSearchText = "";

  @override
  void dispose() {
    _columnSearchController.dispose();
    super.dispose();
  }

  void _reorderColumn(String draggedKey, String targetKey) {
    if (_columnSearchText.isNotEmpty) return;
    final allCols = widget.controller.columnModels;
    final oldIdx = allCols.indexWhere((c) => c.key == draggedKey);
    final newIdx = allCols.indexWhere((c) => c.key == targetKey);

    if (oldIdx != -1 && newIdx != -1 && oldIdx != newIdx) {
      final item = allCols.removeAt(oldIdx);
      final targetIdx = allCols.indexWhere((c) => c.key == targetKey);
      allCols.insert(targetIdx, item);
      widget.controller.updateColumnModels(List.from(allCols));
    }
  }

  void _showAddCalculatedColumnDialog({OmGridColumnModel? existing}) {
    showDialog(
      context: context,
      builder: (context) => FormulaBuilderDialog(
        controller: widget.controller,
        existing: existing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allColumns = widget.controller.columnModels;
    final filteredColumns = allColumns.where((col) {
      if (_columnSearchText.isEmpty) return true;
      return col.column.title.toLowerCase().contains(
            _columnSearchText.toLowerCase(),
          );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16, 8.0, 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget
                          .controller.configuration.columnSearchBorderColor!,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TextField(
                      controller: _columnSearchController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: widget.controller.configuration.labels.search,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 16,
                          color: widget
                              .controller.configuration.columnSearchIconColor!,
                        ),
                        filled: true,
                        fillColor:
                            widget.controller.configuration.inputFillColor,
                        contentPadding: EdgeInsets.only(top: 8),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) =>
                          setState(() => _columnSearchText = val),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, size: 20),
                tooltip:
                    widget.controller.configuration.labels.addCalculatedColumn,
                onPressed: () => _showAddCalculatedColumnDialog(existing: null),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredColumns.length,
            itemBuilder: (context, index) {
              final colModel = filteredColumns[index];
              final hasFilter = (colModel.advancedFilter != null &&
                      colModel.advancedFilter!.conditions.isNotEmpty) ||
                  (colModel.filter == true &&
                      colModel.notSelectedFilterData != null &&
                      colModel.notSelectedFilterData!.isNotEmpty);

              return DragTarget<OmGridColumnDragData>(
                onWillAcceptWithDetails: (details) =>
                    details.data.source == 'columns_tab' &&
                    details.data.column.key != colModel.key,
                onAcceptWithDetails: (details) {
                  _reorderColumn(details.data.column.key, colModel.key);
                },
                builder: (context, candidateData, rejectedData) {
                  final isTarget = candidateData.isNotEmpty;

                  return Column(
                    children: [
                      if (isTarget)
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: widget.controller.configuration.primaryColor,
                        ),
                      Draggable<OmGridColumnDragData>(
                        data: OmGridColumnDragData(
                          column: colModel,
                          source: 'columns_tab',
                        ),
                        onDragStarted: () {
                          widget.controller.setIsDraggingColumnOutside(false);
                        },
                        onDragUpdate: (details) {
                          final isInside = GridUtils.isPointInsideKey(
                            details.globalPosition,
                            widget.controller.gridKey,
                          );
                          widget.controller.setIsDraggingColumnOutside(
                            !isInside,
                          );
                        },
                        onDragEnd: (details) {
                          if (widget.controller.isDraggingColumnOutside) {
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
                          builder: (context, _) {
                            final isOutside =
                                widget.controller.isDraggingColumnOutside;
                            return Material(
                              elevation: 4.0,
                              color: Colors.transparent,
                              child: Container(
                                height: 40,
                                width: 200,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isOutside
                                      ? (widget.controller.configuration
                                          .dragFeedbackOutsideBackgroundColor!)
                                      : (widget.controller.configuration
                                          .dragFeedbackInsideBackgroundColor!),
                                  border: Border.all(
                                    color: isOutside
                                        ? (widget.controller.configuration
                                            .dragFeedbackOutsideBorderColor!)
                                        : (widget.controller.configuration
                                            .dragFeedbackInsideBorderColor!),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: widget.controller.configuration
                                              .dragFeedbackShadowColor ??
                                          Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    if (isOutside)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.visibility_off,
                                          color: widget.controller.configuration
                                              .dragFeedbackIconColor!,
                                          size: 16,
                                        ),
                                      ),
                                    Text(
                                      colModel.column.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isOutside
                                            ? (widget.controller.configuration
                                                .dragFeedbackOutsideTextColor!)
                                            : (widget.controller.configuration
                                                .dragFeedbackInsideTextColor!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildColumnItem(colModel, hasFilter, index),
                        ),
                        child: _buildColumnItem(colModel, hasFilter, index),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        DragTarget<OmGridColumnDragData>(
          onWillAcceptWithDetails: (details) =>
              details.data.source == 'columns_tab' &&
              _columnSearchText.isEmpty &&
              widget.controller.columnModels.last.key !=
                  details.data.column.key,
          onAcceptWithDetails: (details) {
            final allCols = widget.controller.columnModels;
            final oldIdx = allCols.indexWhere(
              (c) => c.key == details.data.column.key,
            );
            if (oldIdx != -1) {
              final item = allCols.removeAt(oldIdx);
              allCols.add(item);
              widget.controller.updateColumnModels(List.from(allCols));
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              height: candidateData.isNotEmpty ? 10 : 2,
              color: candidateData.isNotEmpty
                  ? widget.controller.configuration.primaryColor.withOpacity(
                      0.3,
                    )
                  : Colors.transparent,
            );
          },
        ),
        _buildBottomPanelSection(
            widget.controller.configuration.labels.rowGroups,
            widget.controller.configuration.labels.rowGroupsPlaceholder),
        _buildBottomPanelSection(
            widget.controller.configuration.labels.aggregationsTab,
            widget.controller.configuration.labels.aggregationsPlaceholder),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildColumnItem(
      OmGridColumnModel colModel, bool hasFilter, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          colModel.isVisible = !colModel.isVisible;
          if (!colModel.isVisible) {
            if (colModel.width != null && colModel.width! > 0) {
              colModel.savedWidth = colModel.width;
            }
            colModel.width = 0;
          } else {
            colModel.width =
                (colModel.savedWidth != null && colModel.savedWidth! > 0)
                    ? colModel.savedWidth
                    : (colModel.column.width ?? 100.0);
          }
          widget.controller.updateColumnModels(widget.controller.columnModels);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Row(
            children: [
              Checkbox(
                activeColor: widget.controller.configuration.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                value: colModel.isVisible,
                visualDensity: VisualDensity.compact,
                onChanged: (val) {
                  colModel.isVisible = val ?? true;
                  if (!colModel.isVisible) {
                    if (colModel.width != null && colModel.width! > 0) {
                      colModel.savedWidth = colModel.width;
                    }
                    colModel.width = 0;
                  } else {
                    colModel.width = (colModel.savedWidth != null &&
                            colModel.savedWidth! > 0)
                        ? colModel.savedWidth
                        : (colModel.column.width ?? 100.0);
                  }
                  widget.controller.updateColumnModels(
                    widget.controller.columnModels,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.drag_indicator,
                    size: 14,
                    color: widget.controller.configuration.secondaryTextColor),
              ),
              Expanded(
                child: Text(
                  colModel.column.title,
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          widget.controller.configuration.rowForegroundColor),
                ),
              ),
              if (colModel.isCalculated)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      onPressed: () =>
                          _showAddCalculatedColumnDialog(existing: colModel),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () => widget.controller.removeCalculatedColumn(
                        colModel.key,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              if (colModel.aggregation != OmAggregationType.none)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.controller.configuration.primaryColor
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      colModel.aggregation.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: widget.controller.configuration.primaryColor,
                      ),
                    ),
                  ),
                ),
              if (colModel.isCalculated)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.functions,
                    size: 14,
                    color: widget
                            .controller.configuration.columnFunctionIconColor ??
                        Colors.blue,
                  ),
                ),
              if (hasFilter)
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.filter_alt,
                    size: 14,
                    color: widget.controller.configuration.primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanelSection(String title, String placeholder) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final List<String> activeKeys = title == "Row Groups"
            ? widget.controller.groupedColumns
            : widget.controller.columnModels
                .where((c) => c.aggregation != OmAggregationType.none)
                .map((c) => c.key)
                .toList();

        return DragTarget<OmGridColumnDragData>(
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) {
            if (title == widget.controller.configuration.labels.rowGroups) {
              widget.controller.addGroupedColumn(details.data.column.key);
            } else if (title ==
                widget.controller.configuration.labels.aggregationsTab) {
              widget.controller.updateColumnAggregation(
                details.data.column.key,
                OmAggregationType.sum,
              );
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHovered = candidateData.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.controller.configuration
                            .bottomPanelSectionBorderColor ??
                        widget.controller.configuration.gridBorderColor,
                  ),
                ),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (activeKeys.isNotEmpty)
                      Tooltip(
                        message:
                            widget.controller.configuration.labels.clearAll,
                        child: InkWell(
                          onTap: () {
                            if (title ==
                                widget.controller.configuration.labels
                                    .rowGroups) {
                              widget.controller.clearGroupedColumns();
                            } else {
                              for (var col in widget.controller.columnModels) {
                                if (col.aggregation != OmAggregationType.none) {
                                  widget.controller.updateColumnAggregation(
                                    col.key,
                                    OmAggregationType.none,
                                  );
                                }
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_sweep_outlined,
                              size: 16,
                              color: widget.controller.configuration
                                      .groupPanelClearIconColor ??
                                  Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                initiallyExpanded: true,
                shape: const Border(),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? widget.controller.configuration.primaryColor
                              .withOpacity(0.05)
                          : widget.controller.configuration.inputFillColor,
                      border: Border.all(
                        color: isHovered
                            ? widget.controller.configuration.primaryColor
                            : (widget.controller.configuration
                                    .bottomPanelDragTargetInactiveColor ??
                                widget
                                    .controller.configuration.gridBorderColor),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: activeKeys.isEmpty
                        ? Alignment.center
                        : Alignment.topLeft,
                    child: activeKeys.isEmpty
                        ? _buildPlaceholder(placeholder)
                        : title == "Row Groups"
                            ? _buildRowGroupsList(activeKeys)
                            : _buildAggregationsList(activeKeys),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(String placeholder) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.move_to_inbox_outlined,
          size: 20,
          color: widget.controller.configuration.bottomPanelIconColor ??
              widget.controller.configuration.secondaryTextColor,
        ),
        const SizedBox(height: 4),
        Text(
          placeholder,
          style: TextStyle(
            fontSize: 11,
            color: widget.controller.configuration.bottomPanelIconColor ??
                widget.controller.configuration.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRowGroupsList(List<String> keys) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        widget.controller.reorderGroupedColumns(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final key = keys[index];
        final col = widget.controller.columnModels.firstWhere(
          (c) => c.key == key,
        );
        return Container(
          key: ValueKey(key),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: _itemDecoration(),
          child: ReorderableDragStartListener(
            index: index,
            child: _buildPanelItemRow(
              col: col,
              onRemove: () => widget.controller.removeGroupedColumn(key),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAggregationsList(List<String> keys) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final col = widget.controller.columnModels.firstWhere(
          (c) => c.key == key,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: GridComboBox(
            value: col.aggregation.name,
            configuration: widget.controller.configuration,
            items: OmAggregationType.values
                .where((e) => e != OmAggregationType.none)
                .map(
                  (e) => OmGridComboBoxItem(
                    value: e.name,
                    text: "${col.column.title}: ${e.name.toUpperCase()}",
                  ),
                )
                .toList(),
            onChange: (val) {
              if (val != null && val.toString().isNotEmpty) {
                final type = OmAggregationType.values.firstWhere(
                  (e) => e.name == val,
                );
                widget.controller.updateColumnAggregation(key, type);
              } else {
                widget.controller.updateColumnAggregation(
                  key,
                  OmAggregationType.none,
                );
              }
            },
            borderRadius: 6,
            height: 38,
            fontSize: 12,
            backgroundColor:
                widget.controller.configuration.gridBackgroundColor,
            borderColor: widget.controller.configuration.gridBorderColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            // icon: Icon(
            //   Icons.functions,
            //   size: 14,
            //   color: widget.controller.configuration.primaryColor,
            // ),
            showClearButton: true,
          ),
        );
      },
    );
  }

  BoxDecoration _itemDecoration() {
    return BoxDecoration(
      color: widget.controller.configuration.gridBackgroundColor,
      borderRadius: BorderRadius.circular(6),
      border:
          Border.all(color: widget.controller.configuration.gridBorderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildPanelItemRow({
    required OmGridColumnModel col,
    required VoidCallback onRemove,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Icon(Icons.drag_indicator,
                  size: 14,
                  color: widget.controller.configuration.secondaryTextColor),
            ),
            Expanded(
              child: Text(
                col.column.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.controller.configuration.rowForegroundColor,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  size: 18,
                  color: widget.controller.configuration.secondaryTextColor),
              onPressed: onRemove,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
