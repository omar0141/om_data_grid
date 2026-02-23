import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import '../grid_combo_box/grid_combo_box.dart';
import '../default_button.dart';
import 'chart_types.dart';
import '../../models/grid_column_model.dart';
import '../../models/datagrid_configuration.dart';

class OmChartSettingsSidebar extends StatelessWidget {
  final int activeTab;
  final OmChartType selectedChartType;
  final String xAxisColumn;
  final List<String> yAxisColumns;
  final List<OmGridColumnModel> columns;
  final OmDataGridConfiguration configuration;
  final TextEditingController titleController;
  final bool showLegend;
  final bool showDataLabels;
  final bool showTooltip;
  final bool isTransposed;
  final bool isMobile;
  final Function(int) onTabChanged;
  final Function(OmChartType) onChartTypeChanged;
  final Function(String) onXAxisChanged;
  final Function(List<String>) onYAxisChanged;
  final Function(bool) onShowLegendChanged;
  final Function(bool) onShowDataLabelsChanged;
  final Function(bool) onShowTooltipChanged;
  final Function(bool) onIsTransposedChanged;
  final VoidCallback onTitleChanged;

  // New export callbacks
  final VoidCallback? onExportPDF;
  final VoidCallback? onExportExcel;

  const OmChartSettingsSidebar({
    super.key,
    required this.activeTab,
    required this.selectedChartType,
    required this.xAxisColumn,
    required this.yAxisColumns,
    required this.columns,
    required this.configuration,
    required this.titleController,
    required this.showLegend,
    required this.showDataLabels,
    required this.showTooltip,
    required this.isTransposed,
    required this.onTabChanged,
    required this.onChartTypeChanged,
    required this.onXAxisChanged,
    required this.onYAxisChanged,
    required this.onShowLegendChanged,
    required this.onShowDataLabelsChanged,
    required this.onShowTooltipChanged,
    required this.onIsTransposedChanged,
    required this.onTitleChanged,
    this.isMobile = false,
    this.onExportPDF,
    this.onExportExcel,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return DefaultTabController(
        length: 3,
        initialIndex: activeTab,
        child: Column(
          children: [
            TabBar(
              onTap: onTabChanged,
              labelColor: configuration.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: configuration.primaryColor,
              tabs: const [
                Tab(text: "Type", icon: Icon(Icons.auto_graph)),
                Tab(text: "Data", icon: Icon(Icons.storage)),
                Tab(text: "Settings", icon: Icon(Icons.settings)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFormatTab(context),
                  _buildDataTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
            if (onExportPDF != null || onExportExcel != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacityNew(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (onExportPDF != null)
                      Expanded(
                        child: OmDefaultButton(
                          text: "Export PDF",
                          press: onExportPDF,
                          leadingIcon: Image.asset(
                            'assets/icons/pdf_icon.png',
                            height: 24,
                            width: 24,
                            fit: BoxFit.contain,
                          ),
                          backcolor: configuration.primaryColor,
                          forecolor: configuration.primaryForegroundColor,
                          configuration: configuration,
                        ),
                      ),
                    if (onExportPDF != null && onExportExcel != null)
                      const SizedBox(width: 12),
                    if (onExportExcel != null)
                      Expanded(
                        child: OmDefaultButton(
                          text: "Export Excel",
                          press: onExportExcel,
                          leadingIcon: Image.asset(
                            'assets/icons/excel_icon.png',
                            height: 24,
                            width: 24,
                            fit: BoxFit.contain,
                          ),
                          backcolor: Colors.green.shade700,
                          forecolor: Colors.white,
                          configuration: configuration,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Vertical Navigation Bar
          Container(
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _buildVerticalTabItem(0, Icons.auto_graph),
                _buildVerticalTabItem(1, Icons.storage),
                _buildVerticalTabItem(2, Icons.settings),
                const Spacer(),
                // Export Buttons in Sidebar (Icons only, no background)
                if (onExportPDF != null)
                  _buildSideExportButton(
                    onPressed: onExportPDF!,
                    iconPath: 'packages/om_data_grid/assets/icons/pdf_icon.png',
                    tooltip: 'Export to PDF',
                  ),
                if (onExportExcel != null)
                  _buildSideExportButton(
                    onPressed: onExportExcel!,
                    iconPath: 'packages/om_data_grid/assets/icons/excel_icon.png',
                    tooltip: 'Export to Excel',
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: IndexedStack(
              index: activeTab,
              children: [
                _buildFormatTab(context),
                _buildDataTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTabItem(int index, IconData icon) {
    bool isActive = activeTab == index;
    return InkWell(
      onTap: () => onTabChanged(index),
      child: Container(
        height: 50,
        width: 45,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive ? configuration.primaryColor : Colors.transparent,
              width: 3,
            ),
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
          color: isActive ? Colors.white : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? configuration.primaryColor : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSideExportButton({
    required VoidCallback onPressed,
    required String iconPath,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 45,
          width: 45,
          padding: const EdgeInsets.all(12),
          child: Image.asset(iconPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildFormatTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildPanelSection('CHART TYPE', _buildTypeGrid(context))],
    );
  }

  Widget _buildDataTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPanelSection(
          'CATEGORIES (X-AXIS)',
          _buildAxisDropdown('', xAxisColumn, (val) => onXAxisChanged(val!)),
        ),
        const SizedBox(height: 20),
        _buildPanelSection('MEASURES (Y-AXIS)', _buildMultiMeasureSelection()),
      ],
    );
  }

  Widget _buildMultiMeasureSelection() {
    final chartColumns = columns
        .where((col) => col.showInChart && col.canBeYAxis)
        .toList();
    return Column(
      children: chartColumns.map((col) {
        // Only show columns that are numeric or can be numeric
        // For simplicity, we can show all and let the user decide,
        // or filter like we did in initState.
        bool isSelected = yAxisColumns.contains(col.column.key);
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? configuration.primaryColor.withOpacityNew(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? configuration.primaryColor.withOpacityNew(0.2)
                  : Colors.grey.shade300,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              col.column.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? configuration.primaryColor : Colors.black87,
              ),
            ),
            value: isSelected,
            activeColor: configuration.primaryColor,
            dense: true,
            visualDensity: VisualDensity.compact,
            onChanged: (bool? value) {
              List<String> newSelection = List.from(yAxisColumns);
              if (value == true) {
                newSelection.add(col.column.key);
              } else {
                if (newSelection.length > 1) {
                  newSelection.remove(col.column.key);
                }
              }
              onYAxisChanged(newSelection);
            },
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPanelSection(
          'General Settings',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyLabel('Chart Title'),
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter title...',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: configuration.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) => onTitleChanged(),
              ),
            ],
          ),
        ),
        _buildPanelSection(
          'Interactivity',
          Column(
            children: [
              _buildSwitch(
                'Show Legend',
                showLegend,
                (v) => onShowLegendChanged(v),
              ),
              _buildSwitch(
                'Data Labels',
                showDataLabels,
                (v) => onShowDataLabelsChanged(v),
              ),
              _buildSwitch(
                'Tooltips',
                showTooltip,
                (v) => onShowTooltipChanged(v),
              ),
              _buildSwitch(
                'Transpose Axes',
                isTransposed,
                (v) => onIsTransposedChanged(v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: OmChartType.values.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 4 : 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: isMobile ? 70 : 80,
      ),
      itemBuilder: (context, index) {
        final type = OmChartType.values[index];
        final isSelected = selectedChartType == type;
        return InkWell(
          onTap: () {
            onChartTypeChanged(type);
            if (isMobile) Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(isMobile ? 0 : 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? configuration.primaryColor.withOpacityNew(0.1)
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? configuration.primaryColor
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForType(type),
                  size: isMobile ? 20 : 18,
                  color: isSelected
                      ? configuration.primaryColor
                      : Colors.grey.shade700,
                ),
                const SizedBox(height: 4),
                Text(
                  _getDisplayNameForType(type),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? configuration.primaryColor
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDisplayNameForType(OmChartType type) {
    switch (type) {
      case OmChartType.bar:
        return 'Bar';
      case OmChartType.line:
        return 'Line';
      case OmChartType.column:
        return 'Column';
      case OmChartType.pie:
        return 'Pie';
      case OmChartType.area:
        return 'Area';
      case OmChartType.scatter:
        return 'Scatter';
      case OmChartType.spline:
        return 'Spline';
      case OmChartType.stepline:
        return 'Step Line';
      case OmChartType.doughnut:
        return 'Doughnut';
      case OmChartType.funnel:
        return 'Funnel';
      case OmChartType.pyramid:
        return 'Pyramid';
      case OmChartType.radialBar:
        return 'Radial Bar';
      case OmChartType.histogram:
        return 'Histogram';
      case OmChartType.stackedBar:
        return 'Stacked Bar';
      case OmChartType.stackedColumn:
        return 'Stacked Column';
    }
  }

  IconData _getIconForType(OmChartType type) {
    switch (type) {
      case OmChartType.bar:
        return Icons.align_horizontal_left;
      case OmChartType.line:
        return Icons.show_chart;
      case OmChartType.column:
        return Icons.bar_chart;
      case OmChartType.pie:
        return Icons.pie_chart;
      case OmChartType.area:
        return Icons.area_chart;
      case OmChartType.scatter:
        return Icons.scatter_plot;
      case OmChartType.spline:
        return Icons.gesture;
      case OmChartType.stepline:
        return Icons.stacked_line_chart;
      case OmChartType.doughnut:
        return Icons.donut_large;
      case OmChartType.funnel:
        return Icons.filter_list;
      case OmChartType.pyramid:
        return Icons.change_history;
      case OmChartType.radialBar:
        return Icons.rotate_right;
      case OmChartType.histogram:
        return Icons.analytics;
      case OmChartType.stackedBar:
        return Icons.view_headline;
      case OmChartType.stackedColumn:
        return Icons.view_week;
    }
  }

  Widget _buildAxisDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        GridComboBox(
          items: columns
              .where((e) => e.showInChart && e.canBeXAxis)
              .map(
                (e) =>
                    OmGridComboBoxItem(value: e.column.key, text: e.column.title),
              )
              .toList(),
          initialValue: value,
          enableSearch: true,
          showClearButton: false,
          borderColor: configuration.inputBorderColor,
          onChange: (val) {
            onChanged(val);
          },
          configuration: configuration,
        ),
      ],
    );
  }

  Widget _buildPanelSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: configuration.primaryColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPropertyLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: configuration.primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
