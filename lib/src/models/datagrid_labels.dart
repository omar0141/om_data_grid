import 'package:om_data_grid/src/models/advanced_filter_model.dart';
import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';

class OmDataGridLabels {
  final String search;
  final String noData;
  final String cancel;
  final String apply;
  final String searchAllColumns;
  final String exportToExcel;
  final String exportToPdf;
  final String visualize;
  final String options;
  final String clearFilter;
  final String selectAll;
  final String none;
  final String to;
  final String from;
  final String trueText;
  final String falseText;

  // Sorting
  final String sorting;
  final String sortAscending;
  final String sortDescending;

  // Organization
  final String organization;
  final String pinColumn;
  final String unpin;
  final String pinToLeft;
  final String pinToRight;

  // Grouping & Visibility
  final String groupBy;
  final String hideColumn;

  // Aggregations
  final String aggregations;
  final String noAggregation;
  final String sum;
  final String average;
  final String minimum;
  final String maximum;
  final String count;
  final String first;
  final String last;

  // Layout
  final String gridLayout;
  final String showQuickSearch;
  final String hideQuickSearch;
  final String columnManagement;
  final String resetDefaultLayout;
  final String addButton;
  final String groupPanelPlaceholder;
  final String columnChooserTitle;
  final String columnChooserSearchHint;
  final String clearAll;
  final String reset;

  // Pagination
  final String showing;
  final String toLabel;
  final String ofLabel;
  final String entries;
  final String rowsPerPage;

  // Formula Builder
  final String formulaBuilderTitle;
  final String editFormula;
  final String formulaName;
  final String advancedMode;
  final String standardMode;
  final String buildYourFormula;
  final String preview;
  final String save;

  // Chart
  final String chartType;
  final String chartData;
  final String chartSettings;
  final String exportPdf;
  final String exportExcel;
  final String chartTitle;
  final String xAxis;
  final String yAxis;
  final String showLegend;
  final String showDataLabels;
  final String showTooltip;
  final String transpose;
  final String successfullyExportedToPdf;
  final String errorExportingPdf;
  final String successfullyExportedToExcel;
  final String errorExportingExcel;
  final String noNumericDataSelected;

  // Booleans
  final String yes;
  final String no;

  // Date Picker
  final String applyRange;
  final String openFile;

  // Filter conditions
  final String equals;
  final String notEqual;
  final String contains;
  final String notContains;
  final String startsWith;
  final String endsWith;
  final String greaterThan;
  final String lessThan;
  final String greaterThanOrEqual;
  final String lessThanOrEqual;
  final String between;
  final String empty;
  final String notEmpty;

  const OmDataGridLabels({
    this.search = "Search",
    this.noData = "No data available",
    this.cancel = "Cancel",
    this.apply = "Search",
    this.searchAllColumns = "Search in all columns...",
    this.exportToExcel = "Export to Excel",
    this.exportToPdf = "Export to PDF",
    this.visualize = "Visualize all data",
    this.options = "Options",
    this.clearFilter = "Clear Filter",
    this.selectAll = "Select All",
    this.none = "None",
    this.to = "To...",
    this.from = "From...",
    this.trueText = "true",
    this.falseText = "false",
    this.sorting = "Sorting",
    this.sortAscending = "Sort Ascending",
    this.sortDescending = "Sort Descending",
    this.organization = "Organization",
    this.pinColumn = "Pin Column",
    this.unpin = "Unpin",
    this.pinToLeft = "Pin to Left",
    this.pinToRight = "Pin to Right",
    this.groupBy = "Group By",
    this.hideColumn = "Hide Column",
    this.aggregations = "Aggregations",
    this.noAggregation = "No Aggregation",
    this.sum = "Sum (∑)",
    this.average = "Average (μ)",
    this.minimum = "Minimum",
    this.maximum = "Maximum",
    this.count = "Count (n)",
    this.first = "First",
    this.last = "Last",
    this.gridLayout = "Grid Layout",
    this.showQuickSearch = "Show Quick Search",
    this.hideQuickSearch = "Hide Quick Search",
    this.columnManagement = "Column Management",
    this.resetDefaultLayout = "Reset Default Layout",
    this.addButton = "Add",
    this.groupPanelPlaceholder = "Group by dragging columns here",
    this.columnChooserTitle = "Choose Columns",
    this.columnChooserSearchHint = "Search columns...",
    this.clearAll = "Clear All",
    this.reset = "Reset",
    this.showing = "Showing",
    this.toLabel = "to",
    this.ofLabel = "of",
    this.entries = "entries",
    this.rowsPerPage = "Rows per page:",
    this.formulaBuilderTitle = "Custom Column",
    this.editFormula = "Edit Formula",
    this.formulaName = "Formula Name",
    this.advancedMode = "Advanced Mode",
    this.standardMode = "Standard Mode",
    this.buildYourFormula = "Build your formula",
    this.preview = "Preview",
    this.save = "Save",
    this.chartType = "Type",
    this.chartData = "Data",
    this.chartSettings = "Settings",
    this.exportPdf = "Export PDF",
    this.exportExcel = "Export Excel",
    this.chartTitle = "Chart Title",
    this.xAxis = "X-Axis",
    this.yAxis = "Y-Axis",
    this.showLegend = "Show Legend",
    this.showDataLabels = "Show Data Labels",
    this.showTooltip = "Show Tooltip",
    this.transpose = "Transpose Chart",
    this.successfullyExportedToPdf = "Successfully exported to PDF",
    this.errorExportingPdf = "Error exporting PDF",
    this.successfullyExportedToExcel = "Successfully exported to Excel",
    this.errorExportingExcel = "Error exporting Excel",
    this.noNumericDataSelected = "No numeric data selected for charts",
    this.yes = "Yes",
    this.no = "No",
    this.applyRange = "Apply Range",
    this.openFile = "Open File",
    this.equals = "Equals",
    this.notEqual = "Not equal",
    this.contains = "Contains",
    this.notContains = "Does not contain",
    this.startsWith = "Starts with",
    this.endsWith = "Ends with",
    this.greaterThan = "Greater than",
    this.lessThan = "Less than",
    this.greaterThanOrEqual = "Greater than or equal",
    this.lessThanOrEqual = "Less than or equal",
    this.between = "Between",
    this.empty = "Empty",
    this.notEmpty = "Not empty",
  });

  String getConditionLabel(OmFilterConditionType type) {
    switch (type) {
      case OmFilterConditionType.equals:
        return equals;
      case OmFilterConditionType.notEqual:
        return notEqual;
      case OmFilterConditionType.contains:
        return contains;
      case OmFilterConditionType.notContains:
        return notContains;
      case OmFilterConditionType.startsWith:
        return startsWith;
      case OmFilterConditionType.endsWith:
        return endsWith;
      case OmFilterConditionType.greaterThan:
        return greaterThan;
      case OmFilterConditionType.lessThan:
        return lessThan;
      case OmFilterConditionType.greaterThanOrEqual:
        return greaterThanOrEqual;
      case OmFilterConditionType.lessThanOrEqual:
        return lessThanOrEqual;
      case OmFilterConditionType.between:
        return between;
      case OmFilterConditionType.empty:
        return empty;
      case OmFilterConditionType.notEmpty:
        return notEmpty;
    }
  }

  String getAggregationLabel(OmAggregationType type) {
    switch (type) {
      case OmAggregationType.sum:
        return sum;
      case OmAggregationType.avg:
        return average;
      case OmAggregationType.min:
        return minimum;
      case OmAggregationType.max:
        return maximum;
      case OmAggregationType.count:
        return count;
      case OmAggregationType.first:
        return first;
      case OmAggregationType.last:
        return last;
      case OmAggregationType.none:
        return noAggregation;
    }
  }
}
