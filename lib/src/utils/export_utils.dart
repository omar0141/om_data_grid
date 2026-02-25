import 'dart:ui' hide Color;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:om_data_grid/src/utils/file_viewer/file_viewer.dart';
import '../models/grid_column_model.dart';
import '../models/datagrid_configuration.dart';

class OmGridExportHandler {
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required List<OmGridColumnModel> columns,
    required OmDataGridConfiguration configuration,
    String fileName = 'Grid_Export.xlsx',
  }) async {
    try {
      final List<int> bytes = _generateExcelBytes(data, columns, configuration);

      await _saveAndOpenFile(
        bytes,
        fileName,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } catch (e) {
      debugPrint('Excel Export failed: $e');
      rethrow;
    }
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static xls.HAlignType _toExcelAlign(TextAlign? align) {
    if (align == null) return xls.HAlignType.left;
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return xls.HAlignType.left;
      case TextAlign.right:
      case TextAlign.end:
        return xls.HAlignType.right;
      case TextAlign.center:
        return xls.HAlignType.center;
      case TextAlign.justify:
        return xls.HAlignType.justify;
    }
  }

  static List<int> _generateExcelBytes(
    List<Map<String, dynamic>> data,
    List<OmGridColumnModel> columns,
    OmDataGridConfiguration configuration,
  ) {
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];

    final String headerColor = _colorToHex(configuration.headerBackgroundColor);
    final String headerTextColor = _colorToHex(
      configuration.headerForegroundColor,
    );
    final String rowTextColor = _colorToHex(configuration.rowForegroundColor);
    final String borderColor = _colorToHex(configuration.rowBorderColor);
    final String headerBorderColor = _colorToHex(
      configuration.headerBorderColor,
    );

    final double headerFontSize = configuration.headerTextStyle?.fontSize ?? 12;
    final double rowFontSize = configuration.rowTextStyle?.fontSize ?? 11;

    // Headers
    for (int j = 0; j < columns.length; j++) {
      final col = columns[j];
      final range = sheet.getRangeByIndex(1, j + 1);
      range.setText(col.title);
      range.cellStyle.backColor = headerColor;
      range.cellStyle.fontColor = headerTextColor;
      range.cellStyle.fontSize = headerFontSize;
      range.cellStyle.bold = true;
      range.cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
      range.cellStyle.borders.all.color = headerBorderColor;
      range.cellStyle.vAlign = xls.VAlignType.center;
      range.cellStyle.hAlign = _toExcelAlign(col.textAlign);
    }
    sheet.getRangeByIndex(1, 1, 1, columns.length).rowHeight =
        configuration.headerHeight * 0.75; // Excel points vs Flutter pixels

    // Data
    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      for (int j = 0; j < columns.length; j++) {
        final col = columns[j];
        final val = row[col.key];
        final cell = sheet.getRangeByIndex(i + 2, j + 1);

        cell.cellStyle.fontColor = rowTextColor;
        cell.cellStyle.fontSize = rowFontSize;
        cell.cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
        cell.cellStyle.borders.all.color = borderColor;
        cell.cellStyle.vAlign = xls.VAlignType.center;
        cell.cellStyle.hAlign = _toExcelAlign(col.textAlign);

        if (val is num) {
          cell.setNumber(val.toDouble());
        } else if (val is DateTime) {
          cell.setDateTime(val);
        } else if (val is bool) {
          cell.setText(val ? 'Yes' : 'No');
        } else {
          cell.setText(val?.toString() ?? '');
        }
      }
      sheet.getRangeByIndex(i + 2, 1, i + 2, columns.length).rowHeight =
          configuration.rowHeight * 0.75;
    }

    // Auto fit columns
    for (int j = 0; j < columns.length; j++) {
      sheet.autoFitColumn(j + 1);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    return bytes;
  }

  static Future<void> exportToPDF({
    required List<Map<String, dynamic>> data,
    required List<OmGridColumnModel> columns,
    required OmDataGridConfiguration configuration,
    String title = '',
    String fileName = 'Grid_Export.pdf',
  }) async {
    try {
      final List<int> bytes =
          _generatePdfBytes(data, columns, configuration, title);
      await _saveAndOpenFile(bytes, fileName, 'application/pdf');
    } catch (e) {
      debugPrint('PDF Export failed: $e');
      rethrow;
    }
  }

  static PdfColor _toPdfColor(Color color) {
    return PdfColor(color.red, color.green, color.blue);
  }

  static PdfTextAlignment _toPdfAlign(TextAlign? align) {
    if (align == null) return PdfTextAlignment.left;
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return PdfTextAlignment.left;
      case TextAlign.right:
      case TextAlign.end:
        return PdfTextAlignment.right;
      case TextAlign.center:
        return PdfTextAlignment.center;
      case TextAlign.justify:
        return PdfTextAlignment.justify;
    }
  }

  static List<int> _generatePdfBytes(
    List<Map<String, dynamic>> data,
    List<OmGridColumnModel> columns,
    OmDataGridConfiguration configuration,
    String title,
  ) {
    final PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    final PdfPage page = document.pages.add();

    final double headerFontSize = configuration.headerTextStyle?.fontSize ?? 12;
    final double rowFontSize = configuration.rowTextStyle?.fontSize ?? 10;

    // Title
    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
      brush: PdfSolidBrush(_toPdfColor(configuration.primaryColor)),
      bounds: const Rect.fromLTWH(0, 0, 0, 0),
    );

    // Create a PDF grid
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: columns.length);
    for (int i = 0; i < columns.length; i++) {
      grid.columns[i].format = PdfStringFormat(
        alignment: _toPdfAlign(columns[i].textAlign),
        lineAlignment: PdfVerticalAlignment.middle,
      );
    }

    // Add headers
    final PdfGridRow header = grid.headers.add(1)[0];
    for (int i = 0; i < columns.length; i++) {
      header.cells[i].value = columns[i].title;
      header.cells[i].style = PdfGridCellStyle(
        backgroundBrush: PdfSolidBrush(
          _toPdfColor(configuration.headerBackgroundColor),
        ),
        textBrush: PdfSolidBrush(
          _toPdfColor(configuration.headerForegroundColor),
        ),
        font: PdfStandardFont(
          PdfFontFamily.helvetica,
          headerFontSize,
          style: PdfFontStyle.bold,
        ),
      );
    }

    // Add data
    for (var rowData in data) {
      final PdfGridRow row = grid.rows.add();
      for (int i = 0; i < columns.length; i++) {
        final col = columns[i];
        final val = rowData[col.key];
        row.cells[i].value = val?.toString() ?? '';
        row.cells[i].style = PdfGridCellStyle(
          textBrush: PdfSolidBrush(
            _toPdfColor(configuration.rowForegroundColor),
          ),
          font: PdfStandardFont(PdfFontFamily.helvetica, rowFontSize),
        );
      }
    }

    // Grid layout - borders and padding
    final double vPadding = (configuration.rowHeight - rowFontSize) / 2;
    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(
        left: 8,
        right: 8,
        top: vPadding,
        bottom: vPadding,
      ),
    );

    final PdfPen borderPen = PdfPen(
      _toPdfColor(configuration.rowBorderColor),
      width: configuration.rowBorderWidth,
    );

    for (int i = 0; i < grid.headers.count; i++) {
      for (int j = 0; j < grid.columns.count; j++) {
        grid.headers[i].cells[j].style.borders.all = borderPen;
      }
    }

    for (int i = 0; i < grid.rows.count; i++) {
      for (int j = 0; j < grid.columns.count; j++) {
        grid.rows[i].cells[j].style.borders.all = borderPen;
      }
    }

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 40, 0, 0));

    final List<int> bytes = document.saveSync();
    document.dispose();
    return bytes;
  }

  static Future<void> _saveAndOpenFile(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) async {
    await FileViewer.saveAndOpen(bytes, fileName, mimeType);
  }
}
