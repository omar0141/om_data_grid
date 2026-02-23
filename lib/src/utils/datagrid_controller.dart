import 'package:om_data_grid/src/enums/column_pinning_enum.dart';
import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/side_panel_config.dart';
import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:expressions/expressions.dart';

class DatagridController extends ChangeNotifier {
  List<Map<String, dynamic>> _data;
  List<Map<String, dynamic>> _filteredData;
  List<GridColumnModel> _columnModels;
  late final List<GridColumnModel> _initialColumnModels;
  DatagridConfiguration _configuration;
  final List<String> _groupedColumns = [];
  List<GridSidePanelTab> _additionalSidePanelTabs = [];
  String _globalSearchText = "";
  bool _isDraggingColumnOutside = false;
  GlobalKey? _gridKey;

  /// Callback to trigger visualization (charts).
  /// This is usually provided by the [Datagrid] widget when it attaches.
  void Function(List<Map<String, dynamic>> data, List<GridColumnModel> columns)?
  onVisualize;

  void Function()? onAddPressed;

  void Function()? onShowColumnChooser;
  void Function()? onReset;
  void Function(int oldIndex, int newIndex)? onRowReorder;
  Future<bool> Function(int oldIndex, int newIndex)? onBeforeRowReorder;
  void Function(int oldIndex, int newIndex)? onColumnReorder;

  DatagridController({
    required List<Map<String, dynamic>> data,
    required List<GridColumnModel> columnModels,
    DatagridConfiguration? configuration,
    List<GridSidePanelTab> additionalSidePanelTabs = const [],
    this.onRowReorder,
    this.onBeforeRowReorder,
    this.onColumnReorder,
  }) : _data = data,
       _filteredData = List.from(data),
       _columnModels = columnModels,
       _configuration = configuration ?? DatagridConfiguration(),
       _additionalSidePanelTabs = additionalSidePanelTabs {
    // Initialize original indexes and clones for initial state
    _initialColumnModels = [];
    for (int i = 0; i < columnModels.length; i++) {
      columnModels[i].originalIndex = i;
      _initialColumnModels.add(
        GridColumnModel(
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
  List<GridColumnModel> get columnModels => _columnModels;
  DatagridConfiguration get configuration => _configuration;
  List<String> get groupedColumns => List.unmodifiable(_groupedColumns);
  List<GridSidePanelTab> get additionalSidePanelTabs =>
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
    final filtered = FilterUtils.performFiltering(
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

  void updateColumnModels(List<GridColumnModel> newModels) {
    _columnModels = newModels;
    // Maintain stable logic indices after a bulk update to the column list
    for (int i = 0; i < _columnModels.length; i++) {
      _columnModels[i].originalIndex = i;
    }
    _calculateCalculatedColumns();
    notifyListeners();
  }

  void updateColumnAggregation(String columnKey, AggregationType type) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1) {
      _columnModels[index].aggregation = type;
      notifyListeners();
    }
  }

  void addCalculatedColumn(String title, String formula) {
    final key = "calculated_${DateTime.now().millisecondsSinceEpoch}";
    final newCol = GridColumn(key: key, title: title, formula: formula);
    final model = GridColumnModel(
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
      final sortedCols = List<GridColumnModel>.from(
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

  void updateConfiguration(DatagridConfiguration newConfig) {
    _configuration = newConfig;
    notifyListeners();
  }

  void toggleQuickSearch() {
    _configuration = _configuration.copyWith(
      showQuickSearch: !_configuration.showQuickSearch,
    );
    notifyListeners();
  }

  void updateAdditionalSidePanelTabs(List<GridSidePanelTab> newTabs) {
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
    List<GridColumnModel> columns,
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

  void updateColumnPinning(String columnKey, ColumnPinning pinning) {
    final index = _columnModels.indexWhere((c) => c.key == columnKey);
    if (index != -1) {
      final column = _columnModels[index];
      column.pinning = pinning;

      // Move while maintaining stable order relative to original sequence
      _columnModels.removeAt(index);

      int insertIdx = 0;
      if (pinning == ColumnPinning.left) {
        // Move to appropriate position within left group based on original sequence
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == ColumnPinning.left &&
            _columnModels[insertIdx].originalIndex < column.originalIndex) {
          insertIdx++;
        }
      } else if (pinning == ColumnPinning.right) {
        // Find start of right pinned group
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning != ColumnPinning.right) {
          insertIdx++;
        }
        // Place correctly within right group
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == ColumnPinning.right &&
            _columnModels[insertIdx].originalIndex < column.originalIndex) {
          insertIdx++;
        }
      } else {
        // Return to natural order among unpinned columns
        // Skip all left-pinned columns
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == ColumnPinning.left) {
          insertIdx++;
        }
        // Find position among unpinned columns
        while (insertIdx < _columnModels.length &&
            _columnModels[insertIdx].pinning == ColumnPinning.none &&
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
          (m) => GridColumnModel(
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

  dynamic getAggregationValue(GridColumnModel col) {
    if (col.aggregation == AggregationType.none) return null;
    if (_filteredData.isEmpty) return null;

    final values = _filteredData
        .map((row) => row[col.key])
        .where((val) => val != null)
        .toList();

    if (values.isEmpty) return null;

    switch (col.aggregation) {
      case AggregationType.count:
        return values.length;
      case AggregationType.sum:
        return values.fold<double>(
          0.0,
          (sum, val) => sum + (double.tryParse(val.toString()) ?? 0.0),
        );
      case AggregationType.avg:
        final sum = values.fold<double>(
          0.0,
          (sum, val) => sum + (double.tryParse(val.toString()) ?? 0.0),
        );
        return sum / values.length;
      case AggregationType.min:
        return values
            .map((val) => double.tryParse(val.toString()) ?? 0.0)
            .reduce((min, val) => val < min ? val : min);
      case AggregationType.max:
        return values
            .map((val) => double.tryParse(val.toString()) ?? 0.0)
            .reduce((max, val) => val > max ? val : max);
      case AggregationType.first:
        return values.first;
      case AggregationType.last:
        return values.last;
      default:
        return null;
    }
  }
}
