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

  @override
  void initState() {
    super.initState();
    data = List.generate(10000, (index) {
      final departments = ['Development', 'Design', 'Marketing', 'Sales', 'HR'];
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
        labels: OmDataGridLabels.ar(),
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
      body: Container(
        margin: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Standalone OmQuickFilterBar taking only the controller
            OmQuickFilterBar(
              title: "Employees",
              controller: _controller,
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
                  border: Border.all(
                    color: Colors.grey.withAlpha(51),
                    width: 1,
                  ),
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
                    controller: _controller,
                    onRowTap: _editEmployee,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
