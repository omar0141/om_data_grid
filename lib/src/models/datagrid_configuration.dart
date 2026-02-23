import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';
import '../enums/selection_mode_enum.dart';
import '../enums/grid_border_visibility_enum.dart';
import 'side_panel_config.dart';

enum ColumnWidthMode {
  fill,
  auto,
  fitByCellValue,
  fitByColumnName,
  lastColumnFill,
  none,
}

enum PaginationMode {
  simple, // showing "Page 1 of 10"
  pages, // showing [1, 2, 3...]
}

enum FrozenPaneScrollMode { fixed, sticky }

class QuickFilterConfig {
  final String columnKey;
  final bool isMultiSelect;
  final bool showTitle;

  const QuickFilterConfig({
    required this.columnKey,
    this.isMultiSelect = false,
    this.showTitle = false,
  });
}

class DatagridContextMenuItem {
  final String label;
  final IconData icon;
  final String value;
  final bool isDestructive;
  final void Function(
    List<Map<String, dynamic>> selectedRows,
    List<GridColumnModel> selectedColumns,
  )?
  onPressed;

  const DatagridContextMenuItem({
    required this.label,
    required this.icon,
    required this.value,
    this.isDestructive = false,
    this.onPressed,
  });
}

class DatagridConfiguration {
  final Color headerBackgroundColor;
  final Color headerForegroundColor;
  final Color rowBackgroundColor;
  final Color rowForegroundColor;
  final Color selectedRowColor;
  final Color rowHoverColor;
  final Color selectedRowForegroundColor;
  final Color headerBorderColor;
  final double headerBorderWidth;
  final Color rowBorderColor;
  final double rowBorderWidth;
  final GridBorderVisibility headerBorderVisibility;
  final GridBorderVisibility rowBorderVisibility;
  final TextStyle? headerTextStyle;
  final TextStyle? rowTextStyle;
  final TextStyle? selectedRowTextStyle;
  final Color resizeHandleColor;
  final double resizeHandleWidth;
  final Color paginationBackgroundColor;
  final Color paginationSelectedBackgroundColor;
  final Color paginationSelectedForegroundColor;
  final Color paginationUnselectedBackgroundColor;
  final Color paginationUnselectedForegroundColor;
  final Color paginationTextColor;
  final Color gridBackgroundColor;
  final Color gridBorderColor;
  final Color filterIconColor;
  final Color sortIconColor;
  final Color filterPopupBackgroundColor;
  final Color keyboardHideButtonBackgroundColor;
  final Color keyboardHideButtonForegroundColor;
  final Color primaryColor;
  final Color errorColor;
  final Color inputFillColor;
  final Color inputBorderColor;
  final Color inputFocusBorderColor;
  final Color secondaryTextColor;
  final Color primaryForegroundColor;
  final double minColumnWidth;
  final double rowHeight;
  final double headerHeight;
  final double cacheExtent;
  final ColumnWidthMode columnWidthMode;
  final bool allowPagination;
  final int rowsPerPage;
  final PaginationMode paginationMode;
  final bool allowSorting;
  final bool allowColumnReordering;
  final bool allowRowReordering; // Add field
  final SelectionMode selectionMode;
  final List<int>? rowsPerPageOptions;
  final List<QuickFilterConfig>? quickFilters;
  final bool showSettingsButton;
  final bool showClearFiltersButton;
  final bool showAddButton;
  final String? addButtonText;
  final Widget addButtonIcon;
  final Color? addButtonBackgroundColor;
  final Color? addButtonForegroundColor;
  final Color? addButtonBorderColor;
  final double? addButtonFontSize;
  final FontWeight? addButtonFontWeight;
  final EdgeInsetsGeometry? addButtonPadding;
  final BorderRadiusDirectional? addButtonBorderRadius;
  final bool showFilterOnHover;
  final bool showSortOnHover;
  final bool enableGrouping;
  final bool allowGrouping;
  final bool showGroupingPanel;
  final Color? groupPanelBackgroundColor;
  final Color? groupPanelBorderColor;
  final double? groupPanelBorderWidth;
  final double? groupPanelHeight;
  final TextStyle? groupPanelTextStyle;
  final Color? groupPanelIconColor;
  final Color? groupPanelClearIconColor;
  final Color? groupPanelItemBackgroundColor;
  final Color? groupPanelItemBorderColor;
  final TextStyle? groupPanelItemTextStyle;
  final Color? columnSearchBorderColor;
  final Color? columnSearchIconColor;
  final Color? dragFeedbackOutsideBackgroundColor;
  final Color? dragFeedbackInsideBackgroundColor;
  final Color? dragFeedbackOutsideBorderColor;
  final Color? dragFeedbackInsideBorderColor;
  final Color? dragFeedbackOutsideTextColor;
  final Color? dragFeedbackInsideTextColor;
  final Color? dragFeedbackIconColor;
  final Color? dragFeedbackShadowColor;
  final Color? columnDragIndicatorColor;
  final Color? columnFunctionIconColor;
  final Color? bottomPanelSectionBorderColor;
  final Color? bottomPanelDragTargetColor;
  final Color? bottomPanelDragTargetInactiveColor;
  final Color? bottomPanelIconColor;
  final Color? menuBackgroundColor;
  final Color? menuSurfaceTintColor;
  final Color? menuTextColor;
  final Color? dialogBackgroundColor;
  final Color? dialogSurfaceTintColor;
  final Color? dialogTextColor;
  final List<DatagridContextMenuItem>? contextMenuItems;
  final bool useDefaultContextMenuItems;
  final bool showCopyMenuItem;
  final bool showCopyHeaderMenuItem;
  final bool showEquationMenuItem;
  final bool showSortMenuItem;
  final bool showFilterBySelectionMenuItem;
  final bool showChartsMenuItem;
  final SidePanelConfiguration sidePanelConfiguration;
  final bool showColumnsTab;
  final bool showFiltersTab;
  final bool showQuickSearch;
  final bool showGlobalSearch;
  final int frozenColumnCount;
  final int footerFrozenColumnCount;
  final int frozenRowCount;
  final int footerFrozenRowCount;
  final bool showPlaceholderWhileScrolling;
  final bool shrinkWrapRows;
  final bool shrinkWrapColumns;
  final double frozenPaneElevation;
  final BorderSide? frozenPaneBorderSide;
  final FrozenPaneScrollMode frozenPaneScrollMode;
  final Color? filterTabItemBackgroundColor;
  final Color? filterTabItemBorderColor;
  final Color? filterTabItemParamsColor;
  final Color? filterTabItemIconColor;
  final Color? chartPopupBackgroundColor;
  final Color? chartPopupBorderColor;
  final Color? chartPopupLoadingBackgroundColor;
  final Color? chartPopupLoadingTextColor;
  final Color? chartPopupResizeHandleColor;
  final Color? mobileSettingsBackgroundColor;
  final Color? mobileSettingsHeaderColor;
  final Color? mobileSettingsIconColor;
  final Color? chartTitleColor;
  final Color? chartIconColor;
  final Color? fullScreenButtonColor;
  final Color? closeButtonColor;
  final Color? chartSettingsSidebarBackgroundColor;
  final Color? contextMenuIconColor;
  final Color? contextMenuTextColor;
  final Color? contextMenuDestructiveColor;
  final Color? contextMenuSectionHeaderColor;
  final Color? contextMenuItemIconBackgroundColor;
  final Color? contextMenuSortIconColor;
  final Color? contextMenuPinIconColor;
  final Color? contextMenuGroupIconColor;
  final Color? contextMenuAggregationIconColor;
  final Color? contextMenuLayoutIconColor;

  const DatagridConfiguration({
    this.headerBackgroundColor = const Color(0xFFE7E7E7),
    this.headerForegroundColor = const Color(0xFF131313),
    this.rowBackgroundColor = Colors.transparent,
    this.rowForegroundColor = const Color(0xFF131313),
    this.selectedRowColor = const Color(0x14398FD4),
    this.rowHoverColor = const Color(0x0A000000),
    this.selectedRowForegroundColor = const Color(0xFF131313),
    this.headerBorderColor = const Color(0xFFE5E5E5),
    this.headerBorderWidth = 0.5,
    this.rowBorderColor = const Color(0xFFE5E5E5),
    this.rowBorderWidth = 0.5,
    this.headerBorderVisibility = GridBorderVisibility.both,
    this.rowBorderVisibility = GridBorderVisibility.both,
    this.headerTextStyle,
    this.rowTextStyle,
    this.selectedRowTextStyle,
    this.resizeHandleColor = Colors.transparent,
    this.resizeHandleWidth = 4,
    this.paginationBackgroundColor = const Color(0xFFFFFFFF),
    this.paginationSelectedBackgroundColor = const Color(0xFF398FD4),
    this.paginationSelectedForegroundColor = const Color(0xFFFFFFFF),
    this.paginationUnselectedBackgroundColor = const Color.fromARGB(
      255,
      250,
      249,
      247,
    ),
    this.paginationUnselectedForegroundColor = const Color(0xFFABABAB),
    this.paginationTextColor = const Color(0xFF131313),
    this.gridBackgroundColor = const Color(0xFFFFFFFF),
    this.gridBorderColor = const Color(0xFFE5E5E5),
    this.filterIconColor = const Color(0xFF131313),
    this.sortIconColor = const Color(0xFF131313),
    this.filterPopupBackgroundColor = const Color(0xFFFFFFFF),
    this.keyboardHideButtonBackgroundColor = const Color(0xFF131313),
    this.keyboardHideButtonForegroundColor = const Color(0xFFFFFFFF),
    this.primaryColor = const Color(0xFF398FD4),
    this.errorColor = const Color(0xFFF44242),
    this.inputFillColor = const Color.fromARGB(255, 255, 255, 255),
    this.inputBorderColor = const Color.fromARGB(255, 181, 181, 181),
    this.inputFocusBorderColor = const Color(0xFF398FD4),
    this.secondaryTextColor = const Color(0xFF929292),
    this.primaryForegroundColor = Colors.white,
    this.minColumnWidth = 120,
    this.rowHeight = 40.0,
    this.headerHeight = 50.0,
    this.cacheExtent = 250.0,
    this.columnWidthMode = ColumnWidthMode.fill,
    this.allowPagination = true,
    this.rowsPerPage = 250,
    this.paginationMode = PaginationMode.pages,
    this.allowSorting = true,
    this.allowColumnReordering = true,
    this.allowRowReordering = false, // Add default false
    this.selectionMode = SelectionMode.none,
    this.rowsPerPageOptions,
    this.quickFilters,
    this.showSettingsButton = true,
    this.showClearFiltersButton = true,
    this.showAddButton = false,
    this.addButtonText = 'Add',
    this.addButtonIcon = const Icon(Icons.add, size: 18, color: Colors.white),
    this.addButtonBackgroundColor,
    this.addButtonForegroundColor,
    this.addButtonBorderColor,
    this.addButtonFontSize,
    this.addButtonFontWeight,
    this.addButtonPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.addButtonBorderRadius = const BorderRadiusDirectional.all(
      Radius.circular(8),
    ),
    this.showFilterOnHover = true,
    this.showSortOnHover = true,
    this.enableGrouping = false,
    this.allowGrouping = true,
    this.showGroupingPanel = false,
    this.groupPanelBackgroundColor,
    this.groupPanelBorderColor,
    this.groupPanelBorderWidth,
    this.groupPanelHeight,
    this.groupPanelTextStyle,
    this.groupPanelIconColor,
    this.groupPanelClearIconColor,
    this.groupPanelItemBackgroundColor,
    this.groupPanelItemBorderColor,
    this.groupPanelItemTextStyle,
    this.columnSearchBorderColor = const Color(0xFFE0E0E0),
    this.columnSearchIconColor = const Color(0xFF9E9E9E),
    this.dragFeedbackOutsideBackgroundColor = const Color(0xFFF44336),
    this.dragFeedbackInsideBackgroundColor = const Color(0xFFFFFFFF),
    this.dragFeedbackOutsideBorderColor = const Color(0xFFF44336),
    this.dragFeedbackInsideBorderColor = const Color(0xFFE0E0E0),
    this.dragFeedbackOutsideTextColor = const Color(0xFFFFFFFF),
    this.dragFeedbackInsideTextColor = const Color(0xFF000000),
    this.dragFeedbackIconColor = const Color(0xFFFFFFFF),
    this.dragFeedbackShadowColor = const Color(0x1A000000),
    this.columnDragIndicatorColor = const Color(0xFF9E9E9E),
    this.columnFunctionIconColor = const Color(0xFF2196F3),
    this.bottomPanelSectionBorderColor = const Color(0xFFE0E0E0),
    this.bottomPanelDragTargetColor,
    this.bottomPanelDragTargetInactiveColor = const Color(0xFFEEEEEE),
    this.bottomPanelIconColor = const Color(0xFFBDBDBD),
    this.menuBackgroundColor = const Color(0xFFFFFFFF),
    this.menuSurfaceTintColor = const Color(0xFFFFFFFF),
    this.menuTextColor = const Color(0xFF9E9E9E),
    this.dialogBackgroundColor = const Color(0xFFFFFFFF),
    this.dialogSurfaceTintColor = const Color(0xFFFFFFFF),
    this.dialogTextColor = const Color(0xFF757575),
    this.contextMenuItems,
    this.useDefaultContextMenuItems = true,
    this.showCopyMenuItem = true,
    this.showCopyHeaderMenuItem = true,
    this.showEquationMenuItem = true,
    this.showSortMenuItem = true,
    this.showFilterBySelectionMenuItem = true,
    this.showChartsMenuItem = true,
    this.sidePanelConfiguration = const SidePanelConfiguration(),
    this.showColumnsTab = true,
    this.showFiltersTab = true,
    this.showQuickSearch = false,
    this.showGlobalSearch = false,
    this.frozenColumnCount = 0,
    this.footerFrozenColumnCount = 0,
    this.frozenRowCount = 0,
    this.footerFrozenRowCount = 0,
    this.showPlaceholderWhileScrolling = true,
    this.shrinkWrapRows = false,
    this.shrinkWrapColumns = false,
    this.frozenPaneElevation = 0.0,
    this.frozenPaneBorderSide = const BorderSide(
      color: Color(0xFFE5E5E5),
      width: 1,
    ),
    this.frozenPaneScrollMode = FrozenPaneScrollMode.sticky,
    this.filterTabItemBackgroundColor = const Color(0xFFFFFFFF),
    this.filterTabItemBorderColor = const Color(0xFFEEEEEE),
    this.filterTabItemParamsColor = const Color(0xDD000000),
    this.filterTabItemIconColor = const Color(0xFF757575),
    this.chartPopupBackgroundColor = const Color(0xFFFFFFFF),
    this.chartPopupBorderColor = const Color(0xFFBDBDBD),
    this.chartPopupLoadingBackgroundColor = const Color(0xFF000000),
    this.chartPopupLoadingTextColor = const Color(0xFF000000),
    this.chartPopupResizeHandleColor = const Color(0xFF9E9E9E),
    this.mobileSettingsBackgroundColor = const Color(0xFFFFFFFF),
    this.mobileSettingsHeaderColor,
    this.mobileSettingsIconColor,
    this.chartTitleColor = const Color(0xFFFFFFFF),
    this.chartIconColor = const Color(0xFFFFFFFF),
    this.fullScreenButtonColor = const Color(0xFFFFFFFF),
    this.closeButtonColor = const Color(0xFFFFFFFF),
    this.chartSettingsSidebarBackgroundColor,
    this.contextMenuIconColor = const Color(0xFF616161),
    this.contextMenuTextColor = const Color(0xDD000000),
    this.contextMenuDestructiveColor = const Color(0xFFF44336),
    this.contextMenuSectionHeaderColor,
    this.contextMenuItemIconBackgroundColor,
    this.contextMenuSortIconColor,
    this.contextMenuPinIconColor,
    this.contextMenuGroupIconColor,
    this.contextMenuAggregationIconColor,
    this.contextMenuLayoutIconColor,
  });

  DatagridConfiguration copyWith({
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    Color? rowBackgroundColor,
    Color? rowForegroundColor,
    Color? selectedRowColor,
    Color? rowHoverColor,
    Color? selectedRowForegroundColor,
    Color? headerBorderColor,
    double? headerBorderWidth,
    Color? rowBorderColor,
    double? rowBorderWidth,
    GridBorderVisibility? headerBorderVisibility,
    GridBorderVisibility? rowBorderVisibility,
    TextStyle? headerTextStyle,
    TextStyle? rowTextStyle,
    TextStyle? selectedRowTextStyle,
    Color? resizeHandleColor,
    double? resizeHandleWidth,
    Color? paginationBackgroundColor,
    Color? paginationSelectedBackgroundColor,
    Color? paginationSelectedForegroundColor,
    Color? paginationUnselectedBackgroundColor,
    Color? paginationUnselectedForegroundColor,
    Color? paginationTextColor,
    Color? gridBackgroundColor,
    Color? gridBorderColor,
    Color? filterIconColor,
    Color? sortIconColor,
    Color? filterPopupBackgroundColor,
    Color? keyboardHideButtonBackgroundColor,
    Color? keyboardHideButtonForegroundColor,
    Color? primaryColor,
    Color? errorColor,
    Color? inputFillColor,
    Color? inputBorderColor,
    Color? inputFocusBorderColor,
    Color? secondaryTextColor,
    Color? primaryForegroundColor,
    double? minColumnWidth,
    double? rowHeight,
    double? headerHeight,
    ColumnWidthMode? columnWidthMode,
    bool? allowPagination,
    int? rowsPerPage,
    PaginationMode? paginationMode,
    bool? allowSorting,
    bool? allowColumnReordering,
    bool? allowRowReordering,
    SelectionMode? selectionMode,
    List<int>? rowsPerPageOptions,
    List<QuickFilterConfig>? quickFilters,
    bool? showSettingsButton,
    bool? showClearFiltersButton,
    bool? showAddButton,
    String? addButtonText,
    Widget? addButtonIcon,
    Color? addButtonBackgroundColor,
    Color? addButtonForegroundColor,
    Color? addButtonBorderColor,
    double? addButtonFontSize,
    FontWeight? addButtonFontWeight,
    EdgeInsetsGeometry? addButtonPadding,
    BorderRadiusDirectional? addButtonBorderRadius,
    bool? showFilterOnHover,
    bool? showSortOnHover,
    bool? enableGrouping,
    bool? allowGrouping,
    bool? showGroupingPanel,
    Color? groupPanelBackgroundColor,
    Color? groupPanelBorderColor,
    double? groupPanelBorderWidth,
    double? groupPanelHeight,
    TextStyle? groupPanelTextStyle,
    Color? groupPanelIconColor,
    Color? groupPanelClearIconColor,
    Color? groupPanelItemBackgroundColor,
    Color? groupPanelItemBorderColor,
    TextStyle? groupPanelItemTextStyle,
    Color? columnSearchBorderColor,
    Color? columnSearchIconColor,
    Color? dragFeedbackOutsideBackgroundColor,
    Color? dragFeedbackInsideBackgroundColor,
    Color? dragFeedbackOutsideBorderColor,
    Color? dragFeedbackInsideBorderColor,
    Color? dragFeedbackOutsideTextColor,
    Color? dragFeedbackInsideTextColor,
    Color? dragFeedbackIconColor,
    Color? dragFeedbackShadowColor,
    Color? columnDragIndicatorColor,
    Color? columnFunctionIconColor,
    Color? bottomPanelSectionBorderColor,
    Color? bottomPanelDragTargetColor,
    Color? bottomPanelDragTargetInactiveColor,
    Color? bottomPanelIconColor,
    Color? menuBackgroundColor,
    Color? menuSurfaceTintColor,
    Color? menuTextColor,
    Color? dialogBackgroundColor,
    Color? dialogSurfaceTintColor,
    Color? dialogTextColor,
    List<DatagridContextMenuItem>? contextMenuItems,
    bool? useDefaultContextMenuItems,
    SidePanelConfiguration? sidePanelConfiguration,
    bool? showColumnsTab,
    bool? showFiltersTab,
    bool? showQuickSearch,
    bool? showGlobalSearch,
    int? frozenColumnCount,
    int? footerFrozenColumnCount,
    int? frozenRowCount,
    int? footerFrozenRowCount,
    bool? shrinkWrapRows,
    bool? shrinkWrapColumns,
    double? frozenPaneElevation,
    BorderSide? frozenPaneBorderSide,
    FrozenPaneScrollMode? frozenPaneScrollMode,
    Color? filterTabItemBackgroundColor,
    Color? filterTabItemBorderColor,
    Color? filterTabItemParamsColor,
    Color? filterTabItemIconColor,
    Color? chartPopupBackgroundColor,
    Color? chartPopupBorderColor,
    Color? chartPopupLoadingBackgroundColor,
    Color? chartPopupLoadingTextColor,
    Color? chartPopupResizeHandleColor,
    Color? mobileSettingsBackgroundColor,
    Color? mobileSettingsHeaderColor,
    Color? mobileSettingsIconColor,
    Color? chartTitleColor,
    Color? chartIconColor,
    Color? fullScreenButtonColor,
    Color? closeButtonColor,
    Color? chartSettingsSidebarBackgroundColor,
    Color? contextMenuIconColor,
    Color? contextMenuTextColor,
    Color? contextMenuDestructiveColor,
    Color? contextMenuSectionHeaderColor,
    Color? contextMenuItemIconBackgroundColor,
    Color? contextMenuSortIconColor,
    Color? contextMenuPinIconColor,
    Color? contextMenuGroupIconColor,
    Color? contextMenuAggregationIconColor,
    Color? contextMenuLayoutIconColor,
  }) {
    return DatagridConfiguration(
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerForegroundColor:
          headerForegroundColor ?? this.headerForegroundColor,
      rowBackgroundColor: rowBackgroundColor ?? this.rowBackgroundColor,
      rowForegroundColor: rowForegroundColor ?? this.rowForegroundColor,
      selectedRowColor: selectedRowColor ?? this.selectedRowColor,
      rowHoverColor: rowHoverColor ?? this.rowHoverColor,
      selectedRowForegroundColor:
          selectedRowForegroundColor ?? this.selectedRowForegroundColor,
      headerBorderColor: headerBorderColor ?? this.headerBorderColor,
      headerBorderWidth: headerBorderWidth ?? this.headerBorderWidth,
      rowBorderColor: rowBorderColor ?? this.rowBorderColor,
      rowBorderWidth: rowBorderWidth ?? this.rowBorderWidth,
      headerBorderVisibility:
          headerBorderVisibility ?? this.headerBorderVisibility,
      rowBorderVisibility: rowBorderVisibility ?? this.rowBorderVisibility,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      rowTextStyle: rowTextStyle ?? this.rowTextStyle,
      selectedRowTextStyle: selectedRowTextStyle ?? this.selectedRowTextStyle,
      resizeHandleColor: resizeHandleColor ?? this.resizeHandleColor,
      resizeHandleWidth: resizeHandleWidth ?? this.resizeHandleWidth,
      paginationBackgroundColor:
          paginationBackgroundColor ?? this.paginationBackgroundColor,
      paginationSelectedBackgroundColor:
          paginationSelectedBackgroundColor ??
          this.paginationSelectedBackgroundColor,
      paginationSelectedForegroundColor:
          paginationSelectedForegroundColor ??
          this.paginationSelectedForegroundColor,
      paginationUnselectedBackgroundColor:
          paginationUnselectedBackgroundColor ??
          this.paginationUnselectedBackgroundColor,
      paginationUnselectedForegroundColor:
          paginationUnselectedForegroundColor ??
          this.paginationUnselectedForegroundColor,
      paginationTextColor: paginationTextColor ?? this.paginationTextColor,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      gridBorderColor: gridBorderColor ?? this.gridBorderColor,
      filterIconColor: filterIconColor ?? this.filterIconColor,
      sortIconColor: sortIconColor ?? this.sortIconColor,
      filterPopupBackgroundColor:
          filterPopupBackgroundColor ?? this.filterPopupBackgroundColor,
      keyboardHideButtonBackgroundColor:
          keyboardHideButtonBackgroundColor ??
          this.keyboardHideButtonBackgroundColor,
      keyboardHideButtonForegroundColor:
          keyboardHideButtonForegroundColor ??
          this.keyboardHideButtonForegroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      errorColor: errorColor ?? this.errorColor,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      inputBorderColor: inputBorderColor ?? this.inputBorderColor,
      inputFocusBorderColor:
          inputFocusBorderColor ?? this.inputFocusBorderColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      primaryForegroundColor:
          primaryForegroundColor ?? this.primaryForegroundColor,
      minColumnWidth: minColumnWidth ?? this.minColumnWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      columnWidthMode: columnWidthMode ?? this.columnWidthMode,
      allowPagination: allowPagination ?? this.allowPagination,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      paginationMode: paginationMode ?? this.paginationMode,
      allowSorting: allowSorting ?? this.allowSorting,
      allowColumnReordering:
          allowColumnReordering ?? this.allowColumnReordering,
      allowRowReordering: allowRowReordering ?? this.allowRowReordering,
      selectionMode: selectionMode ?? this.selectionMode,
      rowsPerPageOptions: rowsPerPageOptions ?? this.rowsPerPageOptions,
      quickFilters: quickFilters ?? this.quickFilters,
      showSettingsButton: showSettingsButton ?? this.showSettingsButton,
      showClearFiltersButton:
          showClearFiltersButton ?? this.showClearFiltersButton,
      showAddButton: showAddButton ?? this.showAddButton,
      addButtonText: addButtonText ?? this.addButtonText,
      addButtonIcon: addButtonIcon ?? this.addButtonIcon,
      addButtonBackgroundColor:
          addButtonBackgroundColor ?? this.addButtonBackgroundColor,
      addButtonForegroundColor:
          addButtonForegroundColor ?? this.addButtonForegroundColor,
      addButtonBorderColor: addButtonBorderColor ?? this.addButtonBorderColor,
      addButtonFontSize: addButtonFontSize ?? this.addButtonFontSize,
      addButtonFontWeight: addButtonFontWeight ?? this.addButtonFontWeight,
      addButtonPadding: addButtonPadding ?? this.addButtonPadding,
      addButtonBorderRadius:
          addButtonBorderRadius ?? this.addButtonBorderRadius,
      showFilterOnHover: showFilterOnHover ?? this.showFilterOnHover,
      showSortOnHover: showSortOnHover ?? this.showSortOnHover,
      enableGrouping: enableGrouping ?? this.enableGrouping,
      allowGrouping: allowGrouping ?? this.allowGrouping,
      showGroupingPanel: showGroupingPanel ?? this.showGroupingPanel,
      groupPanelBackgroundColor:
          groupPanelBackgroundColor ?? this.groupPanelBackgroundColor,
      groupPanelBorderColor:
          groupPanelBorderColor ?? this.groupPanelBorderColor,
      groupPanelBorderWidth:
          groupPanelBorderWidth ?? this.groupPanelBorderWidth,
      groupPanelHeight: groupPanelHeight ?? this.groupPanelHeight,
      groupPanelTextStyle: groupPanelTextStyle ?? this.groupPanelTextStyle,
      groupPanelIconColor: groupPanelIconColor ?? this.groupPanelIconColor,
      groupPanelClearIconColor:
          groupPanelClearIconColor ?? this.groupPanelClearIconColor,
      groupPanelItemBackgroundColor:
          groupPanelItemBackgroundColor ?? this.groupPanelItemBackgroundColor,
      groupPanelItemBorderColor:
          groupPanelItemBorderColor ?? this.groupPanelItemBorderColor,
      groupPanelItemTextStyle:
          groupPanelItemTextStyle ?? this.groupPanelItemTextStyle,
      columnSearchBorderColor:
          columnSearchBorderColor ?? this.columnSearchBorderColor,
      columnSearchIconColor:
          columnSearchIconColor ?? this.columnSearchIconColor,
      dragFeedbackOutsideBackgroundColor:
          dragFeedbackOutsideBackgroundColor ??
          this.dragFeedbackOutsideBackgroundColor,
      dragFeedbackInsideBackgroundColor:
          dragFeedbackInsideBackgroundColor ??
          this.dragFeedbackInsideBackgroundColor,
      dragFeedbackOutsideBorderColor:
          dragFeedbackOutsideBorderColor ?? this.dragFeedbackOutsideBorderColor,
      dragFeedbackInsideBorderColor:
          dragFeedbackInsideBorderColor ?? this.dragFeedbackInsideBorderColor,
      dragFeedbackOutsideTextColor:
          dragFeedbackOutsideTextColor ?? this.dragFeedbackOutsideTextColor,
      dragFeedbackInsideTextColor:
          dragFeedbackInsideTextColor ?? this.dragFeedbackInsideTextColor,
      dragFeedbackIconColor:
          dragFeedbackIconColor ?? this.dragFeedbackIconColor,
      dragFeedbackShadowColor:
          dragFeedbackShadowColor ?? this.dragFeedbackShadowColor,
      columnDragIndicatorColor:
          columnDragIndicatorColor ?? this.columnDragIndicatorColor,
      columnFunctionIconColor:
          columnFunctionIconColor ?? this.columnFunctionIconColor,
      bottomPanelSectionBorderColor:
          bottomPanelSectionBorderColor ?? this.bottomPanelSectionBorderColor,
      bottomPanelDragTargetColor:
          bottomPanelDragTargetColor ?? this.bottomPanelDragTargetColor,
      bottomPanelDragTargetInactiveColor:
          bottomPanelDragTargetInactiveColor ??
          this.bottomPanelDragTargetInactiveColor,
      bottomPanelIconColor: bottomPanelIconColor ?? this.bottomPanelIconColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      menuSurfaceTintColor: menuSurfaceTintColor ?? this.menuSurfaceTintColor,
      menuTextColor: menuTextColor ?? this.menuTextColor,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      dialogSurfaceTintColor:
          dialogSurfaceTintColor ?? this.dialogSurfaceTintColor,
      dialogTextColor: dialogTextColor ?? this.dialogTextColor,
      contextMenuItems: contextMenuItems ?? this.contextMenuItems,
      useDefaultContextMenuItems:
          useDefaultContextMenuItems ?? this.useDefaultContextMenuItems,
      sidePanelConfiguration:
          sidePanelConfiguration ?? this.sidePanelConfiguration,
      showColumnsTab: showColumnsTab ?? this.showColumnsTab,
      showFiltersTab: showFiltersTab ?? this.showFiltersTab,
      showQuickSearch: showQuickSearch ?? this.showQuickSearch,
      showGlobalSearch: showGlobalSearch ?? this.showGlobalSearch,
      frozenColumnCount: frozenColumnCount ?? this.frozenColumnCount,
      footerFrozenColumnCount:
          footerFrozenColumnCount ?? this.footerFrozenColumnCount,
      frozenRowCount: frozenRowCount ?? this.frozenRowCount,
      footerFrozenRowCount: footerFrozenRowCount ?? this.footerFrozenRowCount,
      shrinkWrapRows: shrinkWrapRows ?? this.shrinkWrapRows,
      shrinkWrapColumns: shrinkWrapColumns ?? this.shrinkWrapColumns,
      frozenPaneElevation: frozenPaneElevation ?? this.frozenPaneElevation,
      frozenPaneBorderSide: frozenPaneBorderSide ?? this.frozenPaneBorderSide,
      frozenPaneScrollMode: frozenPaneScrollMode ?? this.frozenPaneScrollMode,
      filterTabItemBackgroundColor:
          filterTabItemBackgroundColor ?? this.filterTabItemBackgroundColor,
      filterTabItemBorderColor:
          filterTabItemBorderColor ?? this.filterTabItemBorderColor,
      filterTabItemParamsColor:
          filterTabItemParamsColor ?? this.filterTabItemParamsColor,
      filterTabItemIconColor:
          filterTabItemIconColor ?? this.filterTabItemIconColor,
      chartPopupBackgroundColor:
          chartPopupBackgroundColor ?? this.chartPopupBackgroundColor,
      chartPopupBorderColor:
          chartPopupBorderColor ?? this.chartPopupBorderColor,
      chartPopupLoadingBackgroundColor:
          chartPopupLoadingBackgroundColor ??
          this.chartPopupLoadingBackgroundColor,
      chartPopupLoadingTextColor:
          chartPopupLoadingTextColor ?? this.chartPopupLoadingTextColor,
      chartPopupResizeHandleColor:
          chartPopupResizeHandleColor ?? this.chartPopupResizeHandleColor,
      mobileSettingsBackgroundColor:
          mobileSettingsBackgroundColor ?? this.mobileSettingsBackgroundColor,
      mobileSettingsHeaderColor:
          mobileSettingsHeaderColor ?? this.mobileSettingsHeaderColor,
      mobileSettingsIconColor:
          mobileSettingsIconColor ?? this.mobileSettingsIconColor,
      chartTitleColor: chartTitleColor ?? this.chartTitleColor,
      chartIconColor: chartIconColor ?? this.chartIconColor,
      fullScreenButtonColor:
          fullScreenButtonColor ?? this.fullScreenButtonColor,
      closeButtonColor: closeButtonColor ?? this.closeButtonColor,
      chartSettingsSidebarBackgroundColor:
          chartSettingsSidebarBackgroundColor ??
          this.chartSettingsSidebarBackgroundColor,
      contextMenuIconColor: contextMenuIconColor ?? this.contextMenuIconColor,
      contextMenuTextColor: contextMenuTextColor ?? this.contextMenuTextColor,
      contextMenuDestructiveColor:
          contextMenuDestructiveColor ?? this.contextMenuDestructiveColor,
      contextMenuSectionHeaderColor:
          contextMenuSectionHeaderColor ?? this.contextMenuSectionHeaderColor,
      contextMenuItemIconBackgroundColor:
          contextMenuItemIconBackgroundColor ??
          this.contextMenuItemIconBackgroundColor,
      contextMenuSortIconColor:
          contextMenuSortIconColor ?? this.contextMenuSortIconColor,
      contextMenuPinIconColor:
          contextMenuPinIconColor ?? this.contextMenuPinIconColor,
      contextMenuGroupIconColor:
          contextMenuGroupIconColor ?? this.contextMenuGroupIconColor,
      contextMenuAggregationIconColor:
          contextMenuAggregationIconColor ??
          this.contextMenuAggregationIconColor,
      contextMenuLayoutIconColor:
          contextMenuLayoutIconColor ?? this.contextMenuLayoutIconColor,
    );
  }
}
