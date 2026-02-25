import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';
import 'package:om_data_grid/src/utils/filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../utils/export_utils.dart';
import '../utils/datagrid_controller.dart';
import 'chart_popup.dart';
import 'default_button.dart';

class OmQuickFilterBar extends StatefulWidget {
  final List<OmGridColumnModel>? columns;
  final List<OmQuickFilterConfig>? configs;
  final List<Map<String, dynamic>>? data;
  final OmDataGridConfiguration? configuration;
  final void Function(List<dynamic>)? onSearch;
  final void Function(List<Map<String, dynamic>>, List<OmGridColumnModel>)?
      onVisualize;
  final void Function()? onAddPressed;
  final OmDataGridController? controller;
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final Widget? leading;

  const OmQuickFilterBar({
    super.key,
    this.columns,
    this.configs,
    this.data,
    this.configuration,
    this.onSearch,
    this.onVisualize,
    this.onAddPressed,
    this.controller,
    this.title,
    this.showBackButton = false,
    this.onBackPress,
    this.leading,
  });

  @override
  State<OmQuickFilterBar> createState() => _QuickFilterBarState();
}

class _QuickFilterBarState extends State<OmQuickFilterBar> {
  late List<OmGridColumnModel> _internalColumns;
  late OmDataGridConfiguration _effectiveConfig;
  late List<OmQuickFilterConfig> _configs;
  bool _isSettingsHovered = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.addListener(_handleControllerChange);
    }
    _initInternalState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    if (widget.controller != null) {
      widget.controller!.removeListener(_handleControllerChange);
    }
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      if (widget.controller != null &&
          _searchController.text != widget.controller!.globalSearchText) {
        _searchController.text = widget.controller!.globalSearchText;
      }
      setState(() {
        _initInternalState();
      });
    }
  }

  @override
  void didUpdateWidget(OmQuickFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.columns != oldWidget.columns ||
        widget.configs != oldWidget.configs ||
        widget.configuration != oldWidget.configuration ||
        widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.removeListener(_handleControllerChange);
      }
      if (widget.controller != null) {
        widget.controller!.addListener(_handleControllerChange);
      }
      _initInternalState();
    }
  }

  void _initInternalState() {
    if (widget.controller != null) {
      _effectiveConfig = widget.controller!.configuration;
      _internalColumns = widget.controller!.columnModels;
      _configs = widget.controller!.configuration.quickFilters ?? [];
    } else {
      _effectiveConfig = widget.configuration ?? OmDataGridConfiguration();
      if (widget.columns != null) {
        _internalColumns = widget.columns!;
      } else if (widget.configs != null) {
        _internalColumns = widget.configs!.map((config) {
          return OmGridColumnModel(
            column:
                OmGridColumn(key: config.columnKey, title: config.columnKey),
          );
        }).toList();
      } else {
        _internalColumns = [];
      }
      _configs = widget.configs ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _internalColumns.any(
          (c) =>
              c.filter ||
              (c.advancedFilter != null &&
                  c.advancedFilter!.conditions.isNotEmpty) ||
              (c.quickFilterText != null && c.quickFilterText!.isNotEmpty),
        ) ||
        _searchController.text.isNotEmpty;

    Widget? leadingWidget;
    if (widget.leading != null) {
      leadingWidget = widget.leading;
    } else if (widget.showBackButton || widget.title != null) {
      leadingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showBackButton)
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 22,
                color: _effectiveConfig.rowForegroundColor,
              ),
              onPressed:
                  widget.onBackPress ?? () => Navigator.of(context).maybePop(),
              splashRadius: 20,
            ),
          if (widget.title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Text(
                widget.title!,
                style: TextStyle(
                  color: _effectiveConfig.rowForegroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(color: _effectiveConfig.gridBackgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingWidget != null && _configs.isNotEmpty) ...[
            const SizedBox(width: 8),
            leadingWidget,
            const SizedBox(width: 8),
          ],
          Row(
            children: [
              if (leadingWidget != null && _configs.isEmpty) ...[
                const SizedBox(width: 8),
                leadingWidget,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _configs.map((config) {
                        final column = _internalColumns.firstWhere(
                          (c) => c.key == config.columnKey,
                          orElse: () => OmGridColumnModel(
                            column: OmGridColumn(
                              key: config.columnKey,
                              title: config.columnKey,
                            ),
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 12),
                          child: _buildFilterRow(column, config),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_effectiveConfig.showClearFiltersButton &&
                        hasActiveFilters) ...[
                      _buildClearFiltersButton(),
                      const SizedBox(width: 8),
                    ],
                    if (_effectiveConfig.showGlobalSearch) ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: _buildGlobalSearchField(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_effectiveConfig.showAddButton) ...[
                      SizedBox(
                        height: 38,
                        child: IntrinsicWidth(
                          child: OmDefaultButton(
                            text: _effectiveConfig.addButtonText,
                            leadingIcon: _effectiveConfig.addButtonIcon ??
                                Icon(
                                  Icons.add,
                                  size: 18,
                                  color:
                                      _effectiveConfig.addButtonForegroundColor,
                                ),
                            backcolor:
                                _effectiveConfig.addButtonBackgroundColor,
                            forecolor:
                                _effectiveConfig.addButtonForegroundColor,
                            borderColor: _effectiveConfig.addButtonBorderColor,
                            fontsize: _effectiveConfig.addButtonFontSize,
                            fontWeight: _effectiveConfig.addButtonFontWeight,
                            padding: _effectiveConfig.addButtonPadding,
                            borderRadius:
                                _effectiveConfig.addButtonBorderRadius,
                            height: 38,
                            width: null,
                            press: widget.onAddPressed ??
                                widget.controller?.onAddPressed,
                            configuration: _effectiveConfig,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_effectiveConfig.showSettingsButton)
                      _buildSettingsButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _effectiveConfig.inputBorderColor, width: 0.5),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
      color: _effectiveConfig.gridBackgroundColor,
      tooltip: 'Options',
      onSelected: (value) async {
        final List<Map<String, dynamic>> sourceData =
            widget.controller?.data ?? widget.data ?? [];
        final filteredData = OmFilterUtils.performFiltering(
          data: sourceData
              .map((item) => Map<String, dynamic>.from(item))
              .toList(),
          allColumns: _internalColumns,
          globalSearch: widget.controller?.globalSearchText,
        ).cast<Map<String, dynamic>>();

        if (value == 'excel') {
          await OmGridExportHandler.exportToExcel(
            data: filteredData,
            columns: _internalColumns,
            configuration: _effectiveConfig,
          );
        } else if (value == 'pdf') {
          await OmGridExportHandler.exportToPDF(
            data: filteredData,
            columns: _internalColumns,
            configuration: _effectiveConfig,
          );
        } else if (value == 'visualize') {
          if (widget.controller != null) {
            widget.controller!.visualize(filteredData, _internalColumns);
          } else if (widget.onVisualize != null) {
            widget.onVisualize!(filteredData, _internalColumns);
          } else if (mounted) {
            final size = MediaQuery.of(context).size;
            showDialog(
              context: context,
              builder: (context) => Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(color: Colors.black26),
                    ),
                  ),
                  OmChartPopup(
                    data: filteredData,
                    columns: _internalColumns,
                    onClose: () => Navigator.of(context).pop(),
                    configuration: _effectiveConfig,
                    initialPosition: Offset(
                      size.width * 0.1,
                      size.height * 0.1,
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          'excel',
          Icon(Icons.table_chart, size: 20, color: Colors.green.shade700),
          'Export to Excel',
        ),
        _buildPopupMenuItem(
          'pdf',
          Icon(Icons.picture_as_pdf, size: 22, color: Colors.red.shade700),
          'Export to PDF',
        ),
        _buildPopupMenuItem(
          'visualize',
          Icon(Icons.bar_chart, size: 22, color: _effectiveConfig.primaryColor),
          'Visualize all data',
        ),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isSettingsHovered = true),
        onExit: (_) => setState(() => _isSettingsHovered = false),
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isSettingsHovered
                  ? _effectiveConfig.primaryColor
                  : _effectiveConfig.secondaryTextColor,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Iconsax.setting_2,
            size: 20,
            color: _isSettingsHovered
                ? _effectiveConfig.primaryColor
                : _effectiveConfig.rowForegroundColor.withAlpha(150),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    Widget leading,
    String text,
  ) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, height: 24, child: Center(child: leading)),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: _effectiveConfig.rowForegroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSearchField() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: _effectiveConfig.inputFillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _effectiveConfig.inputBorderColor.withOpacity(0.4),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 2),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
          _performFiltering();
        },
        decoration: InputDecoration(
          hintText: 'Search in all columns...',
          hintStyle: TextStyle(
            color: _effectiveConfig.secondaryTextColor.withOpacity(0.6),
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Iconsax.search_normal_copy,
              size: 18,
              color: _effectiveConfig.secondaryTextColor.withOpacity(0.8),
            ),
          ),
          isDense: true,
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: _effectiveConfig.secondaryTextColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    _performFiltering();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        style: TextStyle(
          color: _effectiveConfig.rowForegroundColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return TextButton.icon(
      onPressed: _clearAllFilters,
      style: TextButton.styleFrom(
        foregroundColor: _effectiveConfig.errorColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return _effectiveConfig.errorColor.withAlpha(25);
          }
          return Colors.transparent;
        }),
      ),
      icon: const Icon(Iconsax.filter_remove, size: 18),
      label: const Text(
        "Clear Filters",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      for (var col in _internalColumns) {
        col.filter = false;
        col.searchText = '';
        col.quickFilterText = null;
        col.notSelectedFilterData = [];
        col.advancedFilter = null;
      }
      _performFiltering();
    });
  }

  Widget _buildFilterRow(OmGridColumnModel column, OmQuickFilterConfig config) {
    // Get unique values from the original (unfiltered) data
    final sourceData = widget.controller?.data ?? widget.data ?? [];
    final List<String> uniqueValues = sourceData
        .map((e) => e[column.key]?.toString() ?? "None")
        .toSet()
        .toList();
    uniqueValues.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.showTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              column.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _effectiveConfig.secondaryTextColor,
              ),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: uniqueValues.map((value) {
              final bool isSelected = !(column.notSelectedFilterData?.any(
                    (e) => e["value"] == value,
                  ) ??
                  false);
              final bool hasQuickFilter =
                  column.notSelectedFilterData != null &&
                      column.notSelectedFilterData!.isNotEmpty;
              final bool activeSelected =
                  (column.filter && hasQuickFilter) ? isSelected : false;

              return GestureDetector(
                onTap: () => _handleTap(column, value, config.isMultiSelect),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: activeSelected
                        ? _effectiveConfig.primaryColor
                        : _effectiveConfig.inputFillColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: activeSelected
                          ? _effectiveConfig.primaryColor
                          : _effectiveConfig.inputBorderColor,
                    ),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: activeSelected
                          ? _effectiveConfig.primaryForegroundColor
                          : _effectiveConfig.rowForegroundColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _handleTap(OmGridColumnModel column, String value, bool isMultiSelect) {
    setState(() {
      final sourceData = widget.controller?.data ?? widget.data ?? [];
      final Set<String> allValues =
          sourceData.map((e) => e[column.key]?.toString() ?? "None").toSet();

      // Start filtering (if not active, or only advanced filter was active)
      if (!column.filter || (column.notSelectedFilterData?.isEmpty ?? true)) {
        // Start filtering: select ONLY this value
        column.filter = true;
        column.notSelectedFilterData = allValues
            .where((v) => v != value)
            .map((v) => {"value": v})
            .toList();
      } else {
        List<dynamic> notSelected = List.from(
          column.notSelectedFilterData ?? [],
        );
        bool isCurrentlySelected = !notSelected.any((e) => e["value"] == value);

        if (isMultiSelect) {
          if (isCurrentlySelected) {
            // Unselect it (add to notSelected)
            notSelected.add({"value": value});
          } else {
            // Select it (remove from notSelected)
            notSelected.removeWhere((e) => e["value"] == value);
          }

          // If everything is now unselected OR everything is now selected, stop filtering
          if (notSelected.length >= allValues.length || notSelected.isEmpty) {
            column.notSelectedFilterData = [];
            // Only set filter to false if no other filter is active
            if (column.advancedFilter == null ||
                column.advancedFilter!.conditions.isEmpty) {
              column.filter = false;
            }
          } else {
            column.notSelectedFilterData = notSelected;
          }
        } else {
          // Single select logic
          if (isCurrentlySelected) {
            // It was the only one selected, now unselect it
            column.notSelectedFilterData = [];
            // Only set filter to false if no other filter is active
            if (column.advancedFilter == null ||
                column.advancedFilter!.conditions.isEmpty) {
              column.filter = false;
            }
          } else {
            // Select this one, unselect everything else
            column.filter = true;
            column.notSelectedFilterData = allValues
                .where((v) => v != value)
                .map((v) => {"value": v})
                .toList();
          }
        }
      }
      _performFiltering();
    });
  }

  void _performFiltering() {
    if (widget.controller != null) {
      widget.controller!.updateGlobalSearchText(_searchController.text);
    }

    final List<Map<String, dynamic>> sourceData =
        widget.controller?.data ?? widget.data ?? [];
    final filteredData = OmFilterUtils.performFiltering(
      data: sourceData,
      allColumns: _internalColumns,
      globalSearch: _searchController.text,
    );

    if (widget.controller != null) {
      widget.controller!.updateFilteredData(
        List<Map<String, dynamic>>.from(filteredData),
      );
    } else if (widget.onSearch != null) {
      widget.onSearch!(filteredData);
    }
  }
}
