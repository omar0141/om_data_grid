import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/enums/column_pinning_enum.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
export 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:flutter/material.dart';

enum StateStyle { tinted, primary, outlined, text }

class StateConfig {
  final StateStyle style;
  final Color color;
  final IconData? icon;
  final String label;

  const StateConfig({
    required this.style,
    required this.color,
    this.icon,
    required this.label,
  });
}

class GridComboBoxSettings {
  final List<GridComboBoxItem> items;
  final bool multipleSelect;
  final bool showInput;
  final String? inputKey;
  final String? valueKey;

  const GridComboBoxSettings({
    required this.items,
    this.multipleSelect = false,
    this.showInput = false,
    this.inputKey,
    this.valueKey,
  });
}

class RowContextMenuItem {
  final String label;
  final IconData? icon;
  final dynamic value;
  final void Function(dynamic row)? onTap;

  const RowContextMenuItem({
    required this.label,
    this.icon,
    required this.value,
    this.onTap,
  });
}

class GridColumn {
  final String key;
  final String title;
  final double? width;
  final TextAlign? textAlign;
  final bool resizable;
  bool allowFiltering;
  bool allowSorting;
  GridRowTypeEnum type;
  final GridComboBoxSettings? comboBoxSettings;
  final String? numberType;
  final bool showInChart;
  final bool canBeXAxis;
  final bool canBeYAxis;
  final String? formula; // Formula for calculated columns
  final String? decimalSeparator;
  final String? thousandsSeparator;
  final int? decimalDigits;
  final String? customDateFormat;
  final double? imageBorderRadius;
  final bool? multiSelect;
  final String? displayKey;
  final String? valueKey;
  final bool? readonlyInView;
  final Future<void> Function(dynamic)? onDelete;
  final Map<dynamic, StateConfig>? stateConfig;
  final List<RowContextMenuItem>? contextMenuOptions;
  final bool showPlaceholderWhileScrolling;

  GridColumn({
    required this.key,
    required this.title,
    this.width,
    this.textAlign = TextAlign.center,
    this.resizable = true,
    this.allowFiltering = true,
    this.allowSorting = true,
    this.type = GridRowTypeEnum.text,
    this.comboBoxSettings,
    this.numberType,
    this.showInChart = true,
    this.canBeXAxis = true,
    this.canBeYAxis = true,
    this.formula,
    this.decimalSeparator,
    this.thousandsSeparator,
    this.decimalDigits,
    this.customDateFormat,
    this.imageBorderRadius,
    this.multiSelect,
    this.displayKey,
    this.valueKey,
    this.readonlyInView,
    this.onDelete,
    this.stateConfig,
    this.contextMenuOptions,
    this.showPlaceholderWhileScrolling = true,
  });

  GridColumn copyWith({
    String? key,
    String? title,
    double? width,
    TextAlign? textAlign,
    bool? resizable,
    bool? allowFiltering,
    bool? allowSorting,
    GridRowTypeEnum? type,
    GridComboBoxSettings? comboBoxSettings,
    String? numberType,
    bool? showInChart,
    bool? canBeXAxis,
    bool? canBeYAxis,
    String? formula,
    String? decimalSeparator,
    String? thousandsSeparator,
    int? decimalDigits,
    String? customDateFormat,
    double? imageBorderRadius,
    bool? multiSelect,
    String? displayKey,
    String? valueKey,
    bool? readonlyInView,
    Future<void> Function(dynamic)? onDelete,
    Map<dynamic, StateConfig>? stateConfig,
    List<RowContextMenuItem>? contextMenuOptions,
    bool? showPlaceholderWhileScrolling,
  }) {
    return GridColumn(
      key: key ?? this.key,
      title: title ?? this.title,
      width: width ?? this.width,
      textAlign: textAlign ?? this.textAlign,
      resizable: resizable ?? this.resizable,
      allowFiltering: allowFiltering ?? this.allowFiltering,
      allowSorting: allowSorting ?? this.allowSorting,
      type: type ?? this.type,
      comboBoxSettings: comboBoxSettings ?? this.comboBoxSettings,
      numberType: numberType ?? this.numberType,
      showInChart: showInChart ?? this.showInChart,
      canBeXAxis: canBeXAxis ?? this.canBeXAxis,
      canBeYAxis: canBeYAxis ?? this.canBeYAxis,
      formula: formula ?? this.formula,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandsSeparator: thousandsSeparator ?? this.thousandsSeparator,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      customDateFormat: customDateFormat ?? this.customDateFormat,
      imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
      multiSelect: multiSelect ?? this.multiSelect,
      displayKey: displayKey ?? this.displayKey,
      valueKey: valueKey ?? this.valueKey,
      readonlyInView: readonlyInView ?? this.readonlyInView,
      onDelete: onDelete ?? this.onDelete,
      stateConfig: stateConfig ?? this.stateConfig,
      contextMenuOptions: contextMenuOptions ?? this.contextMenuOptions,
      showPlaceholderWhileScrolling:
          showPlaceholderWhileScrolling ?? this.showPlaceholderWhileScrolling,
    );
  }
}

class GridColumnModel {
  GridColumn column;
  double? width;
  bool filter;
  List? notSelectedFilterData;
  String searchText;
  String? quickFilterText;
  AdvancedFilterModel? advancedFilter;
  AdvancedFilterModel?
  advancedFilterUI; // For UI persistence in popups (keeping condition type)
  bool isVisible;
  double? savedWidth;
  AggregationType aggregation; // Current aggregation type
  ColumnPinning pinning;
  int originalIndex;

  GridColumnModel({
    required this.column,
    this.width,
    this.filter = false,
    this.notSelectedFilterData,
    this.searchText = '',
    this.quickFilterText,
    this.advancedFilter,
    this.advancedFilterUI,
    this.isVisible = true,
    this.savedWidth,
    this.aggregation = AggregationType.none,
    this.pinning = ColumnPinning.none,
    this.originalIndex = 0,
  });

  String get key => column.key;
  String get title => column.title;
  bool get isResizable => column.resizable;
  bool get isAllowSorting => column.allowSorting;
  bool get isAllowFiltering => column.allowFiltering;
  TextAlign get textAlign => column.textAlign ?? TextAlign.center;
  GridRowTypeEnum get type => column.type;
  GridComboBoxSettings? get comboBoxSettings => column.comboBoxSettings;
  String? get numberType => column.numberType;
  bool get showInChart => column.showInChart;
  bool get canBeXAxis => column.canBeXAxis;
  bool get canBeYAxis => column.canBeYAxis;

  String? get decimalSeparator => column.decimalSeparator;
  String? get thousandsSeparator => column.thousandsSeparator;
  int? get decimalDigits => column.decimalDigits;
  String? get customDateFormat => column.customDateFormat;
  double? get imageBorderRadius => column.imageBorderRadius;
  bool? get multiSelect => column.multiSelect;
  String? get displayKey => column.displayKey;
  String? get valueKey => column.valueKey;
  bool? get readonlyInView => column.readonlyInView;
  Future<void> Function(dynamic)? get onDelete => column.onDelete;
  Map<dynamic, StateConfig>? get stateConfig => column.stateConfig;
  List<RowContextMenuItem>? get contextMenuOptions => column.contextMenuOptions;

  bool get isFiltered =>
      filter ||
      (advancedFilter != null && advancedFilter!.conditions.isNotEmpty);

  bool get isCalculated => column.formula != null;
  bool get showPlaceholderWhileScrolling =>
      column.showPlaceholderWhileScrolling;
}

class GridColumnDragData {
  final GridColumnModel column;
  final String source;

  GridColumnDragData({required this.column, required this.source});
}
