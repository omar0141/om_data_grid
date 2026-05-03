import 'package:flutter/material.dart';
import 'package:om_data_grid/om_data_grid.dart';
import 'employee_dialog.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  late OmDataGridController _controller;
  List<Map<String, dynamic>> data = [];

  // ── Standalone sort state (used by custom toolbar demo) ────────────────────
  String? _customSortKey;
  bool _customSortAscending = true;

  @override
  void initState() {
    super.initState();
    data = List.generate(10000, (index) {
      final departments = ['1', '2', '3', '4', '5'];
      final names = [
        'John Doe',
        'Jane Smith',
        'Sam Johnson',
        'Alice Brown',
        'Bob White',
        'Charlie Green',
        'Diana Ross',
        'Edward Norton',
        'Fiona Apple',
        'George Bush',
      ];
      return {
        "ID": index + 1,
        "Name": names[index % names.length],
        "Job": departments[index % departments.length],
        "Salary": 45000.5 + (index * 750) + (index % 3 == 0 ? 5000 : 0),
        "Experience": (index % 15) + 1,
        "Rating": (3.5 + (index % 15) / 10).clamp(1.0, 5.0),
        "Bonus": 5 + (index % 10),
        "Date": "2023-${(index % 12) + 1}-${(index % 28) + 1}",
        "Time": "${10 + (index % 12)}:30",
        "LastLogin": DateTime.now().subtract(Duration(days: index)),
        "Avatar":
            "https://api.dicebear.com/7.x/avataaars/png?seed=${index + 1}",
        "Status": ['Active', 'Pending', 'Inactive'][index % 3],
      };
    });

    final columnModels = [
      OmGridColumn(
        key: "ID",
        title: "ID",
        width: 80,
        type: OmGridRowTypeEnum.integer,
        thousandsSeparator: ',',
        showPlaceholderWhileScrolling: false,
      ),
      OmGridColumn(
        key: "Name",
        title: "Full Name",
        width: 180,
        showPlaceholderWhileScrolling: false,
        canBeXAxis: true,
      ),
      OmGridColumn(
        key: "Job",
        title: "Department",
        width: 150,
        type: OmGridRowTypeEnum.comboBox,
        comboBoxSettings: OmGridComboBoxSettings(
          items: [
            OmGridComboBoxItem(value: '1', text: 'Development'),
            OmGridComboBoxItem(value: '2', text: 'Design'),
            OmGridComboBoxItem(value: '3', text: 'Marketing'),
            OmGridComboBoxItem(value: '4', text: 'Sales'),
            OmGridComboBoxItem(value: '5', text: 'HR'),
          ],
        ),
        displayKey: "label",
        valueKey: "value",
        showPlaceholderWhileScrolling: false,
        canBeXAxis: true,
      ),
      OmGridColumn(
        key: "Experience",
        title: "Years Exp",
        width: 120,
        type: OmGridRowTypeEnum.integer,
        canBeYAxis: true,
      ),
      OmGridColumn(
        key: "Rating",
        title: "Performance",
        width: 120,
        type: OmGridRowTypeEnum.double,
        decimalSeparator: '.',
        thousandsSeparator: ',',
        decimalDigits: 1,
        canBeYAxis: true,
      ),
      OmGridColumn(
        key: "Date",
        title: "Join Date",
        type: OmGridRowTypeEnum.date,
        customDateFormat: "yyyy-MM-dd",
        width: 140,
      ),
      OmGridColumn(
        key: "Time",
        title: "Shift",
        type: OmGridRowTypeEnum.time,
        customDateFormat: "HH:mm",
        width: 100,
      ),
      OmGridColumn(
        key: "LastLogin",
        title: "Last Seen",
        type: OmGridRowTypeEnum.dateTime,
        customDateFormat: "dd/MM/yyyy HH:mm",
      ),
      OmGridColumn(
        key: "Status",
        title: "Status",
        type: OmGridRowTypeEnum.state,
        stateConfig: {
          'Active': const OmStateConfig(
            style: OmStateStyle.tinted,
            color: Colors.green,
            label: "Active",
          ),
          'Pending': const OmStateConfig(
            style: OmStateStyle.tinted,
            color: Colors.orange,
            label: "Pending",
          ),
          'Inactive': const OmStateConfig(
            style: OmStateStyle.tinted,
            color: Colors.red,
            label: "Inactive",
          ),
        },
      ),
      OmGridColumn(
        key: "Avatar",
        title: "Avatar",
        type: OmGridRowTypeEnum.image,
        width: 100,
        imageBorderRadius: 100,
      ),
      OmGridColumn(
        key: "Salary",
        title: "Annual Salary",
        width: 180,
        type: OmGridRowTypeEnum.double,
        thousandsSeparator: ',',
        decimalSeparator: '.',
      ),
      OmGridColumn(
        key: "delete",
        title: "Delete",
        width: 80,
        type: OmGridRowTypeEnum.delete,
        onDelete: (row) async {
          data.removeWhere((e) => e['ID'] == row['ID']);
          _controller.updateData(data);
        },
      ),
    ].map((col) => OmGridColumnModel(column: col, width: col.width)).toList();

    _controller = OmDataGridController(
      data: data,
      columnModels: columnModels,
      configuration: OmDataGridConfiguration.fromTheme(
        theme: OmDataGridTheme.light(),
        selectionMode: OmSelectionMode.cell,
        allowPagination: true,
        rowsPerPage: 5000,
        rowHeight: 45,
        minColumnWidth: 100,
        columnWidthMode: OmColumnWidthMode.fill,
        showSettingsButton: true,
        showClearFiltersButton: true,
        enableGrouping: true,
        showGroupingPanel: true,
        rowBorderVisibility: OmGridBorderVisibility.horizontal,
        headerBorderVisibility: OmGridBorderVisibility.horizontal,
        showQuickSearch: false,
        showGlobalSearch: true,
        footerFrozenColumnCount: 1,
        frozenColumnCount: 4,
        frozenPaneElevation: 0.5,
        allowRowReordering: false,
        showAddButton: true,
        labels: OmDataGridLabels.en(),
        rowsPerPageOptions: [
          10,
          20,
          35,
          50,
          100,
          200,
          500,
          1000,
          2000,
          5000,
          10000,
        ],
      ),
    );
  }

  void _editEmployee(Map<String, dynamic> row) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EmployeeDialog(
        employee: row,
        primaryColor: _controller.configuration.primaryColor,
      ),
    );

    if (result != null) {
      final index = data.indexWhere((e) => e['ID'] == row['ID']);
      if (index != -1) {
        data[index] = result;
        _controller.updateData(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee updated successfully')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return isMobile ? _buildMobile() : _buildDesktop();
        },
      ),
    );
  }

  // ── Standalone sort helper ─────────────────────────────────────────────────

  void _applyCustomSort(String key, bool ascending) {
    setState(() {
      _customSortKey = key;
      _customSortAscending = ascending;
    });
    // No manual data manipulation needed — the grid reads externalSortKey
    // via didUpdateWidget and re-sorts its internal _filteredData.
  }

  void _clearCustomSort() {
    setState(() => _customSortKey = null);
    // Grid will re-run _applySort with no sort key, restoring original order.
  }

  // ── Mobile layout ──────────────────────────────────────────────────────────

  Widget _buildMobile() {
    final config = _controller.configuration;
    final primary = config.primaryColor;
    final hasSortActive = _customSortKey != null;
    final hasFilterActive = _controller.columnModels.any((c) => c.isFiltered);

    return Column(
      children: [
        // ── Custom toolbar: your own widgets calling the static methods ──────
        Container(
          color: config.menuBackgroundColor ?? Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  'Employees',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: config.gridForegroundColor,
                  ),
                ),
              ),

              // ── Sort button ── calls OmMobileSortSheet.show() directly ──
              _CustomToolbarButton(
                icon: Icons.sort_rounded,
                isActive: hasSortActive,
                primaryColor: primary,
                borderColor: config.gridBorderColor,
                onTap: () async {
                  final result = await OmMobileSortSheet.show(
                    context: context,
                    columns: _controller.columnModels,
                    configuration: config,
                    currentSortKey: _customSortKey,
                    currentAscending: _customSortAscending,
                  );
                  if (result == null) return; // user cancelled
                  if (result.isClear) {
                    _clearCustomSort();
                  } else {
                    _applyCustomSort(result.columnKey, result.ascending);
                  }
                },
              ),

              const SizedBox(width: 8),

              // ── Filter button ── calls OmMobileFilterSheet.show() directly ─
              _CustomToolbarButton(
                icon: Icons.filter_list_rounded,
                isActive: hasFilterActive,
                primaryColor: primary,
                borderColor: config.gridBorderColor,
                onTap: () async {
                  await OmMobileFilterSheet.show(
                    context: context,
                    columns: _controller.columnModels,
                    data: _controller.data,
                    filteredData: _controller.filteredData,
                    configuration: config,
                    onSearch: (filtered) {
                      _controller.updateFilteredData(
                        filtered.cast<Map<String, dynamic>>(),
                      );
                      // Re-apply sort on top of the new filtered set.
                      if (_customSortKey != null) {
                        _applyCustomSort(_customSortKey!, _customSortAscending);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // ── Grid: toolbar hidden because we drive it from above ──────────────
        Expanded(
          child: OmMobileDataGrid(
            controller: _controller,
            viewType: OmMobileViewType.list,
            scrollMode: OmMobileScrollMode.pagination,
            showToolbar: true,
            stickyPagination: false,
            stickyToolbar: false,
            showFilterButton: false,
            showSortButton: false,
            showEntriesBar: false,
            stickyChips: false,
            externalSortKey: _customSortKey,
            externalSortAscending: _customSortAscending,
            onExternalSortClear: _clearCustomSort,
            onRowTap: _editEmployee,
          ),
        ),
      ],
    );
  }

  // ── Desktop layout ─────────────────────────────────────────────────────────

  Widget _buildDesktop() {
    return Container(
      margin: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OmQuickFilterBar(
            title: "Employees",
            controller: _controller,
            isEditing: true,
            onAddPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => EmployeeDialog(
                  primaryColor: _controller.configuration.primaryColor,
                ),
              );

              if (result != null) {
                setState(() {
                  final nextId = data.isEmpty
                      ? 1
                      : (data
                                .map((e) => e['ID'] as int)
                                .reduce((a, b) => a > b ? a : b) +
                            1);
                  result['ID'] = nextId;
                  data.insert(0, result);
                  _controller.updateData(data);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withAlpha(51), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.circular(12),
                child: OmDataGrid(
                  isEditing: true,
                  controller: _controller,
                  // onRowTap: _editEmployee,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widget used only in HomeScreen2 mobile custom toolbar ─────────────

class _CustomToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color primaryColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _CustomToolbarButton({
    required this.icon,
    required this.isActive,
    required this.primaryColor,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withOpacity(0.1)
                  : borderColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? primaryColor.withOpacity(0.4)
                    : borderColor.withOpacity(0.25),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? primaryColor : borderColor,
            ),
          ),
          if (isActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
