import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:flutter/material.dart';

class GridAggregationRow extends StatelessWidget {
  final DatagridController controller;
  final List<GridColumnModel> columns;
  final List<double?> columnWidths;
  final List<int> visibleIndices;

  const GridAggregationRow({
    super.key,
    required this.controller,
    required this.columns,
    required this.columnWidths,
    required this.visibleIndices,
  });

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.end:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!columns.any((c) => c.aggregation != AggregationType.none)) {
      return const SizedBox.shrink();
    }

    final config = controller.configuration;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleIndices.length,
        itemBuilder: (context, vIndex) {
          final index = visibleIndices[vIndex];
          final col = columns[index];
          final width = columnWidths[index];
          final value = controller.getAggregationValue(col);

          if (value == null) {
            return Container(
              width: width,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade100)),
              ),
            );
          }

          String formattedValue = value.toString();
          if (value is double) {
            formattedValue = value.toStringAsFixed(3);
            if (formattedValue.endsWith('.000')) {
              formattedValue = value.toStringAsFixed(0);
            } else if (formattedValue.endsWith('0')) {
              formattedValue = value.toStringAsFixed(2);
            }
          }

          return Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            alignment: _getAlignment(col.textAlign),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: config.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: config.primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    col.aggregation.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: config.primaryColor.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: config.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
