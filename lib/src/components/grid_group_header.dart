import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import '../models/datagrid_configuration.dart';

class GridGroupHeader extends StatelessWidget {
  final Map<String, dynamic> group;
  final OmDataGridConfiguration config;
  final bool isExpanded;
  final bool isHovered;
  final VoidCallback onTap;

  const GridGroupHeader({
    super.key,
    required this.group,
    required this.config,
    required this.isExpanded,
    this.isHovered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final level = group['level'] as int? ?? 0;
    return RepaintBoundary(
      child: Material(
        color: isHovered
            ? config.rowHoverColor
            : (isExpanded
                  ? config.headerBackgroundColor.withOpacityNew(0.08)
                  : config.headerBackgroundColor.withOpacityNew(0.03)),
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: config.rowHeight,
            padding: EdgeInsets.only(left: 16.0 * level + 12.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: config.gridBorderColor, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: config.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${group['groupKey']}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("${group['value']} (${group['count']})"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
