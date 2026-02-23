import 'package:om_data_grid/src/utils/datagrid_controller.dart';
import 'package:flutter/material.dart';

class GridSidePanelTab {
  final String id;
  final IconData icon;
  final String label;
  final Widget Function(BuildContext context, DatagridController controller)
  builder;
  final bool visible;

  const GridSidePanelTab({
    required this.id,
    required this.icon,
    required this.label,
    required this.builder,
    this.visible = true,
  });

  GridSidePanelTab copyWith({
    String? id,
    IconData? icon,
    String? label,
    Widget Function(BuildContext context, DatagridController controller)?
    builder,
    bool? visible,
  }) {
    return GridSidePanelTab(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      builder: builder ?? this.builder,
      visible: visible ?? this.visible,
    );
  }
}

class SidePanelConfiguration {
  final Color? backgroundColor;
  final Color? activeTabColor;
  final Color? inactiveTabColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? activeTextStyleColor;
  final Color? inactiveTextStyleColor;
  final double collapsedWidth;
  final double expandedWidth;
  final Duration animationDuration;

  const SidePanelConfiguration({
    this.backgroundColor = const Color(0xFFF9F9F9),
    this.activeTabColor = Colors.white,
    this.inactiveTabColor = Colors.transparent,
    this.activeIconColor = Colors.black,
    this.inactiveIconColor = Colors.grey,
    this.activeTextStyleColor = Colors.black,
    this.inactiveTextStyleColor = Colors.black,
    this.collapsedWidth = 45.0,
    this.expandedWidth = 250.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  SidePanelConfiguration copyWith({
    Color? backgroundColor,
    Color? activeTabColor,
    Color? inactiveTabColor,
    Color? activeIconColor,
    Color? inactiveIconColor,
    Color? activeTextStyleColor,
    Color? inactiveTextStyleColor,
    double? collapsedWidth,
    double? expandedWidth,
    Duration? animationDuration,
  }) {
    return SidePanelConfiguration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeTabColor: activeTabColor ?? this.activeTabColor,
      inactiveTabColor: inactiveTabColor ?? this.inactiveTabColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      activeTextStyleColor: activeTextStyleColor ?? this.activeTextStyleColor,
      inactiveTextStyleColor:
          inactiveTextStyleColor ?? this.inactiveTextStyleColor,
      collapsedWidth: collapsedWidth ?? this.collapsedWidth,
      expandedWidth: expandedWidth ?? this.expandedWidth,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
