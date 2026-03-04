import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';

// ---------------------------------------------------------------------------
// OmMobileToolbar – search bar + sort / filter action buttons
// ---------------------------------------------------------------------------

/// Search bar with Sort and Filter action buttons.
///
/// The chips bar is now a separate widget [OmMobileChipsBar] so you can place
/// them independently (e.g. sticky vs. scrollable).
class OmMobileToolbar extends StatefulWidget {
  final OmDataGridConfiguration configuration;
  final List<OmGridColumnModel> columns;
  final bool showSearch;
  final bool showSort;
  final bool showFilter;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSortTap;
  final VoidCallback? onFilterTap;
  final String? initialSearch;
  final String? activeSortKey;

  const OmMobileToolbar({
    super.key,
    required this.configuration,
    required this.columns,
    this.showSearch = true,
    this.showSort = true,
    this.showFilter = true,
    this.onSearchChanged,
    this.onSortTap,
    this.onFilterTap,
    this.initialSearch,
    this.activeSortKey,
  });

  @override
  State<OmMobileToolbar> createState() => _OmMobileToolbarState();
}

class _OmMobileToolbarState extends State<OmMobileToolbar> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialSearch ?? '');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.configuration;
    final bg = config.menuBackgroundColor ?? Colors.white;
    final borderColor = config.gridBorderColor;
    final secondaryText = config.secondaryTextColor;
    final textColor = config.gridForegroundColor;
    final primary = config.primaryColor;
    final labels = config.labels;

    final hasActiveFilter = widget.columns.any((c) => c.isFiltered);
    final hasActiveSort =
        widget.activeSortKey != null && widget.activeSortKey!.isNotEmpty;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          if (widget.showSearch) ...[
            Expanded(
              child: _SearchBar(
                controller: _searchCtrl,
                hintText: labels.search,
                textColor: textColor,
                hintColor: secondaryText,
                borderColor: borderColor,
                bg: bg,
                onChanged: widget.onSearchChanged,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.showSort)
            _ActionButton(
              icon: Icons.sort_rounded,
              badgeActive: hasActiveSort,
              primaryColor: primary,
              borderColor: borderColor,
              bg: bg,
              onTap: widget.onSortTap,
            ),
          if (widget.showSort && widget.showFilter) const SizedBox(width: 8),
          if (widget.showFilter)
            _ActionButton(
              icon: Icons.filter_list_rounded,
              badgeActive: hasActiveFilter,
              primaryColor: primary,
              borderColor: borderColor,
              bg: bg,
              onTap: widget.onFilterTap,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OmMobileChipsBar – active filter / sort chips
// ---------------------------------------------------------------------------

/// Displays chips for active sort and per-column filters.
///
/// Place this separately from [OmMobileToolbar] so you can control its
/// sticky behaviour independently.
class OmMobileChipsBar extends StatelessWidget {
  final OmDataGridConfiguration configuration;
  final List<OmGridColumnModel> columns;
  final String? activeSortKey;
  final bool sortAscending;
  final VoidCallback? onClearSort;
  final void Function(OmGridColumnModel col)? onClearColumnFilter;
  final VoidCallback? onClearAllFilters;

  const OmMobileChipsBar({
    super.key,
    required this.configuration,
    required this.columns,
    this.activeSortKey,
    this.sortAscending = true,
    this.onClearSort,
    this.onClearColumnFilter,
    this.onClearAllFilters,
  });

  @override
  Widget build(BuildContext context) {
    final config = configuration;
    final primary = config.primaryColor;
    final bg = config.rowBackgroundColor;
    final textColor = config.gridForegroundColor;
    final secondaryText = config.secondaryTextColor;
    final labels = config.labels;

    final filteredColumns = columns.where((c) => c.isFiltered).toList();
    final hasSortChip = activeSortKey != null && activeSortKey!.isNotEmpty;
    final hasChips = hasSortChip || filteredColumns.isNotEmpty;

    if (!hasChips) return const SizedBox.shrink();

    return Container(
      color: bg,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort chip
              if (hasSortChip) ...[
                _ActiveChip(
                  icon: sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  label: _sortLabel(columns, activeSortKey!, labels),
                  primary: primary,
                  bg: bg,
                  textColor: textColor,
                  secondaryText: secondaryText,
                  onDelete: onClearSort,
                ),
                if (filteredColumns.isNotEmpty) const SizedBox(width: 8),
              ],
              // Per-column filter chips
              ...filteredColumns.asMap().entries.map((entry) {
                final i = entry.key;
                final col = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                      right: i < filteredColumns.length - 1 ? 8 : 0),
                  child: _ActiveChip(
                    icon: Icons.filter_alt_rounded,
                    label: _filterLabel(col, config),
                    primary: primary,
                    bg: bg,
                    textColor: textColor,
                    secondaryText: secondaryText,
                    onDelete: onClearColumnFilter != null
                        ? () => onClearColumnFilter!(col)
                        : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(List<OmGridColumnModel> cols, String key, dynamic labels) {
    final matches = cols.where((c) => c.key == key).toList();
    final title = matches.isNotEmpty ? matches.first.column.title : key;
    return '${labels.sorting}: $title';
  }

  String _filterLabel(OmGridColumnModel col, OmDataGridConfiguration config) {
    if (col.quickFilterText != null && col.quickFilterText!.isNotEmpty) {
      return '${col.column.title}: ${col.quickFilterText}';
    }
    final notSelected = col.notSelectedFilterData;
    if (notSelected != null && notSelected.isNotEmpty) {
      return col.column.title;
    }
    return col.column.title;
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;
  final Color bg;
  final ValueChanged<String>? onChanged;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.hintColor,
    required this.borderColor,
    required this.bg,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.25)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: hintColor),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  child: Icon(Icons.close, size: 18, color: hintColor),
                )
              : null,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool badgeActive;
  final Color primaryColor;
  final Color borderColor;
  final Color bg;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.badgeActive,
    required this.primaryColor,
    required this.borderColor,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeActive
                  ? primaryColor.withOpacity(0.1)
                  : borderColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badgeActive
                    ? primaryColor.withOpacity(0.4)
                    : borderColor.withOpacity(0.25),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: badgeActive ? primaryColor : borderColor,
            ),
          ),
          if (badgeActive)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: bg, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final Color bg;
  final Color textColor;
  final Color secondaryText;
  final VoidCallback? onDelete;

  const _ActiveChip({
    required this.icon,
    required this.label,
    required this.primary,
    required this.bg,
    required this.textColor,
    required this.secondaryText,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: primary,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: primary),
            ),
          ],
        ],
      ),
    );
  }
}
