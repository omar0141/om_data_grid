import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/datagrid_labels.dart';
import '../enums/selection_mode_enum.dart';
import '../enums/grid_border_visibility_enum.dart';
import 'side_panel_config.dart';
import 'datagrid_theme.dart';

/// Defines how column widths are calculated.
enum OmColumnWidthMode {
  /// Columns fill the available width.
  fill,

  /// Columns sized automatically.
  auto,

  /// Columns sized to fit their cell values.
  fitByCellValue,

  /// Columns sized to fit their header name.
  fitByColumnName,

  /// The last column fills the remaining space.
  lastColumnFill,

  /// No automatic sizing.
  none,
}

/// Defines the style of pagination.
enum OmPaginationMode {
  /// Shows "Page X of Y".
  simple,

  /// Shows numbered page buttons [1, 2, 3...].
  pages,
}

/// Defines the scrolling behavior of frozen panes.
enum OmFrozenPaneScrollMode {
  /// Frozen panes remain fixed.
  fixed,

  /// Frozen panes stick to the edge.
  sticky,
}

/// Configuration for the quick filter bar.
class OmQuickFilterConfig {
  /// The key of the column to filter.
  final String columnKey;

  /// Whether multiple values can be selected.
  final bool isMultiSelect;

  /// Whether to show the column title.
  final bool showTitle;

  /// Creates a [OmQuickFilterConfig].
  const OmQuickFilterConfig({
    required this.columnKey,
    this.isMultiSelect = false,
    this.showTitle = false,
  });
}

/// Represents an item in the grid's context menu.
class OmDataGridContextMenuItem {
  /// Label for the menu item.
  final String label;

  /// Icon for the menu item.
  final IconData icon;

  /// Value associated with the menu item.
  final String value;

  /// Whether the action is destructive (e.g., delete).
  final bool isDestructive;

  /// Callback when the item is pressed.
  final void Function(
    List<Map<String, dynamic>> selectedRows,
    List<OmGridColumnModel> selectedColumns,
  )? onPressed;

  /// Creates a [OmDataGridContextMenuItem].
  const OmDataGridContextMenuItem({
    required this.label,
    required this.icon,
    required this.value,
    this.isDestructive = false,
    this.onPressed,
  });
}

/// Configuration for the Data Grid's appearance and behavior.
class OmDataGridConfiguration {
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
  final OmGridBorderVisibility headerBorderVisibility;
  final OmGridBorderVisibility rowBorderVisibility;
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
  final Color gridForegroundColor;
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
  final String? gridFontFamily;
  final double minColumnWidth;
  final double rowHeight;
  final double headerHeight;
  final double cacheExtent;
  final OmColumnWidthMode columnWidthMode;
  final bool allowPagination;
  final int rowsPerPage;
  final OmPaginationMode paginationMode;
  final bool allowSorting;
  final bool allowColumnReordering;
  final bool allowRowReordering; // Add field
  final bool resetPageOnDataChange;
  final OmSelectionMode selectionMode;
  final List<int>? rowsPerPageOptions;
  final List<OmQuickFilterConfig>? quickFilters;
  final bool showSettingsButton;
  final bool showClearFiltersButton;
  final bool showAddButton;
  final String? addButtonText;
  final Widget? addButtonIcon;
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
  final List<OmDataGridContextMenuItem>? contextMenuItems;
  final bool useDefaultContextMenuItems;
  final bool showCopyMenuItem;
  final bool showCopyHeaderMenuItem;
  final bool showEquationMenuItem;
  final bool showSortMenuItem;
  final bool showFilterBySelectionMenuItem;
  final bool showChartsMenuItem;
  final OmSidePanelConfiguration sidePanelConfiguration;
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
  final OmFrozenPaneScrollMode frozenPaneScrollMode;
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
  final OmDataGridLabels labels;

  const OmDataGridConfiguration({
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    Color? rowBackgroundColor,
    Color? rowForegroundColor,
    Color? selectedRowColor,
    Color? rowHoverColor,
    Color? selectedRowForegroundColor,
    Color? headerBorderColor,
    this.headerBorderWidth = 0.5,
    Color? rowBorderColor,
    this.rowBorderWidth = 0.5,
    this.headerBorderVisibility = OmGridBorderVisibility.both,
    this.rowBorderVisibility = OmGridBorderVisibility.both,
    this.headerTextStyle,
    this.rowTextStyle,
    this.selectedRowTextStyle,
    Color? resizeHandleColor,
    this.resizeHandleWidth = 4,
    Color? paginationBackgroundColor,
    Color? paginationSelectedBackgroundColor,
    Color? paginationSelectedForegroundColor,
    Color? paginationUnselectedBackgroundColor,
    Color? paginationUnselectedForegroundColor,
    Color? paginationTextColor,
    Color? gridBackgroundColor,
    Color? gridForegroundColor,
    Color? gridBorderColor,
    Color? filterIconColor,
    Color? sortIconColor,
    Color? filterPopupBackgroundColor,
    Color? keyboardHideButtonBackgroundColor,
    Color? keyboardHideButtonForegroundColor,
    Color? primaryColor,
    this.errorColor = const Color(0xFFF44242),
    Color? inputFillColor,
    Color? inputBorderColor,
    Color? inputFocusBorderColor,
    Color? secondaryTextColor,
    this.primaryForegroundColor = Colors.white,
    this.gridFontFamily,
    this.minColumnWidth = 120,
    this.rowHeight = 40.0,
    this.headerHeight = 50.0,
    this.cacheExtent = 250.0,
    this.columnWidthMode = OmColumnWidthMode.fill,
    this.allowPagination = true,
    this.rowsPerPage = 250,
    this.paginationMode = OmPaginationMode.pages,
    this.allowSorting = true,
    this.allowColumnReordering = true,
    this.allowRowReordering = false,
    this.resetPageOnDataChange = false,
    this.selectionMode = OmSelectionMode.none,
    this.rowsPerPageOptions,
    this.quickFilters,
    this.showSettingsButton = true,
    this.showClearFiltersButton = true,
    this.showAddButton = false,
    this.addButtonText = 'Add',
    this.addButtonIcon,
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
    this.sidePanelConfiguration = const OmSidePanelConfiguration(),
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
    this.frozenPaneScrollMode = OmFrozenPaneScrollMode.sticky,
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
    this.contextMenuDestructiveColor = const Color(0xFFF44336),
    Color? contextMenuSectionHeaderColor,
    Color? contextMenuItemIconBackgroundColor,
    Color? contextMenuSortIconColor,
    Color? contextMenuPinIconColor,
    Color? contextMenuGroupIconColor,
    Color? contextMenuAggregationIconColor,
    Color? contextMenuLayoutIconColor,
    this.labels = const OmDataGridLabels(),
  })  : gridBackgroundColor = gridBackgroundColor ?? const Color(0xFFFFFFFF),
        gridForegroundColor = gridForegroundColor ?? const Color(0xFF1E293B),
        gridBorderColor = gridBorderColor ?? const Color(0xFFE2E8F0),
        primaryColor = primaryColor ?? const Color(0xFF1E293B),
        headerBackgroundColor = headerBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFAFAFA)),
        headerForegroundColor = headerForegroundColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        rowBackgroundColor = rowBackgroundColor ?? Colors.transparent,
        rowForegroundColor = rowForegroundColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        selectedRowColor = selectedRowColor ?? const Color(0x141E293B),
        rowHoverColor = rowHoverColor ?? const Color(0x0A1E293B),
        selectedRowForegroundColor = selectedRowForegroundColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        headerBorderColor =
            headerBorderColor ?? (gridBorderColor ?? const Color(0xFFE2E8F0)),
        rowBorderColor =
            rowBorderColor ?? (gridBorderColor ?? const Color(0xFFE2E8F0)),
        resizeHandleColor = resizeHandleColor ?? Colors.transparent,
        paginationBackgroundColor = paginationBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        paginationSelectedBackgroundColor = paginationSelectedBackgroundColor ??
            (primaryColor ?? const Color(0xFF1E293B)),
        paginationSelectedForegroundColor =
            paginationSelectedForegroundColor ?? Colors.white,
        paginationUnselectedBackgroundColor =
            paginationUnselectedBackgroundColor ??
                const Color.fromARGB(255, 250, 249, 247),
        paginationUnselectedForegroundColor =
            paginationUnselectedForegroundColor ?? const Color(0xFFABABAB),
        paginationTextColor = paginationTextColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        filterIconColor =
            filterIconColor ?? (gridForegroundColor ?? const Color(0xFF1E293B)),
        sortIconColor =
            sortIconColor ?? (gridForegroundColor ?? const Color(0xFF1E293B)),
        filterPopupBackgroundColor = filterPopupBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        keyboardHideButtonBackgroundColor = keyboardHideButtonBackgroundColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        keyboardHideButtonForegroundColor = keyboardHideButtonForegroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        inputFillColor = inputFillColor ??
            (gridBackgroundColor ?? const Color.fromARGB(255, 255, 255, 255)),
        inputBorderColor = inputBorderColor ??
            (gridBorderColor ?? const Color.fromARGB(255, 181, 181, 181)),
        inputFocusBorderColor =
            inputFocusBorderColor ?? (primaryColor ?? const Color(0xFF1E293B)),
        secondaryTextColor = secondaryTextColor ?? const Color(0xFF929292),
        filterTabItemBackgroundColor = filterTabItemBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        filterTabItemBorderColor = filterTabItemBorderColor ??
            (gridBorderColor ?? const Color(0xFFEEEEEE)),
        filterTabItemParamsColor =
            filterTabItemParamsColor ?? const Color(0xDD000000),
        filterTabItemIconColor =
            filterTabItemIconColor ?? const Color(0xFF757575),
        chartPopupBackgroundColor = chartPopupBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        chartPopupBorderColor = chartPopupBorderColor ??
            (gridBorderColor ?? const Color(0xFFBDBDBD)),
        chartPopupLoadingBackgroundColor =
            chartPopupLoadingBackgroundColor ?? const Color(0xFF000000),
        chartPopupLoadingTextColor =
            chartPopupLoadingTextColor ?? const Color(0xFF000000),
        chartPopupResizeHandleColor =
            chartPopupResizeHandleColor ?? const Color(0xFF9E9E9E),
        mobileSettingsBackgroundColor = mobileSettingsBackgroundColor ??
            (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        mobileSettingsHeaderColor = mobileSettingsHeaderColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        mobileSettingsIconColor = mobileSettingsIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        chartTitleColor = chartTitleColor ?? const Color(0xFFFFFFFF),
        chartIconColor = chartIconColor ?? const Color(0xFFFFFFFF),
        fullScreenButtonColor =
            fullScreenButtonColor ?? const Color(0xFFFFFFFF),
        closeButtonColor = closeButtonColor ?? const Color(0xFFFFFFFF),
        chartSettingsSidebarBackgroundColor =
            chartSettingsSidebarBackgroundColor ??
                (gridBackgroundColor ?? const Color(0xFFFFFFFF)),
        contextMenuIconColor = contextMenuIconColor ??
            (gridForegroundColor ?? const Color(0xFF64748B)),
        contextMenuTextColor = contextMenuTextColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuSectionHeaderColor = contextMenuSectionHeaderColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuItemIconBackgroundColor =
            contextMenuItemIconBackgroundColor ?? Colors.transparent,
        contextMenuSortIconColor = contextMenuSortIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuPinIconColor = contextMenuPinIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuGroupIconColor = contextMenuGroupIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuAggregationIconColor = contextMenuAggregationIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B)),
        contextMenuLayoutIconColor = contextMenuLayoutIconColor ??
            (gridForegroundColor ?? const Color(0xFF1E293B));

  /// Creates an [OmDataGridConfiguration] from a simple [OmDataGridTheme].
  ///
  /// This is the **recommended** way to configure colors. Just pass a theme
  /// with a few base colors and all 80+ color properties are derived
  /// automatically. You can still override any individual color.
  ///
  /// ```dart
  /// // Minimal — just a primary color:
  /// OmDataGridConfiguration.fromTheme(
  ///   theme: OmDataGridTheme(primaryColor: Colors.indigo),
  /// )
  ///
  /// // Use a preset + override a few things:
  /// OmDataGridConfiguration.fromTheme(
  ///   theme: OmDataGridTheme.dark(),
  ///   rowHeight: 50,
  ///   allowPagination: true,
  ///   headerBackgroundColor: Colors.blueGrey, // override just this one
  /// )
  /// ```
  factory OmDataGridConfiguration.fromTheme({
    required OmDataGridTheme theme,
    // --- Color overrides (all optional) ---

    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    Color? rowBackgroundColor,
    Color? rowForegroundColor,
    Color? selectedRowColor,
    Color? rowHoverColor,
    Color? selectedRowForegroundColor,
    Color? headerBorderColor,
    double headerBorderWidth = 0.5,
    Color? rowBorderColor,
    double rowBorderWidth = 0.5,
    OmGridBorderVisibility headerBorderVisibility = OmGridBorderVisibility.both,
    OmGridBorderVisibility rowBorderVisibility = OmGridBorderVisibility.both,
    TextStyle? headerTextStyle,
    TextStyle? rowTextStyle,
    TextStyle? selectedRowTextStyle,
    Color? resizeHandleColor,
    double resizeHandleWidth = 4,
    Color? paginationBackgroundColor,
    Color? paginationSelectedBackgroundColor,
    Color? paginationSelectedForegroundColor,
    Color? paginationUnselectedBackgroundColor,
    Color? paginationUnselectedForegroundColor,
    Color? paginationTextColor,
    Color? filterIconColor,
    Color? sortIconColor,
    Color? filterPopupBackgroundColor,
    Color? keyboardHideButtonBackgroundColor,
    Color? keyboardHideButtonForegroundColor,
    Color? inputFillColor,
    Color? inputBorderColor,
    Color? inputFocusBorderColor,
    Color? secondaryTextColor,
    String? gridFontFamily,
    double minColumnWidth = 120,
    double rowHeight = 40.0,
    double headerHeight = 50.0,
    double cacheExtent = 250.0,
    OmColumnWidthMode columnWidthMode = OmColumnWidthMode.fill,
    bool allowPagination = true,
    int rowsPerPage = 250,
    OmPaginationMode paginationMode = OmPaginationMode.pages,
    bool allowSorting = true,
    bool allowColumnReordering = true,
    bool allowRowReordering = false,
    bool resetPageOnDataChange = false,
    OmSelectionMode selectionMode = OmSelectionMode.none,
    List<int>? rowsPerPageOptions,
    List<OmQuickFilterConfig>? quickFilters,
    bool showSettingsButton = true,
    bool showClearFiltersButton = true,
    bool showAddButton = false,
    String? addButtonText = 'Add',
    Widget? addButtonIcon,
    Color? addButtonBackgroundColor,
    Color? addButtonForegroundColor,
    Color? addButtonBorderColor,
    double? addButtonFontSize,
    FontWeight? addButtonFontWeight,
    EdgeInsetsGeometry? addButtonPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    BorderRadiusDirectional? addButtonBorderRadius =
        const BorderRadiusDirectional.all(Radius.circular(8)),
    bool showFilterOnHover = true,
    bool showSortOnHover = true,
    bool enableGrouping = false,
    bool allowGrouping = true,
    bool showGroupingPanel = false,
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
    List<OmDataGridContextMenuItem>? contextMenuItems,
    bool useDefaultContextMenuItems = true,
    bool showCopyMenuItem = true,
    bool showCopyHeaderMenuItem = true,
    bool showEquationMenuItem = true,
    bool showSortMenuItem = true,
    bool showFilterBySelectionMenuItem = true,
    bool showChartsMenuItem = true,
    OmSidePanelConfiguration sidePanelConfiguration =
        const OmSidePanelConfiguration(),
    bool showColumnsTab = true,
    bool showFiltersTab = true,
    bool showQuickSearch = false,
    bool showGlobalSearch = false,
    int frozenColumnCount = 0,
    int footerFrozenColumnCount = 0,
    int frozenRowCount = 0,
    int footerFrozenRowCount = 0,
    bool showPlaceholderWhileScrolling = true,
    bool shrinkWrapRows = false,
    bool shrinkWrapColumns = false,
    double frozenPaneElevation = 0.0,
    BorderSide? frozenPaneBorderSide,
    OmFrozenPaneScrollMode frozenPaneScrollMode = OmFrozenPaneScrollMode.sticky,
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
    Color? primaryForegroundColor,
    OmDataGridLabels? labels,
  }) {
    final t = theme;
    return OmDataGridConfiguration(
      labels: labels ?? const OmDataGridLabels(),
      // Core colors derived from theme
      primaryColor: t.primaryColor,
      primaryForegroundColor: primaryForegroundColor ?? t.onPrimaryColor,
      errorColor: t.errorColor,
      gridBackgroundColor: t.backgroundColor,
      gridForegroundColor: t.foregroundColor,
      gridBorderColor: t.borderColor,
      // Header
      headerBackgroundColor: headerBackgroundColor ?? t.surfaceColor,
      headerForegroundColor: headerForegroundColor ?? t.foregroundColor,
      headerBorderColor: headerBorderColor ?? t.borderColor,
      headerBorderWidth: headerBorderWidth,
      headerBorderVisibility: headerBorderVisibility,
      headerTextStyle: headerTextStyle,
      // Rows
      rowBackgroundColor: rowBackgroundColor ?? Colors.transparent,
      rowForegroundColor: rowForegroundColor ?? t.foregroundColor,
      rowBorderColor: rowBorderColor ?? t.borderColor,
      rowBorderWidth: rowBorderWidth,
      rowBorderVisibility: rowBorderVisibility,
      rowTextStyle: rowTextStyle,
      selectedRowTextStyle: selectedRowTextStyle,
      selectedRowColor: selectedRowColor ?? t.selectionColor,
      rowHoverColor: rowHoverColor ?? t.hoverColor,
      selectedRowForegroundColor:
          selectedRowForegroundColor ?? t.foregroundColor,
      // Resize
      resizeHandleColor: resizeHandleColor ?? Colors.transparent,
      resizeHandleWidth: resizeHandleWidth,
      // Pagination
      paginationBackgroundColor: paginationBackgroundColor ?? t.backgroundColor,
      paginationSelectedBackgroundColor:
          paginationSelectedBackgroundColor ?? t.primaryColor,
      paginationSelectedForegroundColor:
          paginationSelectedForegroundColor ?? t.onPrimaryColor,
      paginationUnselectedBackgroundColor:
          paginationUnselectedBackgroundColor ??
              t.paginationUnselectedBackground,
      paginationUnselectedForegroundColor:
          paginationUnselectedForegroundColor ??
              t.paginationUnselectedForeground,
      paginationTextColor: paginationTextColor ?? t.foregroundColor,
      // Filter / Sort icons
      filterIconColor: filterIconColor ?? t.iconColor,
      sortIconColor: sortIconColor ?? t.iconColor,
      filterPopupBackgroundColor:
          filterPopupBackgroundColor ?? t.backgroundColor,
      // Keyboard
      keyboardHideButtonBackgroundColor:
          keyboardHideButtonBackgroundColor ?? t.foregroundColor,
      keyboardHideButtonForegroundColor:
          keyboardHideButtonForegroundColor ?? t.backgroundColor,
      // Input
      inputFillColor: inputFillColor ?? t.inputFillColor,
      inputBorderColor: inputBorderColor ?? t.inputBorderColor,
      inputFocusBorderColor: inputFocusBorderColor ?? t.inputFocusBorderColor,
      secondaryTextColor: secondaryTextColor ?? t.secondaryTextColor,
      // Font
      gridFontFamily: gridFontFamily,
      // Layout
      minColumnWidth: minColumnWidth,
      rowHeight: rowHeight,
      headerHeight: headerHeight,
      cacheExtent: cacheExtent,
      columnWidthMode: columnWidthMode,
      // Pagination behavior
      allowPagination: allowPagination,
      rowsPerPage: rowsPerPage,
      paginationMode: paginationMode,
      rowsPerPageOptions: rowsPerPageOptions,
      // Behavior
      allowSorting: allowSorting,
      allowColumnReordering: allowColumnReordering,
      allowRowReordering: allowRowReordering,
      resetPageOnDataChange: resetPageOnDataChange,
      selectionMode: selectionMode,
      quickFilters: quickFilters,
      // Toolbar
      showSettingsButton: showSettingsButton,
      showClearFiltersButton: showClearFiltersButton,
      showAddButton: showAddButton,
      addButtonText: addButtonText,
      addButtonIcon: addButtonIcon,
      addButtonBackgroundColor: addButtonBackgroundColor,
      addButtonForegroundColor: addButtonForegroundColor,
      addButtonBorderColor: addButtonBorderColor,
      addButtonFontSize: addButtonFontSize,
      addButtonFontWeight: addButtonFontWeight,
      addButtonPadding: addButtonPadding,
      addButtonBorderRadius: addButtonBorderRadius,
      showFilterOnHover: showFilterOnHover,
      showSortOnHover: showSortOnHover,
      // Grouping
      enableGrouping: enableGrouping,
      allowGrouping: allowGrouping,
      showGroupingPanel: showGroupingPanel,
      groupPanelBackgroundColor: groupPanelBackgroundColor,
      groupPanelBorderColor: groupPanelBorderColor ?? t.borderColor,
      groupPanelBorderWidth: groupPanelBorderWidth,
      groupPanelHeight: groupPanelHeight,
      groupPanelTextStyle: groupPanelTextStyle,
      groupPanelIconColor: groupPanelIconColor,
      groupPanelClearIconColor: groupPanelClearIconColor,
      groupPanelItemBackgroundColor: groupPanelItemBackgroundColor,
      groupPanelItemBorderColor: groupPanelItemBorderColor,
      groupPanelItemTextStyle: groupPanelItemTextStyle,
      // Column search
      columnSearchBorderColor: columnSearchBorderColor ?? t.borderColor,
      columnSearchIconColor: columnSearchIconColor ?? t.mutedIconColor,
      // Drag feedback
      dragFeedbackOutsideBackgroundColor:
          dragFeedbackOutsideBackgroundColor ?? t.errorColor,
      dragFeedbackInsideBackgroundColor:
          dragFeedbackInsideBackgroundColor ?? t.backgroundColor,
      dragFeedbackOutsideBorderColor:
          dragFeedbackOutsideBorderColor ?? t.errorColor,
      dragFeedbackInsideBorderColor:
          dragFeedbackInsideBorderColor ?? t.borderColor,
      dragFeedbackOutsideTextColor:
          dragFeedbackOutsideTextColor ?? t.onPrimaryColor,
      dragFeedbackInsideTextColor:
          dragFeedbackInsideTextColor ?? t.foregroundColor,
      dragFeedbackIconColor: dragFeedbackIconColor ?? t.onPrimaryColor,
      dragFeedbackShadowColor: dragFeedbackShadowColor ?? t.shadowColor,
      columnDragIndicatorColor: columnDragIndicatorColor ?? t.mutedIconColor,
      columnFunctionIconColor:
          columnFunctionIconColor ?? const Color(0xFF2196F3),
      // Bottom panel
      bottomPanelSectionBorderColor:
          bottomPanelSectionBorderColor ?? t.borderColor,
      bottomPanelDragTargetColor: bottomPanelDragTargetColor,
      bottomPanelDragTargetInactiveColor: bottomPanelDragTargetInactiveColor ??
          t.paginationUnselectedBackground,
      bottomPanelIconColor: bottomPanelIconColor ?? t.mutedIconColor,
      // Menu
      menuBackgroundColor: menuBackgroundColor ?? t.backgroundColor,
      menuSurfaceTintColor: menuSurfaceTintColor ?? t.backgroundColor,
      menuTextColor: menuTextColor ?? t.secondaryTextColor,
      // Dialog
      dialogBackgroundColor: dialogBackgroundColor ?? t.backgroundColor,
      dialogSurfaceTintColor: dialogSurfaceTintColor ?? t.backgroundColor,
      dialogTextColor: dialogTextColor ?? t.secondaryTextColor,
      // Context menu
      contextMenuItems: contextMenuItems,
      useDefaultContextMenuItems: useDefaultContextMenuItems,
      showCopyMenuItem: showCopyMenuItem,
      showCopyHeaderMenuItem: showCopyHeaderMenuItem,
      showEquationMenuItem: showEquationMenuItem,
      showSortMenuItem: showSortMenuItem,
      showFilterBySelectionMenuItem: showFilterBySelectionMenuItem,
      showChartsMenuItem: showChartsMenuItem,
      contextMenuIconColor: contextMenuIconColor ?? t.iconColor,
      contextMenuTextColor: contextMenuTextColor ?? t.foregroundColor,
      contextMenuDestructiveColor: contextMenuDestructiveColor ?? t.errorColor,
      contextMenuSectionHeaderColor:
          contextMenuSectionHeaderColor ?? t.foregroundColor,
      contextMenuItemIconBackgroundColor:
          contextMenuItemIconBackgroundColor ?? Colors.transparent,
      contextMenuSortIconColor: contextMenuSortIconColor ?? t.foregroundColor,
      contextMenuPinIconColor: contextMenuPinIconColor ?? t.foregroundColor,
      contextMenuGroupIconColor: contextMenuGroupIconColor ?? t.foregroundColor,
      contextMenuAggregationIconColor:
          contextMenuAggregationIconColor ?? t.foregroundColor,
      contextMenuLayoutIconColor:
          contextMenuLayoutIconColor ?? t.foregroundColor,
      // Side panel
      sidePanelConfiguration:
          sidePanelConfiguration.backgroundColor == const Color(0xFFF9F9F9)
              ? OmSidePanelConfiguration(
                  backgroundColor: t.surfaceColor,
                  activeTabColor: t.backgroundColor,
                  inactiveTabColor: Colors.transparent,
                  activeIconColor: t.primaryColor,
                  inactiveIconColor: t.mutedIconColor,
                  activeTextStyleColor: t.foregroundColor,
                  inactiveTextStyleColor: t.secondaryTextColor,
                )
              : sidePanelConfiguration,
      showColumnsTab: showColumnsTab,
      showFiltersTab: showFiltersTab,
      showQuickSearch: showQuickSearch,
      showGlobalSearch: showGlobalSearch,
      // Frozen panes
      frozenColumnCount: frozenColumnCount,
      footerFrozenColumnCount: footerFrozenColumnCount,
      frozenRowCount: frozenRowCount,
      footerFrozenRowCount: footerFrozenRowCount,
      showPlaceholderWhileScrolling: showPlaceholderWhileScrolling,
      shrinkWrapRows: shrinkWrapRows,
      shrinkWrapColumns: shrinkWrapColumns,
      frozenPaneElevation: frozenPaneElevation,
      frozenPaneBorderSide: frozenPaneBorderSide ??
          BorderSide(
            color: t.borderColor,
            width: 1,
          ),
      frozenPaneScrollMode: frozenPaneScrollMode,
      // Filter tab
      filterTabItemBackgroundColor:
          filterTabItemBackgroundColor ?? t.backgroundColor,
      filterTabItemBorderColor: filterTabItemBorderColor ?? t.borderColor,
      filterTabItemParamsColor: filterTabItemParamsColor ?? t.foregroundColor,
      filterTabItemIconColor: filterTabItemIconColor ?? t.mutedIconColor,
      // Chart popup
      chartPopupBackgroundColor: chartPopupBackgroundColor ?? t.backgroundColor,
      chartPopupBorderColor: chartPopupBorderColor ?? t.borderColor,
      chartPopupLoadingBackgroundColor:
          chartPopupLoadingBackgroundColor ?? t.backgroundColor,
      chartPopupLoadingTextColor:
          chartPopupLoadingTextColor ?? t.foregroundColor,
      chartPopupResizeHandleColor:
          chartPopupResizeHandleColor ?? t.mutedIconColor,
      // Mobile settings
      mobileSettingsBackgroundColor:
          mobileSettingsBackgroundColor ?? t.backgroundColor,
      mobileSettingsHeaderColor: mobileSettingsHeaderColor ?? t.foregroundColor,
      mobileSettingsIconColor: mobileSettingsIconColor ?? t.foregroundColor,
      // Chart overlay
      chartTitleColor: chartTitleColor ?? t.overlayOnSurfaceColor,
      chartIconColor: chartIconColor ?? t.overlayOnSurfaceColor,
      fullScreenButtonColor: fullScreenButtonColor ?? t.overlayOnSurfaceColor,
      closeButtonColor: closeButtonColor ?? t.overlayOnSurfaceColor,
      chartSettingsSidebarBackgroundColor:
          chartSettingsSidebarBackgroundColor ?? t.backgroundColor,
    );
  }

  OmDataGridConfiguration copyWith({
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
    OmGridBorderVisibility? headerBorderVisibility,
    OmGridBorderVisibility? rowBorderVisibility,
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
    Color? gridForegroundColor,
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
    String? gridFontFamily,
    double? minColumnWidth,
    double? rowHeight,
    double? headerHeight,
    OmColumnWidthMode? columnWidthMode,
    bool? allowPagination,
    int? rowsPerPage,
    OmPaginationMode? paginationMode,
    bool? allowSorting,
    bool? allowColumnReordering,
    bool? resetPageOnDataChange,
    bool? allowRowReordering,
    OmSelectionMode? selectionMode,
    List<int>? rowsPerPageOptions,
    List<OmQuickFilterConfig>? quickFilters,
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
    List<OmDataGridContextMenuItem>? contextMenuItems,
    bool? useDefaultContextMenuItems,
    OmSidePanelConfiguration? sidePanelConfiguration,
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
    OmFrozenPaneScrollMode? frozenPaneScrollMode,
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
    OmDataGridLabels? labels,
  }) {
    return OmDataGridConfiguration(
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
      paginationSelectedBackgroundColor: paginationSelectedBackgroundColor ??
          this.paginationSelectedBackgroundColor,
      paginationSelectedForegroundColor: paginationSelectedForegroundColor ??
          this.paginationSelectedForegroundColor,
      paginationUnselectedBackgroundColor:
          paginationUnselectedBackgroundColor ??
              this.paginationUnselectedBackgroundColor,
      paginationUnselectedForegroundColor:
          paginationUnselectedForegroundColor ??
              this.paginationUnselectedForegroundColor,
      paginationTextColor: paginationTextColor ?? this.paginationTextColor,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      gridForegroundColor: gridForegroundColor ?? this.gridForegroundColor,
      gridBorderColor: gridBorderColor ?? this.gridBorderColor,
      filterIconColor: filterIconColor ?? this.filterIconColor,
      sortIconColor: sortIconColor ?? this.sortIconColor,
      filterPopupBackgroundColor:
          filterPopupBackgroundColor ?? this.filterPopupBackgroundColor,
      keyboardHideButtonBackgroundColor: keyboardHideButtonBackgroundColor ??
          this.keyboardHideButtonBackgroundColor,
      keyboardHideButtonForegroundColor: keyboardHideButtonForegroundColor ??
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
      gridFontFamily: gridFontFamily ?? this.gridFontFamily,
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
      resetPageOnDataChange:
          resetPageOnDataChange ?? this.resetPageOnDataChange,
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
      dragFeedbackOutsideBackgroundColor: dragFeedbackOutsideBackgroundColor ??
          this.dragFeedbackOutsideBackgroundColor,
      dragFeedbackInsideBackgroundColor: dragFeedbackInsideBackgroundColor ??
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
      bottomPanelDragTargetInactiveColor: bottomPanelDragTargetInactiveColor ??
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
      chartPopupLoadingBackgroundColor: chartPopupLoadingBackgroundColor ??
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
      contextMenuItemIconBackgroundColor: contextMenuItemIconBackgroundColor ??
          this.contextMenuItemIconBackgroundColor,
      contextMenuSortIconColor:
          contextMenuSortIconColor ?? this.contextMenuSortIconColor,
      contextMenuPinIconColor:
          contextMenuPinIconColor ?? this.contextMenuPinIconColor,
      contextMenuGroupIconColor:
          contextMenuGroupIconColor ?? this.contextMenuGroupIconColor,
      contextMenuAggregationIconColor: contextMenuAggregationIconColor ??
          this.contextMenuAggregationIconColor,
      contextMenuLayoutIconColor:
          contextMenuLayoutIconColor ?? this.contextMenuLayoutIconColor,
      labels: labels ?? this.labels,
    );
  }
}
