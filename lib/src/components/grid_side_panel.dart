import 'package:om_data_grid/src/components/side_panel/tabs/columns_tab.dart';
import 'package:om_data_grid/src/components/side_panel/tabs/filters_tab.dart';
import 'package:om_data_grid/src/models/side_panel_config.dart';
import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:flutter/material.dart';

class GridSidePanel extends StatefulWidget {
  final DatagridController controller;
  final VoidCallback onClose;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const GridSidePanel({
    super.key,
    required this.controller,
    required this.onClose,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  @override
  State<GridSidePanel> createState() => _GridSidePanelState();
}

class _GridSidePanelState extends State<GridSidePanel> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) {
      widget.onExpansionChanged(!widget.isExpanded);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      widget.onExpansionChanged(true);
    }
  }

  List<GridSidePanelTab> _getVisibleTabs() {
    final config = widget.controller.configuration;
    final List<GridSidePanelTab> tabs = [];

    // Add default tabs if enabled in config
    if (config.showColumnsTab) {
      tabs.add(
        GridSidePanelTab(
          id: 'columns',
          icon: Icons.view_headline,
          label: 'Columns',
          builder: (context, controller) => ColumnsTab(controller: controller),
        ),
      );
    }

    if (config.showFiltersTab) {
      tabs.add(
        GridSidePanelTab(
          id: 'filters',
          icon: Icons.filter_alt,
          label: 'Filters',
          builder: (context, controller) => FiltersTab(controller: controller),
        ),
      );
    }

    // Add additional tabs from controller
    tabs.addAll(
      widget.controller.additionalSidePanelTabs.where((t) => t.visible),
    );

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabs = _getVisibleTabs();

    if (visibleTabs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure _selectedIndex is within bounds if tabs changed
    if (_selectedIndex >= visibleTabs.length) {
      _selectedIndex = 0;
    }

    final config = widget.controller.configuration.sidePanelConfiguration;
    double width = config.collapsedWidth;
    if (widget.isExpanded) {
      width += config.expandedWidth;
    }

    return AnimatedContainer(
      duration: config.animationDuration,
      width: width,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: widget.isExpanded
            ? BorderDirectional(
                end: BorderSide(color: Colors.grey.shade300, width: 1),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVerticalTabs(visibleTabs, config),
          if (widget.isExpanded && visibleTabs.isNotEmpty)
            Expanded(
              child: visibleTabs[_selectedIndex].builder(
                context,
                widget.controller,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalTabs(
    List<GridSidePanelTab> tabs,
    SidePanelConfiguration config,
  ) {
    return Container(
      width: config.collapsedWidth,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: BorderDirectional(
          end: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          return _buildVerticalTab(index, tabs[index], config);
        }),
      ),
    );
  }

  Widget _buildVerticalTab(
    int index,
    GridSidePanelTab tab,
    SidePanelConfiguration config,
  ) {
    final isSelected = _selectedIndex == index && widget.isExpanded;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? config.activeTabColor : config.inactiveTabColor,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
              left: BorderSide(
                color: isSelected
                    ? widget.controller.configuration.primaryColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                tab.icon,
                color: isSelected
                    ? config.activeIconColor
                    : config.inactiveIconColor,
                size: 20,
              ),
              const SizedBox(height: 8),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? config.activeTextStyleColor
                        : config.inactiveTextStyleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
