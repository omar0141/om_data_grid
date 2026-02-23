import 'package:om_data_grid/src/components/column_chooser_popup.dart';
import 'package:om_data_grid/src/components/grid_main_container.dart';
import 'package:om_data_grid/src/components/layout_helpers.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:om_data_grid/src/models/chart_instance.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:om_data_grid/src/enums/selection_mode_enum.dart';
import 'package:om_data_grid/src/components/grid_footer.dart';
import 'package:om_data_grid/src/components/chart_popup.dart';
import 'package:om_data_grid/src/components/grid_group_panel.dart';
import 'package:om_data_grid/src/components/grid_side_panel.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/datagrid_utils.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:om_data_grid/src/utils/datagrid_logic_helper.dart';
import 'package:om_data_grid/src/models/cell_position.dart';
import 'package:om_data_grid/src/components/formula_builder_dialog.dart';

double screenWidth = 0.0;
double screenHeight = 0.0;

class Datagrid extends StatefulWidget {
  const Datagrid({
    super.key,

    this.onSelectionChanged,
    this.onRowTap,
    this.onSearch,
    this.onRowReorder,
    this.onBeforeRowReorder,
    this.onColumnReorder,
    this.isEditing = false,
    required this.controller,
  });

  final Function(List<Map<String, dynamic>>)? onSelectionChanged;
  final Function(Map<String, dynamic>)? onRowTap;
  final void Function(List<dynamic>)? onSearch;
  final void Function(int oldIndex, int newIndex)? onRowReorder;
  final Future<bool> Function(int oldIndex, int newIndex)? onBeforeRowReorder;
  final void Function(int oldIndex, int newIndex)? onColumnReorder;
  final DatagridController controller;
  final bool isEditing;

  @override
  State<Datagrid> createState() => _DatagridState();
}

class _DatagridState extends State<Datagrid> {
  late List<GridColumnModel> internalColumns;
  late List<double?> columnWidths;
  final GlobalKey _gridKey = GlobalKey();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _frozenLeftScrollController = ScrollController();
  final ScrollController _frozenRightScrollController = ScrollController();
  List<Map<String, dynamic>> filterDatasource = [];
  List<Map<String, dynamic>> _filteredUnsortedData = [];
  List<dynamic> _flattenedItems = [];
  final Set<String> _expandedGroups = {};
  String? _sortColumnKey;
  bool? _sortAscending; // null = none, true = asc, false = desc
  int _currentPage = 0;
  final Set<Map<String, dynamic>> _selectedRows = {};
  final Set<CellPosition> _selectedCells = {};
  CellPosition? _selectionStart;
  CellPosition? _selectionEnd;
  CellPosition? _selectionAnchor;
  bool _isSelecting = false;
  int? _hoveredRowIndex; // track hovered row index
  final List<ChartInstance> _activeCharts = [];
  late int _rowsPerPage;
  bool _isInternalUpdate = false;
  bool _isSidePanelExpanded = false;
  bool _isColumnChooserVisible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.setGridKey(_gridKey);
    _rowsPerPage = widget.controller.configuration.rowsPerPage;
    widget.controller.addListener(_handleControllerChange);
    widget.controller.onVisualize = _showChartPopup;
    widget.controller.onShowColumnChooser = () {
      setState(() {
        _isColumnChooserVisible = true;
      });
    };
    widget.controller.onReset = () {
      setState(() {
        _sortColumnKey = null;
        _sortAscending = null;
      });
    };
    _initializeInternalColumns();

    _verticalScrollController.addListener(
      () => _syncVerticalScroll(_verticalScrollController),
    );
    _frozenLeftScrollController.addListener(
      () => _syncVerticalScroll(_frozenLeftScrollController),
    );
    _frozenRightScrollController.addListener(
      () => _syncVerticalScroll(_frozenRightScrollController),
    );
  }

  void _syncVerticalScroll(ScrollController source) {
    if (!source.hasClients) return;
    final offset = source.offset;

    if (source != _verticalScrollController &&
        _verticalScrollController.hasClients) {
      if (_verticalScrollController.offset != offset) {
        _verticalScrollController.jumpTo(offset);
      }
    }
    if (source != _frozenLeftScrollController &&
        _frozenLeftScrollController.hasClients) {
      if (_frozenLeftScrollController.offset != offset) {
        _frozenLeftScrollController.jumpTo(offset);
      }
    }
    if (source != _frozenRightScrollController &&
        _frozenRightScrollController.hasClients) {
      if (_frozenRightScrollController.offset != offset) {
        _frozenRightScrollController.jumpTo(offset);
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    if (widget.controller.onVisualize == _showChartPopup) {
      widget.controller.onVisualize = null;
    }
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _frozenLeftScrollController.dispose();
    _frozenRightScrollController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted && !_isInternalUpdate) {
      setState(() {
        _initializeInternalColumns(resetSort: false);
      });
    }
  }

  void _initializeInternalColumns({bool resetSort = true}) {
    internalColumns = List.from(widget.controller.columnModels);

    if (widget.controller.configuration.allowRowReordering) {
      final bool alreadyHasReorder = internalColumns.any(
        (c) => c.key == '__reorder_column__',
      );
      if (!alreadyHasReorder) {
        internalColumns.insert(
          0,
          GridColumnModel(
            column: GridColumn(
              key: '__reorder_column__',
              title: '',
              width: 50,
              allowFiltering: false,
              allowSorting: false,
              resizable: false,
            ),
            width: 50,
            isVisible: true,
          ),
        );
      }
    }

    columnWidths = internalColumns.map((col) => col.width).toList();

    final sourceData = widget.controller.filteredData;
    filterDatasource = sourceData
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    _filteredUnsortedData = List.from(filterDatasource);
    if (resetSort) {
      _sortColumnKey = null;
      _sortAscending = null;
    } else {
      _applySort();
    }
    _currentPage = 0;
    _selectedRows.clear();
    _selectedCells.clear();
    _selectionStart = null;
    _selectionEnd = null;
    _selectionAnchor = null;
    _isSelecting = false;
    _hoveredRowIndex = null;
    _updateFlattenedItems();
    if (widget.onSearch != null) {
      widget.onSearch!(_filteredUnsortedData);
    }
  }

  @override
  void didUpdateWidget(Datagrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      if (oldWidget.controller.onVisualize == _showChartPopup) {
        oldWidget.controller.onVisualize = null;
      }

      widget.controller.addListener(_handleControllerChange);
      widget.controller.onVisualize = _showChartPopup;
      _initializeInternalColumns();
      return;
    }

    if (widget.controller.configuration.rowsPerPage !=
        oldWidget.controller.configuration.rowsPerPage) {
      _rowsPerPage = widget.controller.configuration.rowsPerPage;
    }

    bool columnsFundamentallyChanged = false;
    if (widget.controller.columnModels.isNotEmpty &&
        oldWidget.controller.columnModels.isNotEmpty) {
      if (widget.controller.columnModels.length !=
          oldWidget.controller.columnModels.length) {
        columnsFundamentallyChanged = true;
      } else {
        for (int i = 0; i < widget.controller.columnModels.length; i++) {
          if (widget.controller.columnModels[i].key !=
              oldWidget.controller.columnModels[i].key) {
            columnsFundamentallyChanged = true;
            break;
          }
        }
      }
    }

    if (columnsFundamentallyChanged) {
      _initializeInternalColumns();
    } else if (widget.controller.filteredData !=
        oldWidget.controller.filteredData) {
      // Data changed but columns are same structure
      filterDatasource = widget.controller.filteredData
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _filteredUnsortedData = List.from(filterDatasource);
      _applySort();
      setState(() {});
    }
  }

  void updateColumnWidth(int index, double newWidth) {
    setState(() {
      columnWidths[index] = newWidth;
      internalColumns[index].width = newWidth;
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (internalColumns[oldIndex].key == '__reorder_column__' ||
        internalColumns[newIndex].key == '__reorder_column__') {
      return;
    }

    setState(() {
      final List<GridColumnModel> newColumns = List.from(internalColumns);
      final GridColumnModel col = newColumns.removeAt(oldIndex);
      newColumns.insert(newIndex, col);
      internalColumns = newColumns;

      final List<double?> newWidths = List.from(columnWidths);
      final double? width = newWidths.removeAt(oldIndex);
      newWidths.insert(newIndex, width);
      columnWidths = newWidths;

      _isInternalUpdate = true;
      final userColumns = internalColumns
          .where((c) => c.key != '__reorder_column__')
          .toList();
      widget.controller.updateColumnModels(userColumns);
      _isInternalUpdate = false;
    });

    if (widget.onColumnReorder != null) {
      int actualOldIndex = oldIndex;
      int actualNewIndex = newIndex;

      if (widget.controller.configuration.allowRowReordering) {
        actualOldIndex--;
        actualNewIndex--;
      }

      widget.onColumnReorder!(actualOldIndex, actualNewIndex);
      widget.controller.onColumnReorder?.call(actualOldIndex, actualNewIndex);
    }
  }

  void _handleSort(String columnKey, {bool? ascending}) {
    setState(() {
      if (ascending != null) {
        _sortColumnKey = columnKey;
        _sortAscending = ascending;
      } else {
        if (_sortColumnKey == columnKey) {
          if (_sortAscending == true) {
            _sortAscending = false;
          } else if (_sortAscending == false) {
            _sortColumnKey = null;
            _sortAscending = null;
          } else {
            _sortAscending = true;
          }
        } else {
          _sortColumnKey = columnKey;
          _sortAscending = true;
        }
      }

      _applySort();
    });
  }

  void _applySort() {
    filterDatasource = List.from(_filteredUnsortedData);
    if (_sortColumnKey != null && _sortAscending != null) {
      final col = internalColumns.firstWhere(
        (c) => c.key == _sortColumnKey,
        orElse: () => internalColumns[0],
      );
      final bool isDateOrTime = [
        GridRowTypeEnum.date,
        GridRowTypeEnum.time,
        GridRowTypeEnum.dateTime,
      ].contains(col.type);
      final bool isTime = col.type == GridRowTypeEnum.time;

      filterDatasource.sort((a, b) {
        dynamic valA = a[_sortColumnKey!];
        dynamic valB = b[_sortColumnKey!];

        if (valA == null && valB == null) return 0;
        if (valA == null) return _sortAscending! ? 1 : -1;
        if (valB == null) return _sortAscending! ? -1 : 1;

        int result;
        if (isDateOrTime) {
          final dA = GridDateTimeUtils.tryParse(valA, isTime: isTime);
          final dB = GridDateTimeUtils.tryParse(valB, isTime: isTime);
          if (dA != null && dB != null) {
            result = dA.compareTo(dB);
          } else {
            result = valA.toString().compareTo(valB.toString());
          }
        } else if (valA is Comparable && valB is Comparable) {
          result = valA.compareTo(valB);
        } else {
          result = valA.toString().compareTo(valB.toString());
        }

        return _sortAscending! ? result : -result;
      });
    }
    _updateFlattenedItems();
  }

  void _updateFlattenedItems() {
    final groupedColumns = widget.controller.groupedColumns;
    if (groupedColumns.isEmpty) {
      _flattenedItems = _paginatedData;
    } else {
      final groupedData = DatagridUtils.groupData(
        data: filterDatasource,
        groupKeys: groupedColumns,
      );
      _flattenedItems = _flattenGroupedData(groupedData);
    }
  }

  List<dynamic> _flattenGroupedData(
    List<dynamic> data, {
    int level = 0,
    String parentId = '',
  }) {
    List<dynamic> flattened = [];
    for (var item in data) {
      if (item is Map && item['isGroup'] == true) {
        final groupId = parentId.isEmpty
            ? '${item['value']}'
            : '$parentId|${item['value']}';
        final groupWithMetadata = Map<String, dynamic>.from(item);
        groupWithMetadata['level'] = level;
        groupWithMetadata['groupId'] = groupId;
        flattened.add(groupWithMetadata);
        if (_expandedGroups.contains(groupId)) {
          flattened.addAll(
            _flattenGroupedData(
              item['children'] as List<dynamic>,
              level: level + 1,
              parentId: groupId,
            ),
          );
        }
      } else {
        final row = Map<String, dynamic>.from(item as Map<String, dynamic>);
        row['level'] = level;
        flattened.add(row);
      }
    }
    return flattened;
  }

  void _toggleGroup(String groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
      }
      _updateFlattenedItems();
    });
  }

  List<Map<String, dynamic>> get _paginatedData {
    if (!widget.controller.configuration.allowPagination) {
      return filterDatasource;
    }
    final int start = _currentPage * _rowsPerPage;
    final int end = start + _rowsPerPage;
    if (start >= filterDatasource.length) {
      return [];
    }
    return filterDatasource.sublist(
      start,
      end > filterDatasource.length ? filterDatasource.length : end,
    );
  }

  void _handleRowTap(Map<String, dynamic> row) {
    if (widget.onRowTap != null) {
      widget.onRowTap!(row);
    }

    if (widget.controller.configuration.selectionMode == SelectionMode.none) {
      return;
    }

    setState(() {
      if (widget.controller.configuration.selectionMode != SelectionMode.cell) {
        _selectionStart = null;
        _selectionEnd = null;
      }
      if (widget.controller.configuration.selectionMode ==
          SelectionMode.single) {
        if (_selectedRows.contains(row)) {
          _selectedRows.clear();
        } else {
          _selectedRows.clear();
          _selectedRows.add(row);
        }
      } else if (widget.controller.configuration.selectionMode ==
          SelectionMode.multiple) {
        if (_selectedRows.contains(row)) {
          _selectedRows.remove(row);
        } else {
          _selectedRows.add(row);
        }
      }
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(_selectedRows.toList());
    }
  }

  void _handleCellTapDown(int colIndex, int rowIndex) {
    if (widget.controller.configuration.selectionMode != SelectionMode.cell) {
      return;
    }
    // Prevent selection start on reorder column
    if (internalColumns[colIndex].key == '__reorder_column__') return;

    final isControlPressed =
        RawKeyboard.instance.keysPressed.contains(
          LogicalKeyboardKey.controlLeft,
        ) ||
        RawKeyboard.instance.keysPressed.contains(
          LogicalKeyboardKey.controlRight,
        );
    final isShiftPressed =
        RawKeyboard.instance.keysPressed.contains(
          LogicalKeyboardKey.shiftLeft,
        ) ||
        RawKeyboard.instance.keysPressed.contains(
          LogicalKeyboardKey.shiftRight,
        );

    final pos = CellPosition(rowIndex: rowIndex, columnIndex: colIndex);

    setState(() {
      if (isShiftPressed && _selectionAnchor != null) {
        _selectionStart = _selectionAnchor;
        _selectionEnd = pos;
      } else if (isControlPressed) {
        if (_selectedCells.any(
          (c) => c.rowIndex == rowIndex && c.columnIndex == colIndex,
        )) {
          _selectedCells.removeWhere(
            (c) => c.rowIndex == rowIndex && c.columnIndex == colIndex,
          );
        } else {
          _selectedCells.add(pos);
        }
        _selectionStart = pos;
        _selectionEnd = pos;
        _selectionAnchor = pos;
      } else {
        _selectedCells.clear();
        _selectionStart = pos;
        _selectionEnd = pos;
        _selectionAnchor = pos;
      }
      _isSelecting = true;
      _selectedRows.clear();
    });
  }

  void _handleCellPanUpdate(int colIndex, int rowIndex) {
    if (!_isSelecting) return;
    setState(() {
      _selectionEnd = CellPosition(rowIndex: rowIndex, columnIndex: colIndex);
    });
  }

  void _handleCellPanEnd() {
    setState(() {
      _isSelecting = false;
      // Commit the range to _selectedCells
      if (_selectionStart != null && _selectionEnd != null) {
        final minRow = _selectionStart!.rowIndex < _selectionEnd!.rowIndex
            ? _selectionStart!.rowIndex
            : _selectionEnd!.rowIndex;
        final maxRow = _selectionStart!.rowIndex > _selectionEnd!.rowIndex
            ? _selectionStart!.rowIndex
            : _selectionEnd!.rowIndex;
        final minCol = _selectionStart!.columnIndex < _selectionEnd!.columnIndex
            ? _selectionStart!.columnIndex
            : _selectionEnd!.columnIndex;
        final maxCol = _selectionStart!.columnIndex > _selectionEnd!.columnIndex
            ? _selectionStart!.columnIndex
            : _selectionEnd!.columnIndex;

        for (int r = minRow; r <= maxRow; r++) {
          for (int c = minCol; c <= maxCol; c++) {
            _selectedCells.add(CellPosition(rowIndex: r, columnIndex: c));
          }
        }
      }
      _selectionStart = null;
      _selectionEnd = null;
    });
  }

  bool _isCellSelected(int colIndex, int rowIndex) {
    // Exclude reorder column from usage as selected cell
    if (colIndex < internalColumns.length &&
        internalColumns[colIndex].key == '__reorder_column__') {
      return false;
    }

    final pos = CellPosition(rowIndex: rowIndex, columnIndex: colIndex);

    // Check if in discrete selection set
    if (_selectedCells.contains(pos)) return true;

    // Check if in current drag/range selection
    if (_selectionStart != null && _selectionEnd != null) {
      return pos.isWithin(_selectionStart!, _selectionEnd!);
    }

    return false;
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    int rowIndex, [
    int? columnIndex,
  ]) async {
    final config = widget.controller.configuration;

    if (columnIndex != null) {
      if (config.selectionMode == SelectionMode.cell) {
        if (!_isCellSelected(columnIndex, rowIndex)) {
          _handleCellTapDown(columnIndex, rowIndex);
        } else {
          // If already selected, ensure _selectionStart/End point to the clicked cell
          // so that actions like 'filter by selection' use the correct cell context
          _selectionStart = CellPosition(
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
          _selectionEnd = _selectionStart;
        }
      } else if (config.selectionMode == SelectionMode.single ||
          config.selectionMode == SelectionMode.multiple) {
        final row = _flattenedItems[rowIndex];
        if (row is Map<String, dynamic> && row['isGroup'] != true) {
          if (!_selectedRows.contains(row)) {
            _handleRowTap(row);
          }
          // Set selection start/end even in row mode so context actions know which cell was clicked
          _selectionStart = CellPosition(
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
          _selectionEnd = _selectionStart;
        }
      }
    }

    if ((_selectionStart == null || _selectionEnd == null) &&
        config.selectionMode == SelectionMode.none) {
      // If no selection logic, maybe just show simple menu or nothing?
      // For now, let's keep existing logic which relies on selection.
      // Or we can pretend the clicked row is selected for the action scope if reasonable.
      return;
    }

    final List<PopupMenuEntry<String>> items = [];

    if (config.useDefaultContextMenuItems) {
      if (config.showCopyMenuItem) {
        items.add(_buildMenuItem(Icons.copy, 'Copy', 'copy'));
      }
      if (config.showCopyHeaderMenuItem) {
        items.add(
          _buildMenuItem(Icons.copy_all, 'Copy with Header', 'copy_header'),
        );
      }

      if (config.showCopyMenuItem || config.showCopyHeaderMenuItem) {
        items.add(const PopupMenuDivider());
      }

      if (config.showEquationMenuItem) {
        items.add(
          _buildMenuItem(Icons.functions, 'Create Equation Column', 'equation'),
        );
        items.add(const PopupMenuDivider());
      }

      if (config.showSortMenuItem) {
        items.add(_buildMenuItem(Icons.sort, 'Sort Ascending', 'sort_asc'));
        items.add(
          _buildMenuItem(Icons.sort_by_alpha, 'Sort Descending', 'sort_desc'),
        );
        items.add(const PopupMenuDivider());
      }

      if (config.showFilterBySelectionMenuItem) {
        items.add(
          _buildMenuItem(Icons.filter_alt, 'Filter by Selection', 'filter'),
        );
      }
      if (config.showChartsMenuItem) {
        items.add(_buildMenuItem(Icons.bar_chart, 'Visualize Data', 'charts'));
      }
    }

    if (config.contextMenuItems != null) {
      if (items.isNotEmpty && items.last is! PopupMenuDivider) {
        items.add(const PopupMenuDivider());
      }
      for (var item in config.contextMenuItems!) {
        items.add(
          _buildMenuItem(
            item.icon,
            item.label,
            item.value,
            isDestructive: item.isDestructive,
          ),
        );
      }
    }

    final result = await showMenu<String>(
      context: context,
      color: config.filterPopupBackgroundColor,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1.0,
        position.dy + 1.0,
      ),
      items: items,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    if (result == null) return;

    final customItem = config.contextMenuItems
        ?.where((i) => i.value == result)
        .firstOrNull;
    if (customItem?.onPressed != null) {
      customItem!.onPressed!(_getSelectedData(), _getSelectedColumns());
      return;
    }

    switch (result) {
      case 'copy':
        _copyToClipboard(includeHeader: false);
        break;
      case 'copy_header':
        _copyToClipboard(includeHeader: true);
        break;
      case 'equation':
        _createEquationFromSelection();
        break;
      case 'sort_asc':
        _handleSort(internalColumns[_selectionStart!.columnIndex].key);
        break;
      case 'sort_desc':
        _handleSort(internalColumns[_selectionStart!.columnIndex].key);
        if (_sortAscending == true) {
          _handleSort(internalColumns[_selectionStart!.columnIndex].key);
        }
        break;
      case 'filter':
        _filterBySelection();
        break;
      case 'charts':
        _prepareChartData();
        break;
      case 'delete':
        _showDummyAction('Delete functionality is currently disabled');
        break;
    }
  }

  void _createEquationFromSelection() {
    final selectedCols = _getSelectedColumns();
    if (selectedCols.isEmpty) return;

    // Use titles for better UX
    String formula = selectedCols.map((c) => c.column.title).join(" + ");

    // Create a dummy model to pass the formula
    final dummy = GridColumnModel(
      column: GridColumn(key: '', title: '', formula: formula),
    );

    showDialog(
      context: context,
      builder: (context) =>
          FormulaBuilderDialog(controller: widget.controller, existing: dummy),
    );
  }

  List<Map<String, dynamic>> _getSelectedData() {
    if (_selectedCells.isEmpty) {
      return DatagridLogicHelper.getSelectedData(
        start: _selectionStart,
        end: _selectionEnd,
        flattenedItems: _flattenedItems,
      );
    }

    final Set<int> rowIndices = _selectedCells.map((c) => c.rowIndex).toSet();
    final List<Map<String, dynamic>> selectedData = [];
    for (var idx in rowIndices) {
      if (idx >= 0 && idx < _flattenedItems.length) {
        final item = _flattenedItems[idx];
        if (item is Map<String, dynamic> && item['isGroup'] != true) {
          selectedData.add(item);
        }
      }
    }
    return selectedData;
  }

  List<GridColumnModel> _getSelectedColumns() {
    if (_selectedCells.isEmpty) {
      return DatagridLogicHelper.getSelectedColumns(
        start: _selectionStart,
        end: _selectionEnd,
        internalColumns: internalColumns,
      );
    }

    final Set<int> colIndices = _selectedCells
        .map((c) => c.columnIndex)
        .toSet();
    final List<GridColumnModel> selected = [];
    for (var idx in colIndices) {
      if (idx >= 0 && idx < internalColumns.length) {
        selected.add(internalColumns[idx]);
      }
    }
    return selected;
  }

  void _copyToClipboard({required bool includeHeader}) {
    DatagridLogicHelper.copyToClipboard(
      rows: _getSelectedData(),
      cols: _getSelectedColumns(),
      includeHeader: includeHeader,
    );
    _showDummyAction('Copied to clipboard');
  }

  void _filterBySelection() {
    if (_selectionStart == null) return;
    final row = _flattenedItems[_selectionStart!.rowIndex];
    if (row is! Map<String, dynamic>) return;

    final col = internalColumns[_selectionStart!.columnIndex];
    final value = row[col.key];

    col.notSelectedFilterData = FilterUtils.getExcludedValuesForSelection(
      data: widget.controller.data,
      columnKey: col.key,
      selectedValue: value,
    );
    col.filter = true;

    _filteredUnsortedData = FilterUtils.performFiltering(
      data: widget.controller.data,
      allColumns: internalColumns,
      globalSearch: widget.controller.globalSearchText,
    ).map((e) => Map<String, dynamic>.from(e)).toList();

    _applySort();
    _currentPage = 0;

    _isInternalUpdate = true;
    widget.controller.updateFilteredData(_filteredUnsortedData);
    _isInternalUpdate = false;

    _updateFlattenedItems();
    if (widget.onSearch != null) {
      widget.onSearch!(_filteredUnsortedData);
    }
    setState(() {});
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String label,
    String value, {
    bool isDestructive = false,
  }) {
    final destructiveColor =
        widget.controller.configuration.contextMenuDestructiveColor ??
        Colors.red;
    final iconColor =
        widget.controller.configuration.contextMenuIconColor ??
        Colors.grey[700];
    final textColor =
        widget.controller.configuration.contextMenuTextColor ?? Colors.black87;

    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? destructiveColor : iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? destructiveColor : textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDummyAction(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        width: 300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _prepareChartData() {
    final selectedData = _getSelectedData();
    final selectedColumns = _getSelectedColumns();

    if (selectedData.isEmpty || selectedColumns.isEmpty) {
      return;
    }

    // Filter columns that have numeric values for charting
    final numericColumns = selectedColumns.where((col) {
      if (selectedData.isEmpty) return false;
      final val = selectedData[0][col.column.key];
      return val is num || (val is String && double.tryParse(val) != null);
    }).toList();

    if (numericColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No numeric data selected for charts')),
      );
      return;
    }

    _showChartPopup(selectedData, selectedColumns);
  }

  void _showChartPopup(
    List<Map<String, dynamic>> data,
    List<GridColumnModel> columns,
  ) {
    final Size screenSize = MediaQuery.of(context).size;
    if (screenSize.width < 600) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                ChartPopup(
                  data: data,
                  columns: columns,
                  onClose: () => Navigator.of(context).pop(),
                  configuration: widget.controller.configuration,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      setState(() {
        final id = DateTime.now().toIso8601String();
        // Simple cascade offset
        final offset = 50.0 + (_activeCharts.length * 30.0);

        _activeCharts.add(
          ChartInstance(
            id: id,
            data: data,
            columns: columns,
            initialPosition: Offset(offset, offset),
          ),
        );
      });
    }
  }

  void _handleSearch(dynamic newData) {
    final List<Map<String, dynamic>> mappedData = (newData as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _filteredUnsortedData = mappedData;
    _applySort();
    _currentPage = 0;

    _isInternalUpdate = true;
    widget.controller.updateFilteredData(mappedData);
    _isInternalUpdate = false;
    _updateFlattenedItems();

    if (widget.onSearch != null) {
      widget.onSearch!(newData);
    }
    setState(() {});
  }

  void _handleQuickSearch(String key, String value) {
    final col = internalColumns.firstWhere((c) => c.key == key);
    col.quickFilterText = value;
    col.filter = value.isNotEmpty;

    final newData = FilterUtils.performFiltering(
      data: widget.controller.data,
      allColumns: internalColumns,
      globalSearch: widget.controller.globalSearchText,
    ).map((e) => Map<String, dynamic>.from(e)).toList();

    _filteredUnsortedData = newData;
    _applySort();
    _currentPage = 0;

    _isInternalUpdate = true;
    widget.controller.updateFilteredData(newData);
    _isInternalUpdate = false;
    _updateFlattenedItems();

    if (widget.onSearch != null) {
      widget.onSearch!(newData);
    }
    setState(() {});
  }

  void _handleHoverChanged(int? index) {
    if (_hoveredRowIndex != index) {
      setState(() {
        _hoveredRowIndex = index;
      });
    }
  }

  void _handleRowReorder(int oldIndex, int newIndex) async {
    if (_sortColumnKey != null || widget.controller.groupedColumns.isNotEmpty) {
      return;
    }

    // Adjust for pagination if necessary
    int actualOldIndex = oldIndex;
    int actualNewIndex = newIndex;

    if (widget.controller.configuration.allowPagination) {
      actualOldIndex += _currentPage * _rowsPerPage;
      actualNewIndex += _currentPage * _rowsPerPage;
    }

    if (actualOldIndex < 0 ||
        actualOldIndex >= filterDatasource.length ||
        actualNewIndex < 0 ||
        actualNewIndex > filterDatasource.length) {
      return;
    }

    if (widget.onBeforeRowReorder != null) {
      final canReorder = await widget.onBeforeRowReorder!(
        actualOldIndex,
        actualNewIndex,
      );
      if (!canReorder) return;
    } else if (widget.controller.onBeforeRowReorder != null) {
      final canReorder = await widget.controller.onBeforeRowReorder!(
        actualOldIndex,
        actualNewIndex,
      );
      if (!canReorder) return;
    }

    setState(() {
      final item = filterDatasource.removeAt(actualOldIndex);
      filterDatasource.insert(actualNewIndex, item);
      _updateFlattenedItems();
    });

    if (widget.onRowReorder != null) {
      widget.onRowReorder!(actualOldIndex, actualNewIndex);
    }
    widget.controller.onRowReorder?.call(actualOldIndex, actualNewIndex);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final config = widget.controller.configuration;

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() {
            _selectionStart = null;
            _selectionEnd = null;
            _selectedRows.clear();
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!([]);
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        key: _gridKey,
        clipBehavior: Clip.none,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: config.shrinkWrapRows
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  if (config.showGroupingPanel && config.enableGrouping)
                    GridGroupPanel(
                      controller: widget.controller,
                      groupedColumns: widget.controller.groupedColumns,
                      internalColumns: internalColumns,
                      configuration: config,
                      onGroupAdded: (key) => setState(
                        () => widget.controller.addGroupedColumn(key),
                      ),
                      onGroupRemoved: (key) => setState(() {
                        widget.controller.removeGroupedColumn(key);
                        _expandedGroups.clear();
                      }),
                      onGroupReordered: (oldIndex, newIndex) => setState(() {
                        widget.controller.reorderGroupedColumns(
                          oldIndex,
                          newIndex,
                        );
                        _expandedGroups.clear();
                      }),
                      onClearAll: () => setState(() {
                        widget.controller.clearGroupedColumns();
                        _expandedGroups.clear();
                      }),
                    ),
                  MaybeExpanded(
                    expand: !config.shrinkWrapRows,
                    child: MaybeIntrinsicHeight(
                      intrinsic: config.shrinkWrapRows,
                      child: Row(
                        children: [
                          GridSidePanel(
                            controller: widget.controller,
                            onClose: () {},
                            isExpanded: _isSidePanelExpanded,
                            onExpansionChanged: (v) =>
                                setState(() => _isSidePanelExpanded = v),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: config.gridBorderColor.withOpacityNew(0.1),
                          ),
                          Expanded(
                            child: GridMainContainer(
                              controller: widget.controller,
                              internalColumns: internalColumns,
                              columnWidths: columnWidths,
                              filterDatasource: filterDatasource,
                              horizontalScrollController:
                                  _horizontalScrollController,
                              verticalScrollController:
                                  _verticalScrollController,
                              frozenLeftScrollController:
                                  _frozenLeftScrollController,
                              frozenRightScrollController:
                                  _frozenRightScrollController,
                              constraints: constraints,
                              isSidePanelExpanded: _isSidePanelExpanded,
                              flattenedItems: _flattenedItems,
                              expandedGroups: _expandedGroups,
                              selectedRows: _selectedRows,
                              hoveredRowIndex: _hoveredRowIndex,
                              onToggleGroup: _toggleGroup,
                              onRowTap: _handleRowTap,
                              onCellTapDown: _handleCellTapDown,
                              onCellPanUpdate: _handleCellPanUpdate,
                              onCellPanEnd: _handleCellPanEnd,
                              isCellSelected: _isCellSelected,
                              onShowContextMenu: _showContextMenu,
                              onHoverChanged: _handleHoverChanged,
                              onColumnResize: updateColumnWidth,
                              onSearch: _handleSearch,
                              onSort: _handleSort,
                              onReorder: _handleReorder,
                              onRowReorder: _handleRowReorder,
                              onQuickSearchChanged: _handleQuickSearch,
                              sortColumnKey: _sortColumnKey,
                              sortAscending: _sortAscending,
                              isEditing: widget.isEditing,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (config.allowPagination)
                    GridFooter(
                      totalRows: filterDatasource.length,
                      configuration: widget.controller.configuration,
                      currentPage: _currentPage,
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (rows) {
                        setState(() {
                          _rowsPerPage = rows;
                          _currentPage = 0;
                          _updateFlattenedItems();
                        });
                      },
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          _updateFlattenedItems();
                        });
                      },
                    ),
                ],
              );
            },
          ),
          ..._activeCharts.map(
            (chart) => ChartPopup(
              key: ValueKey(chart.id),
              data: chart.data,
              columns: chart.columns,
              initialPosition: chart.initialPosition,
              onClose: () {
                setState(() {
                  _activeCharts.removeWhere((c) => c.id == chart.id);
                });
              },
              onBringToFront: () {
                setState(() {
                  _activeCharts.remove(chart);
                  _activeCharts.add(chart);
                });
              },
              configuration: widget.controller.configuration,
            ),
          ),
          if (_isColumnChooserVisible)
            ColumnChooserPopup(
              controller: widget.controller,
              onClose: () {
                setState(() {
                  _isColumnChooserVisible = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
