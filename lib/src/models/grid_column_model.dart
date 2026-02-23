import 'package:om_data_grid/src/enums/aggregation_type_enum.dart';
import 'package:om_data_grid/src/enums/column_pinning_enum.dart';
import 'package:om_data_grid/src/enums/grid_row_type_enum.dart';
import 'package:om_data_grid/src/models/advanced_filter_model.dart';
export 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:om_data_grid/src/models/grid_combo_box_item.dart';
import 'package:flutter/material.dart';

/// Defines the style for a state configuration.
enum OmStateStyle {
  /// Tinted background style.
  tinted,

  /// Primary color style.
  primary,

  /// Outlined style.
  outlined,

  /// Text only style.
  text,
}

/// Configuration for a specific state, used for styling cells based on state.
class OmStateConfig {
  /// The style of the state indicator.
  final OmStateStyle style;

  /// The color associated with this state.
  final Color color;

  /// Optional icon for the state.
  final IconData? icon;

  /// Label text for the state.
  final String label;

  /// Creates a [OmStateConfig].
  const OmStateConfig({
    required this.style,
    required this.color,
    this.icon,
    required this.label,
  });
}

/// Settings for a combo box column type.
class OmGridComboBoxSettings {
  /// List of items to display in the combo box.
  final List<OmGridComboBoxItem> items;

  /// Whether multiple selection is allowed.
  final bool multipleSelect;

  /// Whether to show an input field for filtering/searching items.
  final bool showInput;

  /// The key in the item map to use for the input value.
  final String? inputKey;

  /// The key in the item map to use for the underlying value.
  final String? valueKey;

  /// Creates a [OmGridComboBoxSettings].
  const OmGridComboBoxSettings({
    required this.items,
    this.multipleSelect = false,
    this.showInput = false,
    this.inputKey,
    this.valueKey,
  });
}

/// Represents an item in a row context menu.
class OmRowContextMenuItem {
  /// The label to display for the menu item.
  final String label;

  /// Optional icon to display.
  final IconData? icon;

  /// The value associated with this menu item.
  final dynamic value;

  /// Callback when this item is tapped.
  final void Function(dynamic row)? onTap;

  /// Creates a [OmRowContextMenuItem].
  const OmRowContextMenuItem({
    required this.label,
    this.icon,
    required this.value,

    this.onTap,
  });
}

/// Defines the configuration for a grid column.
class OmGridColumn {
  /// Unique key for the column.
  final String key;

  /// Title displayed in the header.
  final String title;

  /// Initial width of the column.
  final double? width;

  /// Text alignment for cell content.
  final TextAlign? textAlign;

  /// Whether the column can be resized.
  final bool resizable;

  /// Whether filtering is allowed on this column.
  bool allowFiltering;

  /// Whether sorting is allowed on this column.
  bool allowSorting;

  /// The type of data presented in the column.
  OmGridRowTypeEnum type;

  /// Settings if the column type is [OmGridRowTypeEnum.comboBox].
  final OmGridComboBoxSettings? comboBoxSettings;

  /// Specific number type formatting (if applicable).
  final String? numberType;

  /// Whether to include this column in charts.
  final bool showInChart;

  /// Whether this column can be used as the X-axis in charts.
  final bool canBeXAxis;

  /// Whether this column can be used as the Y-axis in charts.
  final bool canBeYAxis;

  /// Formula for calculated columns.
  final String? formula;

  /// Decimal separator char.
  final String? decimalSeparator;

  /// Thousands separator char.
  final String? thousandsSeparator;

  /// Number of decimal digits.
  final int? decimalDigits;

  /// Custom date format string.
  final String? customDateFormat;

  /// Border radius for images.
  final double? imageBorderRadius;

  /// Whether multi-choice selection is enabled (for relevant types).
  final bool? multiSelect;

  /// Key for display value.
  final String? displayKey;

  /// Key for underlying value.
  final String? valueKey;

  /// Whether the column is read-only in the view.
  final bool? readonlyInView;

  /// Callback when a value is deleted (if applicable).
  final Future<void> Function(dynamic)? onDelete;

  /// Configuration for state-based styling.
  final Map<dynamic, OmStateConfig>? stateConfig;

  /// Options for the row context menu.
  final List<OmRowContextMenuItem>? contextMenuOptions;

  /// Whether to show a placeholder while scrolling.
  final bool showPlaceholderWhileScrolling;

  /// Creates a [OmGridColumn] configuration.
  OmGridColumn({
    required this.key,
    required this.title,
    this.width,
    this.textAlign = TextAlign.center,
    this.resizable = true,
    this.allowFiltering = true,
    this.allowSorting = true,
    this.type = OmGridRowTypeEnum.text,
    this.comboBoxSettings,
    this.numberType,
    this.showInChart = true,
    this.canBeXAxis = false,
    this.canBeYAxis = false,
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

  OmGridColumn copyWith({
    String? key,
    String? title,
    double? width,
    TextAlign? textAlign,
    bool? resizable,
    bool? allowFiltering,
    bool? allowSorting,
    OmGridRowTypeEnum? type,
    OmGridComboBoxSettings? comboBoxSettings,
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
    Map<dynamic, OmStateConfig>? stateConfig,
    List<OmRowContextMenuItem>? contextMenuOptions,
    bool? showPlaceholderWhileScrolling,
  }) {
    return OmGridColumn(
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

/// Model combining the static configuration [OmGridColumn] and runtime state.
class OmGridColumnModel {
  /// The static configuration of the column.
  OmGridColumn column;

  /// Current width of the column.
  double? width;

  /// Whether the filter is active.
  bool filter;

  /// Data that is NOT selected in the filter.
  List? notSelectedFilterData;

  /// Current search text for filtering.
  String searchText;

  /// Text for quick filtering.
  String? quickFilterText;

  /// Advanced filter configuration.
  OmAdvancedFilterModel? advancedFilter;

  /// Advanced filter UI state.
  OmAdvancedFilterModel?
  advancedFilterUI; // For UI persistence in popups (keeping condition type)

  /// Whether the column is visible.
  bool isVisible;

  /// Saved width state.
  double? savedWidth;

  /// Current aggregation type applied to the column.
  OmAggregationType aggregation; // Current aggregation type

  /// Current pinning state of the column.
  OmColumnPinning pinning;

  /// The original index of the column before reordering.
  int originalIndex;

  /// Creates a [OmGridColumnModel].
  OmGridColumnModel({
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
    this.aggregation = OmAggregationType.none,
    this.pinning = OmColumnPinning.none,
    this.originalIndex = 0,
  });

  /// The Unique key from [OmGridColumn].
  String get key => column.key;

  /// The title from [OmGridColumn].
  String get title => column.title;
  bool get isResizable => column.resizable;
  bool get isAllowSorting => column.allowSorting;
  bool get isAllowFiltering => column.allowFiltering;
  TextAlign get textAlign => column.textAlign ?? TextAlign.center;
  OmGridRowTypeEnum get type => column.type;
  OmGridComboBoxSettings? get comboBoxSettings => column.comboBoxSettings;
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
  Map<dynamic, OmStateConfig>? get stateConfig => column.stateConfig;
  List<OmRowContextMenuItem>? get contextMenuOptions => column.contextMenuOptions;

  bool get isFiltered =>
      filter ||
      (advancedFilter != null && advancedFilter!.conditions.isNotEmpty);

  bool get isCalculated => column.formula != null;
  bool get showPlaceholderWhileScrolling =>
      column.showPlaceholderWhileScrolling;
}

/// Data used during column dragging operations.
class OmGridColumnDragData {
  /// The column being dragged.
  final OmGridColumnModel column;

  /// The source layout identifier.
  final String source;

  /// Creates a [OmGridColumnDragData].
  OmGridColumnDragData({required this.column, required this.source});
}
