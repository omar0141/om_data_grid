import 'package:flutter/material.dart';
import 'package:om_data_grid/src/models/datagrid_configuration.dart';
import 'package:om_data_grid/src/models/grid_column_model.dart';

/// The result returned by [OmMobileSortSheet.show].
///
/// If [columnKey] is empty the caller should treat this as "clear sort".
class OmMobileSortResult {
  final String columnKey;
  final bool ascending;

  const OmMobileSortResult({
    required this.columnKey,
    required this.ascending,
  });

  /// Sentinel value returned when the user explicitly clears the sort.
  bool get isClear => columnKey.isEmpty;
}

/// Full-screen sort-column chooser page.
///
/// Use the static [OmMobileSortSheet.show] helper to open it from any widget:
///
/// ```dart
/// final result = await OmMobileSortSheet.show(
///   context: context,
///   columns: columns,
///   configuration: config,
///   currentSortKey: currentKey,
///   currentAscending: true,
/// );
/// if (result == null) return;           // user cancelled
/// if (result.isClear)  clearSort();     // user cleared sort
/// else                 applySort(result.columnKey, result.ascending);
/// ```
class OmMobileSortSheet extends StatefulWidget {
  final List<OmGridColumnModel> columns;
  final OmDataGridConfiguration configuration;
  final String? currentSortKey;
  final bool currentAscending;

  const OmMobileSortSheet({
    super.key,
    required this.columns,
    required this.configuration,
    this.currentSortKey,
    this.currentAscending = true,
  });

  /// Opens as a full-screen [MaterialPageRoute].
  static Future<OmMobileSortResult?> show({
    required BuildContext context,
    required List<OmGridColumnModel> columns,
    required OmDataGridConfiguration configuration,
    String? currentSortKey,
    bool currentAscending = true,
  }) {
    return Navigator.of(context).push<OmMobileSortResult>(
      MaterialPageRoute<OmMobileSortResult>(
        fullscreenDialog: true,
        builder: (_) => OmMobileSortSheet(
          columns: columns,
          configuration: configuration,
          currentSortKey: currentSortKey,
          currentAscending: currentAscending,
        ),
      ),
    );
  }

  @override
  State<OmMobileSortSheet> createState() => _OmMobileSortSheetState();
}

class _OmMobileSortSheetState extends State<OmMobileSortSheet> {
  late String? _selectedKey;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.currentSortKey;
    _ascending = widget.currentAscending;
  }

  List<OmGridColumnModel> get _sortableColumns => widget.columns
      .where((c) =>
          c.isVisible && c.column.allowSorting && c.key != '__reorder_column__')
      .toList();

  void _clearSort() {
    Navigator.of(context)
        .pop(const OmMobileSortResult(columnKey: '', ascending: true));
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.configuration;
    final bg = config.menuBackgroundColor ?? Colors.white;
    final primary = config.primaryColor;
    final textColor = config.gridForegroundColor;
    final secondaryText = config.secondaryTextColor;
    final labels = config.labels;

    final hasActiveSort =
        widget.currentSortKey != null && widget.currentSortKey!.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          labels.sorting,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: const SizedBox.shrink(),
        actions: [
          if (hasActiveSort)
            TextButton(
              onPressed: _clearSort,
              child: Text(
                labels.clearAll,
                style: TextStyle(
                  color: config.errorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.close, size: 22, color: secondaryText),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: config.gridBorderColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Direction toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Direction',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryText,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: config.gridBorderColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _DirectionButton(
                    label: labels.sortAscending,
                    icon: Icons.arrow_upward_rounded,
                    selected: _ascending,
                    primary: primary,
                    bg: bg,
                    secondaryText: secondaryText,
                    onTap: () => setState(() => _ascending = true),
                  ),
                  _DirectionButton(
                    label: labels.sortDescending,
                    icon: Icons.arrow_downward_rounded,
                    selected: !_ascending,
                    primary: primary,
                    bg: bg,
                    secondaryText: secondaryText,
                    onTap: () => setState(() => _ascending = false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              labels.sorting,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: secondaryText,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 110),
              itemCount: _sortableColumns.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: config.gridBorderColor.withOpacity(0.35),
              ),
              itemBuilder: (context, index) {
                final col = _sortableColumns[index];
                final selected = _selectedKey == col.key;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 2,
                  ),
                  onTap: () => setState(() => _selectedKey = col.key),
                  title: Text(
                    col.column.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? primary : textColor,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded,
                          color: primary, size: 22)
                      : Icon(Icons.radio_button_unchecked_rounded,
                          color: secondaryText.withOpacity(0.5), size: 22),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomBar(context, primary, bg, config, textColor),
    );
  }

  Widget _buildBottomBar(BuildContext context, Color primary, Color bg,
      OmDataGridConfiguration config, Color textColor) {
    final canApply = _selectedKey != null && _selectedKey!.isNotEmpty;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: config.gridBorderColor.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: config.gridBorderColor),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                config.labels.cancel,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canApply
                  ? () => Navigator.of(context).pop(
                        OmMobileSortResult(
                          columnKey: _selectedKey!,
                          ascending: _ascending,
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: config.primaryForegroundColor,
                disabledBackgroundColor: primary.withOpacity(0.3),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sort_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    config.labels.apply,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Direction toggle button
// ---------------------------------------------------------------------------

class _DirectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color primary;
  final Color bg;
  final Color secondaryText;
  final VoidCallback onTap;

  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.primary,
    required this.bg,
    required this.secondaryText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? bg : secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? bg : secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
