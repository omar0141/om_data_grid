import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
export 'package:om_data_grid/src/models/datagrid_configuration.dart'
    show OmColumnWidthMode;

class OmDatagridUtils {
  static double measureText(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }

  static List<double?> calculateColumnWidths({
    required List<OmGridColumnModel> columns,
    required List<Map<String, dynamic>> data,
    required OmDataGridConfiguration configuration,
    required BoxConstraints constraints,
    List<double?>? previousWidths,
  }) {
    List<double?> columnWidths = List.filled(columns.length, null);
    double maxWidth = constraints.maxWidth;
    double minColumnWidth = configuration.minColumnWidth;
    double totalConsumedWidth = 0;
    List<int> fillIndices = [];
    final widthMode = configuration.columnWidthMode;

    // First pass: Calculate explicit widths (none, fitByColumnName, fitByCellValue, auto)
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];

      if (!col.isVisible) {
        columnWidths[i] = 0.0;
        continue;
      }

      // If column has an explicit width set (manually resized), use it
      if (col.width != null) {
        columnWidths[i] = col.width;
        totalConsumedWidth += col.width!;
        continue;
      }

      if (widthMode == OmColumnWidthMode.none) {
        columnWidths[i] = col.width ?? minColumnWidth;
      } else if (widthMode == OmColumnWidthMode.fitByColumnName) {
        columnWidths[i] = measureText(
          col.title,
          configuration.headerTextStyle ??
              TextStyle(
                color: configuration.headerForegroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
        );
      } else if (widthMode == OmColumnWidthMode.fitByCellValue) {
        double maxCellWidth = 0;
        for (var row in data) {
          double w = measureText(
            row[col.key]?.toString() ?? "",
            configuration.rowTextStyle ??
                TextStyle(
                  color: configuration.rowForegroundColor,
                  fontSize: 14,
                ),
          );
          if (w > maxCellWidth) maxCellWidth = w;
        }
        columnWidths[i] = maxCellWidth;
      } else if (widthMode == OmColumnWidthMode.auto ||
          widthMode == OmColumnWidthMode.lastColumnFill) {
        double titleWidth = measureText(
          col.title,
          configuration.headerTextStyle ??
              TextStyle(
                color: configuration.headerForegroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
        );
        double maxCellWidth = 0;
        for (var row in data) {
          double w = measureText(
            row[col.key]?.toString() ?? "",
            configuration.rowTextStyle ??
                TextStyle(
                  color: configuration.rowForegroundColor,
                  fontSize: 14,
                ),
          );
          if (w > maxCellWidth) maxCellWidth = w;
        }
        columnWidths[i] = titleWidth > maxCellWidth ? titleWidth : maxCellWidth;
      }

      // Handle Fill and LastColumnFill detection
      if (widthMode == OmColumnWidthMode.fill) {
        fillIndices.add(i);
      } else {
        // Ensure min width for the calculated values
        if (col.isVisible &&
            columnWidths[i] != null &&
            columnWidths[i]! < minColumnWidth) {
          columnWidths[i] = minColumnWidth;
        }
        totalConsumedWidth += columnWidths[i] ?? 0;
      }
    }

    // Second pass: Calculate Fill columns
    if (fillIndices.isNotEmpty) {
      double remaining = maxWidth - totalConsumedWidth;
      double fillWidth = (remaining > 0 ? remaining : 0) / fillIndices.length;
      for (int index in fillIndices) {
        columnWidths[index] = fillWidth > minColumnWidth
            ? fillWidth
            : minColumnWidth;
        totalConsumedWidth += columnWidths[index]!;
      }
    }

    // Third pass: Handle LastColumnFill
    if (columns.isNotEmpty && widthMode == OmColumnWidthMode.lastColumnFill) {
      // Find the last visible column index
      int lastVisibleIndex = -1;
      for (int i = columns.length - 1; i >= 0; i--) {
        if (columns[i].isVisible) {
          lastVisibleIndex = i;
          break;
        }
      }

      if (lastVisibleIndex != -1) {
        // Recalculate consumed width for all but last visible
        double othersWidth = 0;
        for (int i = 0; i < columns.length; i++) {
          if (i != lastVisibleIndex) {
            othersWidth += columnWidths[i] ?? 0;
          }
        }
        double remaining = maxWidth - othersWidth;
        columnWidths[lastVisibleIndex] = remaining > minColumnWidth
            ? remaining
            : minColumnWidth;
      }
    }

    return columnWidths;
  }

  static List<dynamic> groupData({
    required List<Map<String, dynamic>> data,
    required List<String> groupKeys,
  }) {
    if (groupKeys.isEmpty) return data;

    final String currentKey = groupKeys.first;
    final Map<dynamic, List<Map<String, dynamic>>> groups = {};

    for (var row in data) {
      final value = row[currentKey];
      groups.putIfAbsent(value, () => []).add(row);
    }

    final List<Map<String, dynamic>> result = [];
    groups.forEach((key, rows) {
      result.add({
        'isGroup': true,
        'groupKey': currentKey,
        'value': key,
        'count': rows.length,
        'children': groupKeys.length > 1
            ? groupData(data: rows, groupKeys: groupKeys.sublist(1))
            : rows,
      });
    });

    return result;
  }
}
