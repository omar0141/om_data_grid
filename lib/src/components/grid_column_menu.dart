import 'package:flutter/material.dart';
import '../enums/aggregation_type_enum.dart';
import '../enums/column_pinning_enum.dart';
import '../models/grid_column_model.dart';
import '../utils/datagrid_controller.dart';

class OmGridColumnMenu extends StatelessWidget {
  final OmDataGridController controller;
  final OmGridColumnModel column;
  final String? sortColumnKey;
  final bool? sortAscending;
  final Function(String, {bool? ascending})? onSort;

  const OmGridColumnMenu({
    super.key,
    required this.controller,
    required this.column,
    this.sortColumnKey,
    this.sortAscending,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final configuration = controller.configuration;
    final isSortedAsc = sortColumnKey == column.key && sortAscending == true;
    final isSortedDesc = sortColumnKey == column.key && sortAscending == false;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.15),
          thickness: 1,
          space: 1,
          indent: 0,
          endIndent: 0,
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(
              configuration.menuBackgroundColor ?? Colors.white,
            ),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(12),
            shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.15)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 8),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        menuButtonTheme: MenuButtonThemeData(
          style: MenuItemButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(240, 48),
            shape: const RoundedRectangleBorder(),
            foregroundColor:
                configuration.contextMenuTextColor ?? Colors.grey[800],
            iconColor: configuration.contextMenuIconColor ?? Colors.grey[600],
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: configuration.menuBackgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * value),
              alignment: Alignment.topCenter,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(
                  configuration.labels.sorting,
                  Icons.sort_rounded,
                ),
                _buildMenuItem(
                  label: configuration.labels.sortAscending,
                  icon: Icons.arrow_upward_rounded,
                  isSelected: isSortedAsc,
                  onPressed: () => onSort?.call(column.key, ascending: true),
                ),
                _buildMenuItem(
                  label: configuration.labels.sortDescending,
                  icon: Icons.arrow_downward_rounded,
                  isSelected: isSortedDesc,
                  onPressed: () => onSort?.call(column.key, ascending: false),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1),
                ),
                _buildSectionHeader(
                  configuration.labels.organization,
                  Icons.dashboard_customize_rounded,
                ),
                SubmenuButton(
                  leadingIcon: _buildMenuIcon(Icons.push_pin_outlined),
                  style: MenuItemButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  submenuIcon:
                      WidgetStatePropertyAll(_buildSubmenuIcon(context)),
                  menuStyle: MenuStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  menuChildren: [
                    _buildPinningItem(
                      OmColumnPinning.none,
                      configuration.labels.unpin,
                      Icons.block,
                    ),
                    _buildPinningItem(
                      OmColumnPinning.start,
                      configuration.labels.pinToStart,
                      Directionality.of(context) == TextDirection.ltr
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded,
                    ),
                    _buildPinningItem(
                      OmColumnPinning.end,
                      configuration.labels.pinToEnd,
                      Directionality.of(context) == TextDirection.ltr
                          ? Icons.keyboard_double_arrow_right_rounded
                          : Icons.keyboard_double_arrow_left_rounded,
                    ),
                  ],
                  child: Text(
                    configuration.labels.pinColumn,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: configuration.contextMenuTextColor ??
                          Colors.grey[400],
                    ),
                  ),
                ),
                _buildMenuItem(
                  label: '${configuration.labels.groupBy} ${column.title}',
                  icon: Icons.layers_outlined,
                  onPressed: () => controller.addGroupedColumn(column.key),
                ),
                _buildMenuItem(
                  label: configuration.labels.hideColumn,
                  icon: Icons.visibility_off_outlined,
                  onPressed: () =>
                      controller.toggleColumnVisibility(column.key, false),
                ),
                SubmenuButton(
                  leadingIcon: _buildMenuIcon(Icons.functions_rounded),
                  style: MenuItemButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  submenuIcon:
                      WidgetStatePropertyAll(_buildSubmenuIcon(context)),
                  menuStyle: MenuStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  menuChildren: [
                    _buildAggregationItem(
                      OmAggregationType.none,
                      configuration.labels.noAggregation,
                      Icons.block_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.sum,
                      configuration.labels.sum,
                      Icons.add_circle_outline_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.avg,
                      configuration.labels.average,
                      Icons.show_chart_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.min,
                      configuration.labels.minimum,
                      Icons.vertical_align_bottom_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.max,
                      configuration.labels.maximum,
                      Icons.vertical_align_top_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.count,
                      configuration.labels.count,
                      Icons.numbers_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.first,
                      configuration.labels.first,
                      Icons.skip_previous_rounded,
                    ),
                    _buildAggregationItem(
                      OmAggregationType.last,
                      configuration.labels.last,
                      Icons.skip_next_rounded,
                    ),
                  ],
                  child: Text(
                    configuration.labels.aggregations,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: configuration.contextMenuTextColor ??
                          Colors.grey[400],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1),
                ),
                _buildSectionHeader(
                  configuration.labels.gridLayout,
                  Icons.grid_view_rounded,
                ),
                _buildMenuItem(
                  label: controller.configuration.showQuickSearch
                      ? configuration.labels.hideQuickSearch
                      : configuration.labels.showQuickSearch,
                  icon: controller.configuration.showQuickSearch
                      ? Icons.search_off_rounded
                      : Icons.search_rounded,
                  onPressed: () => controller.toggleQuickSearch(),
                ),
                _buildMenuItem(
                  label: configuration.labels.columnManagement,
                  icon: Icons.view_column_outlined,
                  onPressed: () => controller.onShowColumnChooser?.call(),
                ),
                _buildMenuItem(
                  label: configuration.labels.resetDefaultLayout,
                  icon: Icons.restore_rounded,
                  onPressed: () => controller.resetColumns(),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 12),
      child: Row(
        children: [
          // Icon(icon, size: 14, color: Colors.grey[500]),
          // const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: controller.configuration.contextMenuSectionHeaderColor ??
                  Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, {Color? color}) {
    return Icon(
      icon,
      size: 18,
      color: color ?? controller.configuration.secondaryTextColor,
    );
  }

  Widget _buildSubmenuIcon(BuildContext context) {
    return Icon(
      Directionality.of(context) == TextDirection.ltr
          ? Icons.chevron_right_rounded
          : Icons.chevron_left_rounded,
      size: 15,
      color: Colors.grey[400],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    VoidCallback? onPressed,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    final config = controller.configuration;
    final primaryColor = config.primaryColor;

    final textColor = isDestructive
        ? (config.contextMenuDestructiveColor ?? Colors.red)
        : (isSelected
            ? primaryColor
            : (config.contextMenuTextColor ?? Colors.grey[400]));

    return MenuItemButton(
      leadingIcon: _buildMenuIcon(
        icon,
        color: isDestructive ? textColor : null,
      ),
      trailingIcon: isSelected
          ? Icon(Icons.check_rounded, size: 15, color: primaryColor)
          : null,
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor:
            isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPinningItem(OmColumnPinning value, String text, IconData icon) {
    final isSelected = column.pinning == value;

    return _buildMenuItem(
      label: text,
      icon: icon,
      isSelected: isSelected,
      onPressed: () => controller.updateColumnPinning(column.key, value),
    );
  }

  Widget _buildAggregationItem(
    OmAggregationType value,
    String text,
    IconData icon,
  ) {
    final isSelected = column.aggregation == value;

    return _buildMenuItem(
      label: text,
      icon: icon,
      isSelected: isSelected,
      onPressed: () => controller.updateColumnAggregation(column.key, value),
    );
  }
}
