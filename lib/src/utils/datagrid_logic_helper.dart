import 'package:flutter/services.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/models/cell_position.dart';

class OmDatagridLogicHelper {
  static List<Map<String, dynamic>> getSelectedData({
    required OmCellPosition? start,
    required OmCellPosition? end,
    required List<dynamic> flattenedItems,
  }) {
    if (start == null || end == null) return [];
    List<Map<String, dynamic>> selectedData = [];
    final minRow = start.rowIndex < end.rowIndex
        ? start.rowIndex
        : end.rowIndex;
    final maxRow = start.rowIndex > end.rowIndex
        ? start.rowIndex
        : end.rowIndex;
    for (int i = minRow; i <= maxRow; i++) {
      if (i >= 0 && i < flattenedItems.length) {
        final item = flattenedItems[i];
        if (item is Map<String, dynamic> && item['isGroup'] != true) {
          selectedData.add(item);
        }
      }
    }
    return selectedData;
  }

  static List<OmGridColumnModel> getSelectedColumns({
    required OmCellPosition? start,
    required OmCellPosition? end,
    required List<OmGridColumnModel> internalColumns,
  }) {
    if (start == null || end == null) return [];
    List<OmGridColumnModel> selectedColumns = [];
    final minCol = start.columnIndex < end.columnIndex
        ? start.columnIndex
        : end.columnIndex;
    final maxCol = start.columnIndex > end.columnIndex
        ? start.columnIndex
        : end.columnIndex;
    for (int j = minCol; j <= maxCol; j++) {
      if (j < internalColumns.length) selectedColumns.add(internalColumns[j]);
    }
    return selectedColumns;
  }

  static void copyToClipboard({
    required List<Map<String, dynamic>> rows,
    required List<OmGridColumnModel> cols,
    required bool includeHeader,
  }) {
    if (rows.isEmpty || cols.isEmpty) return;
    StringBuffer buffer = StringBuffer();
    if (includeHeader) {
      buffer.writeln(cols.map((c) => c.title).join('\t'));
    }
    for (var row in rows) {
      buffer.writeln(cols.map((c) => row[c.key]?.toString() ?? '').join('\t'));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }
}
