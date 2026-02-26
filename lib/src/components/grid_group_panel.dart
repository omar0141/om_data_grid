import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';

class OmGridGroupPanel extends StatelessWidget {
  final OmDataGridController controller;
  final List<String> groupedColumns;
  final List<OmGridColumnModel> internalColumns;
  final OmDataGridConfiguration configuration;
  final Function(String) onGroupAdded;
  final Function(String) onGroupRemoved;
  final Function(int, int) onGroupReordered;
  final VoidCallback onClearAll;

  const OmGridGroupPanel({
    super.key,
    required this.controller,
    required this.groupedColumns,
    required this.internalColumns,
    required this.configuration,
    required this.onGroupAdded,
    required this.onGroupRemoved,
    required this.onGroupReordered,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<OmGridColumnDragData>(
      onWillAcceptWithDetails: (details) =>
          !groupedColumns.contains(details.data.column.key),
      onAcceptWithDetails: (details) => onGroupAdded(details.data.column.key),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: configuration.groupPanelHeight ?? 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.amber.withOpacityNew(0.05)
                : (configuration.groupPanelBackgroundColor ??
                    configuration.headerBackgroundColor),
            border: Border(
              bottom: BorderSide(
                color: configuration.groupPanelBorderColor ??
                    configuration.gridBorderColor.withOpacityNew(0.4),
                width: configuration.groupPanelBorderWidth ?? 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.layers_outlined,
                size: 14,
                color: candidateData.isNotEmpty
                    ? Colors.orange
                    : (configuration.groupPanelIconColor ??
                        configuration.headerForegroundColor.withOpacityNew(
                          0.5,
                        )),
              ),
              const SizedBox(width: 8),
              if (groupedColumns.isEmpty)
                Text(
                  configuration.labels.groupPanelPlaceholder,
                  style: candidateData.isNotEmpty
                      ? const TextStyle(color: Colors.orange, fontSize: 11)
                      : (configuration.groupPanelTextStyle ??
                          TextStyle(
                            color: configuration.headerForegroundColor
                                .withOpacityNew(0.5),
                            fontSize: 11,
                          )),
                )
              else
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: groupedColumns.length,
                    separatorBuilder: (context, index) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.chevron_right,
                          size: 15,
                          color: candidateData.isNotEmpty
                              ? Colors.orange
                              : (configuration.groupPanelIconColor ??
                                  configuration.headerForegroundColor
                                      .withOpacityNew(0.5)),
                        ),
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final key = groupedColumns[index];
                      final col = internalColumns.firstWhere(
                        (c) => c.key == key,
                      );
                      final isPanelHovered = candidateData.isNotEmpty;

                      return DragTarget<OmGridColumnDragData>(
                        onWillAcceptWithDetails: (details) =>
                            details.data.source == 'group_chip' &&
                            groupedColumns.contains(details.data.column.key) &&
                            details.data.column.key != key,
                        onAcceptWithDetails: (details) {
                          final oldIdx = groupedColumns.indexOf(
                            details.data.column.key,
                          );
                          if (oldIdx != -1) {
                            onGroupReordered(
                              oldIdx,
                              oldIdx < index ? index + 1 : index,
                            );
                          }
                        },
                        builder: (context, targetCandidateData, _) {
                          final isTargeted = targetCandidateData.isNotEmpty;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isTargeted)
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: Colors.orange,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              Draggable<OmGridColumnDragData>(
                                data: OmGridColumnDragData(
                                  column: col,
                                  source: 'group_chip',
                                ),
                                dragAnchorStrategy: pointerDragAnchorStrategy,
                                onDragStarted: () {
                                  controller.setIsDraggingColumnOutside(false);
                                },
                                onDragUpdate: (details) {
                                  final isInside = GridUtils.isPointInsideKey(
                                    details.globalPosition,
                                    controller.gridKey,
                                  );
                                  controller.setIsDraggingColumnOutside(
                                    !isInside,
                                  );
                                },
                                onDragEnd: (details) {
                                  if (controller.isDraggingColumnOutside) {
                                    if (col.isVisible) {
                                      col.isVisible = false;
                                      col.savedWidth = col.width;
                                      col.width = 0;
                                      controller.updateColumnModels(
                                        controller.columnModels,
                                      );
                                    }
                                  }
                                  controller.setIsDraggingColumnOutside(false);
                                },
                                feedback: ListenableBuilder(
                                  listenable: controller,
                                  builder: (context, _) {
                                    final isOutside =
                                        controller.isDraggingColumnOutside;
                                    return Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOutside
                                              ? Colors.red
                                              : (isPanelHovered
                                                  ? Colors.orange
                                                      .withOpacityNew(0.05)
                                                  : (configuration
                                                          .groupPanelItemBackgroundColor ??
                                                      configuration
                                                          .headerForegroundColor
                                                          .withOpacityNew(
                                                        0.05,
                                                      ))),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: isOutside
                                                ? Colors.red
                                                : (isPanelHovered
                                                    ? Colors.orange
                                                        .withOpacityNew(0.1)
                                                    : (configuration
                                                            .groupPanelItemBorderColor ??
                                                        configuration
                                                            .headerForegroundColor
                                                            .withOpacityNew(
                                                          0.1,
                                                        ))),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isOutside)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  right: 6.0,
                                                ),
                                                child: Icon(
                                                  Icons.visibility_off,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                            Text(
                                              col.title,
                                              style: isOutside
                                                  ? const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                    )
                                                  : (isPanelHovered
                                                      ? const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.orange,
                                                        )
                                                      : (configuration
                                                              .groupPanelItemTextStyle ??
                                                          TextStyle(
                                                            fontSize: 11,
                                                            color: configuration
                                                                .headerForegroundColor,
                                                          ))),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _buildGroupItemChip(
                                    col,
                                    isPanelHovered,
                                  ),
                                ),
                                child: _buildGroupItemChip(col, isPanelHovered),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              if (groupedColumns.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Tooltip(
                    message: "Clear all groups",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: onClearAll,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_sweep_outlined,
                          size: 18,
                          color: configuration.groupPanelClearIconColor ??
                              Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupItemChip(OmGridColumnModel col, bool isPanelHovered) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isPanelHovered
              ? Colors.orange.withOpacityNew(0.05)
              : (configuration.groupPanelItemBackgroundColor ??
                  configuration.headerForegroundColor.withOpacityNew(0.05)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPanelHovered
                ? Colors.orange.withOpacityNew(0.1)
                : (configuration.groupPanelItemBorderColor ??
                    configuration.headerForegroundColor.withOpacityNew(0.1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              col.title,
              style: isPanelHovered
                  ? const TextStyle(fontSize: 11, color: Colors.orange)
                  : (configuration.groupPanelItemTextStyle ??
                      TextStyle(
                        fontSize: 11,
                        color: configuration.headerForegroundColor,
                      )),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onGroupRemoved(col.key),
              child: Icon(
                Icons.close,
                size: 12,
                color: isPanelHovered
                    ? Colors.orange
                    : (configuration.groupPanelItemTextStyle?.color
                            ?.withOpacityNew(0.6) ??
                        configuration.headerForegroundColor.withOpacityNew(
                          0.6,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
