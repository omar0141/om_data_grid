import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:om_data_grid/src/utils/file_viewer/file_viewer.dart';
import 'chart_types.dart';

class OmChartExportHandler {
  static Future<void> exportToPDF({
    required Uint8List chartImageBytes,
    required String title,
  }) async {
    try {
      final List<int> bytes = _generatePdfBytes(chartImageBytes, title);
      await saveAndOpenFile(bytes, 'Chart_Export.pdf', 'application/pdf');
    } catch (e) {
      debugPrint('PDF Export failed: $e');
      rethrow;
    }
  }

  static List<int> _generatePdfBytes(Uint8List imageBytes, String title) {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
      bounds: const ui.Rect.fromLTWH(0, 0, 500, 30),
    );

    page.graphics.drawImage(
      PdfBitmap(imageBytes),
      const ui.Rect.fromLTWH(0, 40, 500, 350),
    );

    final List<int> bytes = document.saveSync();
    document.dispose();
    return bytes;
  }

  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required String xAxisColumn,
    required List<String> yAxisColumns,
    required OmChartType chartType,
    Uint8List? chartImageBytes,
  }) async {
    try {
      final List<int> bytes = _generateExcelBytes(
        data,
        xAxisColumn,
        yAxisColumns,
        chartImageBytes,
      );

      await saveAndOpenFile(
        bytes,
        'Chart_Data.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } catch (e) {
      debugPrint('Excel Export failed: $e');
      rethrow;
    }
  }

  static List<int> _generateExcelBytes(
    List<Map<String, dynamic>> data,
    String xAxisColumn,
    List<String> yAxisColumns,
    Uint8List? imageBytes,
  ) {
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];

    // Headers
    sheet.getRangeByIndex(1, 1).setText(xAxisColumn);
    for (int j = 0; j < yAxisColumns.length; j++) {
      sheet.getRangeByIndex(1, j + 2).setText(yAxisColumns[j]);
    }

    // Data
    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      sheet
          .getRangeByIndex(i + 2, 1)
          .setText(row[xAxisColumn]?.toString() ?? '');
      for (int j = 0; j < yAxisColumns.length; j++) {
        final String yKey = yAxisColumns[j];
        final yVal = row[yKey];
        if (yVal is num) {
          sheet.getRangeByIndex(i + 2, j + 2).setNumber(yVal.toDouble());
        } else {
          sheet.getRangeByIndex(i + 2, j + 2).setText(yVal?.toString() ?? '');
        }
      }
    }

    if (imageBytes != null) {
      // Position the chart image to the right of the data
      sheet.pictures.addStream(1, yAxisColumns.length + 3, imageBytes);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    return bytes;
  }

  static Future<void> saveAndOpenFile(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) async {
    await FileViewer.saveAndOpen(bytes, fileName, mimeType);
  }
}
