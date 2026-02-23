import 'package:om_data_grid/src/utils/general_helpers.dart';
import 'package:flutter/material.dart';
import '../models/datagrid_configuration.dart';
import 'grid_combo_box/grid_combo_box.dart';
import '../models/grid_combo_box_item.dart';

class GridFooter extends StatelessWidget {
  const GridFooter({
    super.key,
    required this.totalRows,
    required this.configuration,
    required this.currentPage,
    required this.onPageChanged,
    this.rowsPerPage,
    this.onRowsPerPageChanged,
  });

  final int totalRows;
  final DatagridConfiguration configuration;
  final int currentPage;
  final Function(int) onPageChanged;
  final int? rowsPerPage;
  final ValueChanged<int>? onRowsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final int actualRowsPerPage = rowsPerPage ?? configuration.rowsPerPage;
    final mode = configuration.paginationMode;
    final int totalPages = totalRows == 0
        ? 1
        : (totalRows / actualRowsPerPage).ceil();
    final int startRow = totalRows == 0
        ? 0
        : currentPage * actualRowsPerPage + 1;
    final int endRow = (currentPage + 1) * actualRowsPerPage > totalRows
        ? totalRows
        : (currentPage + 1) * actualRowsPerPage;

    final int baseRowsPerPage = configuration.rowsPerPage;
    final List<GridComboBoxItem> rowsPerPageOptions = [
      GridComboBoxItem(
        value: baseRowsPerPage.toString(),
        text: '$baseRowsPerPage',
      ),
      GridComboBoxItem(
        value: (baseRowsPerPage * 2).toString(),
        text: '${baseRowsPerPage * 2}',
      ),
      GridComboBoxItem(
        value: (baseRowsPerPage * 3).toString(),
        text: '${baseRowsPerPage * 3}',
      ),
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: configuration.paginationBackgroundColor,
        border: Border(
          top: BorderSide(color: configuration.gridBorderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: configuration.paginationTextColor,
              ),
              children: [
                const TextSpan(text: "Showing "),
                TextSpan(
                  text: "$startRow",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " to "),
                TextSpan(
                  text: "$endRow",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " of "),
                TextSpan(
                  text: "$totalRows",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " entries"),
              ],
            ),
          ),
          Row(
            children: [
              if (onRowsPerPageChanged != null) ...[
                Text(
                  "Rows per page:",
                  style: TextStyle(
                    fontSize: 13,
                    color: configuration.paginationTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  height: 32,
                  child: GridComboBox(
                    items:
                        configuration.rowsPerPageOptions
                            ?.map(
                              (option) => GridComboBoxItem(
                                value: option.toString(),
                                text: option.toString(),
                              ),
                            )
                            .toList() ??
                        rowsPerPageOptions,
                    initialText: actualRowsPerPage.toString(),
                    initialValue: actualRowsPerPage.toString(),
                    enableSearch: false,
                    onChange: (value) {
                      if (value != null) {
                        onRowsPerPageChanged?.call(int.parse(value));
                      }
                    },
                    configuration: configuration,
                    height: 32,
                    fontSize: 13,
                    itemFontSize: 13,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    showClearButton: false,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              _PageNavButton(
                icon: Icons.first_page,
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                tooltip: "First Page",
                configuration: configuration,
              ),
              const SizedBox(width: 4),
              _PageNavButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                tooltip: "Previous Page",
                configuration: configuration,
              ),
              const SizedBox(width: 8),
              if (mode == PaginationMode.simple)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: configuration.paginationUnselectedBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Page ${currentPage + 1} / $totalPages",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: configuration.paginationTextColor,
                    ),
                  ),
                )
              else
                ..._buildPageNumbers(totalPages, context),
              const SizedBox(width: 8),
              _PageNavButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                tooltip: "Next Page",
                configuration: configuration,
              ),
              const SizedBox(width: 4),
              _PageNavButton(
                icon: Icons.last_page,
                onPressed: currentPage < totalPages - 1
                    ? () => onPageChanged(totalPages - 1)
                    : null,
                tooltip: "Last Page",
                configuration: configuration,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages, BuildContext context) {
    List<Widget> widgets = [];
    const int maxVisiblePages = 5;

    int start = currentPage - 1;
    int end = currentPage + 1;

    if (start <= 1) {
      start = 0;
      end = (maxVisiblePages - 1).clamp(0, totalPages - 1);
    } else if (end >= totalPages - 2) {
      end = totalPages - 1;
      start = (totalPages - maxVisiblePages).clamp(0, totalPages - 1);
    }

    if (start > 0) {
      widgets.add(
        _PageNumberButton(
          page: 0,
          isCurrent: currentPage == 0,
          onTap: () => onPageChanged(0),
          configuration: configuration,
        ),
      );
      if (start > 1) {
        widgets.add(_Ellipsis(color: configuration.paginationTextColor));
      }
    }

    for (int i = start; i <= end; i++) {
      widgets.add(
        _PageNumberButton(
          page: i,
          isCurrent: i == currentPage,
          onTap: () => onPageChanged(i),
          configuration: configuration,
        ),
      );
    }

    if (end < totalPages - 1) {
      if (end < totalPages - 2) {
        widgets.add(_Ellipsis(color: configuration.paginationTextColor));
      }
      widgets.add(
        _PageNumberButton(
          page: totalPages - 1,
          isCurrent: currentPage == totalPages - 1,
          onTap: () => onPageChanged(totalPages - 1),
          configuration: configuration,
        ),
      );
    }

    return widgets;
  }
}

class _PageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final DatagridConfiguration configuration;

  const _PageNavButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: configuration.gridBorderColor),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled
                ? configuration.paginationUnselectedBackgroundColor
                : configuration.paginationUnselectedBackgroundColor
                      .withOpacityNew(0.5),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? configuration.paginationUnselectedForegroundColor
                : configuration.paginationUnselectedForegroundColor
                      .withOpacityNew(0.5),
          ),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final int page;
  final bool isCurrent;
  final VoidCallback onTap;
  final DatagridConfiguration configuration;

  const _PageNumberButton({
    required this.page,
    required this.isCurrent,
    required this.onTap,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrent
                ? configuration.paginationSelectedBackgroundColor
                : configuration.paginationUnselectedBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent
                  ? configuration.paginationSelectedBackgroundColor
                  : configuration.gridBorderColor,
            ),
          ),
          child: Text(
            "${page + 1}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent
                  ? configuration.paginationSelectedForegroundColor
                  : configuration.paginationUnselectedForegroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  final Color color;
  const _Ellipsis({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        "...",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
