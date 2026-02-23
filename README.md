# om_data_grid

A high-performance, feature-rich, and fully customizable DataGrid for Flutter. Designed to handle large datasets with ease while providing enterprise-grade features like advanced filtering, multi-level grouping, and built-in visualization.

[![Pub Version](https://img.shields.io/pub/v/om_data_grid)](https://pub.dev/packages/om_data_grid)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🌐 Live Demo

Check out the interactive demo: **[Live Web Demo](https://omar0141.github.io/om_data_grid_release/)**

---

## 📑 Table of Contents

- [🚀 Key Features](#-key-features)
- [🌐 Live Demo](#-live-demo)
- [🛠 Installation](#-installation)
- [📖 Quick Start](#-quick-start)
- [🧩 Advanced Usage](#-advanced-usage)
  - [Column Types](#column-types)
  - [Calculated Columns (Formulas)](#calculated-columns-formulas)
  - [Custom Aggregations](#custom-aggregations)
  - [Theming & UI](#theming--ui)
  - [Context Menus](#context-menus)
  - [Side Panel Customization](#side-panel-customization)
- [📊 Grid Features in Depth](#-grid-features-in-depth)
- [🛠 API Reference](#-api-reference)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🚀 Key Features

- **⚡ Enterprise-Grade Performance**: Built with row and column virtualization to smoothly handle 100,000+ records.
- **🔍 Advanced Filtering System**:
  - Global search with substring highlighting.
  - Quick filter bar for rapid data slicing.
  - Advanced UI filtering per column (Contains, Equals, Starts With, Numeric ranges, etc.).
- **📊 Integrated Data Visualization**: Built-in support for 15+ chart types including Column, Bar, Line, Area, Pie, Doughnut, and more (using Syncfusion).
- **📁 Grouping & Hierarchical Views**:
  - Drag and drop columns to group data dynamically.
  - Multi-level grouping supports nested data exploration.
- **🔢 Aggregations & Summaries**: Automatic calculations in footer rows (Sum, Average, Count, Min, Max, First, Last).
- **📝 Rich Content Support**: Built-in editors for Dates, Checkboxes, Switches, Images, and Files (including Multi-Image/File support).
- **📍 Pinning & Reordering**:
  - Freeze columns/rows to the left, right, top, or bottom.
  - Intuitive drag-and-drop for column and row reordering.
- **💾 Professional Exporting**: Seamlessly export current or filtered views to **Excel (.xlsx)** and **PDF**.

---

## 🛠 Installation

Add `om_data_grid` to your `pubspec.yaml`:

```yaml
dependencies:
  om_data_grid: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## 📖 Quick Start

### 1. Simple Data Structure

```dart
final List<Map<String, dynamic>> myData = [
  {"id": 1, "name": "John Doe", "role": "Developer", "salary": 75000},
  {"id": 2, "name": "Jane Smith", "role": "Designer", "salary": 82000},
];
```

### 2. Configure Your Columns

```dart
final List<GridColumn> columns = [
  GridColumn(key: 'id', title: 'ID', width: 80, type: GridRowTypeEnum.number),
  GridColumn(key: 'name', title: 'Name', width: 150, type: GridRowTypeEnum.text),
  GridColumn(key: 'role', title: 'Role', width: 120, type: GridRowTypeEnum.comboBox),
  GridColumn(key: 'salary', title: 'Salary', width: 130, type: GridRowTypeEnum.double),
];
```

### 3. Initialize Controller & Widget

```dart
final controller = DatagridController(
  data: myData,
  columnModels: columns.map((c) => GridColumnModel(column: c)).toList(),
  configuration: DatagridConfiguration(
    primaryColor: Colors.teal,
    allowPagination: true,
  ),
);

// In your build method
Datagrid(controller: controller)
```

---

## 🧩 Advanced Usage

### Column Types

`om_data_grid` handles much more than just text:

- `GridRowTypeEnum.image`: URL/Asset image display.
- `GridRowTypeEnum.multiImage`: Carousel for multiple images.
- `GridRowTypeEnum.iosSwitch`: Interactive boolean toggle.
- `GridRowTypeEnum.date`: Date picker integration with customizable formatting.
- `GridRowTypeEnum.state`: Conditional status indicators with icons.

### Calculated Columns (Formulas)

Create columns that perform live calculations:

```dart
GridColumn(
  key: 'total_comp',
  title: 'Total Comp',
  // Formula using other column keys
  formula: 'salary + bonus',
  type: GridRowTypeEnum.number,
)
```

### Custom Aggregations

Show summaries at the grid or group level:

```dart
GridColumn(
  key: 'salary',
  title: 'Salary',
  // Options: sum, avg, count, min, max, first, last
  aggregationType: AggregationType.avg,
)
```

### Theming & UI

Customize every pixel of the grid's appearance:

```dart
DatagridConfiguration(
  headerBackgroundColor: Color(0xFF1A1A1A),
  headerForegroundColor: Colors.white,
  rowHoverColor: Colors.blue.withOpacity(0.05),
  gridBorderColor: Colors.grey.shade300,
  rowHeight: 45.0,
  headerHeight: 55.0,
  columnWidthMode: ColumnWidthMode.fitByCellValue,
)
```

### Context Menus

Add custom actions to rows or columns:

```dart
GridColumn(
  key: 'name',
  title: 'Name',
  contextMenuOptions: [
    RowContextMenuItem(
      label: 'Send Email',
      icon: Icons.email,
      onTap: (row) => print('Emailing ${row['name']}'),
    ),
  ],
)
```

### Side Panel Customization

Add your own tools to the grid's side panel:

```dart
DatagridController(
  additionalSidePanelTabs: [
    GridSidePanelTab(
      id: 'custom_reports',
      icon: Icons.analytics,
      label: 'Reports',
      builder: (context, controller) => MyCustomReportWidget(controller: controller),
    ),
  ],
)
```

---

## 📊 Grid Features in Depth

### Data Visualization

The grid isn't just a list; it's an analysis tool. Built-in "Visualize" actions allow users to instantly turn any filtered dataset into a dashboard of charts (Pie, Bar, Column, Area, etc.) with customizable axes and sorting.

### Exporting & Sharing

- **Excel**: Full support for `.xlsx` export, including calculated columns and current filtering state.
- **PDF**: Cleanly formatted PDF reports of your data grid.

### Editing & Input

When `isEditing` is true, cells become interactive:

- **Text/Number**: Standard input.
- **ComboBox**: Single and multi-selection dropdowns.
- **Switches**: Instant boolean updates.
- **Images/Files**: Integrated `image_picker` and `file_picker` support.

---

## 🛠 API Reference

### `Datagrid` Props

| Property             | Type                  | Description                                            |
| :------------------- | :-------------------- | :----------------------------------------------------- |
| `controller`         | `DatagridController`  | **Required**. Manages data, state, and event handling. |
| `onRowTap`           | `Function(Map)`       | Callback when a row is clicked.                        |
| `isEditing`          | `bool`                | Toggles cell editability globally.                     |
| `onSelectionChanged` | `Function(List<Map>)` | Triggered when row selection changes.                  |

### `GridColumn` Configuration

| Property             | Type                       | Description                                   |
| :------------------- | :------------------------- | :-------------------------------------------- |
| `key`                | `String`                   | Maps to the key in your data source.          |
| `title`              | `String`                   | Visible header text.                          |
| `type`               | `GridRowTypeEnum`          | Determines rendering and editing logic.       |
| `allowSorting`       | `bool`                     | If true, user can click header to sort.       |
| `formula`            | `String?`                  | Optional Excel-like formula for calculations. |
| `contextMenuOptions` | `List<RowContextMenuItem>` | Custom row-level actions.                     |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue on GitHub.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
