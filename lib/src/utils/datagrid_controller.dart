import 'package:om_data_grid/src/enums/column_pinning_enum.dart';
import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/side_panel_config.dart';
import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:expressions/expressions.dart';

/// Controller for the Data Grid, managing state, data, and configuration.
class OmDataGridController extends ChangeNotifier {
  List<Map<String, dynamic>> _data;
  List<Map<String, dynamic>> _filteredData;
  List<OmGridColumnModel> _columnModels;
  late final List<OmGridColumnModel> _initialColumnModels;
  OmDataGridConfiguration _configuration;
  final List<String> _groupedColumns = [];
  List<OmGridSidePanelTab> _additionalSidePanelTabs = [];
  String _globalSearchText = "";
  bool _isDraggingColumnOutside = false;
  GlobalKey? _gridKey;

  /// Callback to trigger visualization (charts).
  /// This is usually provided by the [OmDataGrid] widget when it attaches.
  void Function(List<Map<String, dynamic>> data, List<OmGridColumnModel> columns)?
  onVisualize;

  /// Callback when the add button is pressed.
  void Function()? onAddPressed;

  /// Callback to show the column chooser dialog.
  void Function()? onShowColumnChooser;

  /// Callback to reset the grid state.
  void Function()? onReset;

  /// Callback when a row is reordered.
  void Function(int oldIndex, int newIndex)? onRowReorder;

  /// Callback invoked before a row is reordered.
  /// Return true to allow, false to cancel.
  Future<bool> Function(int oldIndex, int newIndex)? onBeforeRowReorder;

  /// Callback when a column is reordered.
  void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// Creates a [OmDataGridController].
  ///
  /// [data] - The initial list of data rows.
  /// [columnModels] - Configuration for the grid columns.
  /// [configuration] - General configuration settings for the grid.
  /// [additionalSidePanelTabs] - Custom tabs to add to the side panel.
  OmDataGridController({
    required List<Map<String, dynamic>> data,
    required List<OmGridColumnModel> columnModels,
    OmDataGridConfiguration? configuration,
    List<OmGridSidePanelTab> additionalSidePanelTabs = const [],
    this.onRowReorder,
    this.onBeforeRowReorder,
    this.onColumnReorder,
  }) : _data = data,
       _filteredData = List.from(data),
       _columnModels = columnModels,
       _configuration = configuration ?? OmDataGridConfiguration(),
       _additionalSidePanelTabs = additionalSidePanelTabs {
    // Initialize original indexes and clones for initial state
    _initialColumnModels = [];
    for (int i = 0; i < columnModels.length; i++) {
      columnModels[i].originalIndex = i;
      _initialColumnModels.add(
        OmGridColumnModel(
          column: columnModels[i].column.copyWith(),
          width: columnModels[i].width,
          isVisible: columnModels[i].isVisible,
          aggregation: columnModels[i].aggregation,
          pinning: columnModels[i].pinning,
          originalIndex: i,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get data => _data;
  List<Map<String, dynamic>> get filteredData => _filteredData;
  List<OmGridColumnModel> get columnModels => _columnModels;
  OmDataGridConfiguration get configuration => _configuration;
  List<String> get groupedColumns => List.unmodifiable(_groupedColumns);
  List<OmGridSidePanelTab> get additionalSidePanelTabs =>
      _additionalSidePanelTabs;
  String get globalSearchText => _globalSearchText;
  bool get isDraggingColumnOutside => _isDraggingColumnOutside;
  GlobalKey? get gridKey => _gridKey;

  void updateData(List<Map<String, dynamic>> newData) {
    _data = newData;
    _applyFilters();
    notifyListeners();
  }

  void updateGlobalSearchText(String text) {
    _globalSearchText = text;
    applyFilters();
  }

  void applyFilters() {
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final filtered = OmFilterUtils.performFiltering(
      data: _data,
      allColumns: _columnModels,
      globalSearch: _globalSearchText,
    );
    _filteredData = filtered.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void updateFilteredData(List<Map<String, dynamic>> newFilteredData) {
    _filteredData = newFilteredData;
    notifyListeners();
  }

  void updateColumnModels(List<OmGridColumnModel> newModels) {
    _columnModels = newModels;
    // Maintain stable logic indices after a bulk update to the column list
    for (int i = 0; i < _columnModels.length; i++) {
      _columnModels[i].originalIndex = i;
    }
    _calculateCalculatedColumns();
    notifyListeners();
  }

  void updateColumnAggregation(String columnKey, OmAggregationType type) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1) {
      _columnModels[index].aggregation = type;
      notifyListeners();
    }
  }

  void addCalculatedColumn(String title, String formula) {
    final key = "calculated_${DateTime.now().millisecondsSinceEpoch}";
    final newCol = OmGridColumn(key: key, title: title, formula: formula);
    final model = OmGridColumnModel(
      column: newCol,
      originalIndex: _columnModels.length,
    );
    _columnModels.add(model);
    _calculateCalculatedColumns();
    notifyListeners();
  }

  void updateCalculatedColumn(String key, String title, String formula) {
    final index = _columnModels.indexWhere((c) => c.key == key);
    if (index != -1 && _columnModels[index].isCalculated) {
      _columnModels[index].column = _columnModels[index].column.copyWith(
        title: title,
        formula: formula,
      );
      _calculateCalculatedColumns();
      notifyListeners();
    }
  }

  void removeCalculatedColumn(String columnKey) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1 && _columnModels[index].isCalculated) {
      _columnModels.removeAt(index);
      // Remove from data rows as well
      for (var row in _data) {
        row.remove(columnKey);
      }
      _applyFilters();
      notifyListeners();
    }
  }

  void _calculateCalculatedColumns() {
    final calculatedCols = _columnModels.where((c) => c.isCalculated).toList();
    if (calculatedCols.isEmpty) {
      _applyFilters();
      return;
    }

    for (var row in _data) {
      // Build evaluation context with BOTH keys and titles
      final context = Map<String, dynamic>.from(row);
      for (var col in _columnModels) {
        if (!col.isCalculated) {
          context[col.column.title] = row[col.key];
        }
      }

      for (var col in calculatedCols) {
        final result = _evaluateFormula(col.column.formula!, context);
        row[col.key] = result;
        context[col.column.title] = result;
        context[col.key] = result;
      }
    }
    _applyFilters();
  }

  dynamic _evaluateFormula(String formula, Map<String, dynamic> context) {
    try {
      String processedFormula = formula;

      // Replace column titles with their keys to support titles with spaces/special chars
      // Sort by length descending to match longest titles first (e.g., "Total Salary" before "Salary")
      final sortedCols = List<OmGridColumnModel>.from(
        _columnModels,
      )..sort((a, b) => b.column.title.length.compareTo(a.column.title.length));

      for (var col in sortedCols) {
        if (col.column.title.isNotEmpty) {
          // Use a simple replace for now. For better robustness, one might use regex
          // to ensure we don't replace parts of other words, but for a data grid
          // column titles are usually distinct enough.
          processedFormula = processedFormula.replaceAll(
            col.column.title,
            col.key,
          );
        }
      }

      final expression = Expression.parse(processedFormula);
      const evaluator = ExpressionEvaluator();
      final result = evaluator.eval(expression, context);
      if (result is num) {
        // Limit to 3 decimal places as requested
        return double.parse(result.toStringAsFixed(3)).toDouble();
      }
      return result;
    } catch (e) {
      return 0;
    }
  }

  void updateConfiguration(OmDataGridConfiguration newConfig) {
    _configuration = newConfig;
    notifyListeners();
  }

  void toggleQuickSearch() {
    _configuration = _configuration.copyWith(
      showQuickSearch: !_configuration.showQuickSearch,
    );
    notifyListeners();
  }

  void updateAdditionalSidePanelTabs(List<OmGridSidePanelTab> newTabs) {
    _additionalSidePanelTabs = newTabs;
    notifyListeners();
  }

  void setIsDraggingColumnOutside(bool value) {
    if (_isDraggingColumnOutside != value) {
      _isDraggingColumnOutside = value;
      notifyListeners();
    }
  }

  void setGridKey(GlobalKey key) {
    _gridKey = key;
  }

  void setAdditionalSidePanelTabVisibility(String id, bool visible) {
    final index = _additionalSidePanelTabs.indexWhere((tab) => tab.id == id);
    if (index != -1) {
      _additionalSidePanelTabs[index] = _additionalSidePanelTabs[index]
          .copyWith(visible: visible);
      notifyListeners();
    }
  }

  void visualize(
    List<Map<String, dynamic>> data,
    List<OmGridColumnModel> columns,
  ) {
    if (onVisualize != null) {
      onVisualize!(data, columns);
    }
  }

  void addGroupedColumn(String key) {
    if (!_groupedColumns.contains(key)) {
      _groupedColumns.add(key);
      notifyListeners();
    }
  }

  void removeGroupedColumn(String key) {
    if (_groupedColumns.remove(key)) {
      notifyListeners();
    }
  }

  void reorderGroupedColumns(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _groupedColumns.removeAt(oldIndex);
    _groupedColumns.insert(newIndex, item);
    notifyListeners();
  }

  void clearGroupedColumns() {
    if (_groupedColumns.isNotEmpty) {
      _groupedColumns.clear();
      notifyListeners();
    }
  }

  void updateColumnPinning(String columnKey, OmColumnPinning pinning) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1) {
      final column = _columnModels[index];
      column.pinning = pinning;

      // Move while maintaining stable order relative to original sequence
      _columnModels.removeAt(index);

      int insertIdx = 0;
      if (pinning == OmColumnPinning.left) {
        // Move to appropriate position within left group based on original sequence
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == OmColumnPinning.left &&
            _columnModels[insertIdx].originalIndex < column.originalIndex) {
          insertIdx++;
        }
      } else if (pinning == OmColumnPinning.right) {
        // Find start of right pinned group
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning != OmColumnPinning.right) {
          insertIdx++;
        }
        // Place correctly within right group
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == OmColumnPinning.right &&
            _columnModels[insertIdx].originalIndex < column.originalIndex) {
          insertIdx++;
        }
      } else {
        // Return to natural order among unpinned columns
        // Skip all left-pinned columns
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == OmColumnPinning.left) {
          insertIdx++;
        }
        // Find position among unpinned columns
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == OmColumnPinning.none &&
            _columnModels[insertIdx].originalIndex < column.originalIndex) {
          insertIdx++;
        }
      }

      _columnModels.insert(insertIdx, column);
      notifyListeners();
    }
  }

  void toggleColumnVisibility(String columnKey, bool isVisible) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1) {
      _columnModels[index].isVisible = isVisible;
      notifyListeners();
    }
  }

  void resetColumns() {
    _columnModels = _initialColumnModels
        .map(
          (m) => OmGridColumnModel(
            column: m.column.copyWith(),
            width: m.width,
            isVisible: m.isVisible,
            aggregation: m.aggregation,
            pinning: m.pinning,
            originalIndex: m.originalIndex,
          ),
        )
        .toList();
    _applyFilters();
    onReset?.call();
    notifyListeners();
  }

  void reorderColumns(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _columnModels.removeAt(oldIndex);
    _columnModels.insert(newIndex, item);

    // Sync originalIndex to match current visual layout as the new default baseline
    for (int i = 0; i < _columnModels.length; i++) {
      _columnModels[i].originalIndex = i;
    }

    notifyListeners();
    onColumnReorder?.call(oldIndex, newIndex);
  }

  void reorderRows(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _data.removeAt(oldIndex);
    _data.insert(newIndex, item);
    _applyFilters();

    notifyListeners();
    onRowReorder?.call(oldIndex, newIndex);
  }

  dynamic getAggregationValue(OmGridColumnModel col) {
    if (col.aggregation == OmAggregationType.none) return null;
    if (_filteredData.isEmpty) return null;

    final values = _filteredData
        .map((row) => row[col.key])
        .where((val) => val != null)
        .toList();

    if (values.isEmpty) return null;

    switch (col.aggregation) {
      case OmAggregationType.count:
        return values.length;
      case OmAggregationType.sum:
        return values.fold<double>(
          0.0,
          (sum, val) => sum + (double.tryParse(val.toString()) ?? 0.0),
        );
      case OmAggregationType.avg:
        final sum = values.fold<double>(
          0.0,
          (sum, val) => sum + (double.tryParse(val.toString()) ?? 0.0),
        );
        return sum / values.length;
      case OmAggregationType.min:
        return values
            .map((val) => double.tryParse(val.toString()) ?? 0.0)
            .reduce((min, val) => val < min ? val : min);
      case OmAggregationType.max:
        return values
            .map((val) => double.tryParse(val.toString()) ?? 0.0)
            .reduce((max, val) => val > max ? val : max);
      case OmAggregationType.first:
        return values.first;
      case OmAggregationType.last:
        return values.last;
      default:
        return null;
    }
  }
}
