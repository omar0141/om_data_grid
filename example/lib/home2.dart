import 'package:flutter/material.dart';
import 'package:om_data_grid/om_data_grid.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  late DatagridController _controller;
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
      GridColumn(
        key: "ID",
        title: "ID",
        width: 80,
        type: GridRowTypeEnum.integer,
        thousandsSeparator: ',',
        showPlaceholderWhileScrolling: false,
      ),
      GridColumn(
        key: "Name",
        title: "Full Name",
        width: 180,
        showPlaceholderWhileScrolling: false,
        canBeXAxis: true,
      ),
      GridColumn(
        key: "Job",
        title: "Department",
        width: 150,
        type: GridRowTypeEnum.comboBox,
        comboBoxSettings: GridComboBoxSettings(
          items: [
            GridComboBoxItem(value: '1', text: 'Development'),
            GridComboBoxItem(value: '2', text: 'Design'),
            GridComboBoxItem(value: '3', text: 'Marketing'),
            GridComboBoxItem(value: '4', text: 'Sales'),
            GridComboBoxItem(value: '5', text: 'HR'),
          ],
        ),
        displayKey: "label",
        valueKey: "value",
        showPlaceholderWhileScrolling: false,
        canBeXAxis: true,
      ),
      GridColumn(
        key: "Experience",
        title: "Years Exp",
        width: 120,
        type: GridRowTypeEnum.integer,
        canBeYAxis: true,
      ),
      GridColumn(
        key: "Rating",
        title: "Performance",
        width: 120,
        type: GridRowTypeEnum.double,
        decimalSeparator: '.',
        thousandsSeparator: ',',
        decimalDigits: 1,
        canBeYAxis: true,
      ),
      GridColumn(
        key: "Date",
        title: "Join Date",
        type: GridRowTypeEnum.date,
        customDateFormat: "yyyy-MM-dd",
        width: 140,
      ),
      GridColumn(
        key: "Time",
        title: "Shift",
        type: GridRowTypeEnum.time,
        customDateFormat: "HH:mm",
        width: 100,
      ),
      GridColumn(
        key: "LastLogin",
        title: "Last Seen",
        type: GridRowTypeEnum.dateTime,
        customDateFormat: "dd/MM/yyyy HH:mm",
      ),
      GridColumn(
        key: "Status",
        title: "Status",
        type: GridRowTypeEnum.state,
        stateConfig: {
          'Active': const StateConfig(
            style: StateStyle.tinted,
            color: Colors.green,
            label: "Active",
          ),
          'Pending': const StateConfig(
            style: StateStyle.tinted,
            color: Colors.orange,
            label: "Pending",
          ),
          'Inactive': const StateConfig(
            style: StateStyle.tinted,
            color: Colors.red,
            label: "Inactive",
          ),
        },
      ),
      GridColumn(
        key: "Avatar",
        title: "Avatar",
        type: GridRowTypeEnum.image,
        width: 100,
        imageBorderRadius: 100,
      ),
      GridColumn(
        key: "Salary",
        title: "Annual Salary",
        width: 180,
        type: GridRowTypeEnum.double,
        thousandsSeparator: ',',
        decimalSeparator: '.',
      ),
      GridColumn(
        key: "delete",
        title: "Delete",
        width: 80,
        type: GridRowTypeEnum.delete,
        onDelete: (row) async {
          // print("Deleting row: ${row['ID']}");
        },
      ),
    ].map((col) => GridColumnModel(column: col, width: col.width)).toList();

    _controller = DatagridController(
      data: data,
      columnModels: columnModels,
      configuration: DatagridConfiguration(
        primaryColor: Color(0xFF1E293B),
        paginationSelectedBackgroundColor: Color(0xFF1E293B),
        headerBackgroundColor: Color.fromRGBO(250, 250, 250, 1),
        headerForegroundColor: Colors.black,
        rowBorderColor: Color.fromARGB(255, 214, 214, 214),
        headerBorderColor: Color.fromARGB(255, 214, 214, 214),
        groupPanelBorderColor: Color.fromARGB(255, 214, 214, 214),
        filterIconColor: Colors.black87,
        sortIconColor: Colors.black87,
        minColumnWidth: 100,
        columnWidthMode: ColumnWidthMode.fill,
        selectionMode: SelectionMode.cell,
        allowPagination: true,
        rowsPerPage: 5000,
        rowHeight: 45,
        quickFilters: [QuickFilterConfig(columnKey: "Job")],
        showSettingsButton: true,
        showClearFiltersButton: true,
        enableGrouping: true,
        showGroupingPanel: true,
        rowBorderVisibility: GridBorderVisibility.horizontal,
        headerBorderVisibility: GridBorderVisibility.horizontal,
        showQuickSearch: false,
        showGlobalSearch: true,
        footerFrozenColumnCount: 1,
        frozenColumnCount: 4,
        frozenPaneElevation: 0.5,
        allowRowReordering: false,
        showAddButton: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Standalone QuickFilterBar taking only the controller
            QuickFilterBar(
              controller: _controller,
              onAddPressed: () {
                data.add({
                  "ID": _controller.data.length + 1,
                  "Name": "New Employee",
                  "Job": "Development",
                  "Salary": 50000,
                  "Experience": 1,
                  "Rating": 3.5,
                  "Bonus": 5,
                  "Date": "2024-01-01",
                  "Time": "09:00",
                  "LastLogin": DateTime.now(),
                  "IsActive": true,
                  "Avatar":
                      "https://api.dicebear.com/7.x/avataaars/png?seed=${_controller.data.length + 1}",
                  "Status": 'Active',
                });
                _controller.updateData(data);
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
                  child: Datagrid(controller: _controller, isEditing: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
