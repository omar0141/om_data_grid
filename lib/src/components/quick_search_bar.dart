import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/grid_border_visibility_enum.dart';

class QuickSearchBar extends StatefulWidget {
  final List<OmGridColumnModel> columns;
  final List<double?> columnWidths;
  final OmDataGridConfiguration configuration;
  final Function(String key, String value) onSearchChanged;
  final ScrollController? horizontalScrollController;

  const QuickSearchBar({
    super.key,
    required this.columns,
    required this.columnWidths,
    required this.configuration,
    required this.onSearchChanged,
    this.horizontalScrollController,
    this.visibleIndicesToRender,
  });

  final List<int>? visibleIndicesToRender;

  @override
  State<QuickSearchBar> createState() => _QuickSearchBarState();
}

class _QuickSearchBarState extends State<QuickSearchBar> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleIndices = <int>[];
    if (widget.visibleIndicesToRender != null) {
      visibleIndices.addAll(widget.visibleIndicesToRender!);
    } else {
      for (int i = 0; i < widget.columns.length; i++) {
        if (widget.columns[i].isVisible) {
          visibleIndices.add(i);
        }
      }
    }

    final searchCells = List.generate(visibleIndices.length, (vIndex) {
      final index = visibleIndices[vIndex];
      final column = widget.columns[index];
      final isFirstVisible = vIndex == 0;
      final width = widget.columnWidths[index];

      final controller = _controllers.putIfAbsent(
        column.key,
        () => TextEditingController(),
      );

      // Sync if externally changed
      String displayValue = column.quickFilterText ?? '';
      if ((column.type == OmGridRowTypeEnum.date ||
              column.type == OmGridRowTypeEnum.dateTime ||
              column.type == OmGridRowTypeEnum.time) &&
          displayValue.contains('|')) {
        try {
          final parts = displayValue.split('|');
          final isTime = column.type == OmGridRowTypeEnum.time;
          final start = OmGridDateTimeUtils.tryParse(parts[0], isTime: isTime);
          final end = parts.length > 1
              ? OmGridDateTimeUtils.tryParse(parts[1], isTime: isTime)
              : null;

          if (start != null && end != null) {
            final dateFormat = column.customDateFormat ?? 'yyyy-MM-dd';
            displayValue =
                "${DateFormat(dateFormat).format(start)} - ${DateFormat(dateFormat).format(end)}";
          }
        } catch (e) {
          // ignore
        }
      }

      if (controller.text != displayValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.text = displayValue;
          }
        });
      }

      Widget cell = Container(
        width: width,
        height: 44,
        decoration: BoxDecoration(
          color: widget.configuration.headerBackgroundColor,
          border: BorderDirectional(
            bottom:
                (widget.configuration.rowBorderVisibility ==
                        OmGridBorderVisibility.horizontal ||
                    widget.configuration.rowBorderVisibility ==
                        OmGridBorderVisibility.both)
                ? BorderSide(
                    width: widget.configuration.rowBorderWidth,
                    color: widget.configuration.rowBorderColor,
                  )
                : BorderSide.none,
            start:
                !isFirstVisible &&
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.configuration.inputBorderColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: [
              OmGridRowTypeEnum.date,
              OmGridRowTypeEnum.dateTime,
              OmGridRowTypeEnum.time,
            ].contains(column.type),
            onTap: () async {
              if (column.type == OmGridRowTypeEnum.date ||
                  column.type == OmGridRowTypeEnum.dateTime) {
                DateTimeRange? picked =
                    await GridDatePickerUtils.showModernDateRangePicker(
                      context: context,
                      configuration: widget.configuration,
                    );

                if (picked != null) {
                  final dateFormat = column.customDateFormat ?? 'yyyy-MM-dd';
                  String displayVal =
                      "${DateFormat(dateFormat).format(picked.start)} - ${DateFormat(dateFormat).format(picked.end)}";
                  String filterVal =
                      "${picked.start.toIso8601String()}|${picked.end.toIso8601String()}";

                  controller.text = displayVal;
                  widget.onSearchChanged(column.key, filterVal);
                }
              } else if (column.type == OmGridRowTypeEnum.time) {
                OmTimeRange? picked =
                    await GridDatePickerUtils.showModernTimeRangePicker(
                      context: context,
                      configuration: widget.configuration,
                    );
                if (picked != null) {
                  final now = DateTime.now();
                  final startDt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    picked.start.hour,
                    picked.start.minute,
                  );
                  final endDt = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    picked.end.hour,
                    picked.end.minute,
                  );
                  final dateFormat = column.customDateFormat ?? 'HH:mm';
                  String displayVal =
                      "${DateFormat(dateFormat).format(startDt)} - ${DateFormat(dateFormat).format(endDt)}";
                  String filterVal =
                      "${DateFormat('HH:mm').format(startDt)}|${DateFormat('HH:mm').format(endDt)}";

                  controller.text = displayVal;
                  widget.onSearchChanged(column.key, filterVal);
                }
              }
            },
            decoration: InputDecoration(
              hintText: 'search...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: widget.configuration.secondaryTextColor.withOpacity(0.5),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        controller.clear();
                        widget.onSearchChanged(column.key, '');
                      },
                      child: const Icon(Icons.clear, size: 16),
                    )
                  : null,
            ),
            style: TextStyle(
              fontSize: 13,
              color: widget.configuration.rowForegroundColor,
            ),
            onChanged: (value) => widget.onSearchChanged(column.key, value),
          ),
        ),
      );

      if (column.key == '__reorder_column__') {
        cell = Container(
          width: width,
          height: 44,
          decoration: BoxDecoration(
            color: widget.configuration.headerBackgroundColor,
            border: BorderDirectional(
              bottom:
                  (widget.configuration.rowBorderVisibility ==
                          OmGridBorderVisibility.horizontal ||
                      widget.configuration.rowBorderVisibility ==
                          OmGridBorderVisibility.both)
                  ? BorderSide(
                      width: widget.configuration.rowBorderWidth,
                      color: widget.configuration.rowBorderColor,
                    )
                  : BorderSide.none,
              start:
                  !isFirstVisible &&
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
        );
      }

      if (width == null) {
        return Expanded(child: cell);
      }
      return cell;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(children: searchCells),
    );
  }
}
